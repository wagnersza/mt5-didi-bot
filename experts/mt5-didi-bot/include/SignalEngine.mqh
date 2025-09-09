//+------------------------------------------------------------------+
//|                                                 SignalEngine.mqh |
//|                        Copyright 2023, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"

#include <Trade/Trade.mqh>

//+------------------------------------------------------------------+
//| Class for the DMI indicator.                                     |
//+------------------------------------------------------------------+
class CDmi
{
protected:
   int               m_handle;           // Indicator handle
   double            m_adx_buffer[];     // Buffer for ADX values
   double            m_plus_di_buffer[]; // Buffer for +DI values
   double            m_minus_di_buffer[];// Buffer for -DI values

public:
                     CDmi();
                    ~CDmi();
   bool              Init(string symbol, ENUM_TIMEFRAMES period, int adx_period);
   double            Adx(int shift);
   double            PlusDi(int shift);
   double            MinusDi(int shift);
   int               GetHandle() const { return m_handle; }
   
   // Getter methods for multi-window display compatibility
   double            GetADX(int shift) const { return const_cast<CDmi*>(this).Adx(shift); }
   double            GetPlusDI(int shift) const { return const_cast<CDmi*>(this).PlusDi(shift); }
   double            GetMinusDI(int shift) const { return const_cast<CDmi*>(this).MinusDi(shift); }
};
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CDmi::CDmi() : m_handle(INVALID_HANDLE)
{
}
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CDmi::~CDmi()
{
   if(m_handle != INVALID_HANDLE)
      IndicatorRelease(m_handle);
}
//+------------------------------------------------------------------+
//| Initialization method.                                           |
//+------------------------------------------------------------------+
bool CDmi::Init(string symbol, ENUM_TIMEFRAMES period, int adx_period)
{
   m_handle = iADX(symbol, period, adx_period);
   if(m_handle == INVALID_HANDLE)
     {
      PrintFormat("Error creating ADX indicator: %d", GetLastError());
      return(false);
     }
   ArraySetAsSeries(m_adx_buffer, true);
   ArraySetAsSeries(m_plus_di_buffer, true);
   ArraySetAsSeries(m_minus_di_buffer, true);
   PrintFormat("DMI initialized for %s, Period %d, ADX Period %d", symbol, (int)period, adx_period);
   return(true);
}
//+------------------------------------------------------------------+
//| Returns the ADX value for the specified bar.                     |
//+------------------------------------------------------------------+
double CDmi::Adx(int shift)
{
   if(CopyBuffer(m_handle, 0, shift, 1, m_adx_buffer) > 0)
      return(m_adx_buffer[0]);
   return(0);
}
//+------------------------------------------------------------------+
//| Returns the +DI value for the specified bar.                     |
//+------------------------------------------------------------------+
double CDmi::PlusDi(int shift)
{
   if(CopyBuffer(m_handle, 1, shift, 1, m_plus_di_buffer) > 0)
      return(m_plus_di_buffer[0]);
   return(0);
}
//+------------------------------------------------------------------+
//| Returns the -DI value for the specified bar.                     |
//+------------------------------------------------------------------+
double CDmi::MinusDi(int shift)
{
   if(CopyBuffer(m_handle, 2, shift, 1, m_minus_di_buffer) > 0)
      return(m_minus_di_buffer[0]);
   return(0);
}

//+------------------------------------------------------------------+
//| Class for the Didi Index indicator.                              |
//+------------------------------------------------------------------+
class CDidiIndex
{
protected:
   int m_short_ma_handle;    // Handle for the short moving average
   int m_medium_ma_handle;   // Handle for the medium moving average
   int m_long_ma_handle;     // Handle for the long moving average

   double m_short_ma_buffer[];  // Buffer for the short moving average
   double m_medium_ma_buffer[]; // Buffer for the medium moving average
   double m_long_ma_buffer[];   // Buffer for the long moving average

public:
   CDidiIndex();
   ~CDidiIndex();

   bool Init(string symbol, ENUM_TIMEFRAMES period, int short_period, int medium_period, int long_period);
   bool IsAgulhada(int shift);
   
