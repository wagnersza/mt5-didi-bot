//+------------------------------------------------------------------+
//|                                            StochasticDisplay.mqh |
//|                        Copyright 2024, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"

//+------------------------------------------------------------------+
//| Stochastic Display Class for dedicated Stochastic window         |
//| Handles %K and %D lines with overbought/oversold levels          |
//+------------------------------------------------------------------+
class CStochasticDisplay
{
protected:
   int               m_window_index;       // Window index for this display
   long              m_chart_id;           // Chart ID
   string            m_object_prefix;      // Prefix for object names
   
   // Drawing parameters
   color             m_k_line_color;       // %K line color
   color             m_d_line_color;       // %D line color
   color             m_level_color;        // Level lines color
   color             m_signal_color;       // Signal marker color
   
   // Display configuration
   double            m_overbought_level;   // Overbought level (typically 80)
   double            m_oversold_level;     // Oversold level (typically 20)
   bool              m_show_levels;        // Whether to show OB/OS levels
   bool              m_show_signals;       // Whether to show crossover signals
   bool              m_show_divergence;    // Whether to show divergence signals
   
public:
                     CStochasticDisplay();
                    ~CStochasticDisplay();
   
   // Initialization and cleanup
   bool              Init(long chart_id, int window_index, string object_prefix = "STOCH");
   void              Cleanup();
   
   // Configuration methods
   void              SetColors(color k_color = clrDodgerBlue, color d_color = clrRed, color level_color = clrDarkGray);
   void              SetLevels(double overbought = 80.0, double oversold = 20.0);
   void              SetDisplayOptions(bool show_levels = true, bool show_signals = true, bool show_divergence = false);
   
   // Drawing methods
   bool              DrawStochasticValues(const double k_value, const double d_value, 
                                         const datetime bar_time, const int bar_shift = 0);
   bool              DrawOverboughtOversoldLevels();
   bool              DrawCrossoverSignal(const datetime bar_time, const string signal_type, const bool is_bullish);
   bool              DrawDivergenceSignal(const datetime bar_time, const string div_type, const color div_color);
   
   // Update methods
   bool              UpdateDisplay(const double k_value, const double d_value, 
                                  const datetime bar_time, const int bar_shift = 0);
   bool              CheckAndDrawSignals(const double k_value, const double d_value, const datetime bar_time);
   bool              ClearDisplay();
   
