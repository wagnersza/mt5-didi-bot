//+------------------------------------------------------------------+
//|                                                 TradeManager.mqh |
//|                        Copyright 2023, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"

#include <Trade/Trade.mqh>
#include "SignalEngine.mqh"

//--- Forward declarations
class CGraphicManager;
class CRiskManager;

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
   void              CheckForEntryWithStops(CDmi &dmi,CDidiIndex &didi,CBollingerBands &bb,CAtr &atr,CRiskManager &risk_mgr);
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
   
   // Stop Loss Placement Methods (T010)
   bool              PlaceStopLoss(ulong ticket, double stop_loss_level);
   bool              ModifyStopLoss(ulong ticket, double new_stop_level);
   bool              PlaceStopLimitOrder(ulong original_ticket, ENUM_ORDER_TYPE order_type, double volume, 
                                        double stop_price, double limit_price);
   bool              ExecuteMarketStopOrder(ulong ticket, double volume);
   
   // Trailing Stop Methods (T011)
   void              CheckTrailingStops(double current_atr);
   void              CheckTrailingStops();  // Overload that gets ATR internally
   bool              AdjustTrailingStop(ulong ticket, double new_stop_level);
   bool              ShouldTrailStop(double entry_price, double current_price, double current_stop, 
                                    double atr_value, double atr_multiplier, ENUM_ORDER_TYPE order_type);
   double            CalculateTrailingStopLevel(double current_price, double atr_value, double atr_multiplier, 
                                               ENUM_ORDER_TYPE order_type);
   bool              ShouldAdjustTrailingStop(double current_stop, double potential_new_stop, ENUM_ORDER_TYPE order_type);
   
   // Error Recovery Methods (T020)
   bool              PlaceStopLossWithRetry(ulong ticket, double stop_loss_level, int max_retries = 3);
   bool              ModifyStopLossWithRetry(ulong ticket, double new_stop_level, int max_retries = 3);
   bool              RecoverFromNetworkError(ulong ticket, double stop_level);
   bool              HandleBrokerRejection(ulong ticket, double stop_level, int error_code);
   bool              IsRetryableError(int error_code);
   void              WaitForConnection(int timeout_seconds = 30);
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
                  
                  // Remove stop loss visualization
                  if(m_graphic_mgr != NULL)
                    {
                     m_graphic_mgr.RemoveStopLoss(IntegerToString(ticket));
                    }
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
                  
                  // Remove stop loss visualization
                  if(m_graphic_mgr != NULL)
                    {
                     m_graphic_mgr.RemoveStopLoss(IntegerToString(ticket));
                    }
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

//+------------------------------------------------------------------+
//| T010: Place stop loss for new trade                             |
//+------------------------------------------------------------------+
bool CTradeManager::PlaceStopLoss(ulong ticket, double stop_loss_level)
  {
   if(!PositionSelectByTicket(ticket))
     {
      PrintFormat("PlaceStopLoss: Position %I64u not found", ticket);
      return false;
     }
   
   if(stop_loss_level <= 0)
     {
      PrintFormat("PlaceStopLoss: Invalid stop loss level %.5f for ticket %I64u", stop_loss_level, ticket);
      return false;
     }
   
   double current_tp = PositionGetDouble(POSITION_TP);
   
   // Attempt to modify the position with stop loss
   bool result = m_trade.PositionModify(ticket, stop_loss_level, current_tp);
   
   if(result)
     {
      PrintFormat("PlaceStopLoss: Stop loss %.5f successfully placed for ticket %I64u", stop_loss_level, ticket);
     }
   else
     {
      PrintFormat("PlaceStopLoss: Failed to place stop loss %.5f for ticket %I64u. Error: %d", 
                  stop_loss_level, ticket, GetLastError());
     }
   
   return result;
  }

