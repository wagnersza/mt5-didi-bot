# MT5 Didi Bot - Multi-Window Configuration Guide

## Overview

This guide covers advanced configuration options for the multi-window display system, including customizable window layouts, colors, and performance settings.

## Window Configuration Options

### Default Configuration

The system comes with optimized default settings:

```mql5
// Default Window Heights (pixels)
#define DEFAULT_DMI_WINDOW_HEIGHT      150
#define DEFAULT_DIDI_WINDOW_HEIGHT     100
#define DEFAULT_STOCH_WINDOW_HEIGHT    100
#define DEFAULT_TRIX_WINDOW_HEIGHT     100
#define DEFAULT_IFR_WINDOW_HEIGHT      100

// Default Colors
#define DEFAULT_BULL_COLOR             clrLimeGreen
#define DEFAULT_BEAR_COLOR             clrRed
#define DEFAULT_NEUTRAL_COLOR          clrYellow
```

### Configurable Parameters

Add these input parameters to customize window behavior:

```mql5
//--- Window Configuration
input group "=== Window Layout ==="
input bool     EnableDMIWindow = true;          // Enable DMI Window
input bool     EnableDidiWindow = true;         // Enable Didi Index Window  
input bool     EnableStochWindow = true;        // Enable Stochastic Window
input bool     EnableTrixWindow = true;         // Enable TRIX Window
input bool     EnableIfrWindow = true;          // Enable IFR/RSI Window

input group "=== Window Heights ==="
input int      DMIWindowHeight = 150;           // DMI Window Height (pixels)
input int      DidiWindowHeight = 100;          // Didi Window Height (pixels)
input int      StochWindowHeight = 100;         // Stochastic Window Height (pixels)
input int      TrixWindowHeight = 100;          // TRIX Window Height (pixels)
input int      IfrWindowHeight = 100;           // IFR Window Height (pixels)

input group "=== Color Scheme ==="
input color    BullSignalColor = clrLimeGreen;  // Bullish Signal Color
input color    BearSignalColor = clrRed;        // Bearish Signal Color
input color    NeutralColor = clrYellow;        // Neutral Signal Color
input color    GridColor = clrDarkGray;         // Grid Color
input color    BackgroundColor = clrBlack;      // Background Color
```

## Window Layout Customization

### Window Enable/Disable

Control which indicator windows are created:

```mql5
// In OnInit()
if(EnableDMIWindow && !g_graphic_manager.CreateDMIWindow(g_dmi, DMIWindowHeight))
{
    Print("Failed to create DMI window");
}

if(EnableDidiWindow && !g_graphic_manager.CreateDidiWindow(g_didi, DidiWindowHeight))
{
    Print("Failed to create Didi window");
}
// ... continue for other windows
```

### Dynamic Window Height Adjustment

Implement runtime height changes:

```mql5
bool AdjustWindowHeight(int window_index, int new_height)
{
    return ChartSetInteger(ChartID(), CHART_HEIGHT_IN_PIXELS, new_height, window_index);
}

// Usage example
void OnChartEvent(const int id, const long& lparam, const double& dparam, const string& sparam)
{
    if(id == CHARTEVENT_CHART_CHANGE)
    {
        // Adjust window heights based on total chart height
        int total_height = (int)ChartGetInteger(ChartID(), CHART_HEIGHT_IN_PIXELS);
        
        // Distribute height proportionally
        AdjustWindowHeight(1, total_height * 20 / 100); // DMI: 20%
        AdjustWindowHeight(2, total_height * 15 / 100); // Didi: 15%
        AdjustWindowHeight(3, total_height * 15 / 100); // Stoch: 15%
        AdjustWindowHeight(4, total_height * 15 / 100); // TRIX: 15%
        AdjustWindowHeight(5, total_height * 15 / 100); // IFR: 15%
        // Main chart gets remaining 20%
    }
}
```

## Color Scheme Configuration

### Custom Color Implementation

Create a color configuration system:

