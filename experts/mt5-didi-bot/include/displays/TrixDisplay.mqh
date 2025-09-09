//+------------------------------------------------------------------+
//|                                                  TrixDisplay.mqh |
//|                        Copyright 2024, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"

//+------------------------------------------------------------------+
//| TRIX Display Class for dedicated TRIX indicator window           |
//| Handles TRIX line with signal line and zero-line crossover       |
//+------------------------------------------------------------------+
class CTrixDisplay
{
protected:
   int               m_window_index;       // Window index for this display
   long              m_chart_id;           // Chart ID
   string            m_object_prefix;      // Prefix for object names
   
   // Drawing parameters
   color             m_trix_color;         // TRIX line color
   color             m_signal_color;       // TRIX signal line color
   color             m_zero_line_color;    // Zero line color
   color             m_signal_marker_color;// Signal marker color
   
   // Display configuration
   bool              m_show_zero_line;     // Whether to show zero line
   bool              m_show_signal_line;   // Whether to show signal line
   bool              m_show_crossovers;    // Whether to show crossover signals
   bool              m_show_momentum;      // Whether to show momentum signals
   
   // TRIX parameters
   double            m_momentum_threshold; // Threshold for momentum signals
   
public:
                     CTrixDisplay();
                    ~CTrixDisplay();
   
   // Initialization and cleanup
   bool              Init(long chart_id, int window_index, string object_prefix = "TRIX");
   void              Cleanup();
   
   // Configuration methods
   void              SetColors(color trix_color = clrLimeGreen, color signal_color = clrRed, color zero_color = clrDarkGray);
   void              SetDisplayOptions(bool show_zero = true, bool show_signal = true, 
                                      bool show_crossovers = true, bool show_momentum = true);
   void              SetMomentumThreshold(double threshold = 0.0001);
   
   // Drawing methods
   bool              DrawTrixValues(const double trix_value, const double signal_value, 
                                   const datetime bar_time, const int bar_shift = 0);
   bool              DrawZeroLine();
   bool              DrawCrossoverSignal(const datetime bar_time, const string signal_type, const bool is_bullish);
   bool              DrawMomentumSignal(const datetime bar_time, const string momentum_type, const color signal_color);
   
   // Update methods
   bool              UpdateDisplay(const double trix_value, const double signal_value, 
                                  const datetime bar_time, const int bar_shift = 0);
   bool              CheckAndDrawSignals(const double trix_value, const double signal_value, 
                                        const datetime bar_time, const double prev_trix = 0);
   bool              ClearDisplay();
   
