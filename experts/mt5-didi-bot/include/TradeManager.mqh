//+------------------------------------------------------------------+
//|                                                 TradeManager.mqh |
//|                        Copyright 2023, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"

#include <Trade/Trade.mqh>
#include "SignalEngine.mqh"

//+------------------------------------------------------------------+
//| Class for managing trades.                                       |
//+------------------------------------------------------------------+
class CTradeManager
  {
protected:
   CTrade            m_trade;          // Trade object
   long              m_magic_number;   // Magic number for trades

public:
                     CTradeManager();
                    ~CTradeManager();
   void              SetMagicNumber(long magic);
   void              CheckForEntry(CDmi &dmi,CDidiIndex &didi,CBollingerBands &bb);
   void              CheckForExit(CDmi &dmi,CStochastic &stoch,CTrix &trix,CBollingerBands &bb);
   void              ReadChartObjects();
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CTradeManager::CTradeManager():m_magic_number(12345)
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
         MqlTradeRequest request={0};
         MqlTradeResult result={0};
         request.action=TRADE_ACTION_DEAL;
         request.symbol=_Symbol;
         request.volume=0.1;
         request.type=ORDER_TYPE_BUY;
         request.price=SymbolInfoDouble(_Symbol,SYMBOL_ASK);
         request.sl=0;
         request.tp=0;
         request.magic=m_magic_number;
         request.comment="Buy Signal";
         if(OrderSend(request,result))
           {
            PrintFormat("CheckForEntry: BUY order sent. Retcode: %d, Deal: %I64u", result.retcode, result.deal);
            if(result.retcode==TRADE_RETCODE_PLACED_PARTIAL)
              {
               PrintFormat("CheckForEntry: Partial fill detected. Filled %.2f lots of %.2f requested.", result.volume, request.volume);
              }
           }
         else
           {
            PrintFormat("CheckForEntry: Failed to send BUY order. Error: %d", GetLastError());
           }
        }
      else if(sell_signal)
        {
         Print("CheckForEntry: Sell signal confirmed. Attempting to open SELL position.");
         MqlTradeRequest request={0};
         MqlTradeResult result={0};
         request.action=TRADE_ACTION_DEAL;
         request.symbol=_Symbol;
         request.volume=0.1;
         request.type=ORDER_TYPE_SELL;
         request.price=SymbolInfoDouble(_Symbol,SYMBOL_BID);
         request.sl=0;
         request.tp=0;
         request.magic=m_magic_number;
         request.comment="Sell Signal";
         if(OrderSend(request,result))
           {
            PrintFormat("CheckForEntry: SELL order sent. Retcode: %d, Deal: %I64u", result.retcode, result.deal);
            if(result.retcode==TRADE_RETCODE_PLACED_PARTIAL)
              {
               PrintFormat("CheckForEntry: Partial fill detected. Filled %.2f lots of %.2f requested.", result.volume, request.volume);
              }
           }
         else
           {
            PrintFormat("CheckForEntry: Failed to send SELL order. Error: %d", GetLastError());
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
      if(PositionSelect(i))
        {
         if(PositionGetInteger(POSITION_MAGIC)==m_magic_number)
           {
            if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY && close_buy_signal)
              {
               PrintFormat("CheckForExit: Buy exit signal confirmed for position #%I64u. Attempting to close.", PositionGetTicket(i));
               if(m_trade.PositionClose(PositionGetTicket(i)))
                 {
                  PrintFormat("CheckForExit: Position #%I64u closed successfully.", PositionGetTicket(i));
                 }
               else
                 {
                  PrintFormat("CheckForExit: Failed to close position #%I64u. Error: %d", PositionGetTicket(i), GetLastError());
                 }
              }
            else if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL && close_sell_signal)
              {
               PrintFormat("CheckForExit: Sell exit signal confirmed for position #%I64u. Attempting to close.", PositionGetTicket(i));
               if(m_trade.PositionClose(PositionGetTicket(i)))
                 {
                  PrintFormat("CheckForExit: Position #%I64u closed successfully.", PositionGetTicket(i));
                 }
               else
                 {
                  PrintFormat("CheckForExit: Failed to close position #%I64u. Error: %d", PositionGetTicket(i), GetLastError());
                 }
              }
            else
              {
               PrintFormat("CheckForExit: No exit signal for position #%I64u.", PositionGetTicket(i));
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
         PrintFormat("ReadChartObjects: Found line: %s, Type: %s, Price: %.5f", name, EnumToString(type), ObjectGetDouble(0,name,OBJPROP_PRICE,0));
        }
     }
   Print("ReadChartObjects: Finished reading chart objects.");
  }