```mql5
struct ColorScheme
{
    color bull_color;
    color bear_color;
    color neutral_color;
    color background_color;
    color grid_color;
    color text_color;
};

// Predefined schemes
ColorScheme GetColorScheme(ENUM_COLOR_SCHEME scheme)
{
    ColorScheme colors;
    
    switch(scheme)
    {
        case COLOR_SCHEME_CLASSIC:
            colors.bull_color = clrLimeGreen;
            colors.bear_color = clrRed;
            colors.neutral_color = clrYellow;
            colors.background_color = clrBlack;
            colors.grid_color = clrDarkGray;
            colors.text_color = clrWhite;
            break;
            
        case COLOR_SCHEME_PROFESSIONAL:
            colors.bull_color = clrDodgerBlue;
            colors.bear_color = clrOrangeRed;
            colors.neutral_color = clrGold;
            colors.background_color = clrMidnightBlue;
            colors.grid_color = clrSlateGray;
            colors.text_color = clrWhiteSmoke;
            break;
            
        case COLOR_SCHEME_HIGH_CONTRAST:
            colors.bull_color = clrLime;
            colors.bear_color = clrMagenta;
            colors.neutral_color = clrCyan;
            colors.background_color = clrBlack;
            colors.grid_color = clrWhite;
            colors.text_color = clrWhite;
            break;
    }
    
    return colors;
}
```

### Window-Specific Color Settings

Apply different color schemes to each window:

```mql5
void ApplyWindowColorScheme(int window_index, ColorScheme& colors)
{
    ChartSetInteger(ChartID(), CHART_COLOR_BACKGROUND, colors.background_color, window_index);
    ChartSetInteger(ChartID(), CHART_COLOR_FOREGROUND, colors.text_color, window_index);
    ChartSetInteger(ChartID(), CHART_COLOR_GRID, colors.grid_color, window_index);
    ChartSetInteger(ChartID(), CHART_SHOW_GRID, true, window_index);
}

// Apply to all windows
void ApplyGlobalColorScheme(ENUM_COLOR_SCHEME scheme)
{
    ColorScheme colors = GetColorScheme(scheme);
    
    for(int i = 0; i < g_window_manager.GetWindowCount(); i++)
    {
        ApplyWindowColorScheme(i, colors);
    }
    
    ChartRedraw();
}
```

## Performance Configuration

### Update Frequency Control

Optimize update cycles for performance:

```mql5
input group "=== Performance Settings ==="
input int      UpdateFrequency = 1;             // Update every N bars (1 = every bar)
input bool     EnableFastMode = false;          // Fast mode (reduced accuracy)
input int      MaxHistoryBars = 1000;           // Maximum history bars to process
input bool     EnableDebugMode = false;         // Enable debug logging

// Implementation
static int update_counter = 0;

void OnTick()
{
    static datetime prev_bar_time = 0;
    datetime current_bar_time = (datetime)SeriesInfoInteger(_Symbol, _Period, SERIES_LASTBAR_DATE);
    
    if(current_bar_time > prev_bar_time)
    {
        prev_bar_time = current_bar_time;
        update_counter++;
        
        // Update only at specified frequency
        if(update_counter >= UpdateFrequency)
        {
            update_counter = 0;
            UpdateAllWindows();
        }
    }
}
```

### Memory Management Settings

Control memory usage:

```mql5
input group "=== Memory Management ==="
input int      IndicatorBufferSize = 5000;      // Indicator buffer size
input bool     EnableMemoryOptimization = true; // Enable memory optimization
input int      CleanupFrequency = 100;          // Cleanup every N ticks

// Buffer size management
void OptimizeIndicatorBuffers()
{
    if(EnableMemoryOptimization)
    {
        // Set buffer sizes for all indicators
        ArraySetAsSeries(g_dmi.m_adx_buffer, true);
        ArrayResize(g_dmi.m_adx_buffer, IndicatorBufferSize);
        
        ArraySetAsSeries(g_didi.m_short_ma_buffer, true);
        ArrayResize(g_didi.m_short_ma_buffer, IndicatorBufferSize);
        
        // Continue for other indicators...
    }
}
```

