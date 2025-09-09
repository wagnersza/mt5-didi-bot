//+------------------------------------------------------------------+
//|                                            MainChartDisplay.mqh |
//|                        Copyright 2024, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"

//+------------------------------------------------------------------+
//| Main Chart Display Class for main chart window (index 0)         |
//| Handles price action, Bollinger Bands, and trade signals        |
//+------------------------------------------------------------------+
class CMainChartDisplay
{
protected:
   long              m_chart_id;           // Chart ID (main window is always index 0)
   string            m_object_prefix;      // Prefix for object names
   
   // Drawing parameters
   color             m_bb_upper_color;     // Bollinger Bands upper line color
   color             m_bb_middle_color;    // Bollinger Bands middle line color
   color             m_bb_lower_color;     // Bollinger Bands lower line color
   color             m_entry_bull_color;   // Bullish entry signal color
   color             m_entry_bear_color;   // Bearish entry signal color
   color             m_exit_color;         // Exit signal color
   
   // Display configuration
   bool              m_show_bollinger;     // Whether to show Bollinger Bands
   bool              m_show_entry_signals; // Whether to show entry signals
   bool              m_show_exit_signals;  // Whether to show exit signals
   bool              m_show_price_levels;  // Whether to show support/resistance levels
   
   // Signal tracking
   int               m_signal_arrow_size;  // Size of signal arrows
   
public:
                     CMainChartDisplay();
                    ~CMainChartDisplay();
   
   // Initialization and cleanup
   bool              Init(long chart_id = 0, string object_prefix = "MAIN");
   void              Cleanup();
   
   // Configuration methods
   void              SetColors(color bb_upper = clrBlue, color bb_middle = clrYellow, color bb_lower = clrBlue,
                              color entry_bull = clrLimeGreen, color entry_bear = clrRed, color exit = clrOrange);
   void              SetDisplayOptions(bool show_bb = true, bool show_entry = true, 
                                      bool show_exit = true, bool show_levels = false);
   void              SetSignalArrowSize(int size = 2);
   
   // Drawing methods - Bollinger Bands
   bool              DrawBollingerBands(const double upper_band, const double middle_band, const double lower_band,
                                       const datetime bar_time, const int bar_shift = 0);
   bool              DrawBollingerBandFill(const double upper_band, const double lower_band, 
                                          const datetime start_time, const datetime end_time);
   
   // Drawing methods - Trading signals
   bool              DrawEntrySignal(const datetime bar_time, const double price, const bool is_bullish, 
                                    const string signal_description = "");
   bool              DrawExitSignal(const datetime bar_time, const double price, const bool is_profit,
                                   const string exit_reason = "");
   bool              DrawPriceLevelLine(const double level_price, const string level_name, 
                                       const color level_color = clrDarkGray, const ENUM_LINE_STYLE style = STYLE_DASH);
   
   // Drawing methods - Price action
   bool              DrawSupportResistance(const double level_price, const string level_type, 
                                          const datetime start_time, const datetime end_time);
   bool              DrawTrendLine(const datetime time1, const double price1, 
                                  const datetime time2, const double price2, const string trend_name);
   
   // Update methods
   bool              UpdateDisplay(const double bb_upper, const double bb_middle, const double bb_lower,
                                  const datetime bar_time, const int bar_shift = 0);
   bool              ClearDisplay();
   bool              ClearSignals();
   