//+------------------------------------------------------------------+
//| T010: Modify existing stop loss                                 |
//+------------------------------------------------------------------+
bool CTradeManager::ModifyStopLoss(ulong ticket, double new_stop_level)
  {
   if(!PositionSelectByTicket(ticket))
     {
      PrintFormat("ModifyStopLoss: Position %I64u not found", ticket);
      return false;
     }
   
   if(new_stop_level <= 0)
     {
      PrintFormat("ModifyStopLoss: Invalid stop loss level %.5f for ticket %I64u", new_stop_level, ticket);
      return false;
     }
   
   double current_sl = PositionGetDouble(POSITION_SL);
   double current_tp = PositionGetDouble(POSITION_TP);
   
   // Check if modification is actually needed
   if(MathAbs(current_sl - new_stop_level) < _Point)
     {
      PrintFormat("ModifyStopLoss: Stop loss %.5f already set for ticket %I64u", new_stop_level, ticket);
      return true;
     }
   
   // Attempt to modify the position
   bool result = m_trade.PositionModify(ticket, new_stop_level, current_tp);
   
   if(result)
     {
      PrintFormat("ModifyStopLoss: Stop loss modified from %.5f to %.5f for ticket %I64u", 
                  current_sl, new_stop_level, ticket);
      
      // Update active stop loss tracking
      UpdateActiveStopLoss(ticket, new_stop_level, TimeCurrent());
     }
   else
     {
      PrintFormat("ModifyStopLoss: Failed to modify stop loss to %.5f for ticket %I64u. Error: %d", 
                  new_stop_level, ticket, GetLastError());
     }
   
   return result;
  }

//+------------------------------------------------------------------+
//| T010: Place stop limit order when stop is triggered            |
//+------------------------------------------------------------------+
bool CTradeManager::PlaceStopLimitOrder(ulong original_ticket, ENUM_ORDER_TYPE order_type, double volume, 
                                        double stop_price, double limit_price)
  {
   if(volume <= 0 || stop_price <= 0 || limit_price <= 0)
     {
      PrintFormat("PlaceStopLimitOrder: Invalid parameters. Volume: %.2f, Stop: %.5f, Limit: %.5f", 
                  volume, stop_price, limit_price);
      return false;
     }
   
   // Validate order type for stop limit
   if(order_type != ORDER_TYPE_BUY_STOP_LIMIT && order_type != ORDER_TYPE_SELL_STOP_LIMIT)
     {
      PrintFormat("PlaceStopLimitOrder: Invalid order type %d for stop limit order", order_type);
      return false;
     }
   
   // Set trade request
   m_trade.SetTypeFilling(ORDER_FILLING_RETURN);
   
   bool result = false;
   if(order_type == ORDER_TYPE_BUY_STOP_LIMIT)
     {
      result = m_trade.BuyStopLimit(volume, limit_price, stop_price, 0, 0, ORDER_TIME_GTC, 0, 
                                   StringFormat("StopLimit for %I64u", original_ticket));
     }
   else
     {
      result = m_trade.SellStopLimit(volume, limit_price, stop_price, 0, 0, ORDER_TIME_GTC, 0, 
                                    StringFormat("StopLimit for %I64u", original_ticket));
     }
   
   // Reset to default filling
   m_trade.SetTypeFilling(ORDER_FILLING_FOK);
   
   if(result)
     {
      PrintFormat("PlaceStopLimitOrder: Stop limit order placed successfully. Type: %d, Volume: %.2f, Stop: %.5f, Limit: %.5f", 
                  order_type, volume, stop_price, limit_price);
     }
   else
     {
      PrintFormat("PlaceStopLimitOrder: Failed to place stop limit order. Error: %d", GetLastError());
     }
   
   return result;
  }