   // Individual MA value getters
   double GetShortMA(int shift);
   double GetMediumMA(int shift);
   double GetLongMA(int shift);
   int GetHandle() const { return m_short_ma_handle; } // Return first handle for window creation
};
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CDidiIndex::CDidiIndex() : m_short_ma_handle(INVALID_HANDLE), m_medium_ma_handle(INVALID_HANDLE), m_long_ma_handle(INVALID_HANDLE)
{
}
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CDidiIndex::~CDidiIndex()
{
   if(m_short_ma_handle != INVALID_HANDLE)
      IndicatorRelease(m_short_ma_handle);
   if(m_medium_ma_handle != INVALID_HANDLE)
      IndicatorRelease(m_medium_ma_handle);
   if(m_long_ma_handle != INVALID_HANDLE)
      IndicatorRelease(m_long_ma_handle);
}
//+------------------------------------------------------------------+
//| Initialization method.                                           |
//+------------------------------------------------------------------+
bool CDidiIndex::Init(string symbol, ENUM_TIMEFRAMES period, int short_period, int medium_period, int long_period)
{
   m_short_ma_handle = iMA(symbol, period, short_period, 0, MODE_SMA, PRICE_CLOSE);
   m_medium_ma_handle = iMA(symbol, period, medium_period, 0, MODE_SMA, PRICE_CLOSE);
   m_long_ma_handle = iMA(symbol, period, long_period, 0, MODE_SMA, PRICE_CLOSE);

   if(m_short_ma_handle == INVALID_HANDLE || m_medium_ma_handle == INVALID_HANDLE || m_long_ma_handle == INVALID_HANDLE)
   {
      PrintFormat("Error creating Didi Index indicators: %d", GetLastError());
      return false;
   }

   ArraySetAsSeries(m_short_ma_buffer, true);
   ArraySetAsSeries(m_medium_ma_buffer, true);
   ArraySetAsSeries(m_long_ma_buffer, true);
   PrintFormat("Didi Index initialized for %s, Period %d, Short %d, Medium %d, Long %d", symbol, (int)period, short_period, medium_period, long_period);
   return true;
}
//+------------------------------------------------------------------+
//| Checks for the "agulhada" signal.                                |
//+------------------------------------------------------------------+
bool CDidiIndex::IsAgulhada(int shift)
{
   if(CopyBuffer(m_short_ma_handle, 0, shift, 2, m_short_ma_buffer) < 2 ||
      CopyBuffer(m_medium_ma_handle, 0, shift, 2, m_medium_ma_buffer) < 2 ||
      CopyBuffer(m_long_ma_handle, 0, shift, 2, m_long_ma_buffer) < 2)
   {
      Print("IsAgulhada: Not enough bars to check.");
      return false;
   }

   // Check for agulhada condition
   // This is a simplified check. A more robust check would be needed.
   bool cross_up = m_short_ma_buffer[1] < m_medium_ma_buffer[1] && m_short_ma_buffer[0] > m_medium_ma_buffer[0];
   bool cross_down = m_short_ma_buffer[1] > m_medium_ma_buffer[1] && m_short_ma_buffer[0] < m_medium_ma_buffer[0];

   if(cross_up || cross_down)
   {
      // Check if all three moving averages are close to each other
      double max_diff = 0.0001; // This should be adjusted based on the asset
      if(MathAbs(m_short_ma_buffer[0] - m_medium_ma_buffer[0]) < max_diff &&
         MathAbs(m_short_ma_buffer[0] - m_long_ma_buffer[0]) < max_diff)
      {
         PrintFormat("IsAgulhada: Agulhada detected! Short: %.5f, Medium: %.5f, Long: %.5f", m_short_ma_buffer[0], m_medium_ma_buffer[0], m_long_ma_buffer[0]);
         return true;
      }
      else
      {
         PrintFormat("IsAgulhada: Cross detected, but MAs not close enough. Short: %.5f, Medium: %.5f, Long: %.5f", m_short_ma_buffer[0], m_medium_ma_buffer[0], m_long_ma_buffer[0]);
      }
   }
   else
   {
      Print("IsAgulhada: No cross detected.");
   }

   return false;
}

//+------------------------------------------------------------------+
//| Returns the Short MA value for the specified bar.               |
//+------------------------------------------------------------------+
double CDidiIndex::GetShortMA(int shift)
{
   if(CopyBuffer(m_short_ma_handle, 0, shift, 1, m_short_ma_buffer) > 0)
      return m_short_ma_buffer[0];
   return 0.0;
}

//+------------------------------------------------------------------+
//| Returns the Medium MA value for the specified bar.              |
//+------------------------------------------------------------------+
double CDidiIndex::GetMediumMA(int shift)
{
   if(CopyBuffer(m_medium_ma_handle, 0, shift, 1, m_medium_ma_buffer) > 0)
      return m_medium_ma_buffer[0];
   return 0.0;
}

