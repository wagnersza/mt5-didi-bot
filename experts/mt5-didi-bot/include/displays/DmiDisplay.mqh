//+------------------------------------------------------------------+
//|                                                   DmiDisplay.mqh |
//|                        Copyright 2024, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"

//+------------------------------------------------------------------+
//| DMI Display Class for dedicated DMI indicator window             |
//| Handles ADX, +DI, -DI visualization in separate window           |
//+------------------------------------------------------------------+
class CDmiDisplay
{
protected:
   int               m_window_index;       // Window index for this display
   long              m_chart_id;           // Chart ID
   string            m_object_prefix;      // Prefix for object names
   
   // Drawing parameters
   color             m_adx_color;          // ADX line color
   color             m_plus_di_color;      // +DI line color  
   color             m_minus_di_color;     // -DI line color
   color             m_level_color;        // Level lines color
   
   // Display configuration
   double            m_adx_threshold;      // ADX threshold level (typically 25)
   double            m_di_crossover_level; // DI crossover reference level (typically 50)
   bool              m_show_levels;        // Whether to show threshold levels
   bool              m_show_signals;       // Whether to show signal markers
   
public:
                     CDmiDisplay();
                    ~CDmiDisplay();
   
   // Initialization and cleanup
   bool              Init(long chart_id, int window_index, string object_prefix = "DMI");
   void              Cleanup();
   
   // Configuration methods
   void              SetColors(color adx_color = clrYellow, color plus_di_color = clrLimeGreen, color minus_di_color = clrRed);
   void              SetThresholds(double adx_threshold = 25.0, double di_level = 50.0);
   void              SetDisplayOptions(bool show_levels = true, bool show_signals = true);
   
   // Drawing methods
   bool              DrawDmiValues(const double adx_value, const double plus_di_value, const double minus_di_value, 
                                   const datetime bar_time, const int bar_shift = 0);
   bool              DrawThresholdLevels();
   bool              DrawSignalMarker(const datetime bar_time, const string signal_type, const color marker_color = clrWhite);
   
   // Update methods
   bool              UpdateDisplay(const double adx_value, const double plus_di_value, const double minus_di_value, 
                                   const datetime bar_time, const int bar_shift = 0);
   bool              ClearDisplay();
   