//+------------------------------------------------------------------+
//| T010: Execute market order as fallback for failed stop limit   |
//+------------------------------------------------------------------+
bool CTradeManager::ExecuteMarketStopOrder(ulong ticket, double volume)
  {
   if(!PositionSelectByTicket(ticket))
     {
      PrintFormat("ExecuteMarketStopOrder: Position %I64u not found", ticket);
      return false;
     }
   
   if(volume <= 0)
     {
      PrintFormat("ExecuteMarketStopOrder: Invalid volume %.2f for ticket %I64u", volume, ticket);
      return false;
     }
   
   ENUM_POSITION_TYPE pos_type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
   
   bool result = false;
   if(pos_type == POSITION_TYPE_BUY)
     {
      result = m_trade.Sell(volume, _Symbol, 0, 0, 0, StringFormat("Market Stop for %I64u", ticket));
     }
   else if(pos_type == POSITION_TYPE_SELL)
     {
      result = m_trade.Buy(volume, _Symbol, 0, 0, 0, StringFormat("Market Stop for %I64u", ticket));
     }
   else
     {
      PrintFormat("ExecuteMarketStopOrder: Invalid position type %d for ticket %I64u", pos_type, ticket);
      return false;
     }
   
   if(result)
     {
      PrintFormat("ExecuteMarketStopOrder: Market stop order executed successfully for ticket %I64u, Volume: %.2f", 
                  ticket, volume);
      
      // Remove from active stops tracking
      RemoveActiveStopLoss(ticket);
     }
   else
     {
      PrintFormat("ExecuteMarketStopOrder: Failed to execute market stop for ticket %I64u. Error: %d", 
                  ticket, GetLastError());
     }
   
   return result;
  }

//+------------------------------------------------------------------+
//| T011: Check and adjust trailing stops for all active trades    |
//+------------------------------------------------------------------+
void CTradeManager::CheckTrailingStops(double current_atr)
  {
   datetime start_time = GetTickCount();
   int active_positions = ArraySize(m_active_stops);
   int trailing_positions = 0;
   int adjustments_made = 0;
   
   if(current_atr <= 0)
     {
      PrintFormat("TradeManager: [ERROR] Invalid ATR value %.5f, skipping trailing stop checks", current_atr);
      return;
     }
   
   PrintFormat("TradeManager: [INFO] Starting trailing stop check - ATR: %.5f, Active stops: %d", 
               current_atr, active_positions);
   
   for(int i = 0; i < ArraySize(m_active_stops); i++)
     {
      if(!m_active_stops[i].is_trailing)
         continue; // Skip non-trailing stops
      
      trailing_positions++;
      ulong ticket = m_active_stops[i].ticket;
      
      if(!PositionSelectByTicket(ticket))
        {
         PrintFormat("TradeManager: [WARN] Position %I64u not found, removing from tracking", ticket);
         RemoveActiveStopLoss(ticket);
         i--; // Adjust index after removal
         continue;
        }
      
      double current_price = 0;
      double entry_price = m_active_stops[i].entry_price;
      ENUM_ORDER_TYPE order_type = m_active_stops[i].order_type;
      string direction = (order_type == ORDER_TYPE_BUY) ? "BUY" : "SELL";
      
      // Get current market price
      if(order_type == ORDER_TYPE_BUY)
         current_price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      else if(order_type == ORDER_TYPE_SELL)
         current_price = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      else
         continue;
      
      double current_stop = PositionGetDouble(POSITION_SL);
      double atr_multiplier = 1.5; // TODO: Get from configuration
      
      // Check if we should trail the stop
      if(ShouldTrailStop(entry_price, current_price, current_stop, current_atr, atr_multiplier, order_type))
        {
         double new_stop = CalculateTrailingStopLevel(current_price, current_atr, atr_multiplier, order_type);
         
         PrintFormat("TradeManager: [DEBUG] Trailing candidate %I64u (%s) - Entry: %.5f, Current: %.5f, OldStop: %.5f, NewStop: %.5f",
                     ticket, direction, entry_price, current_price, current_stop, new_stop);
         
         if(ShouldAdjustTrailingStop(current_stop, new_stop, order_type))
           {
            if(AdjustTrailingStop(ticket, new_stop))
              {
               adjustments_made++;
               PrintFormat("TradeManager: [SUCCESS] Trailing stop adjusted for %I64u (%s) from %.5f to %.5f",
                          ticket, direction, current_stop, new_stop);
              }
           }
        }
     }
   
   datetime processing_time = GetTickCount() - start_time;
   PrintFormat("TradeManager: [INFO] Trailing stop check completed - Positions: %d, Trailing: %d, Adjusted: %d, ProcessTime: %dms",
               active_positions, trailing_positions, adjustments_made, processing_time);
  }