//+------------------------------------------------------------------+
//| Returns the Long MA value for the specified bar.                |
//+------------------------------------------------------------------+
double CDidiIndex::GetLongMA(int shift)
{
   if(CopyBuffer(m_long_ma_handle, 0, shift, 1, m_long_ma_buffer) > 0)
      return m_long_ma_buffer[0];
   return 0.0;
}

//+------------------------------------------------------------------+
//| Class for the Bollinger Bands indicator.                         |
//+------------------------------------------------------------------+
class CBollingerBands
{
protected:
   int m_handle;                     // Indicator handle
   double m_upper_band_buffer[];    // Buffer for the upper band
   double m_middle_band_buffer[];   // Buffer for the middle band
   double m_lower_band_buffer[];    // Buffer for the lower band

public:
   CBollingerBands();
   ~CBollingerBands();

   bool Init(string symbol, ENUM_TIMEFRAMES period, int bb_period, double bb_deviation);
   double UpperBand(int shift);
   double MiddleBand(int shift);
   double LowerBand(int shift);
   int GetHandle() const { return m_handle; }
};
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CBollingerBands::CBollingerBands() : m_handle(INVALID_HANDLE)
{
}
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CBollingerBands::~CBollingerBands()
{
   if(m_handle != INVALID_HANDLE)
      IndicatorRelease(m_handle);
}
//+------------------------------------------------------------------+
//| Initialization method.                                           |
//+------------------------------------------------------------------+
bool CBollingerBands::Init(string symbol, ENUM_TIMEFRAMES period, int bb_period, double bb_deviation)
{
   m_handle = iBands(symbol, period, bb_period, 0, bb_deviation, PRICE_CLOSE);
   if(m_handle == INVALID_HANDLE)
   {
      PrintFormat("Error creating Bollinger Bands indicator: %d", GetLastError());
      return false;
   }

   ArraySetAsSeries(m_upper_band_buffer, true);
   ArraySetAsSeries(m_middle_band_buffer, true);
   ArraySetAsSeries(m_lower_band_buffer, true);
   PrintFormat("Bollinger Bands initialized for %s, Period %d, BB Period %d, Deviation %.2f", symbol, (int)period, bb_period, bb_deviation);
   return true;
}
//+------------------------------------------------------------------+
//| Returns the upper band value for the specified bar.              |
//+------------------------------------------------------------------+
double CBollingerBands::UpperBand(int shift)
{
   if(CopyBuffer(m_handle, 1, shift, 1, m_upper_band_buffer) > 0)
      return m_upper_band_buffer[0];
   return 0;
}
//+------------------------------------------------------------------+
//| Returns the middle band value for the specified bar.             |
//+------------------------------------------------------------------+
double CBollingerBands::MiddleBand(int shift)
{
   if(CopyBuffer(m_handle, 0, shift, 1, m_middle_band_buffer) > 0)
      return m_middle_band_buffer[0];
   return 0;
}
//+------------------------------------------------------------------+
//| Returns the lower band value for the specified bar.              |
//+------------------------------------------------------------------+
double CBollingerBands::LowerBand(int shift)
{
   if(CopyBuffer(m_handle, 2, shift, 1, m_lower_band_buffer) > 0)
      return m_lower_band_buffer[0];
   return 0;
}

//+------------------------------------------------------------------+
//| Class for the Stochastic Oscillator indicator.                   |
//+------------------------------------------------------------------+
class CStochastic
{
protected:
   int m_handle;               // Indicator handle
   double m_main_buffer[];    // Buffer for the main line
   double m_signal_buffer[];  // Buffer for the signal line

public:
   CStochastic();
   ~CStochastic();

   bool Init(string symbol, ENUM_TIMEFRAMES period, int k_period, int d_period, int slowing);
   double Main(int shift);
   double Signal(int shift);
   int GetHandle() const { return m_handle; }
   