   // Utility methods
   bool              IsValidWindow() const;
   string            GetObjectName(const string suffix) const;
   bool              RemoveObject(const string object_name);
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CDmiDisplay::CDmiDisplay() : m_window_index(-1),
                            m_chart_id(0),
                            m_object_prefix("DMI"),
                            m_adx_color(clrYellow),
                            m_plus_di_color(clrLimeGreen),
                            m_minus_di_color(clrRed),
                            m_level_color(clrDarkGray),
                            m_adx_threshold(25.0),
                            m_di_crossover_level(50.0),
                            m_show_levels(true),
                            m_show_signals(true)
{
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CDmiDisplay::~CDmiDisplay()
{
   Cleanup();
}

//+------------------------------------------------------------------+
//| Initialize the DMI display in specified window                   |
//+------------------------------------------------------------------+
bool CDmiDisplay::Init(long chart_id, int window_index, string object_prefix = "DMI")
{
   m_chart_id = (chart_id == 0) ? ChartID() : chart_id;
   m_window_index = window_index;
   m_object_prefix = object_prefix;
   
   if(!IsValidWindow())
   {
      PrintFormat("DmiDisplay::Init() - Invalid window index: %d", m_window_index);
      return false;
   }
   
   // Set window properties for oscillator display (0-100 range)
   ChartSetInteger(m_chart_id, CHART_WINDOW_YDISTANCE, m_window_index, 0);
   
   // Draw threshold levels if enabled
   if(m_show_levels)
   {
      DrawThresholdLevels();
   }
   
   PrintFormat("DmiDisplay initialized for window %d on chart %I64d", m_window_index, m_chart_id);
   return true;
}

//+------------------------------------------------------------------+
//| Cleanup all DMI display objects                                  |
//+------------------------------------------------------------------+
void CDmiDisplay::Cleanup()
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
//| Set color scheme for DMI lines                                   |
//+------------------------------------------------------------------+
void CDmiDisplay::SetColors(color adx_color = clrYellow, color plus_di_color = clrLimeGreen, color minus_di_color = clrRed)
{
   m_adx_color = adx_color;
   m_plus_di_color = plus_di_color;
   m_minus_di_color = minus_di_color;
}

//+------------------------------------------------------------------+
//| Set threshold levels for signals                                 |
//+------------------------------------------------------------------+
void CDmiDisplay::SetThresholds(double adx_threshold = 25.0, double di_level = 50.0)
{
   m_adx_threshold = adx_threshold;
   m_di_crossover_level = di_level;
}

//+------------------------------------------------------------------+
//| Configure display options                                        |
//+------------------------------------------------------------------+
void CDmiDisplay::SetDisplayOptions(bool show_levels = true, bool show_signals = true)
{
   m_show_levels = show_levels;
   m_show_signals = show_signals;
}

//+------------------------------------------------------------------+
//| Draw DMI values as trend lines in the window                     |
//+------------------------------------------------------------------+
bool CDmiDisplay::DrawDmiValues(const double adx_value, const double plus_di_value, const double minus_di_value, 
                                const datetime bar_time, const int bar_shift = 0)
{
   if(!IsValidWindow()) return false;
   
   // Create trend line objects for each DMI component
   string adx_line = GetObjectName(StringFormat("ADX_Line_%d", bar_shift));
   string plus_di_line = GetObjectName(StringFormat("PlusDI_Line_%d", bar_shift));
   string minus_di_line = GetObjectName(StringFormat("MinusDI_Line_%d", bar_shift));
   
   // Draw ADX line point
   if(ObjectCreate(m_chart_id, adx_line, OBJ_TREND, m_window_index, bar_time, adx_value, bar_time, adx_value))
   {
      ObjectSetInteger(m_chart_id, adx_line, OBJPROP_COLOR, m_adx_color);
      ObjectSetInteger(m_chart_id, adx_line, OBJPROP_WIDTH, 2);
      ObjectSetInteger(m_chart_id, adx_line, OBJPROP_STYLE, STYLE_SOLID);
   }
   
   // Draw +DI line point
   if(ObjectCreate(m_chart_id, plus_di_line, OBJ_TREND, m_window_index, bar_time, plus_di_value, bar_time, plus_di_value))
   {
      ObjectSetInteger(m_chart_id, plus_di_line, OBJPROP_COLOR, m_plus_di_color);
      ObjectSetInteger(m_chart_id, plus_di_line, OBJPROP_WIDTH, 1);
      ObjectSetInteger(m_chart_id, plus_di_line, OBJPROP_STYLE, STYLE_SOLID);
   }
   
   // Draw -DI line point  
   if(ObjectCreate(m_chart_id, minus_di_line, OBJ_TREND, m_window_index, bar_time, minus_di_value, bar_time, minus_di_value))
   {
      ObjectSetInteger(m_chart_id, minus_di_line, OBJPROP_COLOR, m_minus_di_color);
      ObjectSetInteger(m_chart_id, minus_di_line, OBJPROP_WIDTH, 1);
      ObjectSetInteger(m_chart_id, minus_di_line, OBJPROP_STYLE, STYLE_SOLID);
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Draw threshold levels in the window                              |
//+------------------------------------------------------------------+
bool CDmiDisplay::DrawThresholdLevels()
{
   if(!IsValidWindow()) return false;
   
   // ADX threshold level (typically 25)
   string adx_level_name = GetObjectName("ADX_Threshold");
   if(ObjectCreate(m_chart_id, adx_level_name, OBJ_HLINE, m_window_index, 0, m_adx_threshold))
   {
      ObjectSetInteger(m_chart_id, adx_level_name, OBJPROP_COLOR, m_level_color);
      ObjectSetInteger(m_chart_id, adx_level_name, OBJPROP_STYLE, STYLE_DOT);
      ObjectSetInteger(m_chart_id, adx_level_name, OBJPROP_WIDTH, 1);
      ObjectSetString(m_chart_id, adx_level_name, OBJPROP_TEXT, StringFormat("ADX %.1f", m_adx_threshold));
   }
   
   // DI crossover reference level (50)
   string di_level_name = GetObjectName("DI_Reference");
   if(ObjectCreate(m_chart_id, di_level_name, OBJ_HLINE, m_window_index, 0, m_di_crossover_level))
   {
      ObjectSetInteger(m_chart_id, di_level_name, OBJPROP_COLOR, m_level_color);
      ObjectSetInteger(m_chart_id, di_level_name, OBJPROP_STYLE, STYLE_DASHDOT);
      ObjectSetInteger(m_chart_id, di_level_name, OBJPROP_WIDTH, 1);
      ObjectSetString(m_chart_id, di_level_name, OBJPROP_TEXT, "DI Reference");
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Draw signal marker in the window                                 |
//+------------------------------------------------------------------+
bool CDmiDisplay::DrawSignalMarker(const datetime bar_time, const string signal_type, const color marker_color = clrWhite)
{
   if(!IsValidWindow() || !m_show_signals) return false;
   
   string marker_name = GetObjectName(StringFormat("Signal_%s_%I64d", signal_type, bar_time));
   
   // Position marker at appropriate level based on signal type
   double marker_level = m_adx_threshold;
   int arrow_code = 233; // Default arrow
   
   if(signal_type == "ADX_Rising")
   {
      marker_level = m_adx_threshold + 5;
      arrow_code = 233; // Up arrow
   }
   else if(signal_type == "DI_Crossover_Bull")
   {
      marker_level = m_di_crossover_level + 10;
      arrow_code = 233; // Up arrow
   }
   else if(signal_type == "DI_Crossover_Bear")
   {
      marker_level = m_di_crossover_level - 10;
      arrow_code = 234; // Down arrow
   }
   
   if(ObjectCreate(m_chart_id, marker_name, OBJ_ARROW, m_window_index, bar_time, marker_level))
   {
      ObjectSetInteger(m_chart_id, marker_name, OBJPROP_ARROWCODE, arrow_code);
      ObjectSetInteger(m_chart_id, marker_name, OBJPROP_COLOR, marker_color);
      ObjectSetInteger(m_chart_id, marker_name, OBJPROP_WIDTH, 2);
      ObjectSetString(m_chart_id, marker_name, OBJPROP_TEXT, signal_type);
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Update the display with new DMI values                           |
//+------------------------------------------------------------------+
bool CDmiDisplay::UpdateDisplay(const double adx_value, const double plus_di_value, const double minus_di_value, 
                               const datetime bar_time, const int bar_shift = 0)
{
   // Draw current values
   bool result = DrawDmiValues(adx_value, plus_di_value, minus_di_value, bar_time, bar_shift);
   
   // Check for signals and draw markers if enabled
   if(m_show_signals)
   {
      // ADX rising above threshold
      if(adx_value > m_adx_threshold)
      {
         DrawSignalMarker(bar_time, "ADX_Rising", clrYellow);
      }
      
      // DI crossover signals
      if(plus_di_value > minus_di_value && plus_di_value > m_di_crossover_level)
      {
         DrawSignalMarker(bar_time, "DI_Crossover_Bull", clrLimeGreen);
      }
      else if(minus_di_value > plus_di_value && minus_di_value > m_di_crossover_level)
      {
         DrawSignalMarker(bar_time, "DI_Crossover_Bear", clrRed);
      }
   }
   
   ChartRedraw(m_chart_id);
   return result;
}

//+------------------------------------------------------------------+
//| Clear all display objects                                        |
//+------------------------------------------------------------------+
bool CDmiDisplay::ClearDisplay()
{
   Cleanup();
   if(m_show_levels)
   {
      DrawThresholdLevels();
   }
   return true;
}

//+------------------------------------------------------------------+
//| Check if window index is valid                                   |
//+------------------------------------------------------------------+
bool CDmiDisplay::IsValidWindow() const
{
   return (m_chart_id > 0 && m_window_index >= 0);
}

//+------------------------------------------------------------------+
//| Generate object name with prefix                                 |
//+------------------------------------------------------------------+
string CDmiDisplay::GetObjectName(const string suffix) const
{
   return StringFormat("%s_%s", m_object_prefix, suffix);
}

//+------------------------------------------------------------------+
//| Remove specific object                                           |
//+------------------------------------------------------------------+
bool CDmiDisplay::RemoveObject(const string object_name)
{
   return ObjectDelete(m_chart_id, object_name);
}