   // Utility methods
   bool              IsValidWindow() const;
   string            GetObjectName(const string suffix) const;
   bool              RemoveObject(const string object_name);
   bool              IsOverbought(const double value) const;
   bool              IsOversold(const double value) const;
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CStochasticDisplay::CStochasticDisplay() : m_window_index(-1),
                                          m_chart_id(0),
                                          m_object_prefix("STOCH"),
                                          m_k_line_color(clrDodgerBlue),
                                          m_d_line_color(clrRed),
                                          m_level_color(clrDarkGray),
                                          m_signal_color(clrYellow),
                                          m_overbought_level(80.0),
                                          m_oversold_level(20.0),
                                          m_show_levels(true),
                                          m_show_signals(true),
                                          m_show_divergence(false)
{
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CStochasticDisplay::~CStochasticDisplay()
{
   Cleanup();
}

//+------------------------------------------------------------------+
//| Initialize the Stochastic display in specified window            |
//+------------------------------------------------------------------+
bool CStochasticDisplay::Init(long chart_id, int window_index, string object_prefix = "STOCH")
{
   m_chart_id = (chart_id == 0) ? ChartID() : chart_id;
   m_window_index = window_index;
   m_object_prefix = object_prefix;
   
   if(!IsValidWindow())
   {
      PrintFormat("StochasticDisplay::Init() - Invalid window index: %d", m_window_index);
      return false;
   }
   
   // Set window properties for oscillator display (0-100 range)
   ChartSetInteger(m_chart_id, CHART_WINDOW_YDISTANCE, m_window_index, 0);
   
   // Draw overbought/oversold levels if enabled
   if(m_show_levels)
   {
      DrawOverboughtOversoldLevels();
   }
   
   PrintFormat("StochasticDisplay initialized for window %d on chart %I64d", m_window_index, m_chart_id);
   return true;
}

//+------------------------------------------------------------------+
//| Cleanup all Stochastic display objects                           |
//+------------------------------------------------------------------+
void CStochasticDisplay::Cleanup()
{
   if(m_chart_id == 0 || m_window_index < 0) return;
   
   // Remove all objects with our prefix from the window
   int objects_total = ObjectsTotal(m_chart_id, m_window_index);
   for(int i = objects_total - 1; i >= 0; i--)
   {
      string obj_name = ObjectName(m_chart_id, i, m_window_index);
      if(StringFind(obj_name, m_object_prefix) == 0)
      {
         ObjectDelete(m_chart_id, obj_name);
      }
   }
   
   ChartRedraw(m_chart_id);
}

//+------------------------------------------------------------------+
//| Set color scheme for Stochastic lines                            |
//+------------------------------------------------------------------+
void CStochasticDisplay::SetColors(color k_color = clrDodgerBlue, color d_color = clrRed, color level_color = clrDarkGray)
{
   m_k_line_color = k_color;
   m_d_line_color = d_color;
   m_level_color = level_color;
}

//+------------------------------------------------------------------+
//| Set overbought and oversold levels                               |
//+------------------------------------------------------------------+
void CStochasticDisplay::SetLevels(double overbought = 80.0, double oversold = 20.0)
{
   m_overbought_level = overbought;
   m_oversold_level = oversold;
}

//+------------------------------------------------------------------+
//| Configure display options                                        |
//+------------------------------------------------------------------+
void CStochasticDisplay::SetDisplayOptions(bool show_levels = true, bool show_signals = true, bool show_divergence = false)
{
   m_show_levels = show_levels;
   m_show_signals = show_signals;
   m_show_divergence = show_divergence;
}

//+------------------------------------------------------------------+
//| Draw Stochastic %K and %D values in the window                   |
//+------------------------------------------------------------------+
bool CStochasticDisplay::DrawStochasticValues(const double k_value, const double d_value, 
                                              const datetime bar_time, const int bar_shift = 0)
{
   if(!IsValidWindow()) return false;
   
   // Create trend line objects for %K and %D
   string k_line = GetObjectName(StringFormat("K_Line_%d", bar_shift));
   string d_line = GetObjectName(StringFormat("D_Line_%d", bar_shift));
   
   // Draw %K line point
   if(ObjectCreate(m_chart_id, k_line, OBJ_TREND, m_window_index, bar_time, k_value, bar_time, k_value))
   {
      ObjectSetInteger(m_chart_id, k_line, OBJPROP_COLOR, m_k_line_color);
      ObjectSetInteger(m_chart_id, k_line, OBJPROP_WIDTH, 1);
      ObjectSetInteger(m_chart_id, k_line, OBJPROP_STYLE, STYLE_SOLID);
   }
   
   // Draw %D line point
   if(ObjectCreate(m_chart_id, d_line, OBJ_TREND, m_window_index, bar_time, d_value, bar_time, d_value))
   {
      ObjectSetInteger(m_chart_id, d_line, OBJPROP_COLOR, m_d_line_color);
      ObjectSetInteger(m_chart_id, d_line, OBJPROP_WIDTH, 2);
      ObjectSetInteger(m_chart_id, d_line, OBJPROP_STYLE, STYLE_SOLID);
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Draw overbought and oversold levels                              |
//+------------------------------------------------------------------+
bool CStochasticDisplay::DrawOverboughtOversoldLevels()
{
   if(!IsValidWindow()) return false;
   
   // Overbought level (typically 80)
   string ob_level_name = GetObjectName("Overbought_Level");
   if(ObjectCreate(m_chart_id, ob_level_name, OBJ_HLINE, m_window_index, 0, m_overbought_level))
   {
      ObjectSetInteger(m_chart_id, ob_level_name, OBJPROP_COLOR, m_level_color);
      ObjectSetInteger(m_chart_id, ob_level_name, OBJPROP_STYLE, STYLE_DOT);
      ObjectSetInteger(m_chart_id, ob_level_name, OBJPROP_WIDTH, 1);
      ObjectSetString(m_chart_id, ob_level_name, OBJPROP_TEXT, StringFormat("OB %.0f", m_overbought_level));
   }
   
   // Oversold level (typically 20)
   string os_level_name = GetObjectName("Oversold_Level");
   if(ObjectCreate(m_chart_id, os_level_name, OBJ_HLINE, m_window_index, 0, m_oversold_level))
   {
      ObjectSetInteger(m_chart_id, os_level_name, OBJPROP_COLOR, m_level_color);
      ObjectSetInteger(m_chart_id, os_level_name, OBJPROP_STYLE, STYLE_DOT);
      ObjectSetInteger(m_chart_id, os_level_name, OBJPROP_WIDTH, 1);
      ObjectSetString(m_chart_id, os_level_name, OBJPROP_TEXT, StringFormat("OS %.0f", m_oversold_level));
   }
   
   // Midline (50)
   string mid_level_name = GetObjectName("Midline");
   if(ObjectCreate(m_chart_id, mid_level_name, OBJ_HLINE, m_window_index, 0, 50.0))
   {
      ObjectSetInteger(m_chart_id, mid_level_name, OBJPROP_COLOR, m_level_color);
      ObjectSetInteger(m_chart_id, mid_level_name, OBJPROP_STYLE, STYLE_DASHDOT);
      ObjectSetInteger(m_chart_id, mid_level_name, OBJPROP_WIDTH, 1);
      ObjectSetString(m_chart_id, mid_level_name, OBJPROP_TEXT, "Midline");
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Draw crossover signal marker                                     |
//+------------------------------------------------------------------+
bool CStochasticDisplay::DrawCrossoverSignal(const datetime bar_time, const string signal_type, const bool is_bullish)
{
   if(!IsValidWindow() || !m_show_signals) return false;
   
   string signal_name = GetObjectName(StringFormat("Signal_%s_%I64d", signal_type, bar_time));
   
   // Position marker based on signal type and zone
   double marker_level;
   int arrow_code;
   color marker_color;
   
   if(is_bullish)
   {
      marker_level = m_oversold_level - 5; // Below oversold level
      arrow_code = 233; // Up arrow
      marker_color = clrLimeGreen;
   }
   else
   {
      marker_level = m_overbought_level + 5; // Above overbought level
      arrow_code = 234; // Down arrow
      marker_color = clrRed;
   }
   
   if(ObjectCreate(m_chart_id, signal_name, OBJ_ARROW, m_window_index, bar_time, marker_level))
   {
      ObjectSetInteger(m_chart_id, signal_name, OBJPROP_ARROWCODE, arrow_code);
      ObjectSetInteger(m_chart_id, signal_name, OBJPROP_COLOR, marker_color);
      ObjectSetInteger(m_chart_id, signal_name, OBJPROP_WIDTH, 2);
      ObjectSetString(m_chart_id, signal_name, OBJPROP_TEXT, signal_type);
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Draw divergence signal                                           |
//+------------------------------------------------------------------+
bool CStochasticDisplay::DrawDivergenceSignal(const datetime bar_time, const string div_type, const color div_color)
{
   if(!IsValidWindow() || !m_show_divergence) return false;
   
   string div_name = GetObjectName(StringFormat("Divergence_%s_%I64d", div_type, bar_time));
   
   double marker_level = 50.0; // Midline position
   int arrow_code = 159; // Circle marker
   
   if(ObjectCreate(m_chart_id, div_name, OBJ_ARROW, m_window_index, bar_time, marker_level))
   {
      ObjectSetInteger(m_chart_id, div_name, OBJPROP_ARROWCODE, arrow_code);
      ObjectSetInteger(m_chart_id, div_name, OBJPROP_COLOR, div_color);
      ObjectSetInteger(m_chart_id, div_name, OBJPROP_WIDTH, 3);
      ObjectSetString(m_chart_id, div_name, OBJPROP_TEXT, "Divergence: " + div_type);
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Update the display with new Stochastic values                    |
//+------------------------------------------------------------------+
bool CStochasticDisplay::UpdateDisplay(const double k_value, const double d_value, 
                                      const datetime bar_time, const int bar_shift = 0)
{
   // Draw current values
   bool result = DrawStochasticValues(k_value, d_value, bar_time, bar_shift);
   
   // Check for signals and draw markers if enabled
   if(m_show_signals)
   {
      CheckAndDrawSignals(k_value, d_value, bar_time);
   }
   
   ChartRedraw(m_chart_id);
   return result;
}

//+------------------------------------------------------------------+
//| Check for Stochastic signals and draw markers                    |
//+------------------------------------------------------------------+
bool CStochasticDisplay::CheckAndDrawSignals(const double k_value, const double d_value, const datetime bar_time)
{
   bool signal_detected = false;
   
   // %K and %D crossover signals
   if(k_value > d_value)
   {
      // Bullish crossover in oversold zone
      if(IsOversold(k_value) && IsOversold(d_value))
      {
         DrawCrossoverSignal(bar_time, "K_over_D_Oversold", true);
         signal_detected = true;
      }
      // General bullish crossover
      else if(k_value < 50.0)
      {
         DrawCrossoverSignal(bar_time, "K_over_D_Bull", true);
         signal_detected = true;
      }
   }
   else if(d_value > k_value)
   {
      // Bearish crossover in overbought zone
      if(IsOverbought(k_value) && IsOverbought(d_value))
      {
         DrawCrossoverSignal(bar_time, "D_over_K_Overbought", false);
         signal_detected = true;
      }
      // General bearish crossover
      else if(k_value > 50.0)
      {
         DrawCrossoverSignal(bar_time, "D_over_K_Bear", false);
         signal_detected = true;
      }
   }
   
   // Overbought/Oversold zone entries
   if(IsOverbought(k_value) && IsOverbought(d_value))
   {
      DrawCrossoverSignal(bar_time, "Overbought_Zone", false);
      signal_detected = true;
   }
   else if(IsOversold(k_value) && IsOversold(d_value))
   {
      DrawCrossoverSignal(bar_time, "Oversold_Zone", true);
      signal_detected = true;
   }
   
   return signal_detected;
}

//+------------------------------------------------------------------+
//| Clear all display objects                                        |
//+------------------------------------------------------------------+
bool CStochasticDisplay::ClearDisplay()
{
   Cleanup();
   if(m_show_levels)
   {
      DrawOverboughtOversoldLevels();
   }
   return true;
}

//+------------------------------------------------------------------+
//| Check if window index is valid                                   |
//+------------------------------------------------------------------+
bool CStochasticDisplay::IsValidWindow() const
{
   return (m_chart_id > 0 && m_window_index >= 0);
}

//+------------------------------------------------------------------+
//| Generate object name with prefix                                 |
//+------------------------------------------------------------------+
string CStochasticDisplay::GetObjectName(const string suffix) const
{
   return StringFormat("%s_%s", m_object_prefix, suffix);
}

//+------------------------------------------------------------------+
//| Remove specific object                                           |
//+------------------------------------------------------------------+
bool CStochasticDisplay::RemoveObject(const string object_name)
{
   return ObjectDelete(m_chart_id, object_name);
}

//+------------------------------------------------------------------+
//| Check if value is in overbought zone                             |
//+------------------------------------------------------------------+
bool CStochasticDisplay::IsOverbought(const double value) const
{
   return (value >= m_overbought_level);
}

//+------------------------------------------------------------------+
//| Check if value is in oversold zone                               |
//+------------------------------------------------------------------+
bool CStochasticDisplay::IsOversold(const double value) const
{
   return (value <= m_oversold_level);
}