   // Utility methods
   bool              IsValidWindow() const;
   string            GetObjectName(const string suffix) const;
   bool              RemoveObject(const string object_name);
   bool              IsAboveZero(const double value) const;
   bool              IsBelowZero(const double value) const;
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CTrixDisplay::CTrixDisplay() : m_window_index(-1),
                              m_chart_id(0),
                              m_object_prefix("TRIX"),
                              m_trix_color(clrLimeGreen),
                              m_signal_color(clrRed),
                              m_zero_line_color(clrDarkGray),
                              m_signal_marker_color(clrYellow),
                              m_show_zero_line(true),
                              m_show_signal_line(true),
                              m_show_crossovers(true),
                              m_show_momentum(true),
                              m_momentum_threshold(0.0001)
{
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CTrixDisplay::~CTrixDisplay()
{
   Cleanup();
}

//+------------------------------------------------------------------+
//| Initialize the TRIX display in specified window                  |
//+------------------------------------------------------------------+
bool CTrixDisplay::Init(long chart_id, int window_index, string object_prefix = "TRIX")
{
   m_chart_id = (chart_id == 0) ? ChartID() : chart_id;
   m_window_index = window_index;
   m_object_prefix = object_prefix;
   
   if(!IsValidWindow())
   {
      PrintFormat("TrixDisplay::Init() - Invalid window index: %d", m_window_index);
      return false;
   }
   
   // Set window properties for oscillator display
   ChartSetInteger(m_chart_id, CHART_WINDOW_YDISTANCE, m_window_index, 0);
   
   // Draw zero line if enabled
   if(m_show_zero_line)
   {
      DrawZeroLine();
   }
   
   PrintFormat("TrixDisplay initialized for window %d on chart %I64d", m_window_index, m_chart_id);
   return true;
}

//+------------------------------------------------------------------+
//| Cleanup all TRIX display objects                                 |
//+------------------------------------------------------------------+
void CTrixDisplay::Cleanup()
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
//| Set color scheme for TRIX lines                                  |
//+------------------------------------------------------------------+
void CTrixDisplay::SetColors(color trix_color = clrLimeGreen, color signal_color = clrRed, color zero_color = clrDarkGray)
{
   m_trix_color = trix_color;
   m_signal_color = signal_color;
   m_zero_line_color = zero_color;
}

//+------------------------------------------------------------------+
//| Configure display options                                        |
//+------------------------------------------------------------------+
void CTrixDisplay::SetDisplayOptions(bool show_zero = true, bool show_signal = true, 
                                     bool show_crossovers = true, bool show_momentum = true)
{
   m_show_zero_line = show_zero;
   m_show_signal_line = show_signal;
   m_show_crossovers = show_crossovers;
   m_show_momentum = show_momentum;
}

//+------------------------------------------------------------------+
//| Set momentum detection threshold                                  |
//+------------------------------------------------------------------+
void CTrixDisplay::SetMomentumThreshold(double threshold = 0.0001)
{
   m_momentum_threshold = threshold;
}

//+------------------------------------------------------------------+
//| Draw TRIX and signal values in the window                        |
//+------------------------------------------------------------------+
bool CTrixDisplay::DrawTrixValues(const double trix_value, const double signal_value, 
                                  const datetime bar_time, const int bar_shift = 0)
{
   if(!IsValidWindow()) return false;
   
   // Create trend line objects for TRIX and signal line
   string trix_line = GetObjectName(StringFormat("TRIX_Line_%d", bar_shift));
   string signal_line = GetObjectName(StringFormat("Signal_Line_%d", bar_shift));
   
   // Draw TRIX line point
   if(ObjectCreate(m_chart_id, trix_line, OBJ_TREND, m_window_index, bar_time, trix_value, bar_time, trix_value))
   {
      ObjectSetInteger(m_chart_id, trix_line, OBJPROP_COLOR, m_trix_color);
      ObjectSetInteger(m_chart_id, trix_line, OBJPROP_WIDTH, 2);
      ObjectSetInteger(m_chart_id, trix_line, OBJPROP_STYLE, STYLE_SOLID);
   }
   
   // Draw signal line point if enabled
   if(m_show_signal_line && signal_value != 0)
   {
      if(ObjectCreate(m_chart_id, signal_line, OBJ_TREND, m_window_index, bar_time, signal_value, bar_time, signal_value))
      {
         ObjectSetInteger(m_chart_id, signal_line, OBJPROP_COLOR, m_signal_color);
         ObjectSetInteger(m_chart_id, signal_line, OBJPROP_WIDTH, 1);
         ObjectSetInteger(m_chart_id, signal_line, OBJPROP_STYLE, STYLE_DASH);
      }
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Draw zero line reference                                         |
//+------------------------------------------------------------------+
bool CTrixDisplay::DrawZeroLine()
{
   if(!IsValidWindow()) return false;
   
   string zero_line_name = GetObjectName("Zero_Line");
   if(ObjectCreate(m_chart_id, zero_line_name, OBJ_HLINE, m_window_index, 0, 0.0))
   {
      ObjectSetInteger(m_chart_id, zero_line_name, OBJPROP_COLOR, m_zero_line_color);
      ObjectSetInteger(m_chart_id, zero_line_name, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSetInteger(m_chart_id, zero_line_name, OBJPROP_WIDTH, 1);
      ObjectSetString(m_chart_id, zero_line_name, OBJPROP_TEXT, "Zero Line");
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Draw crossover signal marker                                     |
//+------------------------------------------------------------------+
bool CTrixDisplay::DrawCrossoverSignal(const datetime bar_time, const string signal_type, const bool is_bullish)
{
   if(!IsValidWindow() || !m_show_crossovers) return false;
   
   string signal_name = GetObjectName(StringFormat("Crossover_%s_%I64d", signal_type, bar_time));
   
   // Position marker based on signal type
   double marker_level = is_bullish ? 0.0005 : -0.0005; // Slightly above/below zero line
   int arrow_code = is_bullish ? 233 : 234; // Up or down arrow
   color marker_color = is_bullish ? clrLimeGreen : clrRed;
   
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
//| Draw momentum signal marker                                      |
//+------------------------------------------------------------------+
bool CTrixDisplay::DrawMomentumSignal(const datetime bar_time, const string momentum_type, const color signal_color)
{
   if(!IsValidWindow() || !m_show_momentum) return false;
   
   string signal_name = GetObjectName(StringFormat("Momentum_%s_%I64d", momentum_type, bar_time));
   
   double marker_level = 0.0; // At zero line
   int arrow_code = 159; // Circle marker
   
   if(ObjectCreate(m_chart_id, signal_name, OBJ_ARROW, m_window_index, bar_time, marker_level))
   {
      ObjectSetInteger(m_chart_id, signal_name, OBJPROP_ARROWCODE, arrow_code);
      ObjectSetInteger(m_chart_id, signal_name, OBJPROP_COLOR, signal_color);
      ObjectSetInteger(m_chart_id, signal_name, OBJPROP_WIDTH, 2);
      ObjectSetString(m_chart_id, signal_name, OBJPROP_TEXT, "Momentum: " + momentum_type);
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Update the display with new TRIX values                          |
//+------------------------------------------------------------------+
bool CTrixDisplay::UpdateDisplay(const double trix_value, const double signal_value, 
                                const datetime bar_time, const int bar_shift = 0)
{
   // Draw current values
   bool result = DrawTrixValues(trix_value, signal_value, bar_time, bar_shift);
   
   // Check for signals and draw markers if enabled
   if(m_show_crossovers || m_show_momentum)
   {
      CheckAndDrawSignals(trix_value, signal_value, bar_time, 0); // Previous value should be passed in real implementation
   }
   
   ChartRedraw(m_chart_id);
   return result;
}

//+------------------------------------------------------------------+
//| Check for TRIX signals and draw markers                          |
//+------------------------------------------------------------------+
bool CTrixDisplay::CheckAndDrawSignals(const double trix_value, const double signal_value, 
                                       const datetime bar_time, const double prev_trix = 0)
{
   bool signal_detected = false;
   
   // Zero line crossover signals
   if(m_show_crossovers)
   {
      // TRIX crossing above zero line (bullish)
      if(IsAboveZero(trix_value) && (prev_trix <= 0 || prev_trix == 0))
      {
         DrawCrossoverSignal(bar_time, "Zero_Cross_Bull", true);
         signal_detected = true;
      }
      // TRIX crossing below zero line (bearish)
      else if(IsBelowZero(trix_value) && (prev_trix >= 0 || prev_trix == 0))
      {
         DrawCrossoverSignal(bar_time, "Zero_Cross_Bear", false);
         signal_detected = true;
      }
      
      // TRIX and signal line crossovers
      if(m_show_signal_line && signal_value != 0)
      {
         if(trix_value > signal_value)
         {
            DrawCrossoverSignal(bar_time, "TRIX_over_Signal", true);
            signal_detected = true;
         }
         else if(signal_value > trix_value)
         {
            DrawCrossoverSignal(bar_time, "Signal_over_TRIX", false);
            signal_detected = true;
         }
      }
   }
   
   // Momentum signals
   if(m_show_momentum)
   {
      // Strong positive momentum
      if(trix_value > m_momentum_threshold)
      {
         DrawMomentumSignal(bar_time, "Strong_Bull", clrLimeGreen);
         signal_detected = true;
      }
      // Strong negative momentum
      else if(trix_value < -m_momentum_threshold)
      {
         DrawMomentumSignal(bar_time, "Strong_Bear", clrRed);
         signal_detected = true;
      }
      
      // Momentum change detection (requires previous value)
      if(prev_trix != 0)
      {
         double momentum_change = trix_value - prev_trix;
         if(MathAbs(momentum_change) > m_momentum_threshold)
         {
            color change_color = (momentum_change > 0) ? clrLimeGreen : clrRed;
            string change_type = (momentum_change > 0) ? "Accelerating" : "Decelerating";
            DrawMomentumSignal(bar_time, change_type, change_color);
            signal_detected = true;
         }
      }
   }
   
   return signal_detected;
}

//+------------------------------------------------------------------+
//| Clear all display objects                                        |
//+------------------------------------------------------------------+
bool CTrixDisplay::ClearDisplay()
{
   Cleanup();
   if(m_show_zero_line)
   {
      DrawZeroLine();
   }
   return true;
}

//+------------------------------------------------------------------+
//| Check if window index is valid                                   |
//+------------------------------------------------------------------+
bool CTrixDisplay::IsValidWindow() const
{
   return (m_chart_id > 0 && m_window_index >= 0);
}

//+------------------------------------------------------------------+
//| Generate object name with prefix                                 |
//+------------------------------------------------------------------+
string CTrixDisplay::GetObjectName(const string suffix) const
{
   return StringFormat("%s_%s", m_object_prefix, suffix);
}

//+------------------------------------------------------------------+
//| Remove specific object                                           |
//+------------------------------------------------------------------+
bool CTrixDisplay::RemoveObject(const string object_name)
{
   return ObjectDelete(m_chart_id, object_name);
}

//+------------------------------------------------------------------+
//| Check if value is above zero                                     |
//+------------------------------------------------------------------+
bool CTrixDisplay::IsAboveZero(const double value) const
{
   return (value > 0);
}

//+------------------------------------------------------------------+
//| Check if value is below zero                                     |
//+------------------------------------------------------------------+
bool CTrixDisplay::IsBelowZero(const double value) const
{
   return (value < 0);
}
