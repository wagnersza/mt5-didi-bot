//+------------------------------------------------------------------+
//|                                               GraphicManager.mqh |
//|                        Copyright 2023, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"

#include "SignalEngine.mqh"
#include "WindowManager.mqh"
#include "displays/MainChartDisplay.mqh"
#include "displays/DmiDisplay.mqh"
#include "displays/DidiDisplay.mqh"
#include "displays/StochasticDisplay.mqh"
#include "displays/TrixDisplay.mqh"
#include "displays/IfrDisplay.mqh"

//+------------------------------------------------------------------+
//| Class for managing chart graphics and visual indicators         |
//+------------------------------------------------------------------+
class CGraphicManager
{
protected:
   string            m_prefix;           // Prefix for object names
   color             m_bull_color;       // Bullish signal color
   color             m_bear_color;       // Bearish signal color
   color             m_neutral_color;    // Neutral signal color
   int               m_arrow_size;       // Arrow size for signals
   
   // Multi-window management
   CWindowManager*   m_window_manager;   // Window lifecycle coordinator
   CMainChartDisplay* m_main_display;    // Main chart display handler
   CDmiDisplay*      m_dmi_display;      // DMI indicator window display
   CDidiDisplay*     m_didi_display;     // Didi Index window display
   CStochasticDisplay* m_stoch_display;  // Stochastic window display
   CTrixDisplay*     m_trix_display;     // TRIX window display
   CIfrDisplay*      m_ifr_display;      // IFR window display
   
   // Window indices for display coordination
   int               m_dmi_window_index;
   int               m_didi_window_index;
   int               m_stoch_window_index;
   int               m_trix_window_index;
   int               m_ifr_window_index;
   
public:
                     CGraphicManager();
                    ~CGraphicManager();
   void              Init(string prefix = "DidiBot_");
   void              ClearAll();
   
   // Multi-window initialization and management
   bool              InitializeWindows(long chart_id = 0);
   bool              CreateIndicatorWindows(CDmi &dmi, CDidiIndex &didi, CStochastic &stoch, CTrix &trix, CIfr &ifr);
   void              CleanupWindows();
   
   // Multi-window display coordination
   void              UpdateAllDisplays(CDmi &dmi, CDidiIndex &didi, CBollingerBands &bb, 
                                     CStochastic &stoch, CTrix &trix, CIfr &ifr);
   void              UpdateWindowDisplays(const datetime bar_time, const int bar_shift = 0);
   
   // Signal visualization methods (backward compatible)
   void              DrawEntrySignal(datetime time, double price, bool is_buy, string reason);
   void              DrawExitSignal(datetime time, double price, bool is_buy, string reason);
   void              UpdateSignalPanel(CDmi &dmi, CDidiIndex &didi, CBollingerBands &bb, 
                                     CStochastic &stoch, CTrix &trix, CIfr &ifr);
   void              UpdateSignalPanelWithStops(CDmi &dmi, CDidiIndex &didi, CBollingerBands &bb, 
                                               CStochastic &stoch, CTrix &trix, CIfr &ifr,
                                               CAtr &atr, CRiskManager &risk_mgr, CTradeManager &trade_mgr);
   
   // Stop loss visualization methods
   void              DrawStopLoss(string ticket, double stop_price, bool is_buy);
   void              UpdateStopLoss(string ticket, double new_stop_price);
   void              RemoveStopLoss(string ticket);
   void              DrawTrailingStop(string ticket, double stop_price, bool is_buy);
   
   // Indicator visualization methods
   void              DrawDidiLevels(CDidiIndex &didi, datetime time);
   void              DrawBollingerBands(CBollingerBands &bb, datetime time);
   void              DrawDMISignals(CDmi &dmi, datetime time);
   void              DrawStochasticLevels(CStochastic &stoch, datetime time);
   void              DrawTrixSignal(CTrix &trix, datetime time);
   void              DrawIFRLevels(CIfr &ifr, datetime time);
   
   // Information panel methods
   void              CreateInfoPanel();
   void              UpdateInfoPanel(string text);
   void              UpdateTradingStatus(string status);
   