   // Getter methods for multi-window display compatibility
   double GetMain(int shift) const { return const_cast<CStochastic*>(this)->Main(shift); }
   double GetSignal(int shift) const { return const_cast<CStochastic*>(this)->Signal(shift); }
};
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CStochastic::CStochastic() : m_handle(INVALID_HANDLE)
{
}
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CStochastic::~CStochastic()
{
   if(m_handle != INVALID_HANDLE)
      IndicatorRelease(m_handle);
}
//+------------------------------------------------------------------+
//| Initialization method.                                           |
//+------------------------------------------------------------------+
bool CStochastic::Init(string symbol, ENUM_TIMEFRAMES period, int k_period, int d_period, int slowing)
{
   m_handle = iStochastic(symbol, period, k_period, d_period, slowing, MODE_SMA, STO_LOWHIGH);
   if(m_handle == INVALID_HANDLE)
   {
      PrintFormat("Error creating Stochastic indicator: %d", GetLastError());
      return false;
   }

   ArraySetAsSeries(m_main_buffer, true);
   ArraySetAsSeries(m_signal_buffer, true);
   PrintFormat("Stochastic initialized for %s, Period %d, K Period %d, D Period %d, Slowing %d", symbol, (int)period, k_period, d_period, slowing);
   return true;
}
//+------------------------------------------------------------------+
//| Returns the main line value for the specified bar.               |
//+------------------------------------------------------------------+
double CStochastic::Main(int shift)
{
   if(CopyBuffer(m_handle, 0, shift, 1, m_main_buffer) > 0)
      return m_main_buffer[0];
   return 0;
}
//+------------------------------------------------------------------+
//| Returns the signal line value for the specified bar.             |
//+------------------------------------------------------------------+
double CStochastic::Signal(int shift)
{
   if(CopyBuffer(m_handle, 1, shift, 1, m_signal_buffer) > 0)
      return m_signal_buffer[0];
   return 0;
}

//+------------------------------------------------------------------+
//| Class for the Trix indicator.                                    |
//+------------------------------------------------------------------+
class CTrix
{
protected:
   int m_ema1_handle;          // First EMA handle
   int m_ema2_handle;          // Second EMA handle  
   int m_ema3_handle;          // Third EMA handle
   double m_ema1_buffer[];     // First EMA buffer
   double m_ema2_buffer[];     // Second EMA buffer
   double m_ema3_buffer[];     // Third EMA buffer
   double m_trix_buffer[];     // TRIX calculation buffer
   int m_period;               // TRIX period
   string m_symbol;            // Symbol
   ENUM_TIMEFRAMES m_timeframe; // Timeframe

public:
   CTrix();
   ~CTrix();

   bool Init(string symbol, ENUM_TIMEFRAMES period, int trix_period);
   double Main(int shift);
   bool CalculateTrix(int shift);
   int GetHandle() const { return m_ema1_handle; } // Return first handle for window creation
   
