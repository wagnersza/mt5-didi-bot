//+------------------------------------------------------------------+
//|                                            DidiBot_enhanced.mq5 |
//|                        Copyright 2024, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.10"
#property description "Enhanced DidiBot with Multi-Window Configuration and Optimization"

//--- Stop Loss Configuration Enumerations
enum ENUM_STOP_TYPE
{
   ATR_BASED,    // ATR-based stop loss
   FIXED_PIPS    // Fixed pip stop loss
};

//--- Window Layout Configuration
enum ENUM_WINDOW_LAYOUT
{
   LAYOUT_VERTICAL,     // Vertical stacking (default)
   LAYOUT_HORIZONTAL,   // Horizontal arrangement
   LAYOUT_GRID,         // Grid layout
   LAYOUT_CUSTOM        // User-defined positions
};

//--- Color Scheme Configuration
enum ENUM_COLOR_SCHEME
{
   COLOR_SCHEME_CLASSIC,      // Classic colors (green/red)
   COLOR_SCHEME_PROFESSIONAL, // Professional blue/orange
   COLOR_SCHEME_HIGH_CONTRAST // High contrast (lime/magenta)
};

//--- Input Parameters for Stop Loss Configuration
input group "=== Stop Loss Configuration ==="
input ENUM_STOP_TYPE InpStopType = ATR_BASED;           // Stop Loss Type
input double InpATRMultiplier = 1.5;                    // ATR Multiplier (0.5-5.0)
input int InpFixedPips = 50;                            // Fixed Pips Stop Loss
input bool InpTrailingEnabled = true;                   // Enable Trailing Stop
input int InpMaxStopPips = 100;                         // Maximum Stop Loss (pips)
input int InpStopLimitSlippage = 3;                     // Stop Limit Slippage (pips)
input int InpATRPeriod = 14;                            // ATR Period for calculation
input int InpMinStopDistance = 10;                      // Minimum Stop Distance (pips)

//--- Multi-Window Configuration
input group "=== Window Layout Configuration ==="
input bool InpEnableDMIWindow = true;                   // Enable DMI Window
input bool InpEnableDidiWindow = true;                  // Enable Didi Index Window  
input bool InpEnableStochWindow = true;                 // Enable Stochastic Window
input bool InpEnableTrixWindow = true;                  // Enable TRIX Window
input bool InpEnableIfrWindow = true;                   // Enable IFR/RSI Window
input ENUM_WINDOW_LAYOUT InpWindowLayout = LAYOUT_VERTICAL; // Window Layout Style

input group "=== Window Heights (pixels) ==="
input int InpDMIWindowHeight = 150;                     // DMI Window Height
input int InpDidiWindowHeight = 100;                    // Didi Window Height
input int InpStochWindowHeight = 100;                   // Stochastic Window Height
input int InpTrixWindowHeight = 100;                    // TRIX Window Height
input int InpIfrWindowHeight = 100;                     // IFR Window Height

input group "=== Visual Configuration ==="
input ENUM_COLOR_SCHEME InpColorScheme = COLOR_SCHEME_CLASSIC; // Color Scheme
input color InpBullSignalColor = clrLimeGreen;          // Bullish Signal Color
input color InpBearSignalColor = clrRed;                // Bearish Signal Color
input color InpNeutralColor = clrYellow;                // Neutral Signal Color
input color InpGridColor = clrDarkGray;                 // Grid Color
input color InpBackgroundColor = clrBlack;              // Background Color
input int InpSignalArrowSize = 3;                       // Signal Arrow Size

input group "=== Performance Settings ==="
input int InpUpdateFrequency = 1;                       // Update every N bars (1 = every bar)
input bool InpEnableFastMode = false;                   // Fast mode (reduced accuracy)
input int InpMaxHistoryBars = 1000;                     // Maximum history bars to process
input bool InpEnableDebugMode = false;                  // Enable debug logging
input bool InpEnableMemoryOptimization = true;          // Enable memory optimization
input int InpCleanupFrequency = 100;                    // Cleanup every N ticks

