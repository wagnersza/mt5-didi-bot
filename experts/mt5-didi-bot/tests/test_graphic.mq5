//+------------------------------------------------------------------+
//|                                           test_graphic.mq5 |
//|                        Copyright 2023, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"

#include "../include/GraphicManager.mqh"
#include "../include/SignalEngine.mqh"

//--- Test objects
CGraphicManager g_graphic_test;
CDmi g_dmi_test;
CDidiIndex g_didi_test;
CBollingerBands g_bb_test;
CStochastic g_stoch_test;
CTrix g_trix_test;
CIfr g_ifr_test;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   Print("GraphicManager Test: Starting initialization...");
   
   // Initialize all indicators for testing
   if(!g_dmi_test.Init(_Symbol, _Period, 14))
   {
      Print("Failed to initialize DMI for testing");
      return INIT_FAILED;
   }
   
   if(!g_didi_test.Init(_Symbol, _Period, 3, 8, 20))
   {
      Print("Failed to initialize Didi Index for testing");
      return INIT_FAILED;
   }
   
   if(!g_bb_test.Init(_Symbol, _Period, 20, 2.0))
   {
      Print("Failed to initialize Bollinger Bands for testing");
      return INIT_FAILED;
   }
   
   if(!g_stoch_test.Init(_Symbol, _Period, 14, 3, 3))
   {
      Print("Failed to initialize Stochastic for testing");
      return INIT_FAILED;
   }
   
   if(!g_trix_test.Init(_Symbol, _Period, 14))
   {
      Print("Failed to initialize TRIX for testing");
      return INIT_FAILED;
   }
   
   if(!g_ifr_test.Init(_Symbol, _Period, 14))
   {
      Print("Failed to initialize IFR for testing");
      return INIT_FAILED;
   }
   
   // Initialize graphic manager
   g_graphic_test.Init("GraphicTest_");
   g_graphic_test.UpdateTradingStatus("TEST MODE");
   
   Print("GraphicManager Test: All components initialized successfully");
   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   g_graphic_test.ClearAll();
   Print("GraphicManager Test: Cleanup completed");
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   static datetime last_test_time = 0;
   static int test_counter = 0;
   
   datetime current_time = TimeCurrent();
   
   // Run tests every 10 seconds
   if(current_time - last_test_time >= 10)
   {
      last_test_time = current_time;
      test_counter++;
      
      Print("GraphicManager Test: Running test cycle #", test_counter);
      
      // Test signal panel update
      TestSignalPanel();
      
      // Test entry/exit signals alternately
      if(test_counter % 2 == 1)
      {
         TestEntrySignals();
      }
      else
      {
         TestExitSignals();
      }
      
      // Test drawing functions
      TestDrawingFunctions();
      
      Print("GraphicManager Test: Cycle #", test_counter, " completed");
   }
}

//+------------------------------------------------------------------+
//| Test signal panel updates                                        |
//+------------------------------------------------------------------+
void TestSignalPanel()
{
   Print("Testing UpdateSignalPanel...");
   g_graphic_test.UpdateSignalPanel(g_dmi_test, g_didi_test, g_bb_test, 
                                   g_stoch_test, g_trix_test, g_ifr_test);
   Print("UpdateSignalPanel test completed");
}

//+------------------------------------------------------------------+
//| Test entry signal drawing                                        |
//+------------------------------------------------------------------+
void TestEntrySignals()
{
   Print("Testing entry signal drawing...");
   
   double current_price = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   datetime current_time = TimeCurrent();
   
   // Test buy signal
   g_graphic_test.DrawEntrySignal(current_time, current_price, true, 
                                 "TEST BUY: DMI+Didi+BB");
   
   // Test sell signal (slightly offset)
   g_graphic_test.DrawEntrySignal(current_time - 60, current_price - (50 * _Point), false, 
                                 "TEST SELL: DMI+Didi+BB");
   
   Print("Entry signal drawing test completed");
}

//+------------------------------------------------------------------+
//| Test exit signal drawing                                         |
//+------------------------------------------------------------------+
void TestExitSignals()
{
   Print("Testing exit signal drawing...");
   
   double current_price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   datetime current_time = TimeCurrent();
   
   // Test buy exit signal
   g_graphic_test.DrawExitSignal(current_time, current_price, true, 
                                "TEST EXIT BUY: Stoch+TRIX");
   
   // Test sell exit signal (slightly offset)
   g_graphic_test.DrawExitSignal(current_time - 60, current_price + (50 * _Point), false, 
                                "TEST EXIT SELL: Stoch+TRIX");
   
   Print("Exit signal drawing test completed");
}

//+------------------------------------------------------------------+
//| Test basic drawing functions                                     |
//+------------------------------------------------------------------+
void TestDrawingFunctions()
{
   Print("Testing basic drawing functions...");
   
   double current_price = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   datetime current_time = TimeCurrent();
   
   // Test horizontal line
   g_graphic_test.DrawHorizontalLine("TestHLine", current_price + (100 * _Point), 
                                    clrYellow, STYLE_DOT, 2);
   
   // Test vertical line
   g_graphic_test.DrawVerticalLine("TestVLine", current_time, clrCyan, STYLE_DASH, 1);
   
   // Test arrow
   g_graphic_test.DrawArrow("TestArrow", current_time, current_price + (200 * _Point), 
                           241, clrMagenta, 4);
   
   // Test text
   g_graphic_test.DrawText("TestText", current_time, current_price + (300 * _Point), 
                          "GRAPHIC TEST", clrWhite, 12);
   
   // Update trading status
   string status = StringFormat("TESTING CYCLE - Price: %.5f", current_price);
   g_graphic_test.UpdateTradingStatus(status);
   
   Print("Basic drawing functions test completed");
}