//+------------------------------------------------------------------+
//| T015: Check trailing stops (overload that gets ATR internally) |
//+------------------------------------------------------------------+
void CTradeManager::CheckTrailingStops()
  {
   // Get ATR value from global ATR indicator (this needs to be set externally)
   // For now, we'll skip if no ATR reference is available
   Print("CheckTrailingStops: Overload method called - requires ATR value from external source");
   
   // This is a placeholder - in real implementation, we would need access to the ATR indicator
   // The DidiBot should call CheckTrailingStops(g_atr.GetCurrentATR()) instead
   double current_atr = 0.0; // Placeholder
   
   if(current_atr > 0)
     {
      CheckTrailingStops(current_atr);
     }
   else
     {
      Print("CheckTrailingStops: Cannot get ATR value, skipping trailing stop checks");
     }
  }

//+------------------------------------------------------------------+
//| T011: Adjust trailing stop for specific trade                   |
//+------------------------------------------------------------------+
bool CTradeManager::AdjustTrailingStop(ulong ticket, double new_stop_level)
  {
   if(!PositionSelectByTicket(ticket))
     {
      PrintFormat("AdjustTrailingStop: Position %I64u not found", ticket);
      return false;
     }
   
   double current_tp = PositionGetDouble(POSITION_TP);
   bool result = m_trade.PositionModify(ticket, new_stop_level, current_tp);
   
   if(result)
     {
      PrintFormat("AdjustTrailingStop: Trailing stop adjusted to %.5f for ticket %I64u", new_stop_level, ticket);
      
      // Update stop loss visualization
      if(m_graphic_mgr != NULL)
        {
         m_graphic_mgr.UpdateStopLoss(IntegerToString(ticket), new_stop_level);
        }
      
      // Update tracking
      UpdateActiveStopLoss(ticket, new_stop_level, TimeCurrent());
     }
   else
     {
      PrintFormat("AdjustTrailingStop: Failed to adjust trailing stop to %.5f for ticket %I64u. Error: %d", 
                  new_stop_level, ticket, GetLastError());
     }
   
   return result;
  }

//+------------------------------------------------------------------+
//| T011: Determine if stop should be trailed                       |
//+------------------------------------------------------------------+
bool CTradeManager::ShouldTrailStop(double entry_price, double current_price, double current_stop, 
                                    double atr_value, double atr_multiplier, ENUM_ORDER_TYPE order_type)
  {
   if(entry_price <= 0 || current_price <= 0 || atr_value <= 0 || atr_multiplier <= 0)
     {
      return false;
     }
   
   double min_movement = atr_value * 0.5; // Minimum movement to trigger trailing
   
   if(order_type == ORDER_TYPE_BUY)
     {
      // For buy trades, price must move up favorably
      double favorable_movement = current_price - entry_price;
      return (favorable_movement > min_movement);
     }
   else if(order_type == ORDER_TYPE_SELL)
     {
      // For sell trades, price must move down favorably
      double favorable_movement = entry_price - current_price;
      return (favorable_movement > min_movement);
     }
   
   return false;
  }

//+------------------------------------------------------------------+
//| T011: Calculate new trailing stop level                         |
//+------------------------------------------------------------------+
double CTradeManager::CalculateTrailingStopLevel(double current_price, double atr_value, double atr_multiplier, 
                                                 ENUM_ORDER_TYPE order_type)
  {
   if(current_price <= 0 || atr_value <= 0 || atr_multiplier <= 0)
     {
      return 0.0;
     }
   
   double stop_distance = atr_value * atr_multiplier;
   
   if(order_type == ORDER_TYPE_BUY)
     {
      return current_price - stop_distance;
     }
   else if(order_type == ORDER_TYPE_SELL)
     {
      return current_price + stop_distance;
     }
   
   return 0.0;
  }