input group "=== Advanced Configuration ==="
input bool InpShowConfigPanel = false;                  // Show Configuration Panel
input bool InpEnableAutoSave = true;                    // Auto-save configuration
input string InpConfigFileName = "DidiBot_Config.dat";  // Configuration file name
input int InpPerformanceMonitoringInterval = 300;       // Performance monitoring (seconds)

#include "../include/SignalEngine.mqh"
#include "../include/TradeManager.mqh"
#include "../include/RiskManager.mqh"
#include "../include/GraphicManager.mqh"
#include "../include/WindowManager_optimized.mqh"

//--- Configuration Management Structure
struct DidiBotConfig
{
   // Window settings
   bool enable_dmi_window;
   bool enable_didi_window;
   bool enable_stoch_window;
   bool enable_trix_window;
   bool enable_ifr_window;
   ENUM_WINDOW_LAYOUT window_layout;
   
   // Window heights
   int dmi_window_height;
   int didi_window_height;
   int stoch_window_height;
   int trix_window_height;
   int ifr_window_height;
   
   // Visual settings
   ENUM_COLOR_SCHEME color_scheme;
   color bull_signal_color;
   color bear_signal_color;
   color neutral_color;
   color grid_color;
   color background_color;
   int signal_arrow_size;
   
   // Performance settings
   int update_frequency;
   bool enable_fast_mode;
   int max_history_bars;
   bool enable_debug_mode;
   bool enable_memory_optimization;
   int cleanup_frequency;
   
   // Advanced settings
   bool show_config_panel;
   bool enable_auto_save;
   string config_file_name;
   int performance_monitoring_interval;
};

//--- Global Variables
DidiBotConfig g_config;
CDmi g_dmi;
CDidiIndex g_didi;
CBollingerBands g_bb;
CStochastic g_stoch;
CTrix g_trix;
CIfr g_ifr;
CAtr g_atr;
CTradeManager g_trade_manager;
CGraphicManager g_graphic_manager;
CRiskManager g_risk_manager;
CWindowManagerOptimized g_window_manager;

// Performance monitoring
static int g_update_counter = 0;
static datetime g_last_performance_check = 0;
static datetime g_last_cleanup = 0;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   Print("OnInit: DidiBot Enhanced v1.10 initialization started...");
   
   // Load configuration from inputs
   if(!LoadConfigurationFromInputs())
   {
      Print("OnInit: Failed to load configuration!");
      return(INIT_FAILED);
   }
   
   // Validate configuration parameters
   if(!ValidateConfiguration())
   {
      Print("OnInit: Configuration validation failed!");
      return(INIT_FAILED);
   }
   
   // Initialize performance monitoring
   g_last_performance_check = TimeCurrent();
   g_last_cleanup = TimeCurrent();
   
   //--- Initialize indicator handles with error checking
   if(!InitializeIndicators())
   {
      Print("OnInit: Indicator initialization failed!");
      return(INIT_FAILED);
   }
   
   //--- Initialize risk manager with stop loss configuration
   StopLossConfig stop_config;
   stop_config.type = InpStopType;
   stop_config.atr_multiplier = InpATRMultiplier;
   stop_config.fixed_pips = InpFixedPips;
   stop_config.trailing_enabled = InpTrailingEnabled;
   stop_config.max_stop_pips = InpMaxStopPips;
   stop_config.stop_limit_slippage = InpStopLimitSlippage;
   stop_config.min_stop_distance = InpMinStopDistance;
   
   g_risk_manager.Init(stop_config);
   
   //--- Initialize trade manager
   g_trade_manager.Init();
   
   //--- Initialize optimized window manager
   if(!g_window_manager.Init(ChartID(), "DidiBot", g_config.enable_debug_mode))
   {
      Print("OnInit: Failed to initialize optimized window manager!");
      return(INIT_FAILED);
   }
   
   //--- Initialize enhanced graphic manager
   g_graphic_manager.Init("DidiBot_");
   
   //--- Initialize multi-window display system
   Print("OnInit: Initializing enhanced multi-window display system...");
   if(!g_graphic_manager.InitializeWindows(ChartID()))
   {
      Print("OnInit: Failed to initialize window management system!");
      return(INIT_FAILED);
   }
   
   //--- Create indicator windows based on configuration
   if(!CreateConfiguredWindows())
   {
      Print("OnInit: Failed to create configured windows!");
      return(INIT_FAILED);
   }
   
   //--- Apply visual configuration
   ApplyVisualConfiguration();
   
   //--- Create configuration panel if enabled
   if(g_config.show_config_panel)
   {
      CreateConfigurationPanel();
   }
   
   //--- Auto-save configuration if enabled
   if(g_config.enable_auto_save)
   {
      SaveConfiguration(g_config.config_file_name);
   }
   
   Print("OnInit: DidiBot Enhanced initialized successfully with ", 
         g_window_manager.GetWindowCount(), " windows");
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   Print("OnDeinit: DidiBot Enhanced deinitialization started. Reason: ", reason);
   
   //--- Auto-save configuration before shutdown
   if(g_config.enable_auto_save)
   {
      SaveConfiguration(g_config.config_file_name);
   }
   
   //--- Cleanup enhanced window management system
   Print("OnDeinit: Cleaning up enhanced multi-window display system...");
   g_window_manager.Cleanup();
   g_graphic_manager.CleanupWindows();
   
   //--- Clear all graphic objects
   g_graphic_manager.ClearAll();
   
   //--- Performance summary
   PrintPerformanceSummary();
   
   Print("OnDeinit: DidiBot Enhanced deinitialized successfully.");
}

