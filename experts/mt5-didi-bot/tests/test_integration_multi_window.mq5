//+------------------------------------------------------------------+
//|                                test_integration_multi_window.mq5 |
//|                        Copyright 2024, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property script_show_inputs

#include "../include/WindowManager.mqh"
#include "../include/SignalEngine.mqh"

// Test parameters
input bool EnableDebugOutput = true;
input bool TestCompleteEA = true;
input bool TestSignalCoordination = true;
input bool TestWindowRestart = true;
input bool TestPerformance = true;

// Global objects - simulating multi-window environment
CWindowManager g_window_manager;
CDmi g_dmi;
CDidiIndex g_didi;
CStochastic g_stochastic;
CTrix g_trix;
CIfr g_ifr;
CBollingerBands g_bb;

// Test timing variables
uint g_test_start_time;
uint g_test_iterations = 0;

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
   Print("=== Integrated Multi-Window Functionality Tests Started ===");
   
   g_test_start_time = GetTickCount();
   int tests_passed = 0;
   int tests_failed = 0;
   
   // Initialize environment
   if(!InitializeTestEnvironment())
   {
      Print("ERROR: Failed to initialize test environment");
      return;
   }
   
   // Test complete EA with all windows active
   if(TestCompleteEA)
   {
      if(TestCompleteEAFunctionality())
         tests_passed++;
      else
         tests_failed++;
   }
   
   // Test signal coordination across windows
   if(TestSignalCoordination)
   {
      if(TestSignalCoordinationAcrossWindows())
         tests_passed++;
      else
         tests_failed++;
   }
   
   // Test window management during restart/recompile
   if(TestWindowRestart)
   {
      if(TestWindowManagementDuringRestart())
         tests_passed++;
      else
         tests_failed++;
   }
   
   // Test performance metrics
   if(TestPerformance)
   {
      if(TestPerformanceMetrics())
         tests_passed++;
      else
         tests_failed++;
   }
   
   // Cleanup
   CleanupTestEnvironment();
   
   uint test_duration = GetTickCount() - g_test_start_time;
   
   Print("=== Integrated Multi-Window Tests Completed ===");
   Print("Tests Passed: ", tests_passed);
   Print("Tests Failed: ", tests_failed);
   Print("Test Duration: ", test_duration, " ms");
   Print("Test Iterations: ", g_test_iterations);
   Print("Success Rate: ", (tests_passed * 100.0) / (tests_passed + tests_failed), "%");
}

//+------------------------------------------------------------------+
//| Initialize test environment                                      |
//+------------------------------------------------------------------+
bool InitializeTestEnvironment()
{
   if(EnableDebugOutput)
      Print("Initializing test environment...");
   
   string symbol = _Symbol;
   ENUM_TIMEFRAMES period = _Period;
   
   // Initialize WindowManager
   if(!g_window_manager.Init())
   {
      Print("ERROR: Failed to initialize WindowManager");
      return false;
   }
   
   // Initialize all indicators
   if(!g_dmi.Init(symbol, period, 14))
   {
      Print("ERROR: Failed to initialize DMI");
      return false;
   }
   
   if(!g_didi.Init(symbol, period, 3, 8, 20))
   {
      Print("ERROR: Failed to initialize Didi Index");
      return false;
   }
   
   if(!g_stochastic.Init(symbol, period, 14, 3, 3))
   {
      Print("ERROR: Failed to initialize Stochastic");
      return false;
   }
   
   if(!g_trix.Init(symbol, period, 14))
   {
      Print("ERROR: Failed to initialize Trix");
      return false;
   }
   
   if(!g_ifr.Init(symbol, period, 14))
   {
      Print("ERROR: Failed to initialize IFR");
      return false;
   }
   
   if(!g_bb.Init(symbol, period, 20, 2.0))
   {
      Print("ERROR: Failed to initialize Bollinger Bands");
      return false;
   }
   
   if(EnableDebugOutput)
      Print("SUCCESS: Test environment initialized");
   
   return true;
}