//+------------------------------------------------------------------+
//| T011: Check if trailing stop should be adjusted                 |
//+------------------------------------------------------------------+
bool CTradeManager::ShouldAdjustTrailingStop(double current_stop, double potential_new_stop, ENUM_ORDER_TYPE order_type)
  {
   if(current_stop <= 0 || potential_new_stop <= 0)
     {
      return false;
     }
   
   // Ensure stop only moves in favorable direction
   if(order_type == ORDER_TYPE_BUY)
     {
      // For buy trades, stop should only move up (higher)
      return (potential_new_stop > current_stop);
     }
   else if(order_type == ORDER_TYPE_SELL)
     {
      // For sell trades, stop should only move down (lower)
      return (potential_new_stop < current_stop);
     }
   
   return false;
  }

//+------------------------------------------------------------------+
//| T013: Enhanced entry check with stop loss integration          |
//+------------------------------------------------------------------+
void CTradeManager::CheckForEntryWithStops(CDmi &dmi,CDidiIndex &didi,CBollingerBands &bb,CAtr &atr,CRiskManager &risk_mgr)
  {
//--- Entry signals
   bool buy_signal=dmi.PlusDi(1)>dmi.MinusDi(1) && didi.IsAgulhada(1) && bb.UpperBand(1)>bb.MiddleBand(1);
   bool sell_signal=dmi.MinusDi(1)>dmi.PlusDi(1) && didi.IsAgulhada(1) && bb.LowerBand(1)<bb.MiddleBand(1);

   PrintFormat("CheckForEntryWithStops: Evaluating signals. Buy: %s, Sell: %s", (string)buy_signal, (string)sell_signal);
   PrintFormat("  DMI: +DI=%.5f, -DI=%.5f", dmi.PlusDi(1), dmi.MinusDi(1));
   PrintFormat("  Didi Agulhada: %s", (string)didi.IsAgulhada(1));
   PrintFormat("  Bollinger Bands: Upper=%.5f, Middle=%.5f, Lower=%.5f", bb.UpperBand(1), bb.MiddleBand(1), bb.LowerBand(1));

   if(PositionsTotal()==0)
     {
      if(buy_signal)
        {
         Print("CheckForEntryWithStops: Buy signal confirmed. Calculating stop loss and position size.");
         double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
         double current_atr = atr.GetCurrentATR();
         
         if(current_atr <= 0)
           {
            Print("CheckForEntryWithStops: Invalid ATR value, skipping trade");
            return;
           }
         
         // Get stop loss configuration
         StopLossConfig config = risk_mgr.GetStopLossConfig();
         
         // Calculate stop loss level
         double stop_loss = 0.0;
         if(config.type == ATR_BASED)
           {
            stop_loss = risk_mgr.CalculateATRStopLoss(ask, current_atr, config.atr_multiplier, ORDER_TYPE_BUY);
           }
         else
           {
            stop_loss = risk_mgr.CalculateFixedPipStopLoss(ask, config.fixed_pips, ORDER_TYPE_BUY);
           }
         
         // Apply maximum stop cap
         stop_loss = risk_mgr.ApplyMaxStopCap(stop_loss, ask, ORDER_TYPE_BUY);
         
         // Validate stop distance
         if(!risk_mgr.ValidateStopDistance(ask, stop_loss, ORDER_TYPE_BUY))
           {
            Print("CheckForEntryWithStops: Stop loss validation failed, skipping trade");
            return;
           }
         
         // Calculate position size based on stop distance
         double stop_distance_pips = MathAbs(ask - stop_loss) / (_Point * 10);
         double lot_size = risk_mgr.CalculateLotSize(stop_distance_pips);
         
         PrintFormat("CheckForEntryWithStops: Entry: %.5f, Stop: %.5f, Distance: %.1f pips, Lot Size: %.2f", 
                     ask, stop_loss, stop_distance_pips, lot_size);
         
         // Draw entry signal on chart
         if(m_graphic_mgr != NULL)
         {
            string reason = StringFormat("DMI: +DI>-DI, Didi: Agulhada, BB: Upper>Middle, SL: %.5f", stop_loss);
            m_graphic_mgr.DrawEntrySignal(TimeCurrent(), ask, true, reason);
         }
         
         // Execute trade with stop loss
         if(m_trade.Buy(lot_size, _Symbol, ask, stop_loss, 0, "Buy Signal with SL"))
           {
            ulong ticket = m_trade.ResultOrder();
            PrintFormat("CheckForEntryWithStops: BUY order sent successfully. Order: %I64u", ticket);
            
            // Draw stop loss visualization
            if(m_graphic_mgr != NULL)
              {
               m_graphic_mgr.DrawStopLoss(IntegerToString(ticket), stop_loss, true);
              }
            
            // Add to stop loss tracking
            if(config.trailing_enabled)
              {
               AddActiveStopLoss(ticket, stop_distance_pips, stop_loss, ask, ORDER_TYPE_BUY);
               PrintFormat("CheckForEntryWithStops: Added ticket %I64u to trailing stop tracking", ticket);
              }
           }
         else
           {
            PrintFormat("CheckForEntryWithStops: Failed to send BUY order. Error: %d, RetCode: %d", 
                       GetLastError(), m_trade.ResultRetcode());
           }
        }
      else if(sell_signal)
        {
         Print("CheckForEntryWithStops: Sell signal confirmed. Calculating stop loss and position size.");
         double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
         double current_atr = atr.GetCurrentATR();
         
         if(current_atr <= 0)
           {
            Print("CheckForEntryWithStops: Invalid ATR value, skipping trade");
            return;
           }
         
         // Get stop loss configuration
         StopLossConfig config = risk_mgr.GetStopLossConfig();
         
         // Calculate stop loss level
         double stop_loss = 0.0;
         if(config.type == ATR_BASED)
           {
            stop_loss = risk_mgr.CalculateATRStopLoss(bid, current_atr, config.atr_multiplier, ORDER_TYPE_SELL);
           }
         else
           {
            stop_loss = risk_mgr.CalculateFixedPipStopLoss(bid, config.fixed_pips, ORDER_TYPE_SELL);
           }
         
         // Apply maximum stop cap
         stop_loss = risk_mgr.ApplyMaxStopCap(stop_loss, bid, ORDER_TYPE_SELL);
         
         // Validate stop distance
         if(!risk_mgr.ValidateStopDistance(bid, stop_loss, ORDER_TYPE_SELL))
           {
            Print("CheckForEntryWithStops: Stop loss validation failed, skipping trade");
            return;
           }
         
         // Calculate position size based on stop distance
         double stop_distance_pips = MathAbs(bid - stop_loss) / (_Point * 10);
         double lot_size = risk_mgr.CalculateLotSize(stop_distance_pips);
         
         PrintFormat("CheckForEntryWithStops: Entry: %.5f, Stop: %.5f, Distance: %.1f pips, Lot Size: %.2f", 
                     bid, stop_loss, stop_distance_pips, lot_size);
         
         // Draw entry signal on chart
         if(m_graphic_mgr != NULL)
         {
            string reason = StringFormat("DMI: -DI>+DI, Didi: Agulhada, BB: Lower<Middle, SL: %.5f", stop_loss);
            m_graphic_mgr.DrawEntrySignal(TimeCurrent(), bid, false, reason);
         }
         
         // Execute trade with stop loss
         if(m_trade.Sell(lot_size, _Symbol, bid, stop_loss, 0, "Sell Signal with SL"))
           {
            ulong ticket = m_trade.ResultOrder();
            PrintFormat("CheckForEntryWithStops: SELL order sent successfully. Order: %I64u", ticket);
            
            // Draw stop loss visualization
            if(m_graphic_mgr != NULL)
              {
               m_graphic_mgr.DrawStopLoss(IntegerToString(ticket), stop_loss, false);
              }
            
            // Add to stop loss tracking
            if(config.trailing_enabled)
              {
               AddActiveStopLoss(ticket, stop_distance_pips, stop_loss, bid, ORDER_TYPE_SELL);
               PrintFormat("CheckForEntryWithStops: Added ticket %I64u to trailing stop tracking", ticket);
              }
           }
         else
           {
            PrintFormat("CheckForEntryWithStops: Failed to send SELL order. Error: %d, RetCode: %d", 
                       GetLastError(), m_trade.ResultRetcode());
           }
        }
      else
        {
         Print("CheckForEntryWithStops: No valid entry signal.");
        }
     }
   else
     {
      Print("CheckForEntryWithStops: Position already open. Skipping entry check.");
     }
  }

