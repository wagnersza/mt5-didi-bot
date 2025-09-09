//+------------------------------------------------------------------+
//|                                                    DidiBot.mq5 |
//|                        Copyright 2023, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.02"

//--- Stop Loss Configuration Enumerations
enum ENUM_STOP_TYPE
  {
   ATR_BASED,    // ATR-based stop loss
   FIXED_PIPS    // Fixed pip stop loss
  };

//--- Input Parameters for Stop Loss Configuration
input group "=== Stop Loss Configuration ==="
input ENUM_STOP_TYPE InpStopType = ATR_BASED;           // Stop Loss Type
input double InpATRMultiplier = 1.5;                    // ATR Multiplier (0.5-5.0)
input int InpFixedPips = 50;                            // Fixed Pips Stop Loss
input bool InpTrailingEnabled = true;                   // Enable Trailing Stop
input int InpMaxStopPips = 100;                         // Maximum Stop Loss (pips)
input int InpStopLimitSlippage = 3;                     // Stop Limit Slippage (pips)
input int InpATRPeriod = 14;                            // ATR Period for calculation
input int InpMinStopDistance = 10;                      // Minimum Stop Distance (pips)

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
CAtr g_atr;
CTradeManager g_trade_manager;
CGraphicManager g_graphic_manager;
CRiskManager g_risk_manager;

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
   
//--- Initialize ATR indicator for stop loss calculations
   if(!g_atr.Init(_Symbol,_Period,InpATRPeriod))
     {
      Print("OnInit: ATR initialization failed!");
      return(INIT_FAILED);
     }
     
//--- Initialize graphic manager
   g_graphic_manager.Init("DidiBot_");
   g_graphic_manager.UpdateTradingStatus("INITIALIZED");
   
//--- Configure stop loss settings from input parameters
   StopLossConfig config;
   config.type = InpStopType;
   config.atr_multiplier = InpATRMultiplier;
   config.fixed_pips = InpFixedPips;
   config.trailing_enabled = InpTrailingEnabled;
   config.max_stop_pips = InpMaxStopPips;
   config.stop_limit_slippage = InpStopLimitSlippage;
   config.atr_period = InpATRPeriod;
   config.min_stop_distance = InpMinStopDistance;
   
//--- Validate stop loss configuration parameters
   if(!g_risk_manager.ValidateStopLossConfig(config))
     {
      Print("OnInit: Stop loss configuration validation failed!");
      return(INIT_FAILED);
     }
   
   g_risk_manager.SetStopLossConfig(config);
   PrintFormat("OnInit: Stop loss configuration applied - Type: %s, ATR Mult: %.2f, Trailing: %s",
               (InpStopType == ATR_BASED) ? "ATR_BASED" : "FIXED_PIPS",
               InpATRMultiplier,
               InpTrailingEnabled ? "ENABLED" : "DISABLED");

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

//--- Update graphic indicators with current values including stop loss info
      g_graphic_manager.UpdateSignalPanelWithStops(g_dmi, g_didi, g_bb, g_stoch, g_trix, g_ifr, g_atr, g_risk_manager, g_trade_manager);
      g_graphic_manager.UpdateTradingStatus("ANALYZING");

//--- Read chart objects
      g_trade_manager.ReadChartObjects();

//--- Check for trading signals
      Print("OnTick: Checking for entry signals...");
      g_trade_manager.CheckForEntryWithStops(g_dmi,g_didi,g_bb,g_atr,g_risk_manager);
      Print("OnTick: Checking for exit signals...");
      g_trade_manager.CheckForExit(g_dmi,g_stoch,g_trix,g_bb);
      
//--- Check and adjust trailing stops on new bar
      if(InpTrailingEnabled)
        {
         Print("OnTick: Checking trailing stops...");
         double current_atr = g_atr.GetCurrentATR();
         g_trade_manager.CheckTrailingStops(current_atr);
        }
      
      g_graphic_manager.UpdateTradingStatus("READY");
     }
//--- Monitor trailing stops every tick for performance optimization
   else if(InpTrailingEnabled)
     {
      static int tick_counter = 0;
      tick_counter++;
      
//--- Check trailing stops every 10 ticks for performance
      if(tick_counter >= 10)
        {
         double current_atr = g_atr.GetCurrentATR();
         g_trade_manager.CheckTrailingStops(current_atr);
         tick_counter = 0;
        }
     }
  }
//+------------------------------------------------------------------+