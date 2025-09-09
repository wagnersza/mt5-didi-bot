//+------------------------------------------------------------------+
//|                                                   IfrDisplay.mqh |
//|                        Copyright 2024, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"

//+------------------------------------------------------------------+
//| IFR (RSI) Display Class for dedicated IFR indicator window       |
//| Handles IFR line with overbought/oversold levels and divergence  |
//+------------------------------------------------------------------+
class CIfrDisplay
{
protected:
   int               m_window_index;       // Window index for this display
   long              m_chart_id;           // Chart ID
   string            m_object_prefix;      // Prefix for object names
   
   // Drawing parameters
   color             m_ifr_color;          // IFR line color
   color             m_level_color;        // Level lines color
   color             m_signal_color;       // Signal marker color
   color             m_divergence_color;   // Divergence marker color
   
   // Display configuration
   double            m_overbought_level;   // Overbought level (typically 70)
   double            m_oversold_level;     // Oversold level (typically 30)
   bool              m_show_levels;        // Whether to show OB/OS levels
   bool              m_show_signals;       // Whether to show entry/exit signals
   bool              m_show_divergence;    // Whether to show divergence signals
   
public:
                     CIfrDisplay();
                    ~CIfrDisplay();
   
   // Initialization and cleanup
   bool              Init(long chart_id, int window_index, string object_prefix = "IFR");
   void              Cleanup();
   
   // Configuration methods
   void              SetColors(color ifr_color = clrDodgerBlue, color level_color = clrDarkGray, 
                              color signal_color = clrYellow, color div_color = clrMagenta);
   void              SetLevels(double overbought = 70.0, double oversold = 30.0);
   void              SetDisplayOptions(bool show_levels = true, bool show_signals = true, bool show_divergence = true);
   
   // Drawing methods
   bool              DrawIfrValue(const double ifr_value, const datetime bar_time, const int bar_shift = 0);
   bool              DrawOverboughtOversoldLevels();
   bool              DrawSignalMarker(const datetime bar_time, const string signal_type, const bool is_bullish);
   bool              DrawDivergenceSignal(const datetime bar_time, const string div_type, const color div_color);
   
   // Update methods
   bool              UpdateDisplay(const double ifr_value, const datetime bar_time, const int bar_shift = 0);
   bool              CheckAndDrawSignals(const double ifr_value, const datetime bar_time);
   bool              ClearDisplay();
   