//+------------------------------------------------------------------+
//| T020: Place stop loss with retry logic and error recovery      |
//+------------------------------------------------------------------+
bool CTradeManager::PlaceStopLossWithRetry(ulong ticket, double stop_loss_level, int max_retries = 3)
  {
   for(int attempt = 1; attempt <= max_retries; attempt++)
     {
      PrintFormat("TradeManager: [INFO] Attempting stop loss placement (attempt %d/%d) for ticket %I64u", 
                  attempt, max_retries, ticket);
      
      if(PlaceStopLoss(ticket, stop_loss_level))
        {
         PrintFormat("TradeManager: [SUCCESS] Stop loss placed successfully on attempt %d", attempt);
         return true;
        }
      
      int error_code = GetLastError();
      
      if(!IsRetryableError(error_code))
        {
         PrintFormat("TradeManager: [ERROR] Non-retryable error %d on attempt %d, aborting", error_code, attempt);
         return HandleBrokerRejection(ticket, stop_loss_level, error_code);
        }
      
      if(attempt < max_retries)
        {
         int delay = attempt * 1000; // Progressive delay: 1s, 2s, 3s
         PrintFormat("TradeManager: [WARN] Retryable error %d, waiting %dms before retry", error_code, delay);
         Sleep(delay);
         
         // Check connection before retry
         if(!TerminalInfoInteger(TERMINAL_CONNECTED))
           {
            WaitForConnection(30);
           }
        }
     }
   
   PrintFormat("TradeManager: [ERROR] Failed to place stop loss after %d attempts", max_retries);
   return false;
  }

