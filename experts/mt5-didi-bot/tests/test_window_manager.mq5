//+------------------------------------------------------------------+
//|                                           test_window_manager.mq5 |
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
input bool TestWindowCreation = true;
input bool TestWindowProperties = true;
input bool TestWindowValidation = true;

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
   Print("=== WindowManager Unit Tests Started ===");
   
   int tests_passed = 0;
   int tests_failed = 0;
   
   if(TestWindowCreation)
   {
      if(TestBasicInitialization())
         tests_passed++;
      else
         tests_failed++;
         
      if(TestWindowCreationAndTracking())
         tests_passed++;
      else
         tests_failed++;
         
      if(TestWindowRemoval())
         tests_passed++;
      else
         tests_failed++;
   }
   
   if(TestWindowProperties)
   {
      if(TestWindowPropertySettings())
         tests_passed++;
      else
         tests_failed++;
         
      if(TestWindowNameResolution())
         tests_passed++;
      else
         tests_failed++;
   }
   
   if(TestWindowValidation)
   {
      if(TestWindowIndexValidation())
         tests_passed++;
      else
         tests_failed++;
         
      if(TestErrorHandling())
         tests_passed++;
      else
         tests_failed++;
   }
   
   // Summary
   Print("=== WindowManager Unit Tests Completed ===");
   PrintFormat("Tests Passed: %d", tests_passed);
   PrintFormat("Tests Failed: %d", tests_failed);
   PrintFormat("Success Rate: %.1f%%", tests_failed == 0 ? 100.0 : (double)tests_passed / (tests_passed + tests_failed) * 100.0);
   
   if(tests_failed == 0)
      Print("✅ ALL TESTS PASSED - WindowManager is ready for integration");
   else
      Print("❌ SOME TESTS FAILED - Review implementation before proceeding");
}

