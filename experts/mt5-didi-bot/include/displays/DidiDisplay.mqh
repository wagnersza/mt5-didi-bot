//+------------------------------------------------------------------+
//|                                                  DidiDisplay.mqh |
//|                        Copyright 2024, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"

//+------------------------------------------------------------------+
//| Didi Index Display Class for dedicated Didi window               |
//| Handles Short, Medium, Long MA visualization and agulhada signals|
//+------------------------------------------------------------------+
class CDidiDisplay
{
protected:
   int               m_window_index;       // Window index for this display
   long              m_chart_id;           // Chart ID
   string            m_object_prefix;      // Prefix for object names
   
   // Drawing parameters
   color             m_short_ma_color;     // Short MA line color (3-period)
   color             m_medium_ma_color;    // Medium MA line color (8-period)
   color             m_long_ma_color;      // Long MA line color (20-period)
   color             m_agulhada_color;     // Agulhada signal color
   color             m_reference_color;    // Reference level color
   
   // Display configuration
   bool              m_show_agulhada;      // Whether to show agulhada signals
   bool              m_show_crossovers;    // Whether to show MA crossover signals
   bool              m_normalize_display;  // Whether to normalize MA values for display
   
public:
                     CDidiDisplay();
                    ~CDidiDisplay();
   
   // Initialization and cleanup
   bool              Init(long chart_id, int window_index, string object_prefix = "DIDI");
   void              Cleanup();
   
   // Configuration methods
   void              SetColors(color short_color = clrRed, color medium_color = clrYellow, color long_color = clrLimeGreen);
   void              SetDisplayOptions(bool show_agulhada = true, bool show_crossovers = true, bool normalize = false);
   
   // Drawing methods
   bool              DrawDidiValues(const double short_ma, const double medium_ma, const double long_ma, 
                                   const datetime bar_time, const int bar_shift = 0);
   bool              DrawAgulhadaSignal(const datetime bar_time, const bool is_bullish);
   bool              DrawCrossoverSignal(const datetime bar_time, const string signal_type, const color signal_color);
   bool              DrawReferenceLine();
   
   // Update methods
   bool              UpdateDisplay(const double short_ma, const double medium_ma, const double long_ma, 
                                  const datetime bar_time, const int bar_shift = 0);
   bool              CheckAndDrawAgulhada(const double short_ma, const double medium_ma, const double long_ma, 
                                         const datetime bar_time);
   bool              ClearDisplay();
   
