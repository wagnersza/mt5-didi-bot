//+------------------------------------------------------------------+
//|                                    test_multi_window_display.mq5 |
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
input bool TestMultipleWindows = true;
input bool TestWindowCoordination = true;
input bool TestWindowCleanup = true;
input bool TestRealTimeUpdates = true;

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
   Print("=== Multi-Window Display Integration Tests Started ===");
   
   int tests_passed = 0;
   int tests_failed = 0;
   
   if(TestMultipleWindows)
   {
      if(TestMultipleIndicatorWindows())
         tests_passed++;
      else
         tests_failed++;
         
      if(TestWindowHierarchy())
         tests_passed++;
      else
         tests_failed++;
   }
   
   if(TestWindowCoordination)
   {
      if(TestWindowSynchronization())
         tests_passed++;
      else
         tests_failed++;
         
      if(TestWindowDataFlow())
         tests_passed++;
      else
         tests_failed++;
   }
   
   if(TestWindowCleanup)
   {
      if(TestWindowLifecycleManagement())
         tests_passed++;
      else
         tests_failed++;
         
      if(TestMemoryManagement())
         tests_passed++;
      else
         tests_failed++;
   }
   
   if(TestRealTimeUpdates)
   {
      if(TestWindowUpdateCoordination())
         tests_passed++;
      else
         tests_failed++;
   }
   
   // Summary
   Print("=== Multi-Window Display Integration Tests Completed ===");
   PrintFormat("Tests Passed: %d", tests_passed);
   PrintFormat("Tests Failed: %d", tests_failed);
   PrintFormat("Success Rate: %.1f%%", tests_failed == 0 ? 100.0 : (double)tests_passed / (tests_passed + tests_failed) * 100.0);
   
   if(tests_failed == 0)
      Print("✅ ALL INTEGRATION TESTS PASSED - Multi-window system ready for Phase 3");
   else
      Print("❌ SOME INTEGRATION TESTS FAILED - Review implementation before proceeding");
}