//+------------------------------------------------------------------+
//| Test basic initialization of WindowManager                       |
//+------------------------------------------------------------------+
bool TestBasicInitialization()
{
   if(EnableDebugOutput)
      Print("\n--- Testing Basic Initialization ---");
      
   CWindowManager window_mgr;
   
   // Test initialization with default parameters
   bool init_result = window_mgr.Init();
   if(!init_result)
   {
      Print("❌ FAILED: Basic initialization failed");
      return false;
   }
   
   // Verify chart ID is set
   long chart_id = window_mgr.GetChartId();
   if(chart_id <= 0)
   {
      Print("❌ FAILED: Invalid chart ID after initialization");
      return false;
   }
   
   // Verify main chart window is registered
   int window_count = window_mgr.GetWindowCount();
   if(window_count != 1)
   {
      PrintFormat("❌ FAILED: Expected 1 window (main chart), got %d", window_count);
      return false;
   }
   
   // Test custom prefix initialization
   CWindowManager custom_mgr;
   bool custom_init = custom_mgr.Init(ChartID(), "TestPrefix");
   if(!custom_init)
   {
      Print("❌ FAILED: Custom prefix initialization failed");
      return false;
   }
   
   if(EnableDebugOutput)
   {
      window_mgr.PrintWindowStatus();
      Print("✅ PASSED: Basic initialization");
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Test window creation and tracking                                |
//+------------------------------------------------------------------+
bool TestWindowCreationAndTracking()
{
   if(EnableDebugOutput)
      Print("\n--- Testing Window Creation and Tracking ---");
      
   CWindowManager window_mgr;
   if(!window_mgr.Init())
   {
      Print("❌ FAILED: WindowManager initialization failed");
      return false;
   }
   
   // Create test indicators for window creation
   CDmi dmi;
   if(!dmi.Init(_Symbol, _Period, 14))
   {
      Print("❌ FAILED: DMI indicator initialization failed");
      return false;
   }
   
   CBollingerBands bb;
   if(!bb.Init(_Symbol, _Period, 20, 2.0))
   {
      Print("❌ FAILED: Bollinger Bands indicator initialization failed");
      return false;
   }
   
   // Test window creation with valid indicator
   int dmi_window = window_mgr.CreateIndicatorWindow("DMI Test Window", dmi.GetHandle());
   if(dmi_window < 0)
   {
      Print("❌ FAILED: DMI window creation failed");
      return false;
   }
   
   // Test window tracking
   int found_window = window_mgr.GetWindowIndex("DMI Test Window");
   if(found_window != dmi_window)
   {
      PrintFormat("❌ FAILED: Window tracking failed. Expected %d, got %d", dmi_window, found_window);
      return false;
   }
   
   // Test window count
   int window_count = window_mgr.GetWindowCount();
   if(window_count != 2) // Main chart + DMI window
   {
      PrintFormat("❌ FAILED: Expected 2 windows, got %d", window_count);
      return false;
   }
   
   // Test window activity status
   bool is_active = window_mgr.IsWindowActive(dmi_window);
   if(!is_active)
   {
      Print("❌ FAILED: Created window should be active");
      return false;
   }
   
   // Test window name retrieval
   string window_name = window_mgr.GetWindowName(dmi_window);
   if(window_name != "DMI Test Window")
   {
      PrintFormat("❌ FAILED: Window name mismatch. Expected 'DMI Test Window', got '%s'", window_name);
      return false;
   }
   
   // Test creation with invalid handle
   int invalid_window = window_mgr.CreateIndicatorWindow("Invalid Window", INVALID_HANDLE);
   if(invalid_window >= 0)
   {
      Print("❌ FAILED: Window creation should fail with invalid handle");
      return false;
   }
   
   if(EnableDebugOutput)
   {
      window_mgr.PrintWindowStatus();
      Print("✅ PASSED: Window creation and tracking");
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Test window removal                                              |
//+------------------------------------------------------------------+
bool TestWindowRemoval()
{
   if(EnableDebugOutput)
      Print("\n--- Testing Window Removal ---");
      
   CWindowManager window_mgr;
   if(!window_mgr.Init())
   {
      Print("❌ FAILED: WindowManager initialization failed");
      return false;
   }
   
   // Create a test window first
   CStochastic stoch;
   if(!stoch.Init(_Symbol, _Period, 5, 3, 3))
   {
      Print("❌ FAILED: Stochastic indicator initialization failed");
      return false;
   }
   
   int test_window = window_mgr.CreateIndicatorWindow("Test Removal Window", stoch.GetHandle());
   if(test_window < 0)
   {
      Print("❌ FAILED: Test window creation failed");
      return false;
   }
   
   // Verify window exists before removal
   bool is_active_before = window_mgr.IsWindowActive(test_window);
   if(!is_active_before)
   {
      Print("❌ FAILED: Test window should be active before removal");
      return false;
   }
   
   // Test window removal
   bool removal_result = window_mgr.RemoveWindow(test_window);
   if(!removal_result)
   {
      Print("❌ FAILED: Window removal failed");
      return false;
   }
   
   // Verify window is no longer active
   bool is_active_after = window_mgr.IsWindowActive(test_window);
   if(is_active_after)
   {
      Print("❌ FAILED: Window should not be active after removal");
      return false;
   }
   
   // Test removal of non-existent window
   bool invalid_removal = window_mgr.RemoveWindow(99999);
   if(invalid_removal)
   {
      Print("❌ FAILED: Removal of non-existent window should fail");
      return false;
   }
   
   // Test removal of main chart window (should fail)
   bool main_removal = window_mgr.RemoveWindow(0);
   if(main_removal)
   {
      Print("❌ FAILED: Main chart window removal should fail");
      return false;
   }
   
   if(EnableDebugOutput)
   {
      window_mgr.PrintWindowStatus();
      Print("✅ PASSED: Window removal");
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Test window property settings                                    |
//+------------------------------------------------------------------+
bool TestWindowPropertySettings()
{
   if(EnableDebugOutput)
      Print("\n--- Testing Window Property Settings ---");
      
   CWindowManager window_mgr;
   if(!window_mgr.Init())
   {
      Print("❌ FAILED: WindowManager initialization failed");
      return false;
   }
   
   // Test setting main chart properties
   bool height_result = window_mgr.SetWindowHeight(0, 300);
   if(!height_result)
   {
      Print("❌ FAILED: Setting window height failed");
      return false;
   }
   
   // Test setting chart properties
   bool prop_result = window_mgr.SetWindowProperty(0, CHART_SHOW_GRID, 1);
   if(!prop_result)
   {
      Print("❌ FAILED: Setting window property failed");
      return false;
   }
   
   // Test setting invalid window properties
   bool invalid_prop = window_mgr.SetWindowProperty(-1, CHART_SHOW_GRID, 1);
   if(invalid_prop)
   {
      Print("❌ FAILED: Setting property on invalid window should fail");
      return false;
   }
   
   if(EnableDebugOutput)
      Print("✅ PASSED: Window property settings");
   
   return true;
}

//+------------------------------------------------------------------+
//| Test window name resolution                                      |
//+------------------------------------------------------------------+
bool TestWindowNameResolution()
{
   if(EnableDebugOutput)
      Print("\n--- Testing Window Name Resolution ---");
      
   CWindowManager window_mgr;
   if(!window_mgr.Init())
   {
      Print("❌ FAILED: WindowManager initialization failed");
      return false;
   }
   
   // Test main chart name
   string main_name = window_mgr.GetWindowName(0);
   if(main_name != "Main Chart")
   {
      PrintFormat("❌ FAILED: Expected main chart name 'Main Chart', got '%s'", main_name);
      return false;
   }
   
   // Test unknown window name
   string unknown_name = window_mgr.GetWindowName(99999);
   if(unknown_name != "Unknown")
   {
      PrintFormat("❌ FAILED: Expected unknown window name 'Unknown', got '%s'", unknown_name);
      return false;
   }
   
   // Test window index lookup
   int main_index = window_mgr.GetWindowIndex("Main Chart");
   if(main_index != 0)
   {
      PrintFormat("❌ FAILED: Expected main chart index 0, got %d", main_index);
      return false;
   }
   
   // Test non-existent window lookup
   int missing_index = window_mgr.GetWindowIndex("Non-existent Window");
   if(missing_index != -1)
   {
      PrintFormat("❌ FAILED: Expected -1 for missing window, got %d", missing_index);
      return false;
   }
   
   if(EnableDebugOutput)
      Print("✅ PASSED: Window name resolution");
   
   return true;
}

//+------------------------------------------------------------------+
//| Test window index validation                                     |
//+------------------------------------------------------------------+
bool TestWindowIndexValidation()
{
   if(EnableDebugOutput)
      Print("\n--- Testing Window Index Validation ---");
      
   CWindowManager window_mgr;
   if(!window_mgr.Init())
   {
      Print("❌ FAILED: WindowManager initialization failed");
      return false;
   }
   
   // Test valid window index (main chart)
   bool valid_index = window_mgr.ValidateWindowIndex(0);
   if(!valid_index)
   {
      Print("❌ FAILED: Main chart window index should be valid");
      return false;
   }
   
   // Test negative window index
   bool negative_index = window_mgr.ValidateWindowIndex(-1);
   if(negative_index)
   {
      Print("❌ FAILED: Negative window index should be invalid");
      return false;
   }
   
   // Test very high window index
   bool high_index = window_mgr.ValidateWindowIndex(99999);
   if(high_index)
   {
      Print("❌ FAILED: Very high window index should be invalid");
      return false;
   }
   
   // Test total windows count
   int total_windows = window_mgr.GetTotalChartWindows();
   if(total_windows < 1)
   {
      PrintFormat("❌ FAILED: Total windows should be at least 1, got %d", total_windows);
      return false;
   }
   
   if(EnableDebugOutput)
      PrintFormat("Total chart windows: %d", total_windows);
      
   if(EnableDebugOutput)
      Print("✅ PASSED: Window index validation");
   
   return true;
}

//+------------------------------------------------------------------+
//| Test error handling scenarios                                    |
//+------------------------------------------------------------------+
bool TestErrorHandling()
{
   if(EnableDebugOutput)
      Print("\n--- Testing Error Handling ---");
      
   // Test uninitialized window manager operations
   CWindowManager uninitialized_mgr;
   
   // These should handle gracefully or return appropriate error states
   int invalid_window = uninitialized_mgr.CreateIndicatorWindow("Test", INVALID_HANDLE);
   if(invalid_window >= 0)
   {
      Print("❌ FAILED: Uninitialized manager should not create windows successfully");
      return false;
   }
   
   // Test invalid chart ID initialization
   CWindowManager invalid_chart_mgr;
   bool invalid_init = invalid_chart_mgr.Init(-1, "Test");
   if(invalid_init)
   {
      Print("❌ FAILED: Invalid chart ID initialization should fail");
      return false;
   }
   
   // Test normal operations with proper initialization
   CWindowManager window_mgr;
   if(!window_mgr.Init())
   {
      Print("❌ FAILED: Normal WindowManager initialization failed");
      return false;
   }
   
   // Test handle validation
   int invalid_handle_result = window_mgr.GetIndicatorHandle(99999);
   if(invalid_handle_result != INVALID_HANDLE)
   {
      PrintFormat("❌ FAILED: Expected INVALID_HANDLE for missing window, got %d", invalid_handle_result);
      return false;
   }
   
   if(EnableDebugOutput)
      Print("✅ PASSED: Error handling");
   
   return true;
}