   // Getter methods for multi-window display compatibility
   double GetTrix(int shift) const { return const_cast<CTrix*>(this)->Main(shift); }
   double GetSignal(int shift) const { return 0.0; } // TRIX typically doesn't have a signal line
};
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CTrix::CTrix() : m_ema1_handle(INVALID_HANDLE), m_ema2_handle(INVALID_HANDLE), m_ema3_handle(INVALID_HANDLE), m_period(0)
{
}
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CTrix::~CTrix()
{
   if(m_ema1_handle != INVALID_HANDLE)
      IndicatorRelease(m_ema1_handle);
   if(m_ema2_handle != INVALID_HANDLE)
      IndicatorRelease(m_ema2_handle);
   if(m_ema3_handle != INVALID_HANDLE)
      IndicatorRelease(m_ema3_handle);
}
//+------------------------------------------------------------------+
//| Initialization method.                                           |
//+------------------------------------------------------------------+
bool CTrix::Init(string symbol, ENUM_TIMEFRAMES period, int trix_period)
{
   m_symbol = symbol;
   m_timeframe = period;
   m_period = trix_period;
   
   // Create three EMAs for TRIX calculation
   m_ema1_handle = iMA(symbol, period, trix_period, 0, MODE_EMA, PRICE_CLOSE);
   m_ema2_handle = iMA(symbol, period, trix_period, 0, MODE_EMA, PRICE_CLOSE);
   m_ema3_handle = iMA(symbol, period, trix_period, 0, MODE_EMA, PRICE_CLOSE);
   
   if(m_ema1_handle == INVALID_HANDLE || m_ema2_handle == INVALID_HANDLE || m_ema3_handle == INVALID_HANDLE)
   {
      PrintFormat("Error creating TRIX EMA indicators: %d", GetLastError());
      return false;
   }

   ArraySetAsSeries(m_ema1_buffer, true);
   ArraySetAsSeries(m_ema2_buffer, true);
   ArraySetAsSeries(m_ema3_buffer, true);
   ArraySetAsSeries(m_trix_buffer, true);
   
   PrintFormat("TRIX initialized for %s, Period %d, TRIX Period %d", symbol, (int)period, trix_period);
   return true;
}
//+------------------------------------------------------------------+
//| Calculate TRIX value manually                                   |
//+------------------------------------------------------------------+
bool CTrix::CalculateTrix(int shift)
{
   // Get close prices
   double close[];
   ArraySetAsSeries(close, true);
   if(CopyClose(m_symbol, m_timeframe, shift, m_period + 10, close) < m_period + 10)
      return false;
   
   // Calculate first EMA
   double ema1[];
   ArrayResize(ema1, m_period + 10);
   ArraySetAsSeries(ema1, true);
   
   // Simple EMA calculation for first level
   ema1[m_period + 9] = close[m_period + 9];
   double alpha = 2.0 / (m_period + 1.0);
   
   for(int i = m_period + 8; i >= 0; i--)
   {
      ema1[i] = alpha * close[i] + (1 - alpha) * ema1[i + 1];
   }
   
   // Calculate second EMA
   double ema2[];
   ArrayResize(ema2, m_period + 10);
   ArraySetAsSeries(ema2, true);
   
   ema2[m_period + 9] = ema1[m_period + 9];
   for(int i = m_period + 8; i >= 0; i--)
   {
      ema2[i] = alpha * ema1[i] + (1 - alpha) * ema2[i + 1];
   }
   
   // Calculate third EMA
   double ema3[];
   ArrayResize(ema3, m_period + 10);
   ArraySetAsSeries(ema3, true);
   
   ema3[m_period + 9] = ema2[m_period + 9];
   for(int i = m_period + 8; i >= 0; i--)
   {
      ema3[i] = alpha * ema2[i] + (1 - alpha) * ema3[i + 1];
   }
   
   // Calculate TRIX
   ArrayResize(m_trix_buffer, 10);
   if(ema3[shift + 1] != 0)
   {
      m_trix_buffer[shift] = 10000.0 * (ema3[shift] - ema3[shift + 1]) / ema3[shift + 1];
   }
   else
   {
      m_trix_buffer[shift] = 0;
   }
   
   return true;
}
//+------------------------------------------------------------------+
//| Returns the main line value for the specified bar.               |
//+------------------------------------------------------------------+
double CTrix::Main(int shift)
{
   if(CalculateTrix(shift))
      return m_trix_buffer[shift];
   return 0;
}

//+------------------------------------------------------------------+
//| Class for the IFR (RSI) indicator.                               |
//+------------------------------------------------------------------+
class CIfr
{
protected:
   int m_handle;           // Indicator handle
   double m_main_buffer[];// Buffer for the main line

public:
   CIfr();
   ~CIfr();

   bool Init(string symbol, ENUM_TIMEFRAMES period, int rsi_period);
   double Main(int shift);
   int GetHandle() const { return m_handle; }
   
   // Getter methods for multi-window display compatibility
   double GetIfr(int shift) const { return const_cast<CIfr*>(this)->Main(shift); }
};
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CIfr::CIfr() : m_handle(INVALID_HANDLE)
{
}
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CIfr::~CIfr()
{
   if(m_handle != INVALID_HANDLE)
      IndicatorRelease(m_handle);
}
//+------------------------------------------------------------------+
//| Initialization method.                                           |
//+------------------------------------------------------------------+
bool CIfr::Init(string symbol, ENUM_TIMEFRAMES period, int rsi_period)
{
   m_handle = iRSI(symbol, period, rsi_period, PRICE_CLOSE);
   if(m_handle == INVALID_HANDLE)
   {
      PrintFormat("Error creating IFR (RSI) indicator: %d", GetLastError());
      return false;
   }

   ArraySetAsSeries(m_main_buffer, true);
   PrintFormat("IFR (RSI) initialized for %s, Period %d, RSI Period %d", symbol, (int)period, rsi_period);
   return true;
}
//+------------------------------------------------------------------+
//| Returns the main line value for the specified bar.               |
//+------------------------------------------------------------------+
double CIfr::Main(int shift)
{
   if(CopyBuffer(m_handle, 0, shift, 1, m_main_buffer) > 0)
      return m_main_buffer[0];
   return 0;
}

//+------------------------------------------------------------------+
//| Class for the ATR (Average True Range) indicator.               |
//+------------------------------------------------------------------+
class CAtr
{
protected:
   int               m_handle;           // Indicator handle
   double            m_atr_buffer[];     // Buffer for ATR values
   