   // Utility methods
   bool              IsValidChart() const;
   string            GetObjectName(const string suffix) const;
   bool              RemoveObject(const string object_name);
   double            GetCurrentPrice(const bool use_bid = true) const;
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CMainChartDisplay::CMainChartDisplay() : m_chart_id(0),
                                        m_object_prefix("MAIN"),
                                        m_bb_upper_color(clrBlue),
                                        m_bb_middle_color(clrYellow),
                                        m_bb_lower_color(clrBlue),
                                        m_entry_bull_color(clrLimeGreen),
                                        m_entry_bear_color(clrRed),
                                        m_exit_color(clrOrange),
                                        m_show_bollinger(true),
                                        m_show_entry_signals(true),
                                        m_show_exit_signals(true),
                                        m_show_price_levels(false),
                                        m_signal_arrow_size(2)
{
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CMainChartDisplay::~CMainChartDisplay()
{
   Cleanup();
}

//+------------------------------------------------------------------+
//| Initialize the main chart display                                |
//+------------------------------------------------------------------+
bool CMainChartDisplay::Init(long chart_id = 0, string object_prefix = "MAIN")
{
   m_chart_id = (chart_id == 0) ? ChartID() : chart_id;
   m_object_prefix = object_prefix;
   
   if(!IsValidChart())
   {
      PrintFormat("MainChartDisplay::Init() - Invalid chart ID: %I64d", m_chart_id);
      return false;
   }
   
   PrintFormat("MainChartDisplay initialized for chart %I64d", m_chart_id);
   return true;
}

//+------------------------------------------------------------------+
//| Cleanup all main chart display objects                           |
//+------------------------------------------------------------------+
void CMainChartDisplay::Cleanup()
{
   if(m_chart_id == 0) return;
   
   // Remove all objects with our prefix from the main window (index 0)
   int objects_total = ObjectsTotal(m_chart_id, 0);
   for(int i = objects_total - 1; i >= 0; i--)
   {
      string obj_name = ObjectName(m_chart_id, i, 0);
      if(StringFind(obj_name, m_object_prefix) == 0)
      {
         ObjectDelete(m_chart_id, obj_name);
      }
   }
   
   ChartRedraw(m_chart_id);
}

//+------------------------------------------------------------------+
//| Set color scheme for main chart elements                         |
//+------------------------------------------------------------------+
void CMainChartDisplay::SetColors(color bb_upper = clrBlue, color bb_middle = clrYellow, color bb_lower = clrBlue,
                                 color entry_bull = clrLimeGreen, color entry_bear = clrRed, color exit = clrOrange)
{
   m_bb_upper_color = bb_upper;
   m_bb_middle_color = bb_middle;
   m_bb_lower_color = bb_lower;
   m_entry_bull_color = entry_bull;
   m_entry_bear_color = entry_bear;
   m_exit_color = exit;
}

//+------------------------------------------------------------------+
//| Configure display options                                        |
//+------------------------------------------------------------------+
void CMainChartDisplay::SetDisplayOptions(bool show_bb = true, bool show_entry = true, 
                                          bool show_exit = true, bool show_levels = false)
{
   m_show_bollinger = show_bb;
   m_show_entry_signals = show_entry;
   m_show_exit_signals = show_exit;
   m_show_price_levels = show_levels;
}

//+------------------------------------------------------------------+
//| Set signal arrow size                                            |
//+------------------------------------------------------------------+
void CMainChartDisplay::SetSignalArrowSize(int size = 2)
{
   m_signal_arrow_size = MathMax(1, MathMin(5, size)); // Clamp between 1 and 5
}

//+------------------------------------------------------------------+
//| Draw Bollinger Bands on main chart                               |
//+------------------------------------------------------------------+
bool CMainChartDisplay::DrawBollingerBands(const double upper_band, const double middle_band, const double lower_band,
                                           const datetime bar_time, const int bar_shift = 0)
{
   if(!IsValidChart() || !m_show_bollinger) return false;
   
   // Create trend line objects for each Bollinger Band
   string upper_line = GetObjectName(StringFormat("BB_Upper_%d", bar_shift));
   string middle_line = GetObjectName(StringFormat("BB_Middle_%d", bar_shift));
   string lower_line = GetObjectName(StringFormat("BB_Lower_%d", bar_shift));
   
   // Draw Upper Bollinger Band
   if(ObjectCreate(m_chart_id, upper_line, OBJ_TREND, 0, bar_time, upper_band, bar_time, upper_band))
   {
      ObjectSetInteger(m_chart_id, upper_line, OBJPROP_COLOR, m_bb_upper_color);
      ObjectSetInteger(m_chart_id, upper_line, OBJPROP_WIDTH, 1);
      ObjectSetInteger(m_chart_id, upper_line, OBJPROP_STYLE, STYLE_SOLID);
   }
   
   // Draw Middle Bollinger Band (SMA)
   if(ObjectCreate(m_chart_id, middle_line, OBJ_TREND, 0, bar_time, middle_band, bar_time, middle_band))
   {
      ObjectSetInteger(m_chart_id, middle_line, OBJPROP_COLOR, m_bb_middle_color);
      ObjectSetInteger(m_chart_id, middle_line, OBJPROP_WIDTH, 1);
      ObjectSetInteger(m_chart_id, middle_line, OBJPROP_STYLE, STYLE_DASH);
   }
   
   // Draw Lower Bollinger Band
   if(ObjectCreate(m_chart_id, lower_line, OBJ_TREND, 0, bar_time, lower_band, bar_time, lower_band))
   {
      ObjectSetInteger(m_chart_id, lower_line, OBJPROP_COLOR, m_bb_lower_color);
      ObjectSetInteger(m_chart_id, lower_line, OBJPROP_WIDTH, 1);
      ObjectSetInteger(m_chart_id, lower_line, OBJPROP_STYLE, STYLE_SOLID);
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Draw filled area between Bollinger Bands                        |
//+------------------------------------------------------------------+
bool CMainChartDisplay::DrawBollingerBandFill(const double upper_band, const double lower_band, 
                                              const datetime start_time, const datetime end_time)
{
   if(!IsValidChart() || !m_show_bollinger) return false;
   
   string fill_name = GetObjectName(StringFormat("BB_Fill_%I64d", start_time));
   
   // Create a rectangle between upper and lower bands
   if(ObjectCreate(m_chart_id, fill_name, OBJ_RECTANGLE, 0, start_time, upper_band, end_time, lower_band))
   {
      ObjectSetInteger(m_chart_id, fill_name, OBJPROP_COLOR, clrLightBlue);
      ObjectSetInteger(m_chart_id, fill_name, OBJPROP_FILL, true);
      ObjectSetInteger(m_chart_id, fill_name, OBJPROP_BACK, true);
      ObjectSetInteger(m_chart_id, fill_name, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSetInteger(m_chart_id, fill_name, OBJPROP_WIDTH, 1);
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Draw entry signal arrow on main chart                            |
//+------------------------------------------------------------------+
bool CMainChartDisplay::DrawEntrySignal(const datetime bar_time, const double price, const bool is_bullish, 
                                        const string signal_description = "")
{
   if(!IsValidChart() || !m_show_entry_signals) return false;
   
   string signal_name = GetObjectName(StringFormat("Entry_%s_%I64d", 
                                     is_bullish ? "Bull" : "Bear", bar_time));
   
   int arrow_code = is_bullish ? 233 : 234; // Up or down arrow
   color arrow_color = is_bullish ? m_entry_bull_color : m_entry_bear_color;
   
   if(ObjectCreate(m_chart_id, signal_name, OBJ_ARROW, 0, bar_time, price))
   {
      ObjectSetInteger(m_chart_id, signal_name, OBJPROP_ARROWCODE, arrow_code);
      ObjectSetInteger(m_chart_id, signal_name, OBJPROP_COLOR, arrow_color);
      ObjectSetInteger(m_chart_id, signal_name, OBJPROP_WIDTH, m_signal_arrow_size);
      ObjectSetString(m_chart_id, signal_name, OBJPROP_TEXT, 
                     "Entry " + (is_bullish ? "BUY" : "SELL") + 
                     (signal_description != "" ? ": " + signal_description : ""));
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Draw exit signal on main chart                                   |
//+------------------------------------------------------------------+
bool CMainChartDisplay::DrawExitSignal(const datetime bar_time, const double price, const bool is_profit,
                                       const string exit_reason = "")
{
   if(!IsValidChart() || !m_show_exit_signals) return false;
   
   string signal_name = GetObjectName(StringFormat("Exit_%s_%I64d", 
                                     is_profit ? "Profit" : "Loss", bar_time));
   
   int arrow_code = 159; // Circle marker
   color arrow_color = is_profit ? clrGreen : clrRed;
   
   if(ObjectCreate(m_chart_id, signal_name, OBJ_ARROW, 0, bar_time, price))
   {
      ObjectSetInteger(m_chart_id, signal_name, OBJPROP_ARROWCODE, arrow_code);
      ObjectSetInteger(m_chart_id, signal_name, OBJPROP_COLOR, arrow_color);
      ObjectSetInteger(m_chart_id, signal_name, OBJPROP_WIDTH, m_signal_arrow_size);
      ObjectSetString(m_chart_id, signal_name, OBJPROP_TEXT, 
                     "Exit " + (is_profit ? "PROFIT" : "LOSS") + 
                     (exit_reason != "" ? ": " + exit_reason : ""));
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Draw horizontal price level line                                 |
//+------------------------------------------------------------------+
bool CMainChartDisplay::DrawPriceLevelLine(const double level_price, const string level_name, 
                                           const color level_color = clrDarkGray, const ENUM_LINE_STYLE style = STYLE_DASH)
{
   if(!IsValidChart() || !m_show_price_levels) return false;
   
   string line_name = GetObjectName("Level_" + level_name);
   
   if(ObjectCreate(m_chart_id, line_name, OBJ_HLINE, 0, 0, level_price))
   {
      ObjectSetInteger(m_chart_id, line_name, OBJPROP_COLOR, level_color);
      ObjectSetInteger(m_chart_id, line_name, OBJPROP_STYLE, style);
      ObjectSetInteger(m_chart_id, line_name, OBJPROP_WIDTH, 1);
      ObjectSetString(m_chart_id, line_name, OBJPROP_TEXT, level_name);
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Draw support/resistance levels                                   |
//+------------------------------------------------------------------+
bool CMainChartDisplay::DrawSupportResistance(const double level_price, const string level_type, 
                                              const datetime start_time, const datetime end_time)
{
   if(!IsValidChart() || !m_show_price_levels) return false;
   
   string level_name = GetObjectName(StringFormat("%s_%.5f", level_type, level_price));
   color level_color = (level_type == "Support") ? clrLimeGreen : clrRed;
   
   if(ObjectCreate(m_chart_id, level_name, OBJ_TREND, 0, start_time, level_price, end_time, level_price))
   {
      ObjectSetInteger(m_chart_id, level_name, OBJPROP_COLOR, level_color);
      ObjectSetInteger(m_chart_id, level_name, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSetInteger(m_chart_id, level_name, OBJPROP_WIDTH, 2);
      ObjectSetInteger(m_chart_id, level_name, OBJPROP_RAY_RIGHT, true);
      ObjectSetString(m_chart_id, level_name, OBJPROP_TEXT, level_type);
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Draw trend line                                                  |
//+------------------------------------------------------------------+
bool CMainChartDisplay::DrawTrendLine(const datetime time1, const double price1, 
                                      const datetime time2, const double price2, const string trend_name)
{
   if(!IsValidChart()) return false;
   
   string line_name = GetObjectName("Trend_" + trend_name);
   
   if(ObjectCreate(m_chart_id, line_name, OBJ_TREND, 0, time1, price1, time2, price2))
   {
      ObjectSetInteger(m_chart_id, line_name, OBJPROP_COLOR, clrYellow);
      ObjectSetInteger(m_chart_id, line_name, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSetInteger(m_chart_id, line_name, OBJPROP_WIDTH, 1);
      ObjectSetInteger(m_chart_id, line_name, OBJPROP_RAY_RIGHT, true);
      ObjectSetString(m_chart_id, line_name, OBJPROP_TEXT, trend_name);
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Update the main chart display                                    |
//+------------------------------------------------------------------+
bool CMainChartDisplay::UpdateDisplay(const double bb_upper, const double bb_middle, const double bb_lower,
                                      const datetime bar_time, const int bar_shift = 0)
{
   bool result = true;
   
   // Draw Bollinger Bands if enabled
   if(m_show_bollinger)
   {
      result &= DrawBollingerBands(bb_upper, bb_middle, bb_lower, bar_time, bar_shift);
   }
   
   ChartRedraw(m_chart_id);
   return result;
}

//+------------------------------------------------------------------+
//| Clear all display objects                                        |
//+------------------------------------------------------------------+
bool CMainChartDisplay::ClearDisplay()
{
   Cleanup();
   return true;
}

//+------------------------------------------------------------------+
//| Clear only trading signal objects                                |
//+------------------------------------------------------------------+
bool CMainChartDisplay::ClearSignals()
{
   if(m_chart_id == 0) return false;
   
   // Remove only signal objects
   int objects_total = ObjectsTotal(m_chart_id, 0);
   for(int i = objects_total - 1; i >= 0; i--)
   {
      string obj_name = ObjectName(m_chart_id, i, 0);
      if(StringFind(obj_name, m_object_prefix + "_Entry_") == 0 ||
         StringFind(obj_name, m_object_prefix + "_Exit_") == 0)
      {
         ObjectDelete(m_chart_id, obj_name);
      }
   }
   
   ChartRedraw(m_chart_id);
   return true;
}

//+------------------------------------------------------------------+
//| Check if chart is valid                                          |
//+------------------------------------------------------------------+
bool CMainChartDisplay::IsValidChart() const
{
   return (m_chart_id > 0);
}

//+------------------------------------------------------------------+
//| Generate object name with prefix                                 |
//+------------------------------------------------------------------+
string CMainChartDisplay::GetObjectName(const string suffix) const
{
   return StringFormat("%s_%s", m_object_prefix, suffix);
}

//+------------------------------------------------------------------+
//| Remove specific object                                           |
//+------------------------------------------------------------------+
bool CMainChartDisplay::RemoveObject(const string object_name)
{
   return ObjectDelete(m_chart_id, object_name);
}

//+------------------------------------------------------------------+
//| Get current market price                                         |
//+------------------------------------------------------------------+
double CMainChartDisplay::GetCurrentPrice(const bool use_bid = true) const
{
   MqlTick last_tick;
   if(SymbolInfoTick(_Symbol, last_tick))
   {
      return use_bid ? last_tick.bid : last_tick.ask;
   }
   return 0.0;
}