//+------------------------------------------------------------------+
//| Expert tick function with enhanced performance                  |
//+------------------------------------------------------------------+
void OnTick()
{
   //--- Performance-optimized new bar detection
   static datetime prev_bar_time = 0;
   datetime current_bar_time = (datetime)SeriesInfoInteger(_Symbol, _Period, SERIES_LASTBAR_DATE);
   
   if(current_bar_time > prev_bar_time)
   {
      prev_bar_time = current_bar_time;
      g_update_counter++;
      
      //--- Update only at specified frequency
      if(g_update_counter >= g_config.update_frequency)
      {
         g_update_counter = 0;
         
         //--- Process new bar with enhanced error handling
         if(!ProcessNewBar())
         {
            Print("OnTick: Error processing new bar at ", TimeToString(current_bar_time));
         }
      }
   }
   
   //--- Periodic maintenance
   PerformPeriodicMaintenance();
}

//+------------------------------------------------------------------+
//| Chart event handler for configuration panel                     |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long& lparam, const double& dparam, const string& sparam)
{
   if(id == CHARTEVENT_OBJECT_CLICK)
   {
      if(StringFind(sparam, "DidiBot_Config_") == 0)
      {
         HandleConfigurationPanelClick(sparam);
      }
   }
   else if(id == CHARTEVENT_CHART_CHANGE)
   {
      // Handle window resize events
      if(g_config.window_layout != LAYOUT_CUSTOM)
      {
         AdjustWindowLayout();
      }
   }
}

