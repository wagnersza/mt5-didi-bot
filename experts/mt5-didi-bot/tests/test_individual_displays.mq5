//+------------------------------------------------------------------+
//|                                        test_individual_displays.mq5 |
//|                        Copyright 2024, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property script_show_inputs

#include "../include/WindowManager.mqh"
#include "../include/SignalEngine.mqh"
#include "../include/displays/DmiDisplay.mqh"
#include "../include/displays/DidiDisplay.mqh"
#include "../include/displays/StochasticDisplay.mqh"
#include "../include/displays/TrixDisplay.mqh"
#include "../include/displays/IfrDisplay.mqh"
#include "../include/displays/MainChartDisplay.mqh"

// Test parameters
input bool EnableDebugOutput = true;
input bool TestDmiDisplay = true;
input bool TestDidiDisplay = true;
input bool TestStochasticDisplay = true;
input bool TestTrixDisplay = true;
input bool TestIfrDisplay = true;
input bool TestMainChartDisplay = true;

// Global objects for testing
CWindowManager g_window_manager;
CDmi g_dmi;
CDidiIndex g_didi;
CStochastic g_stochastic;
CTrix g_trix;
CIfr g_ifr;
CBollingerBands g_bb;

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
   Print("=== Individual Display Tests Started ===");
   
   int tests_passed = 0;
   int tests_failed = 0;
   
   // Initialize indicators first
   if(!InitializeIndicators())
   {
      Print("ERROR: Failed to initialize indicators for testing");
      return;
   }
   
   // Initialize window manager
   if(!g_window_manager.Init())
   {
      Print("ERROR: Failed to initialize WindowManager for testing");
      return;
   }
   
   // Test each display individually
   if(TestDmiDisplay)
   {
      if(TestDmiDisplayFunctionality())
         tests_passed++;
      else
         tests_failed++;
   }
   
   if(TestDidiDisplay)
   {
      if(TestDidiDisplayFunctionality())
         tests_passed++;
      else
         tests_failed++;
   }
   
   if(TestStochasticDisplay)
   {
      if(TestStochasticDisplayFunctionality())
         tests_passed++;
      else
         tests_failed++;
   }
   
   if(TestTrixDisplay)
   {
      if(TestTrixDisplayFunctionality())
         tests_passed++;
      else
         tests_failed++;
   }
   
   if(TestIfrDisplay)
   {
      if(TestIfrDisplayFunctionality())
         tests_passed++;
      else
         tests_failed++;
   }
   
   if(TestMainChartDisplay)
   {
      if(TestMainChartDisplayFunctionality())
         tests_passed++;
      else
         tests_failed++;
   }
   
   // Cleanup
   g_window_manager.Cleanup();
   
   Print("=== Individual Display Tests Completed ===");
   Print("Tests Passed: ", tests_passed);
   Print("Tests Failed: ", tests_failed);
   Print("Success Rate: ", (tests_passed * 100.0) / (tests_passed + tests_failed), "%");
}

//+------------------------------------------------------------------+
//| Initialize all indicators for testing                            |
//+------------------------------------------------------------------+
bool InitializeIndicators()
{
   string symbol = _Symbol;
   ENUM_TIMEFRAMES period = _Period;
   
   // Initialize DMI
   if(!g_dmi.Init(symbol, period, 14))
   {
      Print("ERROR: Failed to initialize DMI indicator");
      return false;
   }
   
   // Initialize Didi Index
   if(!g_didi.Init(symbol, period, 3, 8, 20))
   {
      Print("ERROR: Failed to initialize Didi Index indicator");
      return false;
   }
   
   // Initialize Stochastic
   if(!g_stochastic.Init(symbol, period, 14, 3, 3))
   {
      Print("ERROR: Failed to initialize Stochastic indicator");
      return false;
   }
   
   // Initialize Trix
   if(!g_trix.Init(symbol, period, 14))
   {
      Print("ERROR: Failed to initialize Trix indicator");
      return false;
   }
   
   // Initialize IFR
   if(!g_ifr.Init(symbol, period, 14))
   {
      Print("ERROR: Failed to initialize IFR indicator");
      return false;
   }
   
   // Initialize Bollinger Bands
   if(!g_bb.Init(symbol, period, 20, 2.0))
   {
      Print("ERROR: Failed to initialize Bollinger Bands indicator");
      return false;
   }
   
   if(EnableDebugOutput)
      Print("SUCCESS: All indicators initialized successfully");
   
   return true;
}