   // Utility methods
   void              DrawHorizontalLine(string name, double price, color line_color, 
                                      ENUM_LINE_STYLE style = STYLE_SOLID, int width = 1);
   void              DrawVerticalLine(string name, datetime time, color line_color,
                                    ENUM_LINE_STYLE style = STYLE_SOLID, int width = 1);
   void              DrawArrow(string name, datetime time, double price, int arrow_code, 
                             color arrow_color, int size = 3);
   void              DrawText(string name, datetime time, double price, string text, 
                            color text_color = clrWhite, int font_size = 10);
   void              DeleteObject(string name);
   
private:
   string            GenerateObjectName(string base_name);
   void              SetObjectProperties(string name, color obj_color, int width = 1);
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CGraphicManager::CGraphicManager()
{
   m_prefix = "DidiBot_";
   m_bull_color = clrLimeGreen;
   m_bear_color = clrRed;
   m_neutral_color = clrYellow;
   m_arrow_size = 3;
   
   // Initialize multi-window management objects
   m_window_manager = NULL;
   m_main_display = NULL;
   m_dmi_display = NULL;
   m_didi_display = NULL;
   m_stoch_display = NULL;
   m_trix_display = NULL;
   m_ifr_display = NULL;
   
   // Initialize window indices
   m_dmi_window_index = -1;
   m_didi_window_index = -1;
   m_stoch_window_index = -1;
   m_trix_window_index = -1;
   m_ifr_window_index = -1;
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CGraphicManager::~CGraphicManager()
{
   CleanupWindows();
   ClearAll();
}

//+------------------------------------------------------------------+
//| Initialize graphic manager                                       |
//+------------------------------------------------------------------+
void CGraphicManager::Init(string prefix = "DidiBot_")
{
   m_prefix = prefix;
   ClearAll();
   CreateInfoPanel();
   
   // Initialize window management
   if(!InitializeWindows())
   {
      Print("GraphicManager: Warning - Window initialization failed");
   }
   
   Print("GraphicManager: Initialized with prefix: ", m_prefix);
}

//+------------------------------------------------------------------+
//| Clear all objects created by this manager                       |
//+------------------------------------------------------------------+
void CGraphicManager::ClearAll()
{
   int total = ObjectsTotal(0, -1, -1);
   for(int i = total - 1; i >= 0; i--)
   {
      string name = ObjectName(0, i);
      if(StringFind(name, m_prefix) == 0)
      {
         ObjectDelete(0, name);
      }
   }
   ChartRedraw();
}

//+------------------------------------------------------------------+
//| Draw entry signal arrow and label                               |
//+------------------------------------------------------------------+
void CGraphicManager::DrawEntrySignal(datetime time, double price, bool is_buy, string reason)
{
   string arrow_name = GenerateObjectName("Entry_" + (string)time);
   string text_name = GenerateObjectName("EntryText_" + (string)time);
   
   // Draw arrow
   int arrow_code = is_buy ? 233 : 234; // Up/Down arrows
   color arrow_color = is_buy ? m_bull_color : m_bear_color;
   DrawArrow(arrow_name, time, price, arrow_code, arrow_color, m_arrow_size);
   
   // Add signal text
   string signal_text = (is_buy ? "BUY" : "SELL") + "\n" + reason;
   double text_price = is_buy ? price - (20 * _Point) : price + (20 * _Point);
   DrawText(text_name, time, text_price, signal_text, arrow_color, 8);
   
   Print("GraphicManager: Drew entry signal - ", signal_text, " at ", TimeToString(time));
}

//+------------------------------------------------------------------+
//| Draw exit signal arrow and label                                |
//+------------------------------------------------------------------+
void CGraphicManager::DrawExitSignal(datetime time, double price, bool is_buy, string reason)
{
   string arrow_name = GenerateObjectName("Exit_" + (string)time);
   string text_name = GenerateObjectName("ExitText_" + (string)time);
   
   // Draw exit arrow (different style)
   int arrow_code = is_buy ? 251 : 252; // Different exit arrows
   color arrow_color = is_buy ? clrBlue : clrOrange;
   DrawArrow(arrow_name, time, price, arrow_code, arrow_color, m_arrow_size);
   
   // Add exit text
   string signal_text = "EXIT\n" + reason;
   double text_price = is_buy ? price + (20 * _Point) : price - (20 * _Point);
   DrawText(text_name, time, text_price, signal_text, arrow_color, 8);
   
   Print("GraphicManager: Drew exit signal - ", signal_text, " at ", TimeToString(time));
}

//+------------------------------------------------------------------+
//| Update signal panel with current indicator values               |
//+------------------------------------------------------------------+
void CGraphicManager::UpdateSignalPanel(CDmi &dmi, CDidiIndex &didi, CBollingerBands &bb, 
                                       CStochastic &stoch, CTrix &trix, CIfr &ifr)
{
   datetime current_time = TimeCurrent();
   
   // Update each indicator visualization
   DrawDidiLevels(didi, current_time);
   DrawBollingerBands(bb, current_time);
   DrawDMISignals(dmi, current_time);
   DrawStochasticLevels(stoch, current_time);
   DrawTrixSignal(trix, current_time);
   DrawIFRLevels(ifr, current_time);
   
   // Update info panel with current values
   string panel_text = StringFormat(
      "ADX: %.2f | +DI: %.2f | -DI: %.2f\n" +
      "Didi: %s\n" +
      "BB: U:%.5f M:%.5f L:%.5f\n" +
      "Stoch: %.1f/%.1f\n" +
      "TRIX: %.6f\n" +
      "IFR: %.2f",
      dmi.Adx(1), dmi.PlusDi(1), dmi.MinusDi(1),
      (didi.IsAgulhada(1) ? "AGULHADA" : "NO SIGNAL"),
      bb.UpperBand(1), bb.MiddleBand(1), bb.LowerBand(1),
      stoch.Main(1), stoch.Signal(1),
      trix.Main(1),
      ifr.Main(1)
   );
   
   UpdateInfoPanel(panel_text);
}

//+------------------------------------------------------------------+
//| Update signal panel with stop loss information                  |
//+------------------------------------------------------------------+
void CGraphicManager::UpdateSignalPanelWithStops(CDmi &dmi, CDidiIndex &didi, CBollingerBands &bb, 
                                                CStochastic &stoch, CTrix &trix, CIfr &ifr,
                                                CAtr &atr, CRiskManager &risk_mgr, CTradeManager &trade_mgr)
{
   datetime current_time = TimeCurrent();
   
   // Update each indicator visualization
   DrawDidiLevels(didi, current_time);
   DrawBollingerBands(bb, current_time);
   DrawDMISignals(dmi, current_time);
   DrawStochasticLevels(stoch, current_time);
   DrawTrixSignal(trix, current_time);
   DrawIFRLevels(ifr, current_time);
   
   // Get stop loss configuration and current ATR
   StopLossConfig config = risk_mgr.GetStopLossConfig();
   double current_atr = atr.GetCurrentATR();
   int active_stops = trade_mgr.GetActiveStopLossCount();
   
   // Build panel text with stop loss information
   string panel_text = StringFormat(
      "ADX: %.2f | +DI: %.2f | -DI: %.2f\n" +
      "Didi: %s\n" +
      "BB: U:%.5f M:%.5f L:%.5f\n" +
      "Stoch: %.1f/%.1f\n" +
      "TRIX: %.6f\n" +
      "IFR: %.2f\n" +
      "═══ STOP LOSS INFO ═══\n" +
      "Type: %s | ATR: %.5f\n" +
      "Mult: %.1f | Trailing: %s\n" +
      "Active Stops: %d",
      dmi.Adx(1), dmi.PlusDi(1), dmi.MinusDi(1),
      (didi.IsAgulhada(1) ? "AGULHADA" : "NO SIGNAL"),
      bb.UpperBand(1), bb.MiddleBand(1), bb.LowerBand(1),
      stoch.Main(1), stoch.Signal(1),
      trix.Main(1),
      ifr.Main(1),
      (config.type == ATR_BASED) ? "ATR" : "FIXED",
      current_atr,
      config.atr_multiplier,
      config.trailing_enabled ? "YES" : "NO",
      active_stops
   );
   
   UpdateInfoPanel(panel_text);
}

//+------------------------------------------------------------------+
//| Draw Didi Index levels on chart                                 |
//+------------------------------------------------------------------+
void CGraphicManager::DrawDidiLevels(CDidiIndex &didi, datetime time)
{
   // Show Didi status only (since we don't have individual MA access methods)
   if(didi.IsAgulhada(1))
   {
      DrawText("DidiSignal", time, SymbolInfoDouble(_Symbol, SYMBOL_ASK) + (60 * _Point), 
               "DIDI AGULHADA!", clrYellow, 12);
   }
}

//+------------------------------------------------------------------+
//| Draw Bollinger Bands levels                                     |
//+------------------------------------------------------------------+
void CGraphicManager::DrawBollingerBands(CBollingerBands &bb, datetime time)
{
   double upper = bb.UpperBand(1);
   double middle = bb.MiddleBand(1);
   double lower = bb.LowerBand(1);
   
   DrawHorizontalLine("BB_Upper", upper, clrBlue, STYLE_DOT, 1);
   DrawHorizontalLine("BB_Middle", middle, clrWhite, STYLE_SOLID, 1);
   DrawHorizontalLine("BB_Lower", lower, clrBlue, STYLE_DOT, 1);
   
   // Show BB squeeze or expansion
   double bb_width = upper - lower;
   double current_price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   
   string bb_status = "";
   if(current_price > upper)
      bb_status = "BB BREAKOUT UP";
   else if(current_price < lower)
      bb_status = "BB BREAKOUT DOWN";
   else if(bb_width < (100 * _Point)) // Adjust threshold as needed
      bb_status = "BB SQUEEZE";
   
   if(bb_status != "")
   {
      color bb_color = (current_price > upper) ? clrLimeGreen : 
                       (current_price < lower) ? clrRed : clrYellow;
      DrawText("BB_Status", time, current_price, bb_status, bb_color, 9);
   }
}

//+------------------------------------------------------------------+
//| Draw DMI signals                                                |
//+------------------------------------------------------------------+
void CGraphicManager::DrawDMISignals(CDmi &dmi, datetime time)
{
   double adx = dmi.Adx(1);
   double plus_di = dmi.PlusDi(1);
   double minus_di = dmi.MinusDi(1);
   
   // Show ADX strength
   color adx_color = adx > 25 ? clrLimeGreen : (adx > 20 ? clrYellow : clrRed);
   string adx_text = StringFormat("ADX: %.1f %s", adx, 
      adx > 25 ? "STRONG" : (adx > 20 ? "MEDIUM" : "WEAK"));
   
   DrawText("DMI_ADX", time, SymbolInfoDouble(_Symbol, SYMBOL_ASK), adx_text, adx_color, 9);
   
   // Show DI crossover
   if(MathAbs(plus_di - minus_di) < 2) // Close values indicate potential crossover
   {
      DrawText("DMI_Cross", time, SymbolInfoDouble(_Symbol, SYMBOL_BID), 
               "DI CROSS WATCH", clrYellow, 8);
   }
}

//+------------------------------------------------------------------+
//| Draw Stochastic levels                                          |
//+------------------------------------------------------------------+
void CGraphicManager::DrawStochasticLevels(CStochastic &stoch, datetime time)
{
   double main = stoch.Main(1);
   double signal = stoch.Signal(1);
   
   // Show overbought/oversold levels
   if(main > 80)
   {
      DrawText("Stoch_OB", time, SymbolInfoDouble(_Symbol, SYMBOL_ASK) + (30 * _Point), 
               "STOCH OB", clrRed, 8);
   }
   else if(main < 20)
   {
      DrawText("Stoch_OS", time, SymbolInfoDouble(_Symbol, SYMBOL_BID) - (30 * _Point), 
               "STOCH OS", clrLimeGreen, 8);
   }
   
   // Show crossovers
   if(MathAbs(main - signal) < 5)
   {
      DrawText("Stoch_Cross", time, SymbolInfoDouble(_Symbol, SYMBOL_ASK) + (50 * _Point), 
               "STOCH CROSS", clrYellow, 8);
   }
}

//+------------------------------------------------------------------+
//| Draw TRIX signal                                                |
//+------------------------------------------------------------------+
void CGraphicManager::DrawTrixSignal(CTrix &trix, datetime time)
{
   double current = trix.Main(1);
   double previous = trix.Main(2);
   
   // Show TRIX direction change
   if((current > 0 && previous <= 0) || (current < 0 && previous >= 0))
   {
      color trix_color = current > 0 ? m_bull_color : m_bear_color;
      string trix_text = current > 0 ? "TRIX +" : "TRIX -";
      DrawText("TRIX_Signal", time, SymbolInfoDouble(_Symbol, SYMBOL_ASK) + (10 * _Point), 
               trix_text, trix_color, 8);
   }
}

//+------------------------------------------------------------------+
//| Draw IFR levels                                                 |
//+------------------------------------------------------------------+
void CGraphicManager::DrawIFRLevels(CIfr &ifr, datetime time)
{
   double value = ifr.Main(1);
   
   // Show IFR overbought/oversold
   if(value > 70)
   {
      DrawText("IFR_OB", time, SymbolInfoDouble(_Symbol, SYMBOL_ASK) + (40 * _Point), 
               "IFR OB", clrRed, 8);
   }
   else if(value < 30)
   {
      DrawText("IFR_OS", time, SymbolInfoDouble(_Symbol, SYMBOL_BID) - (40 * _Point), 
               "IFR OS", clrLimeGreen, 8);
   }
}

//+------------------------------------------------------------------+
//| Create information panel                                         |
//+------------------------------------------------------------------+
void CGraphicManager::CreateInfoPanel()
{
   string panel_name = GenerateObjectName("InfoPanel");
   
   // Create a text label for the info panel
   if(ObjectCreate(0, panel_name, OBJ_LABEL, 0, 0, 0))
   {
      ObjectSetInteger(0, panel_name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetInteger(0, panel_name, OBJPROP_XDISTANCE, 10);
      ObjectSetInteger(0, panel_name, OBJPROP_YDISTANCE, 30);
      ObjectSetInteger(0, panel_name, OBJPROP_COLOR, clrWhite);
      ObjectSetInteger(0, panel_name, OBJPROP_FONTSIZE, 9);
      ObjectSetString(0, panel_name, OBJPROP_FONT, "Courier New");
      ObjectSetString(0, panel_name, OBJPROP_TEXT, "DidiBot - Initializing...");
   }
}

//+------------------------------------------------------------------+
//| Update information panel                                         |
//+------------------------------------------------------------------+
void CGraphicManager::UpdateInfoPanel(string text)
{
   string panel_name = GenerateObjectName("InfoPanel");
   ObjectSetString(0, panel_name, OBJPROP_TEXT, "DidiBot Signals:\n" + text);
   ChartRedraw();
}

//+------------------------------------------------------------------+
//| Update trading status                                           |
//+------------------------------------------------------------------+
void CGraphicManager::UpdateTradingStatus(string status)
{
   string status_name = GenerateObjectName("TradingStatus");
   
   if(ObjectFind(0, status_name) < 0)
   {
      if(ObjectCreate(0, status_name, OBJ_LABEL, 0, 0, 0))
      {
         ObjectSetInteger(0, status_name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
         ObjectSetInteger(0, status_name, OBJPROP_XDISTANCE, 10);
         ObjectSetInteger(0, status_name, OBJPROP_YDISTANCE, 200);
         ObjectSetInteger(0, status_name, OBJPROP_COLOR, clrYellow);
         ObjectSetInteger(0, status_name, OBJPROP_FONTSIZE, 11);
         ObjectSetString(0, status_name, OBJPROP_FONT, "Arial Bold");
      }
   }
   
   ObjectSetString(0, status_name, OBJPROP_TEXT, "Status: " + status);
   ChartRedraw();
}

//+------------------------------------------------------------------+
//| Draw horizontal line                                            |
//+------------------------------------------------------------------+
void CGraphicManager::DrawHorizontalLine(string name, double price, color line_color, 
                                        ENUM_LINE_STYLE style = STYLE_SOLID, int width = 1)
{
   string full_name = GenerateObjectName(name);
   
   if(ObjectFind(0, full_name) >= 0)
      ObjectDelete(0, full_name);
      
   if(ObjectCreate(0, full_name, OBJ_HLINE, 0, 0, price))
   {
      ObjectSetInteger(0, full_name, OBJPROP_COLOR, line_color);
      ObjectSetInteger(0, full_name, OBJPROP_STYLE, style);
      ObjectSetInteger(0, full_name, OBJPROP_WIDTH, width);
      ObjectSetInteger(0, full_name, OBJPROP_BACK, true);
   }
}

//+------------------------------------------------------------------+
//| Draw vertical line                                              |
//+------------------------------------------------------------------+
void CGraphicManager::DrawVerticalLine(string name, datetime time, color line_color,
                                      ENUM_LINE_STYLE style = STYLE_SOLID, int width = 1)
{
   string full_name = GenerateObjectName(name);
   
   if(ObjectFind(0, full_name) >= 0)
      ObjectDelete(0, full_name);
      
   if(ObjectCreate(0, full_name, OBJ_VLINE, 0, time, 0))
   {
      ObjectSetInteger(0, full_name, OBJPROP_COLOR, line_color);
      ObjectSetInteger(0, full_name, OBJPROP_STYLE, style);
      ObjectSetInteger(0, full_name, OBJPROP_WIDTH, width);
      ObjectSetInteger(0, full_name, OBJPROP_BACK, true);
   }
}

//+------------------------------------------------------------------+
//| Draw arrow                                                      |
//+------------------------------------------------------------------+
void CGraphicManager::DrawArrow(string name, datetime time, double price, int arrow_code, 
                               color arrow_color, int size = 3)
{
   string full_name = GenerateObjectName(name);
   
   if(ObjectFind(0, full_name) >= 0)
      ObjectDelete(0, full_name);
      
   if(ObjectCreate(0, full_name, OBJ_ARROW, 0, time, price))
   {
      ObjectSetInteger(0, full_name, OBJPROP_ARROWCODE, arrow_code);
      ObjectSetInteger(0, full_name, OBJPROP_COLOR, arrow_color);
      ObjectSetInteger(0, full_name, OBJPROP_WIDTH, size);
   }
}

//+------------------------------------------------------------------+
//| Draw text                                                       |
//+------------------------------------------------------------------+
void CGraphicManager::DrawText(string name, datetime time, double price, string text, 
                              color text_color = clrWhite, int font_size = 10)
{
   string full_name = GenerateObjectName(name);
   
   if(ObjectFind(0, full_name) >= 0)
      ObjectDelete(0, full_name);
      
   if(ObjectCreate(0, full_name, OBJ_TEXT, 0, time, price))
   {
      ObjectSetString(0, full_name, OBJPROP_TEXT, text);
      ObjectSetInteger(0, full_name, OBJPROP_COLOR, text_color);
      ObjectSetInteger(0, full_name, OBJPROP_FONTSIZE, font_size);
      ObjectSetString(0, full_name, OBJPROP_FONT, "Arial");
   }
}

//+------------------------------------------------------------------+
//| Delete object                                                   |
//+------------------------------------------------------------------+
void CGraphicManager::DeleteObject(string name)
{
   string full_name = GenerateObjectName(name);
   ObjectDelete(0, full_name);
}

//+------------------------------------------------------------------+
//| Generate unique object name with prefix                         |
//+------------------------------------------------------------------+
string CGraphicManager::GenerateObjectName(string base_name)
{
   return m_prefix + base_name;
}

//+------------------------------------------------------------------+
//| Set common object properties                                    |
//+------------------------------------------------------------------+
void CGraphicManager::SetObjectProperties(string name, color obj_color, int width = 1)
{
   ObjectSetInteger(0, name, OBJPROP_COLOR, obj_color);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, width);
}

//+------------------------------------------------------------------+
//| Draw stop loss level for a specific trade                       |
//+------------------------------------------------------------------+
void CGraphicManager::DrawStopLoss(string ticket, double stop_price, bool is_buy)
{
   string name = "StopLoss_" + ticket;
   color stop_color = is_buy ? clrRed : clrBlue;
   
   DrawHorizontalLine(name, stop_price, stop_color, STYLE_DOT, 2);
   
   // Add text label for stop loss
   string label_name = "StopLabel_" + ticket;
   datetime current_time = TimeCurrent();
   string label_text = StringFormat("SL: %.5f", stop_price);
   
   DrawText(label_name, current_time, stop_price, label_text, stop_color, 8);
   
   Print("GraphicManager: Stop loss drawn for ticket ", ticket, " at price ", stop_price);
}

//+------------------------------------------------------------------+
//| Update stop loss level for a specific trade                     |
//+------------------------------------------------------------------+
void CGraphicManager::UpdateStopLoss(string ticket, double new_stop_price)
{
   string name = "StopLoss_" + ticket;
   string full_name = GenerateObjectName(name);
   
   if(ObjectFind(0, full_name) >= 0)
   {
      ObjectSetDouble(0, full_name, OBJPROP_PRICE, new_stop_price);
      
      // Update text label
      string label_name = "StopLabel_" + ticket;
      string full_label_name = GenerateObjectName(label_name);
      
      if(ObjectFind(0, full_label_name) >= 0)
      {
         ObjectSetDouble(0, full_label_name, OBJPROP_PRICE, new_stop_price);
         string label_text = StringFormat("SL: %.5f", new_stop_price);
         ObjectSetString(0, full_label_name, OBJPROP_TEXT, label_text);
      }
      
      ChartRedraw(0);
      Print("GraphicManager: Stop loss updated for ticket ", ticket, " to price ", new_stop_price);
   }
}

//+------------------------------------------------------------------+
//| Remove stop loss visualization for a specific trade             |
//+------------------------------------------------------------------+
void CGraphicManager::RemoveStopLoss(string ticket)
{
   string line_name = "StopLoss_" + ticket;
   string label_name = "StopLabel_" + ticket;
   
   DeleteObject(line_name);
   DeleteObject(label_name);
   
   Print("GraphicManager: Stop loss removed for ticket ", ticket);
}

//+------------------------------------------------------------------+
//| Draw trailing stop indication                                   |
//+------------------------------------------------------------------+
void CGraphicManager::DrawTrailingStop(string ticket, double stop_price, bool is_buy)
{
   string name = "TrailStop_" + ticket;
   color trail_color = is_buy ? clrOrange : clrCyan;
   
   DrawHorizontalLine(name, stop_price, trail_color, STYLE_DASHDOT, 2);
   
   // Add trailing stop text label
   string label_name = "TrailLabel_" + ticket;
   datetime current_time = TimeCurrent();
   string label_text = StringFormat("TSL: %.5f", stop_price);
   
   DrawText(label_name, current_time, stop_price, label_text, trail_color, 8);
   
   Print("GraphicManager: Trailing stop drawn for ticket ", ticket, " at price ", stop_price);
}

//+------------------------------------------------------------------+
//| Initialize window management system                              |
//+------------------------------------------------------------------+
bool CGraphicManager::InitializeWindows(long chart_id = 0)
{
   // Initialize window manager
   m_window_manager = new CWindowManager();
   if(m_window_manager == NULL)
   {
      Print("GraphicManager: Failed to create WindowManager");
      return false;
   }
   
   if(!m_window_manager.Init(chart_id, m_prefix))
   {
      Print("GraphicManager: Failed to initialize WindowManager");
      delete m_window_manager;
      m_window_manager = NULL;
      return false;
   }
   
   // Initialize main chart display
   m_main_display = new CMainChartDisplay();
   if(m_main_display == NULL)
   {
      Print("GraphicManager: Failed to create MainChartDisplay");
      return false;
   }
   
   if(!m_main_display.Init(chart_id, 0, m_prefix + "Main"))
   {
      Print("GraphicManager: Failed to initialize MainChartDisplay");
      delete m_main_display;
      m_main_display = NULL;
      return false;
   }
   
   Print("GraphicManager: Window management initialized successfully");
   return true;
}

//+------------------------------------------------------------------+
//| Create indicator windows for multi-window display               |
//+------------------------------------------------------------------+
bool CGraphicManager::CreateIndicatorWindows(CDmi &dmi, CDidiIndex &didi, CStochastic &stoch, CTrix &trix, CIfr &ifr)
{
   if(m_window_manager == NULL)
   {
      Print("GraphicManager: WindowManager not initialized");
      return false;
   }
   
   long chart_id = m_window_manager.GetChartId();
   
   // Create DMI window and display
   m_dmi_window_index = m_window_manager.CreateIndicatorWindow("DMI", dmi.GetHandle());
   if(m_dmi_window_index > 0)
   {
      m_dmi_display = new CDmiDisplay();
      if(m_dmi_display != NULL && m_dmi_display.Init(chart_id, m_dmi_window_index, m_prefix + "DMI"))
      {
         Print("GraphicManager: DMI window created successfully, index: ", m_dmi_window_index);
      }
   }
   
   // Create Didi Index window and display  
   m_didi_window_index = m_window_manager.CreateIndicatorWindow("Didi", didi.GetHandle());
   if(m_didi_window_index > 0)
   {
      m_didi_display = new CDidiDisplay();
      if(m_didi_display != NULL && m_didi_display.Init(chart_id, m_didi_window_index, m_prefix + "Didi"))
      {
         Print("GraphicManager: Didi window created successfully, index: ", m_didi_window_index);
      }
   }
   
   // Create Stochastic window and display
   m_stoch_window_index = m_window_manager.CreateIndicatorWindow("Stochastic", stoch.GetHandle());
   if(m_stoch_window_index > 0)
   {
      m_stoch_display = new CStochasticDisplay();
      if(m_stoch_display != NULL && m_stoch_display.Init(chart_id, m_stoch_window_index, m_prefix + "Stoch"))
      {
         Print("GraphicManager: Stochastic window created successfully, index: ", m_stoch_window_index);
      }
   }
   
   // Create TRIX window and display
   m_trix_window_index = m_window_manager.CreateIndicatorWindow("TRIX", trix.GetHandle());
   if(m_trix_window_index > 0)
   {
      m_trix_display = new CTrixDisplay();
      if(m_trix_display != NULL && m_trix_display.Init(chart_id, m_trix_window_index, m_prefix + "TRIX"))
      {
         Print("GraphicManager: TRIX window created successfully, index: ", m_trix_window_index);
      }
   }
   
   // Create IFR window and display
   m_ifr_window_index = m_window_manager.CreateIndicatorWindow("IFR", ifr.GetHandle());
   if(m_ifr_window_index > 0)
   {
      m_ifr_display = new CIfrDisplay();
      if(m_ifr_display != NULL && m_ifr_display.Init(chart_id, m_ifr_window_index, m_prefix + "IFR"))
      {
         Print("GraphicManager: IFR window created successfully, index: ", m_ifr_window_index);
      }
   }
   
   Print("GraphicManager: Indicator windows creation completed");
   return true;
}

//+------------------------------------------------------------------+
//| Cleanup window management resources                              |
//+------------------------------------------------------------------+
void CGraphicManager::CleanupWindows()
{
   // Cleanup display classes
   if(m_ifr_display != NULL)
   {
      m_ifr_display.Cleanup();
      delete m_ifr_display;
      m_ifr_display = NULL;
   }
   
   if(m_trix_display != NULL)
   {
      m_trix_display.Cleanup();
      delete m_trix_display;
      m_trix_display = NULL;
   }
   
   if(m_stoch_display != NULL)
   {
      m_stoch_display.Cleanup();
      delete m_stoch_display;
      m_stoch_display = NULL;
   }
   
   if(m_didi_display != NULL)
   {
      m_didi_display.Cleanup();
      delete m_didi_display;
      m_didi_display = NULL;
   }
   
   if(m_dmi_display != NULL)
   {
      m_dmi_display.Cleanup();
      delete m_dmi_display;
      m_dmi_display = NULL;
   }
   
   if(m_main_display != NULL)
   {
      m_main_display.Cleanup();
      delete m_main_display;
      m_main_display = NULL;
   }
   
   // Cleanup window manager
   if(m_window_manager != NULL)
   {
      m_window_manager.Cleanup();
      delete m_window_manager;
      m_window_manager = NULL;
   }
   
   // Reset window indices
   m_dmi_window_index = -1;
   m_didi_window_index = -1;
   m_stoch_window_index = -1;
   m_trix_window_index = -1;
   m_ifr_window_index = -1;
   
   Print("GraphicManager: Window cleanup completed");
}

//+------------------------------------------------------------------+
//| Update all indicator displays with current data                  |
//+------------------------------------------------------------------+
void CGraphicManager::UpdateAllDisplays(CDmi &dmi, CDidiIndex &didi, CBollingerBands &bb, 
                                       CStochastic &stoch, CTrix &trix, CIfr &ifr)
{
   datetime current_time = TimeCurrent();
   
   // Update DMI display
   if(m_dmi_display != NULL)
   {
      double adx_value = dmi.GetADX(0);
      double plus_di = dmi.GetPlusDI(0);
      double minus_di = dmi.GetMinusDI(0);
      m_dmi_display.UpdateDisplay(adx_value, plus_di, minus_di, current_time, 0);
   }
   
   // Update Didi display
   if(m_didi_display != NULL)
   {
      double short_ma = didi.GetShortMA(0);
      double medium_ma = didi.GetMediumMA(0);
      double long_ma = didi.GetLongMA(0);
      m_didi_display.UpdateDisplay(short_ma, medium_ma, long_ma, current_time, 0);
   }
   
   // Update Stochastic display
   if(m_stoch_display != NULL)
   {
      double main_value = stoch.GetMain(0);
      double signal_value = stoch.GetSignal(0);
      m_stoch_display.UpdateDisplay(main_value, signal_value, current_time, 0);
   }
   
   // Update TRIX display
   if(m_trix_display != NULL)
   {
      double trix_value = trix.GetTrix(0);
      double trix_signal = trix.GetSignal(0);
      m_trix_display.UpdateDisplay(trix_value, trix_signal, current_time, 0);
   }
   
   // Update IFR display
   if(m_ifr_display != NULL)
   {
      double ifr_value = ifr.GetIfr(0);
      m_ifr_display.UpdateDisplay(ifr_value, current_time, 0);
   }
   
   // Update main chart display with signals
   if(m_main_display != NULL)
   {
      // This will be enhanced based on signal coordination needs
      m_main_display.UpdateDisplay();
   }
}

//+------------------------------------------------------------------+
//| Update window displays for specific bar time and shift           |
//+------------------------------------------------------------------+
void CGraphicManager::UpdateWindowDisplays(const datetime bar_time, const int bar_shift = 0)
{
   // Force chart redraw to ensure all windows are updated
   if(m_window_manager != NULL)
   {
      ChartRedraw(m_window_manager.GetChartId());
   }
   
   Print("GraphicManager: Window displays updated for bar time: ", TimeToString(bar_time));
}
