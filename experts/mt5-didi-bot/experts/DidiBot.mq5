//+------------------------------------------------------------------+
//|                                                    DidiBot.mq5 |
//|                        Copyright 2023, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include "../include/SignalEngine.mqh"
#include "../include/TradeManager.mqh"
#include "../include/RiskManager.mqh"

//--- Indicator instances
CDmi g_dmi;
CDidiIndex g_didi;
CBollingerBands g_bb;
CStochastic g_stoch;
CTrix g_trix;
CIfr g_ifr;
CTradeManager g_trade_manager;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator handles
   if(!g_dmi.Init(_Symbol,_Period,8))
      return(INIT_FAILED);
   if(!g_didi.Init(_Symbol,_Period,3,8,20))
      return(INIT_FAILED);
   if(!g_bb.Init(_Symbol,_Period,8,2.0))
      return(INIT_FAILED);
   if(!g_stoch.Init(_Symbol,_Period,8,3,3))
      return(INIT_FAILED);
   if(!g_trix.Init(_Symbol,_Period,9))
      return(INIT_FAILED);
   if(!g_ifr.Init(_Symbol,_Period,7))
      return(INIT_FAILED);

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//--- Check for connection
   if(!TerminalInfoInteger(TERMINAL_CONNECTED))
     {
      Print("No connection");
      return;
     }

//--- New bar logic
   static datetime prev_bar_time=0;
   datetime current_bar_time=(datetime)SeriesInfoInteger(_Symbol,_Period,SERIES_LASTBAR_DATE);

   if(current_bar_time>prev_bar_time)
     {
      prev_bar_time=current_bar_time;

//--- Read chart objects
      g_trade_manager.ReadChartObjects();

//--- Check for trading signals
      g_trade_manager.CheckForEntry(g_dmi,g_didi,g_bb);
      g_trade_manager.CheckForExit(g_dmi,g_stoch,g_trix,g_bb);
     }
  }
//+------------------------------------------------------------------+