   // Utility methods
   bool              IsValidWindow() const;
   string            GetObjectName(const string suffix) const;
   bool              RemoveObject(const string object_name);
   bool              IsOverbought(const double value) const;
   bool              IsOversold(const double value) const;
   bool              IsNeutral(const double value) const;
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CIfrDisplay::CIfrDisplay() : m_window_index(-1),
                            m_chart_id(0),
                            m_object_prefix("IFR"),
                            m_ifr_color(clrDodgerBlue),
                            m_level_color(clrDarkGray),
                            m_signal_color(clrYellow),
                            m_divergence_color(clrMagenta),
                            m_overbought_level(70.0),
                            m_oversold_level(30.0),
                            m_show_levels(true),
                            m_show_signals(true),
                            m_show_divergence(true)
{
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CIfrDisplay::~CIfrDisplay()
{
   Cleanup();
}

//+------------------------------------------------------------------+
//| Initialize the IFR display in specified window                   |
//+------------------------------------------------------------------+
bool CIfrDisplay::Init(long chart_id, int window_index, string object_prefix = "IFR")
{
   m_chart_id = (chart_id == 0) ? ChartID() : chart_id;
   m_window_index = window_index;
   m_object_prefix = object_prefix;
   
   if(!IsValidWindow())
   {
      PrintFormat("IfrDisplay::Init() - Invalid window index: %d", m_window_index);
      return false;
   }
   
   // Set window properties for oscillator display (0-100 range)
   ChartSetInteger(m_chart_id, CHART_WINDOW_YDISTANCE, m_window_index, 0);
   
   // Draw overbought/oversold levels if enabled
   if(m_show_levels)
   {
      DrawOverboughtOversoldLevels();
   }
   
   PrintFormat("IfrDisplay initialized for window %d on chart %I64d", m_window_index, m_chart_id);
   return true;
}

//+------------------------------------------------------------------+
//| Cleanup all IFR display objects                                  |
//+------------------------------------------------------------------+
void CIfrDisplay::Cleanup()
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
//| Set color scheme for IFR display                                 |
//+------------------------------------------------------------------+
void CIfrDisplay::SetColors(color ifr_color = clrDodgerBlue, color level_color = clrDarkGray, 
                           color signal_color = clrYellow, color div_color = clrMagenta)
{
   m_ifr_color = ifr_color;
   m_level_color = level_color;
   m_signal_color = signal_color;
   m_divergence_color = div_color;
}

//+------------------------------------------------------------------+
//| Set overbought and oversold levels                               |
//+------------------------------------------------------------------+
void CIfrDisplay::SetLevels(double overbought = 70.0, double oversold = 30.0)
{
   m_overbought_level = overbought;
   m_oversold_level = oversold;
}

//+------------------------------------------------------------------+
//| Configure display options                                        |
//+------------------------------------------------------------------+
void CIfrDisplay::SetDisplayOptions(bool show_levels = true, bool show_signals = true, bool show_divergence = true)
{
   m_show_levels = show_levels;
   m_show_signals = show_signals;
   m_show_divergence = show_divergence;
}

//+------------------------------------------------------------------+
//| Draw IFR value in the window                                     |
//+------------------------------------------------------------------+
bool CIfrDisplay::DrawIfrValue(const double ifr_value, const datetime bar_time, const int bar_shift = 0)
{
   if(!IsValidWindow()) return false;
   
   // Create trend line object for IFR
   string ifr_line = GetObjectName(StringFormat("IFR_Line_%d", bar_shift));
   
   // Draw IFR line point
   if(ObjectCreate(m_chart_id, ifr_line, OBJ_TREND, m_window_index, bar_time, ifr_value, bar_time, ifr_value))
   {
      ObjectSetInteger(m_chart_id, ifr_line, OBJPROP_COLOR, m_ifr_color);
      ObjectSetInteger(m_chart_id, ifr_line, OBJPROP_WIDTH, 2);
      ObjectSetInteger(m_chart_id, ifr_line, OBJPROP_STYLE, STYLE_SOLID);
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Draw overbought and oversold levels                              |
//+------------------------------------------------------------------+
bool CIfrDisplay::DrawOverboughtOversoldLevels()
{
   if(!IsValidWindow()) return false;
   
   // Overbought level (typically 70)
   string ob_level_name = GetObjectName("Overbought_Level");
   if(ObjectCreate(m_chart_id, ob_level_name, OBJ_HLINE, m_window_index, 0, m_overbought_level))
   {
      ObjectSetInteger(m_chart_id, ob_level_name, OBJPROP_COLOR, m_level_color);
      ObjectSetInteger(m_chart_id, ob_level_name, OBJPROP_STYLE, STYLE_DOT);
      ObjectSetInteger(m_chart_id, ob_level_name, OBJPROP_WIDTH, 1);
      ObjectSetString(m_chart_id, ob_level_name, OBJPROP_TEXT, StringFormat("OB %.0f", m_overbought_level));
   }
   
   // Oversold level (typically 30)
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
      ObjectSetString(m_chart_id, mid_level_name, OBJPROP_TEXT, "Midline 50");
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Draw signal marker                                               |
//+------------------------------------------------------------------+
bool CIfrDisplay::DrawSignalMarker(const datetime bar_time, const string signal_type, const bool is_bullish)
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
bool CIfrDisplay::DrawDivergenceSignal(const datetime bar_time, const string div_type, const color div_color)
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
      ObjectSetString(m_chart_id, div_name, OBJPROP_TEXT, "IFR Divergence: " + div_type);
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Update the display with new IFR value                            |
//+------------------------------------------------------------------+
bool CIfrDisplay::UpdateDisplay(const double ifr_value, const datetime bar_time, const int bar_shift = 0)
{
   // Draw current value
   bool result = DrawIfrValue(ifr_value, bar_time, bar_shift);
   
   // Check for signals and draw markers if enabled
   if(m_show_signals)
   {
      CheckAndDrawSignals(ifr_value, bar_time);
   }
   
   ChartRedraw(m_chart_id);
   return result;
}

//+------------------------------------------------------------------+
//| Check for IFR signals and draw markers                           |
//+------------------------------------------------------------------+
bool CIfrDisplay::CheckAndDrawSignals(const double ifr_value, const datetime bar_time)
{
   bool signal_detected = false;
   
   // Overbought/Oversold zone signals
   if(IsOverbought(ifr_value))
   {
      DrawSignalMarker(bar_time, "Overbought_Zone", false);
      signal_detected = true;
   }
   else if(IsOversold(ifr_value))
   {
      DrawSignalMarker(bar_time, "Oversold_Zone", true);
      signal_detected = true;
   }
   
   // Zone exit signals (returning to neutral)
   if(IsNeutral(ifr_value))
   {
      // This would typically require knowing the previous state
      // For now, we'll mark neutral zone entries
      DrawSignalMarker(bar_time, "Neutral_Zone", true);
      signal_detected = true;
   }
   
   // Extreme readings
   if(ifr_value >= 80.0)
   {
      DrawSignalMarker(bar_time, "Extreme_Overbought", false);
      signal_detected = true;
   }
   else if(ifr_value <= 20.0)
   {
      DrawSignalMarker(bar_time, "Extreme_Oversold", true);
      signal_detected = true;
   }
   
   // Midline crossings (bullish/bearish bias changes)
   if(ifr_value > 50.0)
   {
      // Could add logic to detect actual crossings with previous value
      // For now, mark when above midline (bullish bias)
   }
   else if(ifr_value < 50.0)
   {
      // Below midline (bearish bias)
   }
   
   return signal_detected;
}

//+------------------------------------------------------------------+
//| Clear all display objects                                        |
//+------------------------------------------------------------------+
bool CIfrDisplay::ClearDisplay()
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
bool CIfrDisplay::IsValidWindow() const
{
   return (m_chart_id > 0 && m_window_index >= 0);
}

//+------------------------------------------------------------------+
//| Generate object name with prefix                                 |
//+------------------------------------------------------------------+
string CIfrDisplay::GetObjectName(const string suffix) const
{
   return StringFormat("%s_%s", m_object_prefix, suffix);
}

//+------------------------------------------------------------------+
//| Remove specific object                                           |
//+------------------------------------------------------------------+
bool CIfrDisplay::RemoveObject(const string object_name)
{
   return ObjectDelete(m_chart_id, object_name);
}

//+------------------------------------------------------------------+
//| Check if value is in overbought zone                             |
//+------------------------------------------------------------------+
bool CIfrDisplay::IsOverbought(const double value) const
{
   return (value >= m_overbought_level);
}

//+------------------------------------------------------------------+
//| Check if value is in oversold zone                               |
//+------------------------------------------------------------------+
bool CIfrDisplay::IsOversold(const double value) const
{
   return (value <= m_oversold_level);
}

//+------------------------------------------------------------------+
//| Check if value is in neutral zone                                |
//+------------------------------------------------------------------+
bool CIfrDisplay::IsNeutral(const double value) const
{
   return (value > m_oversold_level && value < m_overbought_level);
}
