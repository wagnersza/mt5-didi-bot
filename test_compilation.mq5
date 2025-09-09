//+------------------------------------------------------------------+
//| Test Compilation                                                 |
//+------------------------------------------------------------------+

// Include the main headers to test compilation
#include "experts/mt5-didi-bot/include/SignalEngine.mqh"
#include "experts/mt5-didi-bot/include/TradeManager.mqh"
#include "experts/mt5-didi-bot/include/RiskManager.mqh"

// Test enum access
void TestEnumAccess()
{
   ENUM_STOP_TYPE test_type = ATR_BASED;
   Print("Test enum: ", (int)test_type);
}

// Test structure creation
void TestStructureCreation()
{
   StopLossConfig config;
   config.type = ATR_BASED;
   config.atr_multiplier = 1.5;
   config.fixed_pips = 50;
   
   ActiveStopLoss stop;
   stop.ticket = 12345;
   stop.is_trailing = true;
   
   Print("Config type: ", (int)config.type);
   Print("Stop ticket: ", stop.ticket);
}

// Test class instantiation
void TestClassInstantiation()
{
   CRiskManager risk_manager;
   CTradeManager trade_manager;
   CDmi dmi;
   CAtr atr;
   
   Print("Classes instantiated successfully");
}

//+------------------------------------------------------------------+
//| Script program start function                                   |
//+------------------------------------------------------------------+
void OnStart()
{
   TestEnumAccess();
   TestStructureCreation();
   TestClassInstantiation();
   
   Print("Compilation test completed successfully!");
}