   // Utility methods
   bool              IsValidWindow() const;
   string            GetObjectName(const string suffix) const;
   bool              RemoveObject(const string object_name);
   double            NormalizeValue(const double value, const double reference) const;
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CDidiDisplay::CDidiDisplay() : m_window_index(-1),
                              m_chart_id(0),
                              m_object_prefix("DIDI"),
                              m_short_ma_color(clrRed),
                              m_medium_ma_color(clrYellow),
                              m_long_ma_color(clrLimeGreen),
                              m_agulhada_color(clrWhite),
                              m_reference_color(clrDarkGray),
                              m_show_agulhada(true),
                              m_show_crossovers(true),
                              m_normalize_display(false)
{
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CDidiDisplay::~CDidiDisplay()
{
   Cleanup();
}

//+------------------------------------------------------------------+
//| Initialize the Didi display in specified window                  |
//+------------------------------------------------------------------+
bool CDidiDisplay::Init(long chart_id, int window_index, string object_prefix = "DIDI")
{
   m_chart_id = (chart_id == 0) ? ChartID() : chart_id;
   m_window_index = window_index;
   m_object_prefix = object_prefix;
   
   if(!IsValidWindow())
   {
      PrintFormat("DidiDisplay::Init() - Invalid window index: %d", m_window_index);
      return false;
   }
   
   // Set window properties for MA display
   ChartSetInteger(m_chart_id, CHART_WINDOW_YDISTANCE, m_window_index, 0);
   
   // Draw reference line if normalized display
   if(m_normalize_display)
   {
      DrawReferenceLine();
   }
   
   PrintFormat("DidiDisplay initialized for window %d on chart %I64d", m_window_index, m_chart_id);
   return true;
}

//+------------------------------------------------------------------+
//| Cleanup all Didi display objects                                 |
//+------------------------------------------------------------------+
void CDidiDisplay::Cleanup()
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
//| Set color scheme for Didi MA lines                               |
//+------------------------------------------------------------------+
void CDidiDisplay::SetColors(color short_color = clrRed, color medium_color = clrYellow, color long_color = clrLimeGreen)
{
   m_short_ma_color = short_color;
   m_medium_ma_color = medium_color;
   m_long_ma_color = long_color;
}

//+------------------------------------------------------------------+
//| Configure display options                                        |
//+------------------------------------------------------------------+
void CDidiDisplay::SetDisplayOptions(bool show_agulhada = true, bool show_crossovers = true, bool normalize = false)
{
   m_show_agulhada = show_agulhada;
   m_show_crossovers = show_crossovers;
   m_normalize_display = normalize;
}

//+------------------------------------------------------------------+
//| Draw Didi Index MA values in the window                          |
//+------------------------------------------------------------------+
bool CDidiDisplay::DrawDidiValues(const double short_ma, const double medium_ma, const double long_ma, 
                                  const datetime bar_time, const int bar_shift = 0)
{
   if(!IsValidWindow()) return false;
   
   // Calculate display values (normalize if enabled)
   double display_short = m_normalize_display ? NormalizeValue(short_ma, medium_ma) : short_ma;
   double display_medium = m_normalize_display ? NormalizeValue(medium_ma, medium_ma) : medium_ma;
   double display_long = m_normalize_display ? NormalizeValue(long_ma, medium_ma) : long_ma;
   
   // Create trend line objects for each MA
   string short_line = GetObjectName(StringFormat("Short_MA_%d", bar_shift));
   string medium_line = GetObjectName(StringFormat("Medium_MA_%d", bar_shift));
   string long_line = GetObjectName(StringFormat("Long_MA_%d", bar_shift));
   
   // Draw Short MA (3-period) line point
   if(ObjectCreate(m_chart_id, short_line, OBJ_TREND, m_window_index, bar_time, display_short, bar_time, display_short))
   {
      ObjectSetInteger(m_chart_id, short_line, OBJPROP_COLOR, m_short_ma_color);
      ObjectSetInteger(m_chart_id, short_line, OBJPROP_WIDTH, 1);
      ObjectSetInteger(m_chart_id, short_line, OBJPROP_STYLE, STYLE_SOLID);
   }
   
   // Draw Medium MA (8-period) line point
   if(ObjectCreate(m_chart_id, medium_line, OBJ_TREND, m_window_index, bar_time, display_medium, bar_time, display_medium))
   {
      ObjectSetInteger(m_chart_id, medium_line, OBJPROP_COLOR, m_medium_ma_color);
      ObjectSetInteger(m_chart_id, medium_line, OBJPROP_WIDTH, 2);
      ObjectSetInteger(m_chart_id, medium_line, OBJPROP_STYLE, STYLE_SOLID);
   }
   
   // Draw Long MA (20-period) line point  
   if(ObjectCreate(m_chart_id, long_line, OBJ_TREND, m_window_index, bar_time, display_long, bar_time, display_long))
   {
      ObjectSetInteger(m_chart_id, long_line, OBJPROP_COLOR, m_long_ma_color);
      ObjectSetInteger(m_chart_id, long_line, OBJPROP_WIDTH, 1);
      ObjectSetInteger(m_chart_id, long_line, OBJPROP_STYLE, STYLE_SOLID);
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Draw agulhada signal marker                                      |
//+------------------------------------------------------------------+
bool CDidiDisplay::DrawAgulhadaSignal(const datetime bar_time, const bool is_bullish)
{
   if(!IsValidWindow() || !m_show_agulhada) return false;
   
   string signal_name = GetObjectName(StringFormat("Agulhada_%s_%I64d", 
                                     is_bullish ? "Bull" : "Bear", bar_time));
   
   // Position marker based on signal type
   double marker_level = 0;
   int arrow_code = is_bullish ? 233 : 234; // Up or down arrow
   color marker_color = is_bullish ? clrLimeGreen : clrRed;
   
   // Use a relative position for the marker
   if(m_normalize_display)
   {
      marker_level = is_bullish ? 1.01 : 0.99; // Above/below reference line
   }
   else
   {
      // For non-normalized display, we'll need to get current price levels
      // This is a simplified approach - in practice, you'd get current MA values
      marker_level = 0; // Will be adjusted based on current MA values
   }
   
   if(ObjectCreate(m_chart_id, signal_name, OBJ_ARROW, m_window_index, bar_time, marker_level))
   {
      ObjectSetInteger(m_chart_id, signal_name, OBJPROP_ARROWCODE, arrow_code);
      ObjectSetInteger(m_chart_id, signal_name, OBJPROP_COLOR, marker_color);
      ObjectSetInteger(m_chart_id, signal_name, OBJPROP_WIDTH, 3);
      ObjectSetString(m_chart_id, signal_name, OBJPROP_TEXT, "Agulhada " + (is_bullish ? "Bullish" : "Bearish"));
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Draw MA crossover signal                                         |
//+------------------------------------------------------------------+
bool CDidiDisplay::DrawCrossoverSignal(const datetime bar_time, const string signal_type, const color signal_color)
{
   if(!IsValidWindow() || !m_show_crossovers) return false;
   
   string signal_name = GetObjectName(StringFormat("Crossover_%s_%I64d", signal_type, bar_time));
   
   double marker_level = m_normalize_display ? 1.0 : 0; // Reference level
   int arrow_code = 159; // Circle marker
   
   if(ObjectCreate(m_chart_id, signal_name, OBJ_ARROW, m_window_index, bar_time, marker_level))
   {
      ObjectSetInteger(m_chart_id, signal_name, OBJPROP_ARROWCODE, arrow_code);
      ObjectSetInteger(m_chart_id, signal_name, OBJPROP_COLOR, signal_color);
      ObjectSetInteger(m_chart_id, signal_name, OBJPROP_WIDTH, 2);
      ObjectSetString(m_chart_id, signal_name, OBJPROP_TEXT, "MA Crossover: " + signal_type);
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Draw reference line for normalized display                       |
//+------------------------------------------------------------------+
bool CDidiDisplay::DrawReferenceLine()
{
   if(!IsValidWindow()) return false;
   
   string ref_line_name = GetObjectName("Reference_Line");
   if(ObjectCreate(m_chart_id, ref_line_name, OBJ_HLINE, m_window_index, 0, 1.0))
   {
      ObjectSetInteger(m_chart_id, ref_line_name, OBJPROP_COLOR, m_reference_color);
      ObjectSetInteger(m_chart_id, ref_line_name, OBJPROP_STYLE, STYLE_DASHDOT);
      ObjectSetInteger(m_chart_id, ref_line_name, OBJPROP_WIDTH, 1);
      ObjectSetString(m_chart_id, ref_line_name, OBJPROP_TEXT, "Medium MA Reference");
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Update the display with new Didi values                          |
//+------------------------------------------------------------------+
bool CDidiDisplay::UpdateDisplay(const double short_ma, const double medium_ma, const double long_ma, 
                                const datetime bar_time, const int bar_shift = 0)
{
   // Draw current values
   bool result = DrawDidiValues(short_ma, medium_ma, long_ma, bar_time, bar_shift);
   
   // Check for agulhada and crossover signals
   CheckAndDrawAgulhada(short_ma, medium_ma, long_ma, bar_time);
   
   ChartRedraw(m_chart_id);
   return result;
}

//+------------------------------------------------------------------+
//| Check for agulhada conditions and draw signals                   |
//+------------------------------------------------------------------+
bool CDidiDisplay::CheckAndDrawAgulhada(const double short_ma, const double medium_ma, const double long_ma, 
                                       const datetime bar_time)
{
   if(!m_show_agulhada) return false;
   
   // Agulhada conditions:
   // Bullish: Short MA > Medium MA > Long MA (all MAs in ascending order)
   // Bearish: Short MA < Medium MA < Long MA (all MAs in descending order)
   
   bool bullish_agulhada = (short_ma > medium_ma) && (medium_ma > long_ma);
   bool bearish_agulhada = (short_ma < medium_ma) && (medium_ma < long_ma);
   
   if(bullish_agulhada)
   {
      DrawAgulhadaSignal(bar_time, true);
      if(m_show_crossovers)
         DrawCrossoverSignal(bar_time, "Bullish_Alignment", clrLimeGreen);
   }
   else if(bearish_agulhada)
   {
      DrawAgulhadaSignal(bar_time, false);
      if(m_show_crossovers)
         DrawCrossoverSignal(bar_time, "Bearish_Alignment", clrRed);
   }
   
   return (bullish_agulhada || bearish_agulhada);
}

//+------------------------------------------------------------------+
//| Clear all display objects                                        |
//+------------------------------------------------------------------+
bool CDidiDisplay::ClearDisplay()
{
   Cleanup();
   if(m_normalize_display)
   {
      DrawReferenceLine();
   }
   return true;
}

//+------------------------------------------------------------------+
//| Check if window index is valid                                   |
//+------------------------------------------------------------------+
bool CDidiDisplay::IsValidWindow() const
{
   return (m_chart_id > 0 && m_window_index >= 0);
}

//+------------------------------------------------------------------+
//| Generate object name with prefix                                 |
//+------------------------------------------------------------------+
string CDidiDisplay::GetObjectName(const string suffix) const
{
   return StringFormat("%s_%s", m_object_prefix, suffix);
}

//+------------------------------------------------------------------+
//| Remove specific object                                           |
//+------------------------------------------------------------------+
bool CDidiDisplay::RemoveObject(const string object_name)
{
   return ObjectDelete(m_chart_id, object_name);
}

//+------------------------------------------------------------------+
//| Normalize value relative to reference (for display purposes)     |
//+------------------------------------------------------------------+
double CDidiDisplay::NormalizeValue(const double value, const double reference) const
{
   if(reference == 0) return 1.0;
   return value / reference;
}