//+------------------------------------------------------------------+
//| T020: Modify stop loss with retry logic and error recovery     |
//+------------------------------------------------------------------+
bool CTradeManager::ModifyStopLossWithRetry(ulong ticket, double new_stop_level, int max_retries = 3)
  {
   for(int attempt = 1; attempt <= max_retries; attempt++)
     {
      PrintFormat("TradeManager: [INFO] Attempting stop loss modification (attempt %d/%d) for ticket %I64u", 
                  attempt, max_retries, ticket);
      
      if(ModifyStopLoss(ticket, new_stop_level))
        {
         PrintFormat("TradeManager: [SUCCESS] Stop loss modified successfully on attempt %d", attempt);
         return true;
        }
      
      int error_code = GetLastError();
      
      if(!IsRetryableError(error_code))
        {
         PrintFormat("TradeManager: [ERROR] Non-retryable error %d on attempt %d, aborting", error_code, attempt);
         return HandleBrokerRejection(ticket, new_stop_level, error_code);
        }
      
      if(attempt < max_retries)
        {
         int delay = attempt * 1000; // Progressive delay: 1s, 2s, 3s
         PrintFormat("TradeManager: [WARN] Retryable error %d, waiting %dms before retry", error_code, delay);
         Sleep(delay);
         
         // Check connection before retry
         if(!TerminalInfoInteger(TERMINAL_CONNECTED))
           {
            WaitForConnection(30);
           }
        }
     }
   
   PrintFormat("TradeManager: [ERROR] Failed to modify stop loss after %d attempts", max_retries);
   return false;
  }

//+------------------------------------------------------------------+
//| T020: Recover from network connection errors                    |
//+------------------------------------------------------------------+
bool CTradeManager::RecoverFromNetworkError(ulong ticket, double stop_level)
  {
   PrintFormat("TradeManager: [INFO] Attempting network error recovery for ticket %I64u", ticket);
   
   WaitForConnection(60); // Wait up to 60 seconds for reconnection
   
   if(TerminalInfoInteger(TERMINAL_CONNECTED))
     {
      PrintFormat("TradeManager: [SUCCESS] Connection recovered, retrying stop loss operation");
      return PlaceStopLossWithRetry(ticket, stop_level, 2); // Reduced retries after recovery
     }
   
   PrintFormat("TradeManager: [ERROR] Network recovery failed for ticket %I64u", ticket);
   return false;
  }

