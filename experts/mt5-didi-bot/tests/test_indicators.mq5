//+------------------------------------------------------------------+
//|                                            test_indicators.mq5 |
//|                        Copyright 2023, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"

#include "../include/SignalEngine.mqh"

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   TestDMI();
   TestDidiIndex();
   TestBollingerBands();
   TestStochastic();
   TestTrix();
   TestIfr();
  }

//+------------------------------------------------------------------+
//| Test for the DMI indicator.                                      |
//+------------------------------------------------------------------+
void TestDMI()
  {
   CDmi dmi;
   if(dmi.Init(_Symbol,_Period,14))
     {
      double adx=dmi.Adx(0);
      double plus_di=dmi.PlusDi(0);
      double minus_di=dmi.MinusDi(0);

      Print("ADX: ",adx,", +DI: ",plus_di,", -DI: ",minus_di);

      // Basic assertion
      if(adx>0 && plus_di>0 && minus_di>0)
        {
         Print("TestDMI: PASSED");
        }
      else
        {
         Print("TestDMI: FAILED");
        }
     }
   else
     {
      Print("Failed to initialize DMI indicator");
     }
  }

//+------------------------------------------------------------------+
//| Test for the Didi Index indicator.                               |
//+------------------------------------------------------------------+
void TestDidiIndex()
  {
   CDidiIndex didi;
   if(didi.Init(_Symbol, _Period, 3, 8, 20))
     {
      if(didi.IsAgulhada(0))
        {
         Print("Didi Index: Agulhada detected!");
        }
      else
        {
         Print("Didi Index: No agulhada.");
        }
      Print("TestDidiIndex: PASSED");
     }
   else
     {
      Print("Failed to initialize Didi Index indicator");
      Print("TestDidiIndex: FAILED");
     }
  }

//+------------------------------------------------------------------+
//| Test for the Bollinger Bands indicator.                          |
//+------------------------------------------------------------------+
void TestBollingerBands()
  {
   CBollingerBands bb;
   if(bb.Init(_Symbol, _Period, 20, 2.0))
     {
      double upper = bb.UpperBand(0);
      double middle = bb.MiddleBand(0);
      double lower = bb.LowerBand(0);

      Print("Bollinger Bands: Upper=", upper, ", Middle=", middle, ", Lower=", lower);

      // Basic assertion
      if(upper > middle && middle > lower)
        {
         Print("TestBollingerBands: PASSED");
        }
      else
        {
         Print("TestBollingerBands: FAILED");
        }
     }
   else
     {
      Print("Failed to initialize Bollinger Bands indicator");
      Print("TestBollingerBands: FAILED");
     }
  }

//+------------------------------------------------------------------+
//| Test for the Stochastic Oscillator indicator.                    |
//+------------------------------------------------------------------+
void TestStochastic()
  {
   CStochastic stoch;
   if(stoch.Init(_Symbol, _Period, 5, 3, 3))
     {
      double main = stoch.Main(0);
      double signal = stoch.Signal(0);

      Print("Stochastic: Main=", main, ", Signal=", signal);

      // Basic assertion
      if(main >= 0 && main <= 100 && signal >= 0 && signal <= 100)
        {
         Print("TestStochastic: PASSED");
        }
      else
        {
         Print("TestStochastic: FAILED");
        }
     }
   else
     {
      Print("Failed to initialize Stochastic indicator");
      Print("TestStochastic: FAILED");
     }
  }

//+------------------------------------------------------------------+
//| Test for the Trix indicator.                                     |
//+------------------------------------------------------------------+
void TestTrix()
  {
   CTrix trix;
   if(trix.Init(_Symbol, _Period, 14))
     {
      double main = trix.Main(0);

      Print("Trix: Main=", main);

      // Basic assertion
      if(main != 0)
        {
         Print("TestTrix: PASSED");
        }
      else
        {
         Print("TestTrix: FAILED");
        }
     }
   else
     {
      Print("Failed to initialize Trix indicator");
      Print("TestTrix: FAILED");
     }
  }

//+------------------------------------------------------------------+
//| Test for the IFR (RSI) indicator.                                |
//+------------------------------------------------------------------+
void TestIfr()
  {
   CIfr ifr;
   if(ifr.Init(_Symbol, _Period, 14))
     {
      double main = ifr.Main(0);

      Print("IFR (RSI): Main=", main);

      // Basic assertion
      if(main >= 0 && main <= 100)
        {
         Print("TestIfr: PASSED");
        }
      else
        {
         Print("TestIfr: FAILED");
        }
     }
   else
     {
      Print("Failed to initialize IFR (RSI) indicator");
      Print("TestIfr: FAILED");
     }
  }