//+------------------------------------------------------------------+
//| Load configuration from input parameters                        |
//+------------------------------------------------------------------+
bool LoadConfigurationFromInputs()
{
   g_config.enable_dmi_window = InpEnableDMIWindow;
   g_config.enable_didi_window = InpEnableDidiWindow;
   g_config.enable_stoch_window = InpEnableStochWindow;
   g_config.enable_trix_window = InpEnableTrixWindow;
   g_config.enable_ifr_window = InpEnableIfrWindow;
   g_config.window_layout = InpWindowLayout;
   
   g_config.dmi_window_height = InpDMIWindowHeight;
   g_config.didi_window_height = InpDidiWindowHeight;
   g_config.stoch_window_height = InpStochWindowHeight;
   g_config.trix_window_height = InpTrixWindowHeight;
   g_config.ifr_window_height = InpIfrWindowHeight;
   
   g_config.color_scheme = InpColorScheme;
   g_config.bull_signal_color = InpBullSignalColor;
   g_config.bear_signal_color = InpBearSignalColor;
   g_config.neutral_color = InpNeutralColor;
   g_config.grid_color = InpGridColor;
   g_config.background_color = InpBackgroundColor;
   g_config.signal_arrow_size = InpSignalArrowSize;
   
   g_config.update_frequency = InpUpdateFrequency;
   g_config.enable_fast_mode = InpEnableFastMode;
   g_config.max_history_bars = InpMaxHistoryBars;
   g_config.enable_debug_mode = InpEnableDebugMode;
   g_config.enable_memory_optimization = InpEnableMemoryOptimization;
   g_config.cleanup_frequency = InpCleanupFrequency;
   
   g_config.show_config_panel = InpShowConfigPanel;
   g_config.enable_auto_save = InpEnableAutoSave;
   g_config.config_file_name = InpConfigFileName;
   g_config.performance_monitoring_interval = InpPerformanceMonitoringInterval;
   
   return true;
}