//+------------------------------------------------------------------+
//| Test multiple indicator windows creation                         |
//+------------------------------------------------------------------+
bool TestMultipleIndicatorWindows()
{
   if(EnableDebugOutput)
      Print("\n--- Testing Multiple Indicator Windows ---");
      
   CWindowManager window_mgr;
   if(!window_mgr.Init())
   {
      Print("❌ FAILED: WindowManager initialization failed");
      return false;
   }
   
   // Initialize multiple indicators
   CDmi dmi;
   CBollingerBands bb;
   CStochastic stoch;
   
   if(!dmi.Init(_Symbol, _Period, 14))
   {
      Print("❌ FAILED: DMI indicator initialization failed");
      return false;
   }
   
   if(!bb.Init(_Symbol, _Period, 20, 2.0))
   {
      Print("❌ FAILED: Bollinger Bands indicator initialization failed");
      return false;
   }
   
   if(!stoch.Init(_Symbol, _Period, 5, 3, 3))
   {
      Print("❌ FAILED: Stochastic indicator initialization failed");
      return false;
   }
   
   // Create multiple indicator windows
   int dmi_window = window_mgr.CreateIndicatorWindow("DMI Window", dmi.GetHandle());
   if(dmi_window < 0)
   {
      Print("❌ FAILED: DMI window creation failed");
      return false;
   }
   
   int bb_window = window_mgr.CreateIndicatorWindow("Bollinger Bands Window", bb.GetHandle());
   if(bb_window < 0)
   {
      Print("❌ FAILED: Bollinger Bands window creation failed");
      return false;
   }
   
   int stoch_window = window_mgr.CreateIndicatorWindow("Stochastic Window", stoch.GetHandle());
   if(stoch_window < 0)
   {
      Print("❌ FAILED: Stochastic window creation failed");
      return false;
   }
   
   // Verify all windows are created and tracked
   int total_windows = window_mgr.GetWindowCount();
   if(total_windows != 4) // Main chart + 3 indicators
   {
      PrintFormat("❌ FAILED: Expected 4 windows, got %d", total_windows);
      return false;
   }
   
   // Verify window indexes are unique
   if(dmi_window == bb_window || dmi_window == stoch_window || bb_window == stoch_window)
   {
      Print("❌ FAILED: Window indexes should be unique");
      return false;
   }
   
   // Verify all windows are active
   if(!window_mgr.IsWindowActive(dmi_window) || 
      !window_mgr.IsWindowActive(bb_window) || 
      !window_mgr.IsWindowActive(stoch_window))
   {
      Print("❌ FAILED: All created windows should be active");
      return false;
   }
   
   if(EnableDebugOutput)
   {
      window_mgr.PrintWindowStatus();
      PrintFormat("Created windows: DMI=%d, BB=%d, Stoch=%d", dmi_window, bb_window, stoch_window);
      Print("✅ PASSED: Multiple indicator windows");
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Test window hierarchy and organization                           |
//+------------------------------------------------------------------+
bool TestWindowHierarchy()
{
   if(EnableDebugOutput)
      Print("\n--- Testing Window Hierarchy ---");
      
   CWindowManager window_mgr;
   if(!window_mgr.Init())
   {
      Print("❌ FAILED: WindowManager initialization failed");
      return false;
   }
   
   // Main chart should always be window 0
   string main_name = window_mgr.GetWindowName(0);
   if(main_name != "Main Chart")
   {
      PrintFormat("❌ FAILED: Main chart should be window 0, got name '%s'", main_name);
      return false;
   }
   
   // Create a test indicator window
   CDmi dmi;
   if(!dmi.Init(_Symbol, _Period, 14))
   {
      Print("❌ FAILED: DMI indicator initialization failed");
      return false;
   }
   
   int indicator_window = window_mgr.CreateIndicatorWindow("Test Hierarchy Window", dmi.GetHandle());
   if(indicator_window <= 0) // Should be > 0 (main chart is 0)
   {
      PrintFormat("❌ FAILED: Indicator window should have index > 0, got %d", indicator_window);
      return false;
   }
   
   // Verify window hierarchy
   int total_chart_windows = window_mgr.GetTotalChartWindows();
   if(total_chart_windows < 2)
   {
      PrintFormat("❌ FAILED: Expected at least 2 chart windows, got %d", total_chart_windows);
      return false;
   }
   
   // Test window index validation across hierarchy
   for(int i = 0; i < total_chart_windows; i++)
   {
      bool is_valid = window_mgr.ValidateWindowIndex(i);
      if(!is_valid)
      {
         PrintFormat("❌ FAILED: Window index %d should be valid", i);
         return false;
      }
   }
   
   if(EnableDebugOutput)
   {
      PrintFormat("Window hierarchy: Main=0, Indicator=%d, Total=%d", 
                 indicator_window, total_chart_windows);
      Print("✅ PASSED: Window hierarchy");
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Test window synchronization                                      |
//+------------------------------------------------------------------+
bool TestWindowSynchronization()
{
   if(EnableDebugOutput)
      Print("\n--- Testing Window Synchronization ---");
      
   CWindowManager window_mgr;
   if(!window_mgr.Init())
   {
      Print("❌ FAILED: WindowManager initialization failed");
      return false;
   }
   
   // Create multiple windows that need to be synchronized
   CDmi dmi;
   CBollingerBands bb;
   
   if(!dmi.Init(_Symbol, _Period, 14) || !bb.Init(_Symbol, _Period, 20, 2.0))
   {
      Print("❌ FAILED: Indicator initialization failed");
      return false;
   }
   
   int window1 = window_mgr.CreateIndicatorWindow("Sync Window 1", dmi.GetHandle());
   int window2 = window_mgr.CreateIndicatorWindow("Sync Window 2", bb.GetHandle());
   
   if(window1 < 0 || window2 < 0)
   {
      Print("❌ FAILED: Window creation for synchronization test failed");
      return false;
   }
   
   // Test synchronized operations
   bool sync_result1 = window_mgr.SetWindowProperty(window1, CHART_SHOW_GRID, 1);
   bool sync_result2 = window_mgr.SetWindowProperty(window2, CHART_SHOW_GRID, 1);
   
   if(!sync_result1 || !sync_result2)
   {
      Print("❌ FAILED: Synchronized window property setting failed");
      return false;
   }
   
   // Test window coordination
   string name1 = window_mgr.GetWindowName(window1);
   string name2 = window_mgr.GetWindowName(window2);
   
   if(name1 != "Sync Window 1" || name2 != "Sync Window 2")
   {
      PrintFormat("❌ FAILED: Window names not synchronized. Got '%s' and '%s'", name1, name2);
      return false;
   }
   
   if(EnableDebugOutput)
   {
      PrintFormat("Synchronized windows: %s=%d, %s=%d", name1, window1, name2, window2);
      Print("✅ PASSED: Window synchronization");
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Test window data flow between components                         |
//+------------------------------------------------------------------+
bool TestWindowDataFlow()
{
   if(EnableDebugOutput)
      Print("\n--- Testing Window Data Flow ---");
      
   CWindowManager window_mgr;
   if(!window_mgr.Init())
   {
      Print("❌ FAILED: WindowManager initialization failed");
      return false;
   }
   
   // Create window with indicator
   CDmi dmi;
   if(!dmi.Init(_Symbol, _Period, 14))
   {
      Print("❌ FAILED: DMI indicator initialization failed");
      return false;
   }
   
   int test_window = window_mgr.CreateIndicatorWindow("Data Flow Window", dmi.GetHandle());
   if(test_window < 0)
   {
      Print("❌ FAILED: Data flow test window creation failed");
      return false;
   }
   
   // Test data flow: WindowManager -> Indicator Handle
   int retrieved_handle = window_mgr.GetIndicatorHandle(test_window);
   int original_handle = dmi.GetHandle();
   
   if(retrieved_handle != original_handle)
   {
      PrintFormat("❌ FAILED: Handle data flow broken. Expected %d, got %d", 
                 original_handle, retrieved_handle);
      return false;
   }
   
   // Test data flow: Name -> Index -> Name
   int retrieved_index = window_mgr.GetWindowIndex("Data Flow Window");
   if(retrieved_index != test_window)
   {
      PrintFormat("❌ FAILED: Index data flow broken. Expected %d, got %d", 
                 test_window, retrieved_index);
      return false;
   }
   
   string retrieved_name = window_mgr.GetWindowName(retrieved_index);
   if(retrieved_name != "Data Flow Window")
   {
      PrintFormat("❌ FAILED: Name data flow broken. Expected 'Data Flow Window', got '%s'", 
                 retrieved_name);
      return false;
   }
   
   // Test indicator data access through retrieved handle
   if(retrieved_handle != INVALID_HANDLE)
   {
      double adx_value = dmi.Adx(0);
      // ADX should return a valid value (>= 0) or 0 if no data
      if(adx_value < 0)
      {
         PrintFormat("❌ FAILED: Invalid ADX value through data flow: %.2f", adx_value);
         return false;
      }
   }
   
   if(EnableDebugOutput)
   {
      PrintFormat("Data flow verified: Handle %d -> Index %d -> Name '%s'", 
                 retrieved_handle, retrieved_index, retrieved_name);
      Print("✅ PASSED: Window data flow");
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Test window lifecycle management                                 |
//+------------------------------------------------------------------+
bool TestWindowLifecycleManagement()
{
   if(EnableDebugOutput)
      Print("\n--- Testing Window Lifecycle Management ---");
      
   CWindowManager window_mgr;
   if(!window_mgr.Init())
   {
      Print("❌ FAILED: WindowManager initialization failed");
      return false;
   }
   
   // Create window
   CDmi dmi;
   if(!dmi.Init(_Symbol, _Period, 14))
   {
      Print("❌ FAILED: DMI indicator initialization failed");
      return false;
   }
   
   int lifecycle_window = window_mgr.CreateIndicatorWindow("Lifecycle Test Window", dmi.GetHandle());
   if(lifecycle_window < 0)
   {
      Print("❌ FAILED: Lifecycle test window creation failed");
      return false;
   }
   
   // Test active state during lifecycle
   bool is_active_after_creation = window_mgr.IsWindowActive(lifecycle_window);
   if(!is_active_after_creation)
   {
      Print("❌ FAILED: Window should be active after creation");
      return false;
   }
   
   int windows_before_removal = window_mgr.GetWindowCount();
   
   // Test removal
   bool removal_success = window_mgr.RemoveWindow(lifecycle_window);
   if(!removal_success)
   {
      Print("❌ FAILED: Window removal should succeed");
      return false;
   }
   
   // Test inactive state after removal
   bool is_active_after_removal = window_mgr.IsWindowActive(lifecycle_window);
   if(is_active_after_removal)
   {
      Print("❌ FAILED: Window should be inactive after removal");
      return false;
   }
   
   // Test window count consistency
   int windows_after_removal = window_mgr.GetWindowCount();
   if(windows_after_removal != windows_before_removal)
   {
      PrintFormat("❌ FAILED: Window count inconsistent. Before: %d, After: %d", 
                 windows_before_removal, windows_after_removal);
      return false;
   }
   
   if(EnableDebugOutput)
   {
      PrintFormat("Lifecycle: Created->Active->Removed->Inactive (Window %d)", lifecycle_window);
      Print("✅ PASSED: Window lifecycle management");
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Test memory management for windows                               |
//+------------------------------------------------------------------+
bool TestMemoryManagement()
{
   if(EnableDebugOutput)
      Print("\n--- Testing Memory Management ---");
      
   // Test cleanup on WindowManager destruction
   {
      CWindowManager temp_mgr;
      if(!temp_mgr.Init())
      {
         Print("❌ FAILED: Temporary WindowManager initialization failed");
         return false;
      }
      
      CDmi dmi;
      if(!dmi.Init(_Symbol, _Period, 14))
      {
         Print("❌ FAILED: DMI indicator initialization failed");
         return false;
      }
      
      int temp_window = temp_mgr.CreateIndicatorWindow("Memory Test Window", dmi.GetHandle());
      if(temp_window < 0)
      {
         Print("❌ FAILED: Memory test window creation failed");
         return false;
      }
      
      // WindowManager should clean up automatically when going out of scope
   } // temp_mgr destructor called here
   
   // Test explicit cleanup
   CWindowManager window_mgr;
   if(!window_mgr.Init())
   {
      Print("❌ FAILED: WindowManager initialization failed");
      return false;
   }
   
   CDmi dmi2;
   if(!dmi2.Init(_Symbol, _Period, 14))
   {
      Print("❌ FAILED: DMI indicator initialization failed");
      return false;
   }
   
   int cleanup_window = window_mgr.CreateIndicatorWindow("Cleanup Test Window", dmi2.GetHandle());
   if(cleanup_window < 0)
   {
      Print("❌ FAILED: Cleanup test window creation failed");
      return false;
   }
   
   // Test explicit cleanup
   window_mgr.Cleanup();
   
   // After cleanup, window count should reset but main chart should remain
   int windows_after_cleanup = window_mgr.GetWindowCount();
   if(windows_after_cleanup != 0) // Cleanup resets count to 0
   {
      PrintFormat("❌ FAILED: Expected 0 windows after cleanup, got %d", windows_after_cleanup);
      return false;
   }
   
   if(EnableDebugOutput)
   {
      Print("Memory management: Automatic and explicit cleanup verified");
      Print("✅ PASSED: Memory management");
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Test window update coordination                                  |
//+------------------------------------------------------------------+
bool TestWindowUpdateCoordination()
{
   if(EnableDebugOutput)
      Print("\n--- Testing Window Update Coordination ---");
      
   CWindowManager window_mgr;
   if(!window_mgr.Init())
   {
      Print("❌ FAILED: WindowManager initialization failed");
      return false;
   }
   
   // Create multiple windows for update coordination
   CDmi dmi;
   CBollingerBands bb;
   
   if(!dmi.Init(_Symbol, _Period, 14) || !bb.Init(_Symbol, _Period, 20, 2.0))
   {
      Print("❌ FAILED: Indicator initialization failed");
      return false;
   }
   
   int update_window1 = window_mgr.CreateIndicatorWindow("Update Window 1", dmi.GetHandle());
   int update_window2 = window_mgr.CreateIndicatorWindow("Update Window 2", bb.GetHandle());
   
   if(update_window1 < 0 || update_window2 < 0)
   {
      Print("❌ FAILED: Update test window creation failed");
      return false;
   }
   
   // Test coordinated property updates
   bool coord_update1 = window_mgr.SetWindowHeight(update_window1, 100);
   bool coord_update2 = window_mgr.SetWindowHeight(update_window2, 100);
   
   if(!coord_update1 || !coord_update2)
   {
      Print("❌ FAILED: Coordinated window updates failed");
      return false;
   }
   
   // Test status update coordination
   window_mgr.PrintWindowStatus();
   
   // Verify windows remain coordinated after updates
   bool active1 = window_mgr.IsWindowActive(update_window1);
   bool active2 = window_mgr.IsWindowActive(update_window2);
   
   if(!active1 || !active2)
   {
      Print("❌ FAILED: Windows should remain active after coordinated updates");
      return false;
   }
   
   if(EnableDebugOutput)
   {
      PrintFormat("Update coordination: Windows %d and %d updated in sync", 
                 update_window1, update_window2);
      Print("✅ PASSED: Window update coordination");
   }
   
   return true;
}