//+------------------------------------------------------------------+
//| T020: Handle broker rejection with fallback strategies         |
//+------------------------------------------------------------------+
bool CTradeManager::HandleBrokerRejection(ulong ticket, double stop_level, int error_code)
  {
   PrintFormat("TradeManager: [WARN] Handling broker rejection - Error: %d, Ticket: %I64u", error_code, ticket);
   
   switch(error_code)
     {
      case TRADE_RETCODE_INVALID_STOPS:
        {
         // Adjust stop level to broker requirements
         double min_distance = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL) * _Point;
         if(min_distance > 0)
           {
            if(!PositionSelectByTicket(ticket))
              return false;
            
            double entry_price = PositionGetDouble(POSITION_PRICE_OPEN);
            ENUM_ORDER_TYPE order_type = (ENUM_ORDER_TYPE)PositionGetInteger(POSITION_TYPE);
            
            double adjusted_stop = 0;
            if(order_type == ORDER_TYPE_BUY)
              adjusted_stop = entry_price - min_distance - (10 * _Point); // Extra buffer
            else
              adjusted_stop = entry_price + min_distance + (10 * _Point);
            
            PrintFormat("TradeManager: [INFO] Adjusting stop from %.5f to %.5f due to broker requirements", 
                       stop_level, adjusted_stop);
            return PlaceStopLoss(ticket, adjusted_stop);
           }
         break;
        }
      
      case TRADE_RETCODE_NO_MONEY:
        {
         PrintFormat("TradeManager: [ERROR] Insufficient funds - Cannot place stop loss for ticket %I64u", ticket);
         return false;
        }
      
      case TRADE_RETCODE_MARKET_CLOSED:
        {
         PrintFormat("TradeManager: [WARN] Market closed - Will retry when market opens");
         // Could implement a queue for pending operations
         return false;
        }
      
      default:
        {
         PrintFormat("TradeManager: [ERROR] Unhandled broker rejection: %d", error_code);
         return false;
        }
     }
   
   return false;
  }

//+------------------------------------------------------------------+
//| T020: Check if error code is retryable                         |
//+------------------------------------------------------------------+
bool CTradeManager::IsRetryableError(int error_code)
  {
   switch(error_code)
     {
      case TRADE_RETCODE_CONNECTION:
      case TRADE_RETCODE_TIMEOUT:
      case TRADE_RETCODE_REJECT:
      case TRADE_RETCODE_REQUOTE:
      case TRADE_RETCODE_SERVER_DISABLES_AT:
        return true;
      
      case TRADE_RETCODE_INVALID_STOPS:
      case TRADE_RETCODE_NO_MONEY:
      case TRADE_RETCODE_MARKET_CLOSED:
      case TRADE_RETCODE_INVALID_ORDER:
        return false;
      
      default:
        return true; // Default to retryable for unknown errors
     }
  }

//+------------------------------------------------------------------+
//| T020: Wait for broker connection with timeout                  |
//+------------------------------------------------------------------+
void CTradeManager::WaitForConnection(int timeout_seconds = 30)
  {
   PrintFormat("TradeManager: [INFO] Waiting for broker connection (timeout: %d seconds)", timeout_seconds);
   
   datetime start_time = TimeCurrent();
   
   while(!TerminalInfoInteger(TERMINAL_CONNECTED) && 
         (TimeCurrent() - start_time) < timeout_seconds)
     {
      Sleep(1000); // Check every second
      PrintFormat("TradeManager: [DEBUG] Still waiting for connection...");
     }
   
   if(TerminalInfoInteger(TERMINAL_CONNECTED))
     {
      PrintFormat("TradeManager: [SUCCESS] Broker connection restored");
     }
   else
     {
      PrintFormat("TradeManager: [ERROR] Connection timeout after %d seconds", timeout_seconds);
     }
  }