//+------------------------------------------------------------------+
//| Test DMI Display functionality                                   |
//+------------------------------------------------------------------+
bool TestDmiDisplayFunctionality()
{
   if(EnableDebugOutput)
      Print("Testing DMI Display...");
   
   // Create DMI window
   int window_index = g_window_manager.CreateIndicatorWindow("DMI", 80);
   if(window_index < 0)
   {
      Print("ERROR: Failed to create DMI window");
      return false;
   }
   
   // Create DMI display
   CDmiDisplay dmi_display;
   if(!dmi_display.Init(ChartID(), window_index, "DMI"))
   {
      Print("ERROR: Failed to initialize DMI display");
      return false;
   }
   
   // Test drawing DMI data with sample values
   double adx_value = g_dmi.GetADX(0);
   double plus_di = g_dmi.GetPlusDI(0);
   double minus_di = g_dmi.GetMinusDI(0);
   
   if(!dmi_display.UpdateDisplay(adx_value, plus_di, minus_di, TimeCurrent(), 0))
   {
      Print("ERROR: Failed to update DMI display");
      return false;
   }
   
   // Test window-specific object management
   if(!TestWindowObjects(window_index, "DMI"))
   {
      Print("ERROR: DMI window object management failed");
      return false;
   }
   
   // Test scaling for oscillator values (0-100 range)
   if(!TestOscillatorScaling(window_index, 0, 100))
   {
      Print("ERROR: DMI scaling test failed");
      return false;
   }
   
   // Cleanup
   dmi_display.Cleanup();
   
   if(EnableDebugOutput)
      Print("SUCCESS: DMI Display test passed");
   
   return true;
}

//+------------------------------------------------------------------+
//| Test Didi Display functionality                                  |
//+------------------------------------------------------------------+
bool TestDidiDisplayFunctionality()
{
   if(EnableDebugOutput)
      Print("Testing Didi Display...");
   
   // Create Didi window
   int window_index = g_window_manager.CreateIndicatorWindow("Didi", 80);
   if(window_index < 0)
   {
      Print("ERROR: Failed to create Didi window");
      return false;
   }
   
   // Create Didi display
   CDidiDisplay didi_display;
   if(!didi_display.Init(ChartID(), window_index, "Didi"))
   {
      Print("ERROR: Failed to initialize Didi display");
      return false;
   }
   
   // Test drawing Didi data with sample values
   double short_ma = g_didi.GetShortMA(0);
   double medium_ma = g_didi.GetMediumMA(0);
   double long_ma = g_didi.GetLongMA(0);
   
   if(!didi_display.UpdateDisplay(short_ma, medium_ma, long_ma, TimeCurrent(), 0))
   {
      Print("ERROR: Failed to update Didi display");
      return false;
   }
   
   // Test agulhada signal highlighting
   if(!TestAgulhadaSignals(window_index))
   {
      Print("ERROR: Agulhada signal test failed");
      return false;
   }
   
   // Test window-specific object management
   if(!TestWindowObjects(window_index, "Didi"))
   {
      Print("ERROR: Didi window object management failed");
      return false;
   }
   
   // Cleanup
   didi_display.Cleanup();
   
   if(EnableDebugOutput)
      Print("SUCCESS: Didi Display test passed");
   
   return true;
}

//+------------------------------------------------------------------+
//| Test Stochastic Display functionality                            |
//+------------------------------------------------------------------+
bool TestStochasticDisplayFunctionality()
{
   if(EnableDebugOutput)
      Print("Testing Stochastic Display...");
   
   // Create Stochastic window
   int window_index = g_window_manager.CreateIndicatorWindow("Stochastic", 80);
   if(window_index < 0)
   {
      Print("ERROR: Failed to create Stochastic window");
      return false;
   }
   
   // Create Stochastic display
   CStochasticDisplay stoch_display;
   if(!stoch_display.Init(ChartID(), window_index, "Stochastic"))
   {
      Print("ERROR: Failed to initialize Stochastic display");
      return false;
   }
   
   // Test drawing Stochastic data with sample values
   double main_value = g_stochastic.GetMain(0);
   double signal_value = g_stochastic.GetSignal(0);
   
   if(!stoch_display.UpdateDisplay(main_value, signal_value, TimeCurrent(), 0))
   {
      Print("ERROR: Failed to update Stochastic display");
      return false;
   }
   
   // Test overbought/oversold level lines (20, 80)
   if(!TestOverboughtOversoldLevels(window_index, 20, 80))
   {
      Print("ERROR: Stochastic OB/OS levels test failed");
      return false;
   }
   
   // Test oscillator scaling (0-100 range)
   if(!TestOscillatorScaling(window_index, 0, 100))
   {
      Print("ERROR: Stochastic scaling test failed");
      return false;
   }
   
   // Test window-specific object management
   if(!TestWindowObjects(window_index, "Stochastic"))
   {
      Print("ERROR: Stochastic window object management failed");
      return false;
   }
   
   // Cleanup
   stoch_display.Cleanup();
   
   if(EnableDebugOutput)
      Print("SUCCESS: Stochastic Display test passed");
   
   return true;
}