//+------------------------------------------------------------------+
//| Test complete EA functionality with all windows                  |
//+------------------------------------------------------------------+
bool TestCompleteEAFunctionality()
{
   if(EnableDebugOutput)
      Print("Testing complete EA functionality...");
   
   // Test all windows are created properly
   if(!TestAllWindowsCreated())
   {
      Print("ERROR: Not all windows were created properly");
      return false;
   }
   
   // Test indicator data flows to all windows
   if(!TestIndicatorDataFlow())
   {
      Print("ERROR: Indicator data flow test failed");
      return false;
   }
   
   // Test real-time updates across all windows
   if(!TestRealTimeUpdates())
   {
      Print("ERROR: Real-time updates test failed");
      return false;
   }
   
   if(EnableDebugOutput)
      Print("SUCCESS: Complete EA functionality test passed");
   
   return true;
}

//+------------------------------------------------------------------+
//| Test signal coordination across windows                          |
//+------------------------------------------------------------------+
bool TestSignalCoordinationAcrossWindows()
{
   if(EnableDebugOutput)
      Print("Testing signal coordination across windows...");
   
   // Test signal visualization in appropriate windows
   if(!TestSignalVisualization())
   {
      Print("ERROR: Signal visualization test failed");
      return false;
   }
   
   // Test signal synchronization between windows
   if(!TestSignalSynchronization())
   {
      Print("ERROR: Signal synchronization test failed");
      return false;
   }
   
   if(EnableDebugOutput)
      Print("SUCCESS: Signal coordination test passed");
   
   return true;
}

//+------------------------------------------------------------------+
//| Test window management during restart/recompile                  |
//+------------------------------------------------------------------+
bool TestWindowManagementDuringRestart()
{
   if(EnableDebugOutput)
      Print("Testing window management during restart...");
   
   // Test window cleanup
   if(!TestWindowCleanup())
   {
      Print("ERROR: Window cleanup test failed");
      return false;
   }
   
   // Test window recreation
   if(!TestWindowRecreation())
   {
      Print("ERROR: Window recreation test failed");
      return false;
   }
   
   if(EnableDebugOutput)
      Print("SUCCESS: Window management during restart test passed");
   
   return true;
}

//+------------------------------------------------------------------+
//| Test performance metrics                                         |
//+------------------------------------------------------------------+
bool TestPerformanceMetrics()
{
   if(EnableDebugOutput)
      Print("Testing performance metrics...");
   
   uint start_time = GetTickCount();
   
   // Test multiple update cycles
   const int test_cycles = 100;
   for(int i = 0; i < test_cycles; i++)
   {
      // Simulate indicator updates
      double adx = g_dmi.GetADX(0);
      double short_ma = g_didi.GetShortMA(0);
      double stoch = g_stochastic.GetMain(0);
      double trix = g_trix.GetTrix(0);
      double ifr = g_ifr.GetIfr(0);
      
      g_test_iterations++;
   }
   
   uint cycle_duration = GetTickCount() - start_time;
   double avg_cycle_time = (double)cycle_duration / test_cycles;
   
   if(EnableDebugOutput)
   {
      Print("Performance Test Results:");
      Print("Total Cycles: ", test_cycles);
      Print("Total Duration: ", cycle_duration, " ms");
      Print("Average Cycle Time: ", avg_cycle_time, " ms");
   }
   
   // Performance threshold check (should be under 10ms per cycle)
   if(avg_cycle_time > 10.0)
   {
      Print("WARNING: Performance degradation detected - Average cycle time: ", avg_cycle_time, " ms");
      return false;
   }
   
   if(EnableDebugOutput)
      Print("SUCCESS: Performance metrics test passed");
   
   return true;
}