## Advanced Configuration Options

### Window Position Management

Control window positions and layouts:

```mql5
enum ENUM_WINDOW_LAYOUT
{
    LAYOUT_VERTICAL,     // Vertical stacking (default)
    LAYOUT_HORIZONTAL,   // Horizontal arrangement
    LAYOUT_GRID,         // Grid layout
    LAYOUT_CUSTOM        // User-defined positions
};

input ENUM_WINDOW_LAYOUT WindowLayout = LAYOUT_VERTICAL;

void ArrangeWindows(ENUM_WINDOW_LAYOUT layout)
{
    switch(layout)
    {
        case LAYOUT_VERTICAL:
            // Stack windows vertically with equal heights
            SetVerticalLayout();
            break;
            
        case LAYOUT_HORIZONTAL:
            // Arrange windows horizontally
            SetHorizontalLayout();
            break;
            
        case LAYOUT_GRID:
            // 2x3 grid arrangement
            SetGridLayout();
            break;
            
        case LAYOUT_CUSTOM:
            // Load user-defined positions
            LoadCustomLayout();
            break;
    }
}
```

### Export/Import Configuration

Save and load window configurations:

```mql5
struct WindowConfig
{
    bool enabled;
    int height;
    color background_color;
    color line_color;
    int line_width;
};

// Save configuration
bool SaveWindowConfiguration(string filename)
{
    int file_handle = FileOpen(filename, FILE_WRITE | FILE_BIN);
    if(file_handle == INVALID_HANDLE)
        return false;
        
    WindowConfig config[];
    ArrayResize(config, 6); // 6 windows
    
    // Populate configuration array
    for(int i = 0; i < 6; i++)
    {
        config[i].enabled = g_window_manager.IsWindowActive(i);
        config[i].height = GetWindowHeight(i);
        config[i].background_color = GetWindowBackgroundColor(i);
        // ... fill other properties
    }
    
    FileWriteArray(file_handle, config);
    FileClose(file_handle);
    return true;
}

// Load configuration
bool LoadWindowConfiguration(string filename)
{
    int file_handle = FileOpen(filename, FILE_READ | FILE_BIN);
    if(file_handle == INVALID_HANDLE)
        return false;
        
    WindowConfig config[];
    int count = FileReadArray(file_handle, config);
    FileClose(file_handle);
    
    if(count != 6)
        return false;
        
    // Apply configuration
    for(int i = 0; i < count; i++)
    {
        if(config[i].enabled)
        {
            SetWindowHeight(i, config[i].height);
            SetWindowBackgroundColor(i, config[i].background_color);
            // ... apply other properties
        }
        else
        {
            DisableWindow(i);
        }
    }
    
    return true;
}
```

## User Interface Configuration

### Configuration Panel

Create an on-screen configuration panel:

```mql5
void CreateConfigurationPanel()
{
    string panel_name = "ConfigPanel";
    
    // Main panel background
    ObjectCreate(0, panel_name, OBJ_RECTANGLE_LABEL, 0, 0, 0);
    ObjectSetInteger(0, panel_name, OBJPROP_XDISTANCE, 10);
    ObjectSetInteger(0, panel_name, OBJPROP_YDISTANCE, 10);
    ObjectSetInteger(0, panel_name, OBJPROP_XSIZE, 200);
    ObjectSetInteger(0, panel_name, OBJPROP_YSIZE, 300);
    ObjectSetInteger(0, panel_name, OBJPROP_BGCOLOR, clrDarkSlateGray);
    ObjectSetInteger(0, panel_name, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    
    // Window enable/disable buttons
    CreateConfigButton("BtnDMI", "DMI", 20, 40, EnableDMIWindow);
    CreateConfigButton("BtnDidi", "Didi", 20, 70, EnableDidiWindow);
    CreateConfigButton("BtnStoch", "Stoch", 20, 100, EnableStochWindow);
    CreateConfigButton("BtnTrix", "TRIX", 20, 130, EnableTrixWindow);
    CreateConfigButton("BtnIFR", "IFR", 20, 160, EnableIfrWindow);
    
    // Height adjustment controls
    CreateSlider("SliderDMI", 120, 40, DMIWindowHeight);
    CreateSlider("SliderDidi", 120, 70, DidiWindowHeight);
    // ... continue for other windows
}

void CreateConfigButton(string name, string text, int x, int y, bool state)
{
    ObjectCreate(0, name, OBJ_BUTTON, 0, 0, 0);
    ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
    ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
    ObjectSetInteger(0, name, OBJPROP_XSIZE, 80);
    ObjectSetInteger(0, name, OBJPROP_YSIZE, 25);
    ObjectSetString(0, name, OBJPROP_TEXT, text);
    ObjectSetInteger(0, name, OBJPROP_STATE, state);
    ObjectSetInteger(0, name, OBJPROP_COLOR, state ? clrLimeGreen : clrRed);
}
```