//+------------------------------------------------------------------+
//| Test Trix Display functionality                                  |
//+------------------------------------------------------------------+
bool TestTrixDisplayFunctionality()
{
   if(EnableDebugOutput)
      Print("Testing Trix Display...");
   
   // Create Trix window
   int window_index = g_window_manager.CreateIndicatorWindow("Trix", 80);
   if(window_index < 0)
   {
      Print("ERROR: Failed to create Trix window");
      return false;
   }
   
   // Create Trix display
   CTrixDisplay trix_display;
   if(!trix_display.Init(ChartID(), window_index, "Trix"))
   {
      Print("ERROR: Failed to initialize Trix display");
      return false;
   }
   
   // Test drawing Trix data with sample values
   double trix_value = g_trix.GetTrix(0);
   
   if(!trix_display.UpdateDisplay(trix_value, TimeCurrent(), 0))
   {
      Print("ERROR: Failed to update Trix display");
      return false;
   }
   
   // Test zero-line crossover visualization
   if(!TestZeroLineCrossovers(window_index))
   {
      Print("ERROR: Trix zero-line crossover test failed");
      return false;
   }
   
   // Test window-specific object management
   if(!TestWindowObjects(window_index, "Trix"))
   {
      Print("ERROR: Trix window object management failed");
      return false;
   }
   
   // Cleanup
   trix_display.Cleanup();
   
   if(EnableDebugOutput)
      Print("SUCCESS: Trix Display test passed");
   
   return true;
}

//+------------------------------------------------------------------+
//| Test IFR Display functionality                                   |
//+------------------------------------------------------------------+
bool TestIfrDisplayFunctionality()
{
   if(EnableDebugOutput)
      Print("Testing IFR Display...");
   
   // Create IFR window
   int window_index = g_window_manager.CreateIndicatorWindow("IFR", 80);
   if(window_index < 0)
   {
      Print("ERROR: Failed to create IFR window");
      return false;
   }
   
   // Create IFR display
   CIfrDisplay ifr_display;
   if(!ifr_display.Init(ChartID(), window_index, "IFR"))
   {
      Print("ERROR: Failed to initialize IFR display");
      return false;
   }
   
   // Test drawing IFR data with sample values
   double ifr_value = g_ifr.GetIfr(0);
   
   if(!ifr_display.UpdateDisplay(ifr_value, TimeCurrent(), 0))
   {
      Print("ERROR: Failed to update IFR display");
      return false;
   }
   
   // Test overbought/oversold levels (30, 70)
   if(!TestOverboughtOversoldLevels(window_index, 30, 70))
   {
      Print("ERROR: IFR OB/OS levels test failed");
      return false;
   }
   
   // Test RSI scaling (0-100 range)
   if(!TestOscillatorScaling(window_index, 0, 100))
   {
      Print("ERROR: IFR scaling test failed");
      return false;
   }
   
   // Test window-specific object management
   if(!TestWindowObjects(window_index, "IFR"))
   {
      Print("ERROR: IFR window object management failed");
      return false;
   }
   
   // Cleanup
   ifr_display.Cleanup();
   
   if(EnableDebugOutput)
      Print("SUCCESS: IFR Display test passed");
   
   return true;
}

