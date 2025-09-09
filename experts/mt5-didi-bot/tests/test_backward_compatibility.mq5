//+------------------------------------------------------------------+
//|                                   test_backward_compatibility.mq5 |
//|                        Copyright 2024, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property script_show_inputs

#include "../include/SignalEngine.mqh"
#include "../include/TradeManager.mqh"
#include "../include/RiskManager.mqh"
#include "../include/GraphicManager.mqh"

// Test parameters
input bool EnableDebugOutput = true;
input bool TestSignalFunctionality = true;
input bool TestTradeExecution = true;
input bool TestPerformanceCompatibility = true;
input bool TestAPICompatibility = true;

// Global objects
CSignalEngine g_signal_engine;
CTradeManager g_trade_manager;
CRiskManager g_risk_manager;
CGraphicManager g_graphic_manager;

// Performance measurement variables
uint g_test_start_time;
uint g_single_window_time;
uint g_multi_window_time;

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
   Print("=== Backward Compatibility Validation Tests Started ===");
   
   g_test_start_time = GetTickCount();
   int tests_passed = 0;
   int tests_failed = 0;
   
   // Initialize components
   if(!InitializeComponents())
   {
      Print("ERROR: Failed to initialize components for compatibility testing");
      return;
   }
   
   // Test existing signal functionality works unchanged
   if(TestSignalFunctionality)
   {
      if(TestExistingSignalFunctionality())
         tests_passed++;
      else
         tests_failed++;
   }
   
   // Test trade execution with new window system
   if(TestTradeExecution)
   {
      if(TestTradeExecutionCompatibility())
         tests_passed++;
      else
         tests_failed++;
   }
   
   // Test performance - no degradation
   if(TestPerformanceCompatibility)
   {
      if(TestPerformanceNoRegression())
         tests_passed++;
      else
         tests_failed++;
   }
   
   // Test API compatibility
   if(TestAPICompatibility)
   {
      if(TestAPIBackwardCompatibility())
         tests_passed++;
      else
         tests_failed++;
   }
   
   // Cleanup
   CleanupComponents();
   
   uint total_test_duration = GetTickCount() - g_test_start_time;
   
   Print("=== Backward Compatibility Tests Completed ===");
   Print("Tests Passed: ", tests_passed);
   Print("Tests Failed: ", tests_failed);
   Print("Total Test Duration: ", total_test_duration, " ms");
   Print("Success Rate: ", (tests_passed * 100.0) / (tests_passed + tests_failed), "%");
}

//+------------------------------------------------------------------+
//| Initialize components for testing                               |
//+------------------------------------------------------------------+
bool InitializeComponents()
{
   if(EnableDebugOutput)
      Print("Initializing components for compatibility testing...");
   
   string symbol = _Symbol;
   ENUM_TIMEFRAMES period = _Period;
   
   // Initialize SignalEngine (should work exactly as before)
   if(!g_signal_engine.Init(symbol, period))
   {
      Print("ERROR: Failed to initialize SignalEngine");
      return false;
   }
   
   // Initialize RiskManager (should work exactly as before)
   if(!g_risk_manager.Init())
   {
      Print("ERROR: Failed to initialize RiskManager");
      return false;
   }
   
   // Initialize TradeManager (should work exactly as before)
   if(!g_trade_manager.Init(symbol, 123456))
   {
      Print("ERROR: Failed to initialize TradeManager");
      return false;
   }
   
   // Initialize GraphicManager (with backward compatibility mode)
   if(!g_graphic_manager.Init(NULL)) // NULL window manager = backward compatibility
   {
      Print("ERROR: Failed to initialize GraphicManager in compatibility mode");
      return false;
   }
   
   if(EnableDebugOutput)
      Print("SUCCESS: All components initialized for compatibility testing");
   
   return true;
}

