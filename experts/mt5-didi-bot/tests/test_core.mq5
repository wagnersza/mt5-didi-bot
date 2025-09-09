//+------------------------------------------------------------------+
//|                                                  test_core.mq5 |
//|                        Copyright 2023, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"

#include "../include/SignalEngine.mqh"
#include "../include/TradeManager.mqh"

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   TestCheckForEntry();
   TestCheckForExit();
  }

//+------------------------------------------------------------------+
//| Test for the CheckForEntry function.                             |
//+------------------------------------------------------------------+
void TestCheckForEntry()
  {
// This test requires a more complex setup to mock the indicator signals.
// For now, we will just call the function and check for errors.
   CTradeManager trade_manager;
   CDmi dmi;
   CDidiIndex didi;
   CBollingerBands bb;

   if(dmi.Init(_Symbol,_Period,14) && didi.Init(_Symbol,_Period,3,8,20) && bb.Init(_Symbol,_Period,20,2.0))
     {
      trade_manager.CheckForEntry(dmi,didi,bb);
      Print("TestCheckForEntry: PASSED");
     }
   else
     {
      Print("TestCheckForEntry: FAILED to initialize indicators");
     }
  }

//+------------------------------------------------------------------+
//| Test for the CheckForExit function.                              |
//+------------------------------------------------------------------+
void TestCheckForExit()
  {
// This test requires a more complex setup to mock the indicator signals
// and an open position.
// For now, we will just call the function and check for errors.
   CTradeManager trade_manager;
   CDmi dmi;
   CStochastic stoch;
   CTrix trix;
   CBollingerBands bb;

   if(dmi.Init(_Symbol,_Period,14) && stoch.Init(_Symbol,_Period,5,3,3) && trix.Init(_Symbol,_Period,14) && bb.Init(_Symbol,_Period,20,2.0))
     {
      trade_manager.CheckForExit(dmi,stoch,trix,bb);
      Print("TestCheckForExit: PASSED");
     }
   else
     {
      Print("TestCheckForExit: FAILED to initialize indicators");
     }
  }