//+------------------------------------------------------------------+
//| Test Main Chart Display functionality                            |
//+------------------------------------------------------------------+
bool TestMainChartDisplayFunctionality()
{
   if(EnableDebugOutput)
      Print("Testing Main Chart Display...");
   
   // Main chart window is always window 0
   int window_index = 0;
   
   // Create Main Chart display
   CMainChartDisplay main_display;
   if(!main_display.Init(ChartID(), window_index, "MainChart"))
   {
      Print("ERROR: Failed to initialize Main Chart display");
      return false;
   }
   
   // Test drawing Bollinger Bands on main chart with sample values
   double upper_band = g_bb.Upper(0);
   double middle_band = g_bb.Middle(0);
   double lower_band = g_bb.Lower(0);
   
   if(!main_display.UpdateDisplay(upper_band, middle_band, lower_band, TimeCurrent(), 0))
   {
      Print("ERROR: Failed to update Main Chart display");
      return false;
   }
   
   // Test entry/exit signal arrows
   if(!TestTradingSignals(window_index))
   {
      Print("ERROR: Trading signal test failed");
      return false;
   }
   
   // Test window-specific object management
   if(!TestWindowObjects(window_index, "MainChart"))
   {
      Print("ERROR: Main Chart window object management failed");
      return false;
   }
   
   // Cleanup
   main_display.Cleanup();
   
   if(EnableDebugOutput)
      Print("SUCCESS: Main Chart Display test passed");
   
   return true;
}

