//+------------------------------------------------------------------+
//|                                               GraphicManager.mqh |
//|                        Copyright 2023, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"

#include "SignalEngine.mqh"

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
   
public:
                     CGraphicManager();
                    ~CGraphicManager();
   void              Init(string prefix = "DidiBot_");
   void              ClearAll();
   
   // Signal visualization methods
   void              DrawEntrySignal(datetime time, double price, bool is_buy, string reason);
   void              DrawExitSignal(datetime time, double price, bool is_buy, string reason);
   void              UpdateSignalPanel(CDmi &dmi, CDidiIndex &didi, CBollingerBands &bb, 
                                     CStochastic &stoch, CTrix &trix, CIfr &ifr);
   
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
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CGraphicManager::~CGraphicManager()
{
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
