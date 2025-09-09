//+------------------------------------------------------------------+
//|                                                 TradeManager.mqh |
//|                        Copyright 2023, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"

#include <Trade/Trade.mqh>
#include "SignalEngine.mqh"

//--- Forward declaration
class CGraphicManager;

//--- Active Stop Loss Tracking Structure
struct ActiveStopLoss
  {
   ulong             ticket;             // Trade ticket number
   double            original_distance;  // Initial stop distance in pips
   double            current_level;      // Current stop loss level
   datetime          last_trail_time;    // Last trailing adjustment time
   bool              is_trailing;        // Trailing status
   double            entry_price;        // Original entry price
   ENUM_ORDER_TYPE   order_type;         // Buy or sell order type
  };

//+------------------------------------------------------------------+
//| Class for managing trades.                                       |
//+------------------------------------------------------------------+
class CTradeManager
  {
protected:
   CTrade            m_trade;            // Trade object
   long              m_magic_number;     // Magic number for trades
   CGraphicManager   *m_graphic_mgr;     // Reference to graphic manager
   ActiveStopLoss    m_active_stops[];   // Array of active stop losses

public:
                     CTradeManager();
                    ~CTradeManager();
   void              SetMagicNumber(long magic);
   void              SetGraphicManager(CGraphicManager *graphic_mgr);
   void              CheckForEntry(CDmi &dmi,CDidiIndex &didi,CBollingerBands &bb);
   void              CheckForExit(CDmi &dmi,CStochastic &stoch,CTrix &trix,CBollingerBands &bb);
   void              ReadChartObjects();
   
   // Active Stop Loss Management Methods
   bool              AddActiveStopLoss(ulong ticket, double original_distance, double current_level, 
                                      double entry_price, ENUM_ORDER_TYPE order_type);
   bool              RemoveActiveStopLoss(ulong ticket);
   bool              UpdateActiveStopLoss(ulong ticket, double new_level, datetime trail_time);
   ActiveStopLoss*   GetActiveStopLoss(ulong ticket);
   int               GetActiveStopLossCount();
   void              CleanupClosedTrades();
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CTradeManager::CTradeManager():m_magic_number(12345), m_graphic_mgr(NULL)
  {
   m_trade.SetExpertMagicNumber(m_magic_number);
   m_trade.SetTypeFilling(ORDER_FILLING_FOK);
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CTradeManager::~CTradeManager()
  {
  }
//+------------------------------------------------------------------+
//| Sets the magic number for trades.                                |
//+------------------------------------------------------------------+
void CTradeManager::SetMagicNumber(long magic)
  {
   m_magic_number=magic;
   m_trade.SetExpertMagicNumber(m_magic_number);
  }
//+------------------------------------------------------------------+
//| Sets the graphic manager reference.                              |
//+------------------------------------------------------------------+
void CTradeManager::SetGraphicManager(CGraphicManager *graphic_mgr)
  {
   m_graphic_mgr = graphic_mgr;
  }
//+------------------------------------------------------------------+
//| Checks for trade entry signals.                                  |
//+------------------------------------------------------------------+
void CTradeManager::CheckForEntry(CDmi &dmi,CDidiIndex &didi,CBollingerBands &bb)
  {
//--- Entry signals
   bool buy_signal=dmi.PlusDi(1)>dmi.MinusDi(1) && didi.IsAgulhada(1) && bb.UpperBand(1)>bb.MiddleBand(1);
   bool sell_signal=dmi.MinusDi(1)>dmi.PlusDi(1) && didi.IsAgulhada(1) && bb.LowerBand(1)<bb.MiddleBand(1);

   PrintFormat("CheckForEntry: Evaluating signals. Buy: %s, Sell: %s", (string)buy_signal, (string)sell_signal);
   PrintFormat("  DMI: +DI=%.5f, -DI=%.5f", dmi.PlusDi(1), dmi.MinusDi(1));
   PrintFormat("  Didi Agulhada: %s", (string)didi.IsAgulhada(1));
   PrintFormat("  Bollinger Bands: Upper=%.5f, Middle=%.5f, Lower=%.5f", bb.UpperBand(1), bb.MiddleBand(1), bb.LowerBand(1));

   if(PositionsTotal()==0)
     {
      if(buy_signal)
        {
         Print("CheckForEntry: Buy signal confirmed. Attempting to open BUY position.");
         double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
         
         // Draw entry signal on chart
         if(m_graphic_mgr != NULL)
         {
            string reason = "DMI: +DI>-DI, Didi: Agulhada, BB: Upper>Middle";
            m_graphic_mgr.DrawEntrySignal(TimeCurrent(), ask, true, reason);
         }
         
         if(m_trade.Buy(0.1, _Symbol, ask, 0, 0, "Buy Signal"))
           {
            PrintFormat("CheckForEntry: BUY order sent successfully. Order: %I64u", m_trade.ResultOrder());
           }
         else
           {
            PrintFormat("CheckForEntry: Failed to send BUY order. Error: %d, RetCode: %d", 
                       GetLastError(), m_trade.ResultRetcode());
           }
        }
      else if(sell_signal)
        {
         Print("CheckForEntry: Sell signal confirmed. Attempting to open SELL position.");
         double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
         
         // Draw entry signal on chart
         if(m_graphic_mgr != NULL)
         {
            string reason = "DMI: -DI>+DI, Didi: Agulhada, BB: Lower<Middle";
            m_graphic_mgr.DrawEntrySignal(TimeCurrent(), bid, false, reason);
         }
         
         if(m_trade.Sell(0.1, _Symbol, bid, 0, 0, "Sell Signal"))
           {
            PrintFormat("CheckForEntry: SELL order sent successfully. Order: %I64u", m_trade.ResultOrder());
           }
         else
           {
            PrintFormat("CheckForEntry: Failed to send SELL order. Error: %d, RetCode: %d", 
                       GetLastError(), m_trade.ResultRetcode());
           }
        }
      else
        {
         Print("CheckForEntry: No valid entry signal.");
        }
     }
   else
     {
      Print("CheckForEntry: Position already open. Skipping entry check.");
     }
  }
//+------------------------------------------------------------------+
//| Checks for trade exit signals.                                   |
//+------------------------------------------------------------------+
void CTradeManager::CheckForExit(CDmi &dmi,CStochastic &stoch,CTrix &trix,CBollingerBands &bb)
  {
//--- Exit signals
   bool close_buy_signal=dmi.Adx(1)<32 && stoch.Main(1)<stoch.Signal(1) && trix.Main(1)<0 && bb.UpperBand(1)<bb.MiddleBand(1);
   bool close_sell_signal=dmi.Adx(1)<32 && stoch.Main(1)>stoch.Signal(1) && trix.Main(1)>0 && bb.LowerBand(1)>bb.MiddleBand(1);

   PrintFormat("CheckForExit: Evaluating signals. Close Buy: %s, Close Sell: %s", (string)close_buy_signal, (string)close_sell_signal);
   PrintFormat("  DMI ADX: %.5f", dmi.Adx(1));
   PrintFormat("  Stochastic: Main=%.5f, Signal=%.5f", stoch.Main(1), stoch.Signal(1));
   PrintFormat("  Trix: Main=%.5f", trix.Main(1));
   PrintFormat("  Bollinger Bands: Upper=%.5f, Middle=%.5f, Lower=%.5f", bb.UpperBand(1), bb.MiddleBand(1), bb.LowerBand(1));

   for(int i=PositionsTotal()-1; i>=0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket))
        {
         if(PositionGetInteger(POSITION_MAGIC)==m_magic_number)
           {
            if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY && close_buy_signal)
              {
               PrintFormat("CheckForExit: Buy exit signal confirmed for position #%I64u. Attempting to close.", ticket);
               
               // Draw exit signal on chart
               if(m_graphic_mgr != NULL)
               {
                  double exit_price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
                  string reason = "ADX<32, Stoch Cross Down, TRIX<0, BB Squeeze";
                  m_graphic_mgr.DrawExitSignal(TimeCurrent(), exit_price, true, reason);
               }
               
               if(m_trade.PositionClose(ticket))
                 {
                  PrintFormat("CheckForExit: Position #%I64u closed successfully.", ticket);
                 }
               else
                 {
                  PrintFormat("CheckForExit: Failed to close position #%I64u. Error: %d", ticket, GetLastError());
                 }
              }
            else if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL && close_sell_signal)
              {
               PrintFormat("CheckForExit: Sell exit signal confirmed for position #%I64u. Attempting to close.", ticket);
               
               // Draw exit signal on chart
               if(m_graphic_mgr != NULL)
               {
                  double exit_price = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
                  string reason = "ADX<32, Stoch Cross Up, TRIX>0, BB Squeeze";
                  m_graphic_mgr.DrawExitSignal(TimeCurrent(), exit_price, false, reason);
               }
               
               if(m_trade.PositionClose(ticket))
                 {
                  PrintFormat("CheckForExit: Position #%I64u closed successfully.", ticket);
                 }
               else
                 {
                  PrintFormat("CheckForExit: Failed to close position #%I64u. Error: %d", ticket, GetLastError());
                 }
              }
            else
              {
               PrintFormat("CheckForExit: No exit signal for position #%I64u.", ticket);
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
//| Reads chart objects.                                             |
//+------------------------------------------------------------------+
void CTradeManager::ReadChartObjects()
  {
   Print("ReadChartObjects: Reading chart objects...");
   for(int i=0; i<ObjectsTotal(0); i++)
     {
      string name=ObjectName(0,i);
      ENUM_OBJECT type=(ENUM_OBJECT)ObjectGetInteger(0,name,OBJPROP_TYPE);

      if(type==OBJ_TREND || type==OBJ_HLINE)
        {
         string type_str = (type==OBJ_TREND) ? "OBJ_TREND" : "OBJ_HLINE";
         PrintFormat("ReadChartObjects: Found line: %s, Type: %s, Price: %.5f", name, type_str, ObjectGetDouble(0,name,OBJPROP_PRICE,0));
        }
     }
   Print("ReadChartObjects: Finished reading chart objects.");
  }
//+------------------------------------------------------------------+
//| Adds a new active stop loss to tracking.                         |
//+------------------------------------------------------------------+
bool CTradeManager::AddActiveStopLoss(ulong ticket, double original_distance, double current_level, 
                                     double entry_price, ENUM_ORDER_TYPE order_type)
  {
   // Check if already exists
   for(int i = 0; i < ArraySize(m_active_stops); i++)
     {
      if(m_active_stops[i].ticket == ticket)
        {
         PrintFormat("AddActiveStopLoss: Stop loss for ticket %I64u already exists", ticket);
         return false;
        }
     }
   
   // Resize array and add new stop loss
   int new_size = ArraySize(m_active_stops) + 1;
   ArrayResize(m_active_stops, new_size);
   
   int index = new_size - 1;
   m_active_stops[index].ticket = ticket;
   m_active_stops[index].original_distance = original_distance;
   m_active_stops[index].current_level = current_level;
   m_active_stops[index].last_trail_time = TimeCurrent();
   m_active_stops[index].is_trailing = false;
   m_active_stops[index].entry_price = entry_price;
   m_active_stops[index].order_type = order_type;
   
   PrintFormat("AddActiveStopLoss: Added stop loss tracking for ticket %I64u at level %.5f", 
               ticket, current_level);
   return true;
  }
//+------------------------------------------------------------------+
//| Removes active stop loss from tracking.                          |
//+------------------------------------------------------------------+
bool CTradeManager::RemoveActiveStopLoss(ulong ticket)
  {
   for(int i = 0; i < ArraySize(m_active_stops); i++)
     {
      if(m_active_stops[i].ticket == ticket)
        {
         // Shift remaining elements
         for(int j = i; j < ArraySize(m_active_stops) - 1; j++)
           {
            m_active_stops[j] = m_active_stops[j + 1];
           }
         
         // Resize array
         ArrayResize(m_active_stops, ArraySize(m_active_stops) - 1);
         
         PrintFormat("RemoveActiveStopLoss: Removed stop loss tracking for ticket %I64u", ticket);
         return true;
        }
     }
   
   PrintFormat("RemoveActiveStopLoss: Stop loss for ticket %I64u not found", ticket);
   return false;
  }
//+------------------------------------------------------------------+
//| Updates active stop loss information.                            |
//+------------------------------------------------------------------+
bool CTradeManager::UpdateActiveStopLoss(ulong ticket, double new_level, datetime trail_time)
  {
   for(int i = 0; i < ArraySize(m_active_stops); i++)
     {
      if(m_active_stops[i].ticket == ticket)
        {
         m_active_stops[i].current_level = new_level;
         m_active_stops[i].last_trail_time = trail_time;
         m_active_stops[i].is_trailing = true;
         
         PrintFormat("UpdateActiveStopLoss: Updated stop loss for ticket %I64u to level %.5f", 
                     ticket, new_level);
         return true;
        }
     }
   
   PrintFormat("UpdateActiveStopLoss: Stop loss for ticket %I64u not found", ticket);
   return false;
  }
//+------------------------------------------------------------------+
//| Gets active stop loss by ticket number.                          |
//+------------------------------------------------------------------+
ActiveStopLoss* CTradeManager::GetActiveStopLoss(ulong ticket)
  {
   for(int i = 0; i < ArraySize(m_active_stops); i++)
     {
      if(m_active_stops[i].ticket == ticket)
        {
         return &m_active_stops[i];
        }
     }
   
   return NULL;
  }
//+------------------------------------------------------------------+
//| Gets count of active stop losses.                                |
//+------------------------------------------------------------------+
int CTradeManager::GetActiveStopLossCount()
  {
   return ArraySize(m_active_stops);
  }
//+------------------------------------------------------------------+
//| Cleans up stop losses for closed trades.                         |
//+------------------------------------------------------------------+
void CTradeManager::CleanupClosedTrades()
  {
   for(int i = ArraySize(m_active_stops) - 1; i >= 0; i--)
     {
      ulong ticket = m_active_stops[i].ticket;
      
      // Check if position still exists
      if(!PositionSelectByTicket(ticket))
        {
         PrintFormat("CleanupClosedTrades: Removing closed trade %I64u from stop loss tracking", ticket);
         RemoveActiveStopLoss(ticket);
        }
     }
  }