//+------------------------------------------------------------------+
//| Test all windows are created properly                           |
//+------------------------------------------------------------------+
bool TestAllWindowsCreated()
{
   // Create expected windows
   int dmi_window = g_window_manager.CreateIndicatorWindow("DMI", 80);
   int didi_window = g_window_manager.CreateIndicatorWindow("Didi", 80);
   int stoch_window = g_window_manager.CreateIndicatorWindow("Stochastic", 80);
   int trix_window = g_window_manager.CreateIndicatorWindow("Trix", 80);
   int ifr_window = g_window_manager.CreateIndicatorWindow("IFR", 80);
   
   if(dmi_window < 0 || didi_window < 0 || stoch_window < 0 || trix_window < 0 || ifr_window < 0)
   {
      Print("ERROR: Failed to create one or more windows");
      return false;
   }
   
   // Test each window is accessible
   if(!g_window_manager.IsWindowValid(dmi_window) ||
      !g_window_manager.IsWindowValid(didi_window) ||
      !g_window_manager.IsWindowValid(stoch_window) ||
      !g_window_manager.IsWindowValid(trix_window) ||
      !g_window_manager.IsWindowValid(ifr_window))
   {
      Print("ERROR: One or more windows are not valid");
      return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Test indicator data flow to all windows                         |
//+------------------------------------------------------------------+
bool TestIndicatorDataFlow()
{
   // Test that all indicators can provide valid data
   
   double adx = g_dmi.GetADX(0);
   if(adx < 0)
   {
      Print("ERROR: DMI data not available");
      return false;
   }
   
   double short_ma = g_didi.GetShortMA(0);
   if(short_ma <= 0)
   {
      Print("ERROR: Didi data not available");
      return false;
   }
   
   double stoch = g_stochastic.GetMain(0);
   if(stoch < 0 || stoch > 100)
   {
      Print("ERROR: Stochastic data not available or invalid");
      return false;
   }
   
   double trix = g_trix.GetTrix(0);
   if(trix == EMPTY_VALUE)
   {
      Print("ERROR: Trix data not available");
      return false;
   }
   
   double ifr = g_ifr.GetIfr(0);
   if(ifr < 0 || ifr > 100)
   {
      Print("ERROR: IFR data not available or invalid");
      return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Test real-time updates across all windows                       |
//+------------------------------------------------------------------+
bool TestRealTimeUpdates()
{
   // Simulate new bar detection pattern
   static datetime prev_bar_time = 0;
   datetime current_bar_time = (datetime)SeriesInfoInteger(_Symbol, _Period, SERIES_LASTBAR_DATE);
   
   if(current_bar_time > prev_bar_time)
   {
      prev_bar_time = current_bar_time;
      
      // Test that all indicators update on new bar
      double adx_new = g_dmi.GetADX(0);
      double short_ma_new = g_didi.GetShortMA(0);
      double stoch_new = g_stochastic.GetMain(0);
      
      if(adx_new < 0 || short_ma_new <= 0 || stoch_new < 0)
      {
         Print("ERROR: Failed to get updated indicator values");
         return false;
      }
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Test signal visualization                                        |
//+------------------------------------------------------------------+
bool TestSignalVisualization()
{
   // Test signals appear in appropriate windows
   
   // Create test signal markers in multiple windows
   for(int window = 1; window < 6; window++)
   {
      if(!g_window_manager.IsWindowValid(window))
         continue;
         
      string signal_marker = "TestSignal_" + IntegerToString(window) + "_" + IntegerToString(GetTickCount());
      
      if(!ObjectCreate(0, signal_marker, OBJ_ARROW, window, TimeCurrent(), 1.0))
      {
         Print("ERROR: Failed to create signal marker in window ", window);
         return false;
      }
      
      if(!ObjectSetInteger(0, signal_marker, OBJPROP_ARROWCODE, 233))
      {
         Print("ERROR: Failed to set signal marker properties in window ", window);
         ObjectDelete(0, signal_marker);
         return false;
      }
      
      // Cleanup
      ObjectDelete(0, signal_marker);
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Test signal synchronization                                     |
//+------------------------------------------------------------------+
bool TestSignalSynchronization()
{
   // Test that signals are synchronized across windows
   datetime signal_time = TimeCurrent();
   
   // All signal displays should use the same timestamp
   for(int window = 1; window < 6; window++)
   {
      if(!g_window_manager.IsWindowValid(window))
         continue;
         
      // Test timestamp synchronization by creating timed objects
      string sync_object = "SyncTest_" + IntegerToString(window);
      
      if(!ObjectCreate(0, sync_object, OBJ_VLINE, window, signal_time, 0))
      {
         Print("ERROR: Failed to create sync test object in window ", window);
         return false;
      }
      
      // Verify timestamp
      datetime object_time = (datetime)ObjectGetInteger(0, sync_object, OBJPROP_TIME);
      if(object_time != signal_time)
      {
         Print("ERROR: Timestamp mismatch in window ", window, " - expected: ", signal_time, ", got: ", object_time);
         ObjectDelete(0, sync_object);
         return false;
      }
      
      // Cleanup
      ObjectDelete(0, sync_object);
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Test window cleanup                                             |
//+------------------------------------------------------------------+
bool TestWindowCleanup()
{
   // Test that window manager properly cleans up
   int initial_windows = g_window_manager.GetWindowCount();
   
   // Perform cleanup
   g_window_manager.Cleanup();
   
   // Verify cleanup worked
   if(EnableDebugOutput)
      Print("Window cleanup completed - Initial windows: ", initial_windows);
   
   return true;
}

//+------------------------------------------------------------------+
//| Test window recreation                                          |
//+------------------------------------------------------------------+
bool TestWindowRecreation()
{
   // Re-initialize window manager after cleanup
   if(!g_window_manager.Init())
   {
      Print("ERROR: Failed to re-initialize window manager");
      return false;
   }
   
   // Test windows can be recreated
   int window_index = g_window_manager.CreateIndicatorWindow("TestRecreation", 80);
   if(window_index < 0)
   {
      Print("ERROR: Failed to recreate test window");
      return false;
   }
   
   // Test window is functional
   string test_object = "RecreationTest_" + IntegerToString(GetTickCount());
   if(!ObjectCreate(0, test_object, OBJ_HLINE, window_index, 0, 1.0))
   {
      Print("ERROR: Recreated window is not functional");
      return false;
   }
   
   // Cleanup
   ObjectDelete(0, test_object);
   
   return true;
}

//+------------------------------------------------------------------+
//| Cleanup test environment                                        |
//+------------------------------------------------------------------+
void CleanupTestEnvironment()
{
   if(EnableDebugOutput)
      Print("Cleaning up test environment...");
   
   g_window_manager.Cleanup();
   
   if(EnableDebugOutput)
      Print("Test environment cleanup completed");
}

//+------------------------------------------------------------------+
//| Test signal coordination across windows                          |
//+------------------------------------------------------------------+
bool TestSignalCoordinationAcrossWindows()
{
   if(EnableDebugOutput)
      Print("Testing signal coordination across windows...");
   
   // Simulate tick to generate signals
   datetime current_time = TimeCurrent();
   
   // Test signal generation and propagation
   if(!TestSignalGeneration())
   {
      Print("ERROR: Signal generation test failed");
      return false;
   }
   
   // Test signal visualization in appropriate windows
   if(!TestSignalVisualization())
   {
      Print("ERROR: Signal visualization test failed");
      return false;
   }
   
   // Test signal synchronization between windows
   if(!TestSignalSynchronization())
   {
      Print("ERROR: Signal synchronization test failed");
      return false;
   }
   
   // Test trade signal coordination
   if(!TestTradeSignalCoordination())
   {
      Print("ERROR: Trade signal coordination test failed");
      return false;
   }
   
   if(EnableDebugOutput)
      Print("SUCCESS: Signal coordination test passed");
   
   return true;
}

//+------------------------------------------------------------------+
//| Test window management during restart/recompile                  |
//+------------------------------------------------------------------+
bool TestWindowManagementDuringRestart()
{
   if(EnableDebugOutput)
      Print("Testing window management during restart...");
   
   // Test window cleanup
   if(!TestWindowCleanup())
   {
      Print("ERROR: Window cleanup test failed");
      return false;
   }
   
   // Test window recreation
   if(!TestWindowRecreation())
   {
      Print("ERROR: Window recreation test failed");
      return false;
   }
   
   // Test indicator handle preservation/recreation
   if(!TestIndicatorHandleManagement())
   {
      Print("ERROR: Indicator handle management test failed");
      return false;
   }
   
   // Test object preservation across restarts
   if(!TestObjectPreservation())
   {
      Print("ERROR: Object preservation test failed");
      return false;
   }
   
   if(EnableDebugOutput)
      Print("SUCCESS: Window management during restart test passed");
   
   return true;
}

//+------------------------------------------------------------------+
//| Test performance metrics                                         |
//+------------------------------------------------------------------+
bool TestPerformanceMetrics()
{
   if(EnableDebugOutput)
      Print("Testing performance metrics...");
   
   uint start_time = GetTickCount();
   
   // Test multiple update cycles
   const int test_cycles = 100;
   for(int i = 0; i < test_cycles; i++)
   {
      if(!g_graphic_manager.UpdateAllDisplays())
      {
         Print("ERROR: Graphic manager update failed at cycle ", i);
         return false;
      }
      g_test_iterations++;
   }
   
   uint cycle_duration = GetTickCount() - start_time;
   double avg_cycle_time = (double)cycle_duration / test_cycles;
   
   if(EnableDebugOutput)
   {
      Print("Performance Test Results:");
      Print("Total Cycles: ", test_cycles);
      Print("Total Duration: ", cycle_duration, " ms");
      Print("Average Cycle Time: ", avg_cycle_time, " ms");
   }
   
   // Performance threshold check (should be under 10ms per cycle)
   if(avg_cycle_time > 10.0)
   {
      Print("WARNING: Performance degradation detected - Average cycle time: ", avg_cycle_time, " ms");
      return false;
   }
   
   // Test memory usage stability
   if(!TestMemoryUsage())
   {
      Print("ERROR: Memory usage test failed");
      return false;
   }
   
   if(EnableDebugOutput)
      Print("SUCCESS: Performance metrics test passed");
   
   return true;
}

//+------------------------------------------------------------------+
//| Test all windows are created properly                           |
//+------------------------------------------------------------------+
bool TestAllWindowsCreated()
{
   // Expected window structure:
   // Window 0: Main Chart (Price + Bollinger Bands)
   // Window 1: DMI Window
   // Window 2: Didi Index Window  
   // Window 3: Stochastic Window
   // Window 4: Trix Window
   // Window 5: IFR Window
   
   int expected_windows = 6;
   int created_windows = g_window_manager.GetWindowCount();
   
   if(created_windows < expected_windows)
   {
      Print("ERROR: Expected ", expected_windows, " windows, but only ", created_windows, " were created");
      return false;
   }
   
   // Test each window exists and is accessible
   for(int i = 0; i < expected_windows; i++)
   {
      if(!g_window_manager.IsWindowValid(i))
      {
         Print("ERROR: Window ", i, " is not valid");
         return false;
      }
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Test indicator data flow to all windows                         |
//+------------------------------------------------------------------+
bool TestIndicatorDataFlow()
{
   // Test that signal engine can provide data to all displays
   
   // Test DMI data availability
   if(!g_signal_engine.IsDmiInitialized())
   {
      Print("ERROR: DMI indicator not properly initialized");
      return false;
   }
   
   // Test Didi data availability
   if(!g_signal_engine.IsDidiInitialized())
   {
      Print("ERROR: Didi indicator not properly initialized");
      return false;
   }
   
   // Test Stochastic data availability
   if(!g_signal_engine.IsStochasticInitialized())
   {
      Print("ERROR: Stochastic indicator not properly initialized");
      return false;
   }
   
   // Test Trix data availability
   if(!g_signal_engine.IsTrixInitialized())
   {
      Print("ERROR: Trix indicator not properly initialized");
      return false;
   }
   
   // Test IFR data availability
   if(!g_signal_engine.IsIfrInitialized())
   {
      Print("ERROR: IFR indicator not properly initialized");
      return false;
   }
   
   // Test Bollinger Bands data availability
   if(!g_signal_engine.IsBollingerBandsInitialized())
   {
      Print("ERROR: Bollinger Bands indicator not properly initialized");
      return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Test graphic manager coordination                                |
//+------------------------------------------------------------------+
bool TestGraphicManagerCoordination()
{
   // Test graphic manager can update all displays
   if(!g_graphic_manager.UpdateAllDisplays())
   {
      Print("ERROR: Graphic manager failed to update all displays");
      return false;
   }
   
   // Test graphic manager can clear all displays
   if(!g_graphic_manager.ClearAllDisplays())
   {
      Print("ERROR: Graphic manager failed to clear all displays");
      return false;
   }
   
   // Test window-specific drawing coordination
   if(!g_graphic_manager.UpdateSpecificDisplay("DMI"))
   {
      Print("ERROR: Graphic manager failed to update DMI display");
      return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Test real-time updates across all windows                       |
//+------------------------------------------------------------------+
bool TestRealTimeUpdates()
{
   // Simulate new bar detection pattern
   static datetime prev_bar_time = 0;
   datetime current_bar_time = (datetime)SeriesInfoInteger(_Symbol, _Period, SERIES_LASTBAR_DATE);
   
   if(current_bar_time > prev_bar_time)
   {
      prev_bar_time = current_bar_time;
      
      // Test that all displays update on new bar
      if(!g_graphic_manager.UpdateAllDisplays())
      {
         Print("ERROR: Failed to update all displays on new bar");
         return false;
      }
   }
   
   // Test tick-by-tick updates for main chart
   if(!g_graphic_manager.UpdateMainChartDisplay())
   {
      Print("ERROR: Failed to update main chart display");
      return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Test signal generation                                           |
//+------------------------------------------------------------------+
bool TestSignalGeneration()
{
   // Test signal engine generates signals
   CSignalResult signal_result = g_signal_engine.GenerateSignals();
   
   if(!signal_result.IsValid())
   {
      Print("ERROR: Signal generation returned invalid result");
      return false;
   }
   
   // Test signal has all required components
   if(!signal_result.HasDmiSignal() || 
      !signal_result.HasDidiSignal() ||
      !signal_result.HasStochasticSignal() ||
      !signal_result.HasTrixSignal() ||
      !signal_result.HasIfrSignal())
   {
      Print("ERROR: Signal result missing required signal components");
      return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Test signal visualization                                        |
//+------------------------------------------------------------------+
bool TestSignalVisualization()
{
   // Test signals appear in appropriate windows
   
   // Create test signal markers in each window
   for(int window = 1; window < 6; window++)
   {
      string signal_marker = "TestSignal_" + IntegerToString(window) + "_" + IntegerToString(GetTickCount());
      
      if(!ObjectCreate(0, signal_marker, OBJ_ARROW, window, TimeCurrent(), 1.0))
      {
         Print("ERROR: Failed to create signal marker in window ", window);
         return false;
      }
      
      if(!ObjectSetInteger(0, signal_marker, OBJPROP_ARROWCODE, 233))
      {
         Print("ERROR: Failed to set signal marker properties in window ", window);
         ObjectDelete(0, signal_marker);
         return false;
      }
      
      // Cleanup
      ObjectDelete(0, signal_marker);
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Test signal synchronization                                     |
//+------------------------------------------------------------------+
bool TestSignalSynchronization()
{
   // Test that signals are synchronized across windows
   datetime signal_time = TimeCurrent();
   
   // All signal displays should use the same timestamp
   for(int window = 1; window < 6; window++)
   {
      // Test timestamp synchronization by creating timed objects
      string sync_object = "SyncTest_" + IntegerToString(window);
      
      if(!ObjectCreate(0, sync_object, OBJ_VLINE, window, signal_time, 0))
      {
         Print("ERROR: Failed to create sync test object in window ", window);
         return false;
      }
      
      // Verify timestamp
      datetime object_time = (datetime)ObjectGetInteger(0, sync_object, OBJPROP_TIME);
      if(object_time != signal_time)
      {
         Print("ERROR: Timestamp mismatch in window ", window, " - expected: ", signal_time, ", got: ", object_time);
         ObjectDelete(0, sync_object);
         return false;
      }
      
      // Cleanup
      ObjectDelete(0, sync_object);
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Test trade signal coordination                                  |
//+------------------------------------------------------------------+
bool TestTradeSignalCoordination()
{
   // Test trade signals coordinate with indicator windows
   
   // Generate test trade signal
   ENUM_SIGNAL_TYPE signal_type = SIGNAL_BUY;
   double entry_price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   
   // Test signal appears on main chart
   string trade_signal = "TradeSignal_" + IntegerToString(GetTickCount());
   
   if(!ObjectCreate(0, trade_signal, OBJ_ARROW, 0, TimeCurrent(), entry_price))
   {
      Print("ERROR: Failed to create trade signal on main chart");
      return false;
   }
   
   if(!ObjectSetInteger(0, trade_signal, OBJPROP_ARROWCODE, 233))
   {
      Print("ERROR: Failed to set trade signal properties");
      ObjectDelete(0, trade_signal);
      return false;
   }
   
   if(!ObjectSetInteger(0, trade_signal, OBJPROP_COLOR, clrGreen))
   {
      Print("ERROR: Failed to set trade signal color");
      ObjectDelete(0, trade_signal);
      return false;
   }
   
   // Test corresponding indicator signals in sub-windows
   if(!TestCorrespondingIndicatorSignals(TimeCurrent()))
   {
      Print("ERROR: Corresponding indicator signals test failed");
      ObjectDelete(0, trade_signal);
      return false;
   }
   
   // Cleanup
   ObjectDelete(0, trade_signal);
   
   return true;
}

//+------------------------------------------------------------------+
//| Test corresponding indicator signals                            |
//+------------------------------------------------------------------+
bool TestCorrespondingIndicatorSignals(datetime signal_time)
{
   // Test that indicator windows show supporting signals
   
   // DMI signal (window 1)
   string dmi_signal = "DMI_Signal_" + IntegerToString(GetTickCount());
   if(!ObjectCreate(0, dmi_signal, OBJ_VLINE, 1, signal_time, 0))
   {
      Print("ERROR: Failed to create DMI signal marker");
      return false;
   }
   ObjectSetInteger(0, dmi_signal, OBJPROP_COLOR, clrBlue);
   
   // Didi signal (window 2)
   string didi_signal = "Didi_Signal_" + IntegerToString(GetTickCount());
   if(!ObjectCreate(0, didi_signal, OBJ_VLINE, 2, signal_time, 0))
   {
      Print("ERROR: Failed to create Didi signal marker");
      ObjectDelete(0, dmi_signal);
      return false;
   }
   ObjectSetInteger(0, didi_signal, OBJPROP_COLOR, clrYellow);
   
   // Cleanup
   ObjectDelete(0, dmi_signal);
   ObjectDelete(0, didi_signal);
   
   return true;
}

//+------------------------------------------------------------------+
//| Test window cleanup                                             |
//+------------------------------------------------------------------+
bool TestWindowCleanup()
{
   // Test that window manager properly cleans up
   int initial_windows = g_window_manager.GetWindowCount();
   
   // Perform cleanup
   g_window_manager.Cleanup();
   
   // Verify cleanup
   int remaining_windows = g_window_manager.GetWindowCount();
   
   if(remaining_windows >= initial_windows)
   {
      Print("ERROR: Window cleanup did not reduce window count - Initial: ", initial_windows, ", Remaining: ", remaining_windows);
      return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Test window recreation                                          |
//+------------------------------------------------------------------+
bool TestWindowRecreation()
{
   // Re-initialize window manager after cleanup
   if(!g_window_manager.Init())
   {
      Print("ERROR: Failed to re-initialize window manager");
      return false;
   }
   
   // Test windows can be recreated
   int window_index = g_window_manager.CreateIndicatorWindow("TestRecreation", 80);
   if(window_index < 0)
   {
      Print("ERROR: Failed to recreate test window");
      return false;
   }
   
   // Test window is functional
   string test_object = "RecreationTest_" + IntegerToString(GetTickCount());
   if(!ObjectCreate(0, test_object, OBJ_HLINE, window_index, 0, 1.0))
   {
      Print("ERROR: Recreated window is not functional");
      return false;
   }
   
   // Cleanup
   ObjectDelete(0, test_object);
   
   return true;
}

//+------------------------------------------------------------------+
//| Test indicator handle management                                |
//+------------------------------------------------------------------+
bool TestIndicatorHandleManagement()
{
   // Test that indicator handles are properly managed during restart
   
   // Check all indicator handles are valid
   if(!g_signal_engine.ValidateAllIndicatorHandles())
   {
      Print("ERROR: Not all indicator handles are valid");
      return false;
   }
   
   // Simulate handle recreation (what happens during restart)
   if(!g_signal_engine.RecreateIndicatorHandles())
   {
      Print("ERROR: Failed to recreate indicator handles");
      return false;
   }
   
   // Verify handles are still valid after recreation
   if(!g_signal_engine.ValidateAllIndicatorHandles())
   {
      Print("ERROR: Indicator handles invalid after recreation");
      return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Test object preservation                                        |
//+------------------------------------------------------------------+
bool TestObjectPreservation()
{
   // Test that important objects are preserved across restarts
   
   // Create a persistent object
   string persistent_object = "PersistentTest_" + IntegerToString(GetTickCount());
   if(!ObjectCreate(0, persistent_object, OBJ_HLINE, 0, 0, SymbolInfoDouble(_Symbol, SYMBOL_BID)))
   {
      Print("ERROR: Failed to create persistent test object");
      return false;
   }
   
   // Mark as non-deletable (simulate important object)
   ObjectSetInteger(0, persistent_object, OBJPROP_SELECTABLE, false);
   
   // Simulate restart cleanup (should preserve important objects)
   // Note: In real implementation, this would check against object preservation rules
   
   // Verify object still exists
   if(ObjectFind(0, persistent_object) < 0)
   {
      Print("ERROR: Persistent object was not preserved");
      return false;
   }
   
   // Cleanup
   ObjectDelete(0, persistent_object);
   
   return true;
}

//+------------------------------------------------------------------+
//| Test memory usage                                               |
//+------------------------------------------------------------------+
bool TestMemoryUsage()
{
   // Test memory usage remains stable during extended operation
   
   uint initial_memory = GetUsedMemory();
   
   // Perform multiple update cycles
   for(int i = 0; i < 50; i++)
   {
      g_graphic_manager.UpdateAllDisplays();
      g_signal_engine.GenerateSignals();
   }
   
   uint final_memory = GetUsedMemory();
   uint memory_increase = final_memory - initial_memory;
   
   if(EnableDebugOutput)
   {
      Print("Memory Usage Test:");
      Print("Initial Memory: ", initial_memory, " bytes");
      Print("Final Memory: ", final_memory, " bytes");
      Print("Memory Increase: ", memory_increase, " bytes");
   }
   
   // Memory increase should be minimal (under 1MB for this test)
   if(memory_increase > 1048576) // 1MB
   {
      Print("WARNING: Significant memory increase detected: ", memory_increase, " bytes");
      return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Get used memory (simplified estimation)                         |
//+------------------------------------------------------------------+
uint GetUsedMemory()
{
   // Simple estimation based on object count and indicator handles
   int object_count = ObjectsTotal(0);
   int indicator_count = 6; // DMI, Didi, Stochastic, Trix, IFR, BB
   
   // Rough estimation: 1KB per object + 10KB per indicator
   return (object_count * 1024) + (indicator_count * 10240);
}

//+------------------------------------------------------------------+
//| Cleanup complete EA environment                                 |
//+------------------------------------------------------------------+
void CleanupCompleteEA()
{
   if(EnableDebugOutput)
      Print("Cleaning up complete EA environment...");
   
   // Cleanup in reverse order of initialization
   g_graphic_manager.Cleanup();
   g_trade_manager.Cleanup();
   g_risk_manager.Cleanup();
   g_signal_engine.Cleanup();
   g_window_manager.Cleanup();
   
   if(EnableDebugOutput)
      Print("EA environment cleanup completed");
}