   // Performance optimization: caching
   double            m_cached_atr;       // Cached ATR value
   datetime          m_cache_time;       // Time of last cache update
   int               m_cache_bar;        // Bar number of last cache
   bool              m_cache_valid;      // Cache validity flag

public:
                     CAtr();
                    ~CAtr();
   bool              Init(string symbol, ENUM_TIMEFRAMES period, int atr_period);
   double            Main(int shift);
   bool              GetValues(double &atr_array[], int start_pos, int count);
   double            GetCurrentATR();
   bool              IsValidHandle() const;
   void              InvalidateCache();  // Force cache refresh
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CAtr::CAtr() : m_handle(INVALID_HANDLE), m_cached_atr(0.0), m_cache_time(0), 
               m_cache_bar(-1), m_cache_valid(false)
{
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CAtr::~CAtr()
{
   if(m_handle != INVALID_HANDLE)
      IndicatorRelease(m_handle);
}

//+------------------------------------------------------------------+
//| Initialization method.                                           |
//+------------------------------------------------------------------+
bool CAtr::Init(string symbol, ENUM_TIMEFRAMES period, int atr_period)
{
   m_handle = iATR(symbol, period, atr_period);
   if(m_handle == INVALID_HANDLE)
   {
      PrintFormat("OnInit: ATR initialization failed for %s, Period %d, ATR Period %d. Error: %d", 
                  symbol, (int)period, atr_period, GetLastError());
      return false;
   }

   ArraySetAsSeries(m_atr_buffer, true);
   PrintFormat("OnInit: ATR initialized successfully for %s, Period %d, ATR Period %d", 
               symbol, (int)period, atr_period);
   return true;
}

//+------------------------------------------------------------------+
//| Returns the ATR value for the specified bar.                    |
//+------------------------------------------------------------------+
double CAtr::Main(int shift)
{
   if(m_handle == INVALID_HANDLE)
   {
      Print("CAtr::Main: ATR handle is invalid");
      return 0.0;
   }
   
   if(CopyBuffer(m_handle, 0, shift, 1, m_atr_buffer) > 0)
   {
      if(m_atr_buffer[0] > 0)
         return m_atr_buffer[0];
      else
      {
         PrintFormat("CAtr::Main: Invalid ATR value %.5f at shift %d", m_atr_buffer[0], shift);
         return 0.0;
      }
   }
   
   PrintFormat("CAtr::Main: Failed to copy ATR buffer at shift %d. Error: %d", shift, GetLastError());
   return 0.0;
}

//+------------------------------------------------------------------+
//| Get multiple ATR values at once                                 |
//+------------------------------------------------------------------+
bool CAtr::GetValues(double &atr_array[], int start_pos, int count)
{
   if(m_handle == INVALID_HANDLE)
   {
      Print("CAtr::GetValues: ATR handle is invalid");
      return false;
   }
   
   ArraySetAsSeries(atr_array, true);
   int copied = CopyBuffer(m_handle, 0, start_pos, count, atr_array);
   
   if(copied != count)
   {
      PrintFormat("CAtr::GetValues: Failed to copy %d ATR values. Copied: %d, Error: %d", 
                  count, copied, GetLastError());
      return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Get current ATR value with performance caching                  |
//+------------------------------------------------------------------+
double CAtr::GetCurrentATR()
{
   datetime current_time = TimeCurrent();
   int current_bar = Bars(_Symbol, _Period) - 1; // Current completed bar
   
   // Check if cache is valid (same bar and recent time)
   if(m_cache_valid && m_cache_bar == current_bar && 
      (current_time - m_cache_time) < 30) // Cache valid for 30 seconds
     {
      return m_cached_atr;
     }
   
   // Cache miss - fetch new value
   double atr_value = Main(1); // Use shift 1 for last completed bar
   
   if(atr_value > 0)
     {
      // Update cache
      m_cached_atr = atr_value;
      m_cache_time = current_time;
      m_cache_bar = current_bar;
      m_cache_valid = true;
     }
   
   return atr_value;
}

//+------------------------------------------------------------------+
//| Invalidate cache to force refresh                               |
//+------------------------------------------------------------------+
void CAtr::InvalidateCache()
{
   m_cache_valid = false;
   m_cached_atr = 0.0;
   m_cache_time = 0;
   m_cache_bar = -1;
}

//+------------------------------------------------------------------+
//| Check if ATR handle is valid                                    |
//+------------------------------------------------------------------+
bool CAtr::IsValidHandle() const
{
   return (m_handle != INVALID_HANDLE);
}