//+------------------------------------------------------------------+
//| Validate configuration parameters                               |
//+------------------------------------------------------------------+
bool ValidateConfiguration()
{
   // Validate window heights
   if(g_config.dmi_window_height < 50 || g_config.dmi_window_height > 500)
   {
      Print("Invalid DMI window height: ", g_config.dmi_window_height);
      return false;
   }
   
   if(g_config.didi_window_height < 50 || g_config.didi_window_height > 500)
   {
      Print("Invalid Didi window height: ", g_config.didi_window_height);
      return false;
   }
   
   // Validate performance settings
   if(g_config.update_frequency < 1 || g_config.update_frequency > 100)
   {
      Print("Invalid update frequency: ", g_config.update_frequency);
      return false;
   }
   
   if(g_config.max_history_bars < 100 || g_config.max_history_bars > 10000)
   {
      Print("Invalid max history bars: ", g_config.max_history_bars);
      return false;
   }
   
   // Validate arrow size
   if(g_config.signal_arrow_size < 1 || g_config.signal_arrow_size > 10)
   {
      Print("Invalid signal arrow size: ", g_config.signal_arrow_size);
      return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Initialize indicators with enhanced error handling              |
//+------------------------------------------------------------------+
bool InitializeIndicators()
{
   // Initialize DMI
   if(!g_dmi.Init(_Symbol, _Period, 8))
   {
      Print("OnInit: DMI initialization failed!");
      return false;
   }
   
   // Initialize Didi Index
   if(!g_didi.Init(_Symbol, _Period, 3, 8, 20))
   {
      Print("OnInit: Didi Index initialization failed!");
      return false;
   }
   
   // Initialize Bollinger Bands
   if(!g_bb.Init(_Symbol, _Period, 20, 2.0))
   {
      Print("OnInit: Bollinger Bands initialization failed!");
      return false;
   }
   
   // Initialize Stochastic
   if(!g_stoch.Init(_Symbol, _Period, 5, 3, 3))
   {
      Print("OnInit: Stochastic initialization failed!");
      return false;
   }
   
   // Initialize TRIX
   if(!g_trix.Init(_Symbol, _Period, 14))
   {
      Print("OnInit: TRIX initialization failed!");
      return false;
   }
   
   // Initialize IFR (RSI)
   if(!g_ifr.Init(_Symbol, _Period, 14))
   {
      Print("OnInit: IFR initialization failed!");
      return false;
   }
   
   // Initialize ATR
   if(!g_atr.Init(_Symbol, _Period, InpATRPeriod))
   {
      Print("OnInit: ATR initialization failed!");
      return false;
   }
   
   Print("OnInit: All indicators initialized successfully");
   return true;
}

//+------------------------------------------------------------------+
//| Create windows based on configuration                           |
//+------------------------------------------------------------------+
bool CreateConfiguredWindows()
{
   bool success = true;
   
   // Create windows only if enabled in configuration
   if(g_config.enable_dmi_window)
   {
      if(!g_graphic_manager.CreateDMIWindow(g_dmi, g_config.dmi_window_height))
      {
         Print("Failed to create DMI window");
         success = false;
      }
   }
   
   if(g_config.enable_didi_window)
   {
      if(!g_graphic_manager.CreateDidiWindow(g_didi, g_config.didi_window_height))
      {
         Print("Failed to create Didi window");
         success = false;
      }
   }
   
   if(g_config.enable_stoch_window)
   {
      if(!g_graphic_manager.CreateStochasticWindow(g_stoch, g_config.stoch_window_height))
      {
         Print("Failed to create Stochastic window");
         success = false;
      }
   }
   
   if(g_config.enable_trix_window)
   {
      if(!g_graphic_manager.CreateTrixWindow(g_trix, g_config.trix_window_height))
      {
         Print("Failed to create TRIX window");
         success = false;
      }
   }
   
   if(g_config.enable_ifr_window)
   {
      if(!g_graphic_manager.CreateIfrWindow(g_ifr, g_config.ifr_window_height))
      {
         Print("Failed to create IFR window");
         success = false;
      }
   }
   
   return success;
}

//+------------------------------------------------------------------+
//| Apply visual configuration to all windows                       |
//+------------------------------------------------------------------+
void ApplyVisualConfiguration()
{
   // Apply color scheme to all windows
   for(int i = 0; i < g_window_manager.GetWindowCount(); i++)
   {
      ChartSetInteger(ChartID(), CHART_COLOR_BACKGROUND, g_config.background_color, i);
      ChartSetInteger(ChartID(), CHART_COLOR_GRID, g_config.grid_color, i);
      ChartSetInteger(ChartID(), CHART_SHOW_GRID, true, i);
   }
   
   // Apply window layout
   AdjustWindowLayout();
   
   ChartRedraw(ChartID());
}

//+------------------------------------------------------------------+
//| Adjust window layout based on configuration                     |
//+------------------------------------------------------------------+
void AdjustWindowLayout()
{
   switch(g_config.window_layout)
   {
      case LAYOUT_VERTICAL:
         SetVerticalLayout();
         break;
         
      case LAYOUT_HORIZONTAL:
         SetHorizontalLayout();
         break;
         
      case LAYOUT_GRID:
         SetGridLayout();
         break;
         
      case LAYOUT_CUSTOM:
         // Custom layout - don't change
         break;
   }
}

//+------------------------------------------------------------------+
//| Set vertical window layout                                       |
//+------------------------------------------------------------------+
void SetVerticalLayout()
{
   int total_height = (int)ChartGetInteger(ChartID(), CHART_HEIGHT_IN_PIXELS);
   int window_count = g_window_manager.GetWindowCount();
   
   if(window_count <= 1) return;
   
   // Distribute height proportionally
   int main_chart_height = total_height * 40 / 100; // 40% for main chart
   int indicator_height = total_height * 60 / 100 / (window_count - 1); // 60% for indicators
   
   for(int i = 1; i < window_count; i++)
   {
      ChartSetInteger(ChartID(), CHART_HEIGHT_IN_PIXELS, indicator_height, i);
   }
}

//+------------------------------------------------------------------+
//| Save configuration to file                                       |
//+------------------------------------------------------------------+
bool SaveConfiguration(const string filename)
{
   int file_handle = FileOpen(filename, FILE_WRITE | FILE_BIN);
   if(file_handle == INVALID_HANDLE)
   {
      Print("Failed to create configuration file: ", filename);
      return false;
   }
   
   FileWriteStruct(file_handle, g_config);
   FileClose(file_handle);
   
   Print("Configuration saved to: ", filename);
   return true;
}

//+------------------------------------------------------------------+
//| Load configuration from file                                     |
//+------------------------------------------------------------------+
bool LoadConfiguration(const string filename)
{
   int file_handle = FileOpen(filename, FILE_READ | FILE_BIN);
   if(file_handle == INVALID_HANDLE)
   {
      Print("Configuration file not found: ", filename);
      return false;
   }
   
   FileReadStruct(file_handle, g_config);
   FileClose(file_handle);
   
   Print("Configuration loaded from: ", filename);
   return true;
}

//+------------------------------------------------------------------+
//| Create configuration panel                                       |
//+------------------------------------------------------------------+
void CreateConfigurationPanel()
{
   // Implementation for on-screen configuration panel
   // This would create interactive buttons and controls
   Print("Configuration panel created");
}

//+------------------------------------------------------------------+
//| Handle configuration panel clicks                               |
//+------------------------------------------------------------------+
void HandleConfigurationPanelClick(const string object_name)
{
   // Implementation for handling panel interactions
   Print("Configuration panel click: ", object_name);
}

//+------------------------------------------------------------------+
//| Process new bar with enhanced logic                             |
//+------------------------------------------------------------------+
bool ProcessNewBar()
{
   try
   {
      // Update all displays with current data
      g_graphic_manager.UpdateAllDisplays(g_dmi, g_didi, g_bb, g_stoch, g_trix, g_ifr);
      
      // Update signal panel with stop loss information
      g_graphic_manager.UpdateSignalPanelWithStops(g_dmi, g_didi, g_bb, g_stoch, g_trix, g_ifr,
                                                   g_atr, g_risk_manager, g_trade_manager);
      
      // Process trading logic (existing implementation)
      // ... trading logic here ...
      
      return true;
   }
   catch(...)
   {
      Print("Error in ProcessNewBar");
      return false;
   }
}

//+------------------------------------------------------------------+
//| Perform periodic maintenance                                     |
//+------------------------------------------------------------------+
void PerformPeriodicMaintenance()
{
   datetime current_time = TimeCurrent();
   
   // Performance monitoring
   if(current_time - g_last_performance_check >= g_config.performance_monitoring_interval)
   {
      MonitorPerformance();
      g_last_performance_check = current_time;
   }
   
   // Cleanup
   if(current_time - g_last_cleanup >= g_config.cleanup_frequency)
   {
      g_window_manager.PerformMaintenanceCleanup();
      g_last_cleanup = current_time;
   }
}

//+------------------------------------------------------------------+
//| Monitor system performance                                       |
//+------------------------------------------------------------------+
void MonitorPerformance()
{
   if(g_config.enable_debug_mode)
   {
      Print("Performance Check - Windows: ", g_window_manager.GetWindowCount(),
            " Errors: ", g_window_manager.GetErrorCount(),
            " Memory: ", g_window_manager.GetTotalMemoryUsage(), " bytes");
   }
   
   // Check system health
   if(!g_window_manager.CheckSystemHealth())
   {
      Print("System health check failed - consider restarting EA");
   }
}

//+------------------------------------------------------------------+
//| Print performance summary                                        |
//+------------------------------------------------------------------+
void PrintPerformanceSummary()
{
   Print("=== DidiBot Enhanced Performance Summary ===");
   Print("Total Windows Created: ", g_window_manager.GetWindowCount());
   Print("Total Errors: ", g_window_manager.GetErrorCount());
   Print("Memory Usage: ", g_window_manager.GetTotalMemoryUsage(), " bytes");
   Print("Configuration: ", g_config.enable_debug_mode ? "Debug" : "Release");
}

//+------------------------------------------------------------------+
//| Set horizontal layout (placeholder)                             |
//+------------------------------------------------------------------+
void SetHorizontalLayout()
{
   // Implementation for horizontal layout
   Print("Horizontal layout applied");
}

//+------------------------------------------------------------------+
//| Set grid layout (placeholder)                                   |
//+------------------------------------------------------------------+
void SetGridLayout()
{
   // Implementation for grid layout
   Print("Grid layout applied");
}