### Configuration Presets

Implement quick-access presets:

```mql5
enum ENUM_CONFIG_PRESET
{
    PRESET_MINIMAL,      // Main chart + Didi only
    PRESET_STANDARD,     // All windows with default settings  
    PRESET_ADVANCED,     // All windows with optimized sizes
    PRESET_ANALYSIS,     // Focus on oscillators
    PRESET_TREND         // Focus on trend indicators
};

void ApplyConfigurationPreset(ENUM_CONFIG_PRESET preset)
{
    switch(preset)
    {
        case PRESET_MINIMAL:
            EnableDMIWindow = false;
            EnableDidiWindow = true;
            EnableStochWindow = false;
            EnableTrixWindow = false;
            EnableIfrWindow = false;
            break;
            
        case PRESET_STANDARD:
            EnableDMIWindow = true;
            EnableDidiWindow = true;
            EnableStochWindow = true;
            EnableTrixWindow = true;
            EnableIfrWindow = true;
            DMIWindowHeight = 150;
            DidiWindowHeight = 100;
            StochWindowHeight = 100;
            TrixWindowHeight = 100;
            IfrWindowHeight = 100;
            break;
            
        case PRESET_ANALYSIS:
            EnableDMIWindow = false;
            EnableDidiWindow = false;
            EnableStochWindow = true;
            EnableTrixWindow = true;
            EnableIfrWindow = true;
            StochWindowHeight = 150;
            TrixWindowHeight = 150;
            IfrWindowHeight = 150;
            break;
    }
    
    RecreateWindows();
}
```

## Implementation Guidelines

### Adding Configuration to Existing EA

1. **Add Input Parameters**:
   - Define input variables for all configurable options
   - Group related parameters for better organization

2. **Modify Initialization**:
   - Update `OnInit()` to use configuration parameters
   - Add validation for parameter ranges

3. **Update Window Management**:
   - Modify window creation to use configuration
   - Add runtime configuration change support

4. **Implement Save/Load**:
   - Add configuration persistence
   - Support for multiple configuration profiles

### Best Practices

1. **Parameter Validation**:
   ```mql5
   bool ValidateConfiguration()
   {
       if(DMIWindowHeight < 50 || DMIWindowHeight > 500)
       {
           Print("Invalid DMI window height: ", DMIWindowHeight);
           return false;
       }
       // ... validate other parameters
       return true;
   }
   ```

2. **Runtime Updates**:
   ```mql5
   void OnChartEvent(const int id, const long& lparam, const double& dparam, const string& sparam)
   {
       if(id == CHARTEVENT_OBJECT_CLICK)
       {
           if(StringFind(sparam, "Btn") == 0)
           {
               HandleConfigButtonClick(sparam);
           }
       }
   }
   ```

3. **Error Handling**:
   - Validate all configuration parameters
   - Provide fallback defaults for invalid values
   - Log configuration errors clearly

4. **Performance Considerations**:
   - Cache configuration values
   - Minimize runtime configuration changes
   - Use efficient update mechanisms

This configuration system provides comprehensive control over the multi-window display while maintaining ease of use for both novice and advanced users.
