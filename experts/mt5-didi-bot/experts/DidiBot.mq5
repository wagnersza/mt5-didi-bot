//+------------------------------------------------------------------+
//|                                                    DidiBot.mq5 |
//|                        Copyright 2023, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.01"

#include "../include/SignalEngine.mqh"
#include "../include/TradeManager.mqh"
#include "../include/RiskManager.mqh"
#include "../include/GraphicManager.mqh"

//--- Indicator instances
CDmi g_dmi;
CDidiIndex g_didi;
CBollingerBands g_bb;
CStochastic g_stoch;
CTrix g_trix;
CIfr g_ifr;
CTradeManager g_trade_manager;
CGraphicManager g_graphic_manager;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator handles
   Print("OnInit: Initializing DidiBot...");
   if(!g_dmi.Init(_Symbol,_Period,8))
     {
      Print("OnInit: DMI initialization failed!");
      return(INIT_FAILED);
     }
   if(!g_didi.Init(_Symbol,_Period,3,8,20))
     {
      Print("OnInit: Didi Index initialization failed!");
      return(INIT_FAILED);
     }
   if(!g_bb.Init(_Symbol,_Period,8,2.0))
     {
      Print("OnInit: Bollinger Bands initialization failed!");
      return(INIT_FAILED);
     }
   if(!g_stoch.Init(_Symbol,_Period,8,3,3))
     {
      Print("OnInit: Stochastic initialization failed!");
      return(INIT_FAILED);
     }
   if(!g_trix.Init(_Symbol,_Period,9))
     {
      Print("OnInit: Trix initialization failed!");
      return(INIT_FAILED);
     }
   if(!g_ifr.Init(_Symbol,_Period,7))
     {
      Print("OnInit: IFR initialization failed!");
      return(INIT_FAILED);
     }
     
//--- Initialize graphic manager
   g_graphic_manager.Init("DidiBot_");
   g_graphic_manager.UpdateTradingStatus("INITIALIZED");
   
//--- Connect trade manager with graphic manager
   g_trade_manager.SetGraphicManager(&g_graphic_manager);
   
   Print("OnInit: DidiBot initialized successfully.");
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   g_graphic_manager.ClearAll();
   Print("OnDeinit: DidiBot deinitialized. Reason: ", reason);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//--- Check for connection
   if(!TerminalInfoInteger(TERMINAL_CONNECTED))
     {
      Print("OnTick: No connection to broker. Waiting for reconnect...");
      return;
     }

//--- New bar logic
   static datetime prev_bar_time=0;
   datetime current_bar_time=(datetime)SeriesInfoInteger(_Symbol,_Period,SERIES_LASTBAR_DATE);

   if(current_bar_time>prev_bar_time)
     {
      prev_bar_time=current_bar_time;
      Print("OnTick: New bar detected. Time: ", TimeToString(current_bar_time));

//--- Update graphic indicators with current values
      g_graphic_manager.UpdateSignalPanel(g_dmi, g_didi, g_bb, g_stoch, g_trix, g_ifr);
      g_graphic_manager.UpdateTradingStatus("ANALYZING");

//--- Read chart objects
      g_trade_manager.ReadChartObjects();

//--- Check for trading signals
      Print("OnTick: Checking for entry signals...");
      g_trade_manager.CheckForEntry(g_dmi,g_didi,g_bb);
      Print("OnTick: Checking for exit signals...");
      g_trade_manager.CheckForExit(g_dmi,g_stoch,g_trix,g_bb);
      
      g_graphic_manager.UpdateTradingStatus("READY");
     }
  }
//+------------------------------------------------------------------+