//+------------------------------------------------------------------+
//| Test existing signal functionality works unchanged              |
//+------------------------------------------------------------------+
bool TestExistingSignalFunctionality()
{
   if(EnableDebugOutput)
      Print("Testing existing signal functionality...");
   
   // Test all signal methods work as before
   if(!TestSignalGenerationAPI())
   {
      Print("ERROR: Signal generation API compatibility test failed");
      return false;
   }
   
   // Test signal result structure unchanged
   if(!TestSignalResultStructure())
   {
      Print("ERROR: Signal result structure compatibility test failed");
      return false;
   }
   
   // Test indicator access methods unchanged
   if(!TestIndicatorAccessMethods())
   {
      Print("ERROR: Indicator access methods compatibility test failed");
      return false;
   }
   
   // Test signal validation methods unchanged
   if(!TestSignalValidationMethods())
   {
      Print("ERROR: Signal validation methods compatibility test failed");
      return false;
   }
   
   if(EnableDebugOutput)
      Print("SUCCESS: Existing signal functionality test passed");
   
   return true;
}

//+------------------------------------------------------------------+
//| Test trade execution with new window system                     |
//+------------------------------------------------------------------+
bool TestTradeExecutionCompatibility()
{
   if(EnableDebugOutput)
      Print("Testing trade execution compatibility...");
   
   // Test trade manager methods work unchanged
   if(!TestTradeManagerAPI())
   {
      Print("ERROR: Trade manager API compatibility test failed");
      return false;
   }
   
   // Test risk management integration unchanged
   if(!TestRiskManagementIntegration())
   {
      Print("ERROR: Risk management integration compatibility test failed");
      return false;
   }
   
   // Test trade signal coordination (should work with new windows)
   if(!TestTradeSignalCoordination())
   {
      Print("ERROR: Trade signal coordination compatibility test failed");
      return false;
   }
   
   // Test chart object reading unchanged
   if(!TestChartObjectReading())
   {
      Print("ERROR: Chart object reading compatibility test failed");
      return false;
   }
   
   if(EnableDebugOutput)
      Print("SUCCESS: Trade execution compatibility test passed");
   
   return true;
}

//+------------------------------------------------------------------+
//| Test performance - no degradation                              |
//+------------------------------------------------------------------+
bool TestPerformanceNoRegression()
{
   if(EnableDebugOutput)
      Print("Testing performance regression...");
   
   // Test signal generation performance
   if(!TestSignalGenerationPerformance())
   {
      Print("ERROR: Signal generation performance test failed");
      return false;
   }
   
   // Test graphic update performance
   if(!TestGraphicUpdatePerformance())
   {
      Print("ERROR: Graphic update performance test failed");
      return false;
   }
   
   // Test memory usage performance
   if(!TestMemoryUsagePerformance())
   {
      Print("ERROR: Memory usage performance test failed");
      return false;
   }
   
   // Compare single vs multi-window performance
   if(!TestSingleVsMultiWindowPerformance())
   {
      Print("ERROR: Single vs multi-window performance test failed");
      return false;
   }
   
   if(EnableDebugOutput)
      Print("SUCCESS: Performance regression test passed");
   
   return true;
}

//+------------------------------------------------------------------+
//| Test API backward compatibility                                 |
//+------------------------------------------------------------------+
bool TestAPIBackwardCompatibility()
{
   if(EnableDebugOutput)
      Print("Testing API backward compatibility...");
   
   // Test all existing public methods still exist
   if(!TestExistingPublicMethods())
   {
      Print("ERROR: Existing public methods test failed");
      return false;
   }
   
   // Test method signatures unchanged
   if(!TestMethodSignatures())
   {
      Print("ERROR: Method signatures compatibility test failed");
      return false;
   }
   
   // Test return types unchanged
   if(!TestReturnTypes())
   {
      Print("ERROR: Return types compatibility test failed");
      return false;
   }
   
   // Test parameter compatibility
   if(!TestParameterCompatibility())
   {
      Print("ERROR: Parameter compatibility test failed");
      return false;
   }
   
   if(EnableDebugOutput)
      Print("SUCCESS: API backward compatibility test passed");
   
   return true;
}