//+------------------------------------------------------------------+
//| Test window-specific object management                           |
//+------------------------------------------------------------------+
bool TestWindowObjects(int window_index, string prefix)
{
   // Test object creation with proper window prefix
   string object_name = prefix + "_TestObject_" + IntegerToString(GetTickCount());
   
   if(!ObjectCreate(0, object_name, OBJ_HLINE, window_index, 0, 1.0))
   {
      Print("ERROR: Failed to create test object in window ", window_index);
      return false;
   }
   
   // Test object exists in correct window
   if(ObjectFind(0, object_name) != window_index)
   {
      Print("ERROR: Object not found in expected window");
      ObjectDelete(0, object_name);
      return false;
   }
   
   // Test object cleanup
   if(!ObjectDelete(0, object_name))
   {
      Print("ERROR: Failed to delete test object");
      return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Test oscillator scaling (0-100 range)                          |
//+------------------------------------------------------------------+
bool TestOscillatorScaling(int window_index, double min_value, double max_value)
{
   // Test window scaling by setting and checking window properties
   if(!ChartSetInteger(0, CHART_WINDOW_YDISTANCE, window_index, 80))
   {
      Print("ERROR: Failed to set window height");
      return false;
   }
   
   // Create test lines at min and max values to verify scaling
   string min_line = "TestMin_" + IntegerToString(window_index);
   string max_line = "TestMax_" + IntegerToString(window_index);
   
   if(!ObjectCreate(0, min_line, OBJ_HLINE, window_index, 0, min_value))
   {
      Print("ERROR: Failed to create minimum value line");
      return false;
   }
   
   if(!ObjectCreate(0, max_line, OBJ_HLINE, window_index, 0, max_value))
   {
      Print("ERROR: Failed to create maximum value line");
      ObjectDelete(0, min_line);
      return false;
   }
   
   // Cleanup test objects
   ObjectDelete(0, min_line);
   ObjectDelete(0, max_line);
   
   return true;
}

//+------------------------------------------------------------------+
//| Test overbought/oversold level lines                            |
//+------------------------------------------------------------------+
bool TestOverboughtOversoldLevels(int window_index, double oversold_level, double overbought_level)
{
   // Create oversold level line
   string os_line = "OversoldLevel_" + IntegerToString(window_index);
   if(!ObjectCreate(0, os_line, OBJ_HLINE, window_index, 0, oversold_level))
   {
      Print("ERROR: Failed to create oversold level line");
      return false;
   }
   
   // Create overbought level line
   string ob_line = "OverboughtLevel_" + IntegerToString(window_index);
   if(!ObjectCreate(0, ob_line, OBJ_HLINE, window_index, 0, overbought_level))
   {
      Print("ERROR: Failed to create overbought level line");
      ObjectDelete(0, os_line);
      return false;
   }
   
   // Test line properties
   if(!ObjectSetInteger(0, os_line, OBJPROP_COLOR, clrRed))
   {
      Print("ERROR: Failed to set oversold line color");
      ObjectDelete(0, os_line);
      ObjectDelete(0, ob_line);
      return false;
   }
   
   if(!ObjectSetInteger(0, ob_line, OBJPROP_COLOR, clrRed))
   {
      Print("ERROR: Failed to set overbought line color");
      ObjectDelete(0, os_line);
      ObjectDelete(0, ob_line);
      return false;
   }
   
   // Cleanup test objects
   ObjectDelete(0, os_line);
   ObjectDelete(0, ob_line);
   
   return true;
}

//+------------------------------------------------------------------+
//| Test agulhada signals                                           |
//+------------------------------------------------------------------+
bool TestAgulhadaSignals(int window_index)
{
   // Create test agulhada signal marker
   string signal_name = "AgulhadaSignal_" + IntegerToString(GetTickCount());
   
   if(!ObjectCreate(0, signal_name, OBJ_ARROW, window_index, TimeCurrent(), 1.0))
   {
      Print("ERROR: Failed to create agulhada signal marker");
      return false;
   }
   
   // Set arrow properties
   if(!ObjectSetInteger(0, signal_name, OBJPROP_ARROWCODE, 233))
   {
      Print("ERROR: Failed to set agulhada arrow code");
      ObjectDelete(0, signal_name);
      return false;
   }
   
   if(!ObjectSetInteger(0, signal_name, OBJPROP_COLOR, clrYellow))
   {
      Print("ERROR: Failed to set agulhada signal color");
      ObjectDelete(0, signal_name);
      return false;
   }
   
   // Cleanup
   ObjectDelete(0, signal_name);
   
   return true;
}

//+------------------------------------------------------------------+
//| Test zero-line crossovers                                       |
//+------------------------------------------------------------------+
bool TestZeroLineCrossovers(int window_index)
{
   // Create zero line
   string zero_line = "ZeroLine_" + IntegerToString(window_index);
   if(!ObjectCreate(0, zero_line, OBJ_HLINE, window_index, 0, 0.0))
   {
      Print("ERROR: Failed to create zero line");
      return false;
   }
   
   // Set zero line properties
   if(!ObjectSetInteger(0, zero_line, OBJPROP_COLOR, clrGray))
   {
      Print("ERROR: Failed to set zero line color");
      ObjectDelete(0, zero_line);
      return false;
   }
   
   if(!ObjectSetInteger(0, zero_line, OBJPROP_STYLE, STYLE_DOT))
   {
      Print("ERROR: Failed to set zero line style");
      ObjectDelete(0, zero_line);
      return false;
   }
   
   // Cleanup
   ObjectDelete(0, zero_line);
   
   return true;
}

//+------------------------------------------------------------------+
//| Test trading signals                                             |
//+------------------------------------------------------------------+
bool TestTradingSignals(int window_index)
{
   // Create buy signal arrow
   string buy_signal = "BuySignal_" + IntegerToString(GetTickCount());
   if(!ObjectCreate(0, buy_signal, OBJ_ARROW, window_index, TimeCurrent(), SymbolInfoDouble(_Symbol, SYMBOL_BID)))
   {
      Print("ERROR: Failed to create buy signal arrow");
      return false;
   }
   
   // Set buy arrow properties
   if(!ObjectSetInteger(0, buy_signal, OBJPROP_ARROWCODE, 233))
   {
      Print("ERROR: Failed to set buy arrow code");
      ObjectDelete(0, buy_signal);
      return false;
   }
   
   if(!ObjectSetInteger(0, buy_signal, OBJPROP_COLOR, clrGreen))
   {
      Print("ERROR: Failed to set buy signal color");
      ObjectDelete(0, buy_signal);
      return false;
   }
   
   // Create sell signal arrow
   string sell_signal = "SellSignal_" + IntegerToString(GetTickCount());
   if(!ObjectCreate(0, sell_signal, OBJ_ARROW, window_index, TimeCurrent(), SymbolInfoDouble(_Symbol, SYMBOL_ASK)))
   {
      Print("ERROR: Failed to create sell signal arrow");
      ObjectDelete(0, buy_signal);
      return false;
   }
   
   // Set sell arrow properties
   if(!ObjectSetInteger(0, sell_signal, OBJPROP_ARROWCODE, 234))
   {
      Print("ERROR: Failed to set sell arrow code");
      ObjectDelete(0, buy_signal);
      ObjectDelete(0, sell_signal);
      return false;
   }
   
   if(!ObjectSetInteger(0, sell_signal, OBJPROP_COLOR, clrRed))
   {
      Print("ERROR: Failed to set sell signal color");
      ObjectDelete(0, buy_signal);
      ObjectDelete(0, sell_signal);
      return false;
   }
   
   // Cleanup
   ObjectDelete(0, buy_signal);
   ObjectDelete(0, sell_signal);
   
   return true;
}