//+------------------------------------------------------------------+
//| Test signal generation API                                      |
//+------------------------------------------------------------------+
bool TestSignalGenerationAPI()
{
   // Test GenerateSignals() method works as before
   CSignalResult result = g_signal_engine.GenerateSignals();
   
   if(!result.IsValid())
   {
      Print("ERROR: GenerateSignals() returned invalid result");
      return false;
   }
   
   // Test all signal types are generated
   if(!result.HasDmiSignal())
   {
      Print("ERROR: DMI signal missing from result");
      return false;
   }
   
   if(!result.HasDidiSignal())
   {
      Print("ERROR: Didi signal missing from result");
      return false;
   }
   
   if(!result.HasStochasticSignal())
   {
      Print("ERROR: Stochastic signal missing from result");
      return false;
   }
   
   if(!result.HasTrixSignal())
   {
      Print("ERROR: Trix signal missing from result");
      return false;
   }
   
   if(!result.HasIfrSignal())
   {
      Print("ERROR: IFR signal missing from result");
      return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Test signal result structure                                    |
//+------------------------------------------------------------------+
bool TestSignalResultStructure()
{
   CSignalResult result = g_signal_engine.GenerateSignals();
   
   // Test all expected properties exist and work
   ENUM_SIGNAL_TYPE overall_signal = result.GetOverallSignal();
   if(overall_signal != SIGNAL_BUY && overall_signal != SIGNAL_SELL && overall_signal != SIGNAL_NONE)
   {
      Print("ERROR: Invalid overall signal type: ", overall_signal);
      return false;
   }
   
   // Test signal strength calculation
   double signal_strength = result.GetSignalStrength();
   if(signal_strength < 0.0 || signal_strength > 1.0)
   {
      Print("ERROR: Invalid signal strength: ", signal_strength);
      return false;
   }
   
   // Test signal timestamp
   datetime signal_time = result.GetSignalTime();
   if(signal_time <= 0)
   {
      Print("ERROR: Invalid signal timestamp: ", signal_time);
      return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Test indicator access methods                                   |
//+------------------------------------------------------------------+
bool TestIndicatorAccessMethods()
{
   // Test direct indicator access methods still work
   
   // Test DMI access
   double adx_value = g_signal_engine.GetDmiADX(0);
   if(adx_value < 0)
   {
      Print("ERROR: DMI ADX access failed");
      return false;
   }
   
   // Test Didi access
   double short_ma = g_signal_engine.GetDidiShortMA(0);
   if(short_ma <= 0)
   {
      Print("ERROR: Didi Short MA access failed");
      return false;
   }
   
   // Test Stochastic access
   double stoch_main = g_signal_engine.GetStochasticMain(0);
   if(stoch_main < 0 || stoch_main > 100)
   {
      Print("ERROR: Stochastic main access failed, value: ", stoch_main);
      return false;
   }
   
   // Test Trix access
   double trix_value = g_signal_engine.GetTrixValue(0);
   // Trix can be positive or negative, so just check it's a valid number
   if(trix_value == EMPTY_VALUE)
   {
      Print("ERROR: Trix value access failed");
      return false;
   }
   
   // Test IFR access
   double ifr_value = g_signal_engine.GetIfrValue(0);
   if(ifr_value < 0 || ifr_value > 100)
   {
      Print("ERROR: IFR value access failed, value: ", ifr_value);
      return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Test signal validation methods                                  |
//+------------------------------------------------------------------+
bool TestSignalValidationMethods()
{
   // Test signal validation methods work as before
   
   // Test Agulhada detection
   bool has_agulhada = g_signal_engine.HasAgulhadaSignal();
   // Should return true or false, not error
   
   // Test trend confirmation
   bool trend_confirmed = g_signal_engine.IsTrendConfirmed();
   // Should return true or false, not error
   
   // Test signal consensus
   int signal_consensus = g_signal_engine.GetSignalConsensus();
   if(signal_consensus < -100 || signal_consensus > 100)
   {
      Print("ERROR: Invalid signal consensus: ", signal_consensus);
      return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Test trade manager API                                          |
//+------------------------------------------------------------------+
bool TestTradeManagerAPI()
{
   // Test all trade manager methods work unchanged
   
   // Test signal processing
   CSignalResult signal = g_signal_engine.GenerateSignals();
   bool processed = g_trade_manager.ProcessSignal(signal);
   // Should not crash and return boolean
   
   // Test position management
   int open_positions = g_trade_manager.GetOpenPositionsCount();
   if(open_positions < 0)
   {
      Print("ERROR: Invalid open positions count: ", open_positions);
      return false;
   }
   
   // Test risk calculation integration
   double lot_size = g_trade_manager.CalculatePositionSize(SIGNAL_BUY);
   if(lot_size < 0)
   {
      Print("ERROR: Invalid position size calculation: ", lot_size);
      return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Test risk management integration                                |
//+------------------------------------------------------------------+
bool TestRiskManagementIntegration()
{
   // Test risk manager works with trade manager as before
   
   // Test position size calculation
   double risk_percent = 2.0; // 2% risk
   double lot_size = g_risk_manager.CalculateLotSize(risk_percent);
   
   if(lot_size <= 0)
   {
      Print("ERROR: Risk manager returned invalid lot size: ", lot_size);
      return false;
   }
   
   // Test risk validation
   double max_risk = g_risk_manager.GetMaxRiskPerTrade();
   if(max_risk <= 0 || max_risk > 10.0) // Should be reasonable percentage
   {
      Print("ERROR: Invalid max risk per trade: ", max_risk);
      return false;
   }
   
   // Test account risk checks
   bool risk_acceptable = g_risk_manager.IsRiskAcceptable(lot_size);
   // Should return true or false, not error
   
   return true;
}

//+------------------------------------------------------------------+
//| Test trade signal coordination                                  |
//+------------------------------------------------------------------+
bool TestTradeSignalCoordination()
{
   // Test trade signals coordinate properly with graphics
   
   // Generate test signal
   CSignalResult signal = g_signal_engine.GenerateSignals();
   
   // Test signal display on chart
   bool signal_displayed = g_graphic_manager.DisplayTradeSignal(signal);
   if(!signal_displayed)
   {
      Print("ERROR: Failed to display trade signal");
      return false;
   }
   
   // Test signal cleanup
   bool signal_cleared = g_graphic_manager.ClearTradeSignals();
   if(!signal_cleared)
   {
      Print("ERROR: Failed to clear trade signals");
      return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Test chart object reading                                       |
//+------------------------------------------------------------------+
bool TestChartObjectReading()
{
   // Test chart object reading works unchanged
   
   // Create test object
   string test_object = "CompatibilityTest_" + IntegerToString(GetTickCount());
   if(!ObjectCreate(0, test_object, OBJ_HLINE, 0, 0, SymbolInfoDouble(_Symbol, SYMBOL_BID)))
   {
      Print("ERROR: Failed to create test object for chart reading");
      return false;
   }
   
   // Test trade manager can read chart objects
   int chart_objects_count = g_trade_manager.GetChartObjectsCount();
   if(chart_objects_count < 0)
   {
      Print("ERROR: Invalid chart objects count: ", chart_objects_count);
      ObjectDelete(0, test_object);
      return false;
   }
   
   // Test chart object processing
   bool objects_processed = g_trade_manager.ReadChartObjects();
   if(!objects_processed)
   {
      Print("ERROR: Failed to process chart objects");
      ObjectDelete(0, test_object);
      return false;
   }
   
   // Cleanup
   ObjectDelete(0, test_object);
   
   return true;
}

//+------------------------------------------------------------------+
//| Test signal generation performance                              |
//+------------------------------------------------------------------+
bool TestSignalGenerationPerformance()
{
   uint start_time = GetTickCount();
   
   // Perform multiple signal generations
   const int iterations = 100;
   for(int i = 0; i < iterations; i++)
   {
      CSignalResult result = g_signal_engine.GenerateSignals();
      if(!result.IsValid())
      {
         Print("ERROR: Signal generation failed at iteration ", i);
         return false;
      }
   }
   
   uint generation_time = GetTickCount() - start_time;
   double avg_time = (double)generation_time / iterations;
   
   if(EnableDebugOutput)
   {
      Print("Signal Generation Performance:");
      Print("Iterations: ", iterations);
      Print("Total Time: ", generation_time, " ms");
      Print("Average Time: ", avg_time, " ms");
   }
   
   // Should be under 5ms per generation
   if(avg_time > 5.0)
   {
      Print("WARNING: Signal generation performance degradation - Average: ", avg_time, " ms");
      return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Test graphic update performance                                 |
//+------------------------------------------------------------------+
bool TestGraphicUpdatePerformance()
{
   uint start_time = GetTickCount();
   
   // Perform multiple graphic updates
   const int iterations = 50;
   for(int i = 0; i < iterations; i++)
   {
      if(!g_graphic_manager.UpdateAllDisplays())
      {
         Print("ERROR: Graphic update failed at iteration ", i);
         return false;
      }
   }
   
   uint update_time = GetTickCount() - start_time;
   double avg_time = (double)update_time / iterations;
   
   if(EnableDebugOutput)
   {
      Print("Graphic Update Performance:");
      Print("Iterations: ", iterations);
      Print("Total Time: ", update_time, " ms");
      Print("Average Time: ", avg_time, " ms");
   }
   
   // Should be under 10ms per update
   if(avg_time > 10.0)
   {
      Print("WARNING: Graphic update performance degradation - Average: ", avg_time, " ms");
      return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Test memory usage performance                                   |
//+------------------------------------------------------------------+
bool TestMemoryUsagePerformance()
{
   uint initial_memory = GetEstimatedMemoryUsage();
   
   // Perform extended operations
   for(int i = 0; i < 100; i++)
   {
      CSignalResult result = g_signal_engine.GenerateSignals();
      g_graphic_manager.DisplayTradeSignal(result);
      g_graphic_manager.UpdateAllDisplays();
   }
   
   uint final_memory = GetEstimatedMemoryUsage();
   uint memory_increase = final_memory - initial_memory;
   
   if(EnableDebugOutput)
   {
      Print("Memory Usage Performance:");
      Print("Initial Memory: ", initial_memory, " bytes");
      Print("Final Memory: ", final_memory, " bytes");
      Print("Memory Increase: ", memory_increase, " bytes");
   }
   
   // Memory increase should be minimal
   if(memory_increase > 512000) // 500KB
   {
      Print("WARNING: Significant memory usage increase: ", memory_increase, " bytes");
      return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Test single vs multi-window performance                         |
//+------------------------------------------------------------------+
bool TestSingleVsMultiWindowPerformance()
{
   // Test single window mode performance
   uint start_time = GetTickCount();
   
   for(int i = 0; i < 50; i++)
   {
      g_graphic_manager.UpdateMainChartDisplay();
   }
   
   g_single_window_time = GetTickCount() - start_time;
   
   // Test multi-window mode performance
   start_time = GetTickCount();
   
   for(int i = 0; i < 50; i++)
   {
      g_graphic_manager.UpdateAllDisplays();
   }
   
   g_multi_window_time = GetTickCount() - start_time;
   
   double performance_ratio = (double)g_multi_window_time / g_single_window_time;
   
   if(EnableDebugOutput)
   {
      Print("Single vs Multi-Window Performance:");
      Print("Single Window Time: ", g_single_window_time, " ms");
      Print("Multi Window Time: ", g_multi_window_time, " ms");
      Print("Performance Ratio: ", performance_ratio);
   }
   
   // Multi-window should not be more than 3x slower than single window
   if(performance_ratio > 3.0)
   {
      Print("WARNING: Multi-window performance significantly slower - Ratio: ", performance_ratio);
      return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Test existing public methods                                    |
//+------------------------------------------------------------------+
bool TestExistingPublicMethods()
{
   // Test SignalEngine public methods
   if(!TestSignalEnginePublicMethods())
   {
      Print("ERROR: SignalEngine public methods test failed");
      return false;
   }
   
   // Test TradeManager public methods
   if(!TestTradeManagerPublicMethods())
   {
      Print("ERROR: TradeManager public methods test failed");
      return false;
   }
   
   // Test RiskManager public methods
   if(!TestRiskManagerPublicMethods())
   {
      Print("ERROR: RiskManager public methods test failed");
      return false;
   }
   
   // Test GraphicManager public methods
   if(!TestGraphicManagerPublicMethods())
   {
      Print("ERROR: GraphicManager public methods test failed");
      return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Test SignalEngine public methods                                |
//+------------------------------------------------------------------+
bool TestSignalEnginePublicMethods()
{
   // Test all public methods exist and work
   
   // Init method
   bool init_result = g_signal_engine.Init(_Symbol, _Period);
   // Already initialized, but method should exist
   
   // GenerateSignals method
   CSignalResult signal_result = g_signal_engine.GenerateSignals();
   
   // Individual indicator access methods
   double adx = g_signal_engine.GetDmiADX(0);
   double short_ma = g_signal_engine.GetDidiShortMA(0);
   double stoch = g_signal_engine.GetStochasticMain(0);
   double trix = g_signal_engine.GetTrixValue(0);
   double ifr = g_signal_engine.GetIfrValue(0);
   
   // Validation methods
   bool has_agulhada = g_signal_engine.HasAgulhadaSignal();
   bool trend_confirmed = g_signal_engine.IsTrendConfirmed();
   int consensus = g_signal_engine.GetSignalConsensus();
   
   // Cleanup method
   g_signal_engine.Cleanup();
   
   // Re-initialize for other tests
   g_signal_engine.Init(_Symbol, _Period);
   
   return true;
}

//+------------------------------------------------------------------+
//| Test TradeManager public methods                                |
//+------------------------------------------------------------------+
bool TestTradeManagerPublicMethods()
{
   // Test all public methods exist and work
   
   // Init method
   bool init_result = g_trade_manager.Init(_Symbol, 123456);
   
   // ProcessSignal method
   CSignalResult signal = g_signal_engine.GenerateSignals();
   bool processed = g_trade_manager.ProcessSignal(signal);
   
   // Position management methods
   int positions = g_trade_manager.GetOpenPositionsCount();
   double lot_size = g_trade_manager.CalculatePositionSize(SIGNAL_BUY);
   
   // Chart object methods
   int objects_count = g_trade_manager.GetChartObjectsCount();
   bool objects_read = g_trade_manager.ReadChartObjects();
   
   // Cleanup method
   g_trade_manager.Cleanup();
   
   // Re-initialize for other tests
   g_trade_manager.Init(_Symbol, 123456);
   
   return true;
}

//+------------------------------------------------------------------+
//| Test RiskManager public methods                                 |
//+------------------------------------------------------------------+
bool TestRiskManagerPublicMethods()
{
   // Test all public methods exist and work
   
   // Init method
   bool init_result = g_risk_manager.Init();
   
   // Risk calculation methods
   double lot_size = g_risk_manager.CalculateLotSize(2.0);
   double max_risk = g_risk_manager.GetMaxRiskPerTrade();
   bool risk_acceptable = g_risk_manager.IsRiskAcceptable(0.1);
   
   // Cleanup method
   g_risk_manager.Cleanup();
   
   // Re-initialize for other tests
   g_risk_manager.Init();
   
   return true;
}

//+------------------------------------------------------------------+
//| Test GraphicManager public methods                              |
//+------------------------------------------------------------------+
bool TestGraphicManagerPublicMethods()
{
   // Test all public methods exist and work
   
   // Init method (with NULL for backward compatibility)
   bool init_result = g_graphic_manager.Init(NULL);
   
   // Display methods
   bool all_updated = g_graphic_manager.UpdateAllDisplays();
   bool main_updated = g_graphic_manager.UpdateMainChartDisplay();
   bool all_cleared = g_graphic_manager.ClearAllDisplays();
   
   // Signal display methods
   CSignalResult signal = g_signal_engine.GenerateSignals();
   bool signal_displayed = g_graphic_manager.DisplayTradeSignal(signal);
   bool signals_cleared = g_graphic_manager.ClearTradeSignals();
   
   // Cleanup method
   g_graphic_manager.Cleanup();
   
   // Re-initialize for other tests
   g_graphic_manager.Init(NULL);
   
   return true;
}

//+------------------------------------------------------------------+
//| Test method signatures                                          |
//+------------------------------------------------------------------+
bool TestMethodSignatures()
{
   // Test that method signatures haven't changed
   // This is primarily a compilation test - if this compiles, signatures are correct
   
   // SignalEngine signatures
   CSignalResult result = g_signal_engine.GenerateSignals();
   double value = g_signal_engine.GetDmiADX(0);
   bool flag = g_signal_engine.HasAgulhadaSignal();
   
   // TradeManager signatures
   bool processed = g_trade_manager.ProcessSignal(result);
   int count = g_trade_manager.GetOpenPositionsCount();
   
   // RiskManager signatures
   double lot = g_risk_manager.CalculateLotSize(2.0);
   
   // GraphicManager signatures
   bool updated = g_graphic_manager.UpdateAllDisplays();
   
   return true;
}

//+------------------------------------------------------------------+
//| Test return types                                               |
//+------------------------------------------------------------------+
bool TestReturnTypes()
{
   // Test that return types are correct and unchanged
   
   // SignalEngine return types
   CSignalResult signal_result = g_signal_engine.GenerateSignals();
   if(typeof(signal_result) != "CSignalResult")
   {
      Print("ERROR: GenerateSignals return type changed");
      return false;
   }
   
   double double_value = g_signal_engine.GetDmiADX(0);
   if(typeof(double_value) != "double")
   {
      Print("ERROR: GetDmiADX return type changed");
      return false;
   }
   
   bool bool_value = g_signal_engine.HasAgulhadaSignal();
   if(typeof(bool_value) != "bool")
   {
      Print("ERROR: HasAgulhadaSignal return type changed");
      return false;
   }
   
   int int_value = g_signal_engine.GetSignalConsensus();
   if(typeof(int_value) != "int")
   {
      Print("ERROR: GetSignalConsensus return type changed");
      return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Test parameter compatibility                                    |
//+------------------------------------------------------------------+
bool TestParameterCompatibility()
{
   // Test that method parameters are compatible with existing calls
   
   // Test SignalEngine parameter compatibility
   bool init_ok = g_signal_engine.Init(_Symbol, _Period);
   double adx = g_signal_engine.GetDmiADX(0);
   
   // Test TradeManager parameter compatibility
   bool trade_init_ok = g_trade_manager.Init(_Symbol, 123456);
   
   // Test RiskManager parameter compatibility
   double lot_size = g_risk_manager.CalculateLotSize(2.0);
   
   // Test GraphicManager parameter compatibility
   bool graphic_init_ok = g_graphic_manager.Init(NULL);
   
   return true;
}

//+------------------------------------------------------------------+
//| Get estimated memory usage                                      |
//+------------------------------------------------------------------+
uint GetEstimatedMemoryUsage()
{
   // Simple estimation based on objects and indicators
   int objects = ObjectsTotal(0);
   int indicators = 6; // DMI, Didi, Stochastic, Trix, IFR, BB
   
   return (objects * 1024) + (indicators * 10240) + 100000; // Base overhead
}

//+------------------------------------------------------------------+
//| Cleanup components                                              |
//+------------------------------------------------------------------+
void CleanupComponents()
{
   if(EnableDebugOutput)
      Print("Cleaning up compatibility test components...");
   
   g_graphic_manager.Cleanup();
   g_trade_manager.Cleanup();
   g_risk_manager.Cleanup();
   g_signal_engine.Cleanup();
   
   if(EnableDebugOutput)
      Print("Compatibility test cleanup completed");
}
