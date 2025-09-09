# MT5 Didi Bot - Multi-Window System User Guide

## Overview

The MT5 Didi Bot implements a sophisticated multi-window display system that separates each technical indicator into its own dedicated window for improved analysis and visual clarity.

## Window Layout

The system creates 6 windows total:

### 1. Main Chart Window (Window 0)
- **Purpose**: Price action display with Bollinger Bands
- **Content**: 
  - Candlestick price data
  - Bollinger Bands upper/middle/lower lines
  - Trade entry/exit signal arrows
  - Stop loss and take profit levels

### 2. DMI Window (Window 1)
- **Purpose**: Directional Movement Index analysis
- **Content**:
  - ADX line (trend strength indicator)
  - +DI line (positive directional indicator) 
  - -DI line (negative directional indicator)
  - Threshold levels at 25 and 50
  - DMI crossover signals

### 3. Didi Index Window (Window 2)
- **Purpose**: Didi Index moving average analysis
- **Content**:
  - Short MA (3-period)
  - Medium MA (8-period) 
  - Long MA (20-period)
  - Agulhada signal highlighting
  - MA crossover visualization

### 4. Stochastic Window (Window 3)
- **Purpose**: Stochastic oscillator momentum analysis
- **Content**:
  - %K line (fast stochastic)
  - %D line (slow stochastic)
  - Overbought level (80)
  - Oversold level (20)
  - Crossover signals

### 5. TRIX Window (Window 4)
- **Purpose**: TRIX momentum indicator
- **Content**:
  - TRIX line
  - Signal line
  - Zero-line crossovers
  - Momentum change signals

### 6. IFR/RSI Window (Window 5)
- **Purpose**: Relative Strength Index analysis
- **Content**:
  - RSI line (0-100 scale)
  - Overbought level (70)
  - Oversold level (30)
  - Divergence signals

## Installation and Setup

### 1. EA Installation
1. Copy `DidiBot.ex5` to your MetaTrader 5 data folder under `MQL5/Experts/`
2. Restart MetaTrader 5 or refresh Expert Advisors list
3. Drag the EA to any chart

### 2. First-Time Setup
When you first attach the EA to a chart:

1. **Automatic Window Creation**: The EA will automatically create all 6 indicator windows
2. **Window Arrangement**: Windows will be arranged vertically with default heights
3. **Indicator Initialization**: All technical indicators will be initialized and begin calculating

### 3. Window Management
The system automatically:
- Creates windows with appropriate scaling for each indicator type
- Assigns unique identifiers to prevent conflicts
- Manages memory for all window objects
- Handles cleanup when EA is removed

## Multi-Window Configuration

### Default Window Settings
- **Main Chart**: Full-height price display
- **DMI Window**: 150 pixels height, 0-100 scale
- **Didi Window**: 100 pixels height, price-based scale
- **Stochastic Window**: 100 pixels height, 0-100 scale
- **TRIX Window**: 100 pixels height, centered zero-line
- **IFR Window**: 100 pixels height, 0-100 scale

### Window Colors
Each window uses a distinct color scheme:
- **DMI**: Blue (ADX), Green (+DI), Red (-DI)
- **Didi**: Red (Short), Yellow (Medium), Blue (Long)
- **Stochastic**: Blue (%K), Red (%D)
- **TRIX**: Magenta (TRIX), Cyan (Signal)
- **IFR**: Orange (RSI)

## Trading Signals

### Signal Generation
The multi-window system coordinates signals across all indicators:

1. **Primary Signals**: Generated on the main chart as arrows
2. **Supporting Signals**: Displayed in respective indicator windows
3. **Signal Confirmation**: Requires alignment across multiple indicators

### Signal Types

#### Buy Signals (Green Arrows)
- Didi Index "agulhada" formation (Short > Medium > Long)
- DMI showing strong trend (+DI > -DI, ADX > 25)
- Stochastic oversold reversal (%K and %D > 20)
- TRIX zero-line crossover upward
- RSI oversold recovery (> 30)

#### Sell Signals (Red Arrows)
- Didi Index reverse formation (Short < Medium < Long)
- DMI showing strong downtrend (-DI > +DI, ADX > 25)
- Stochastic overbought reversal (%K and %D < 80)
- TRIX zero-line crossover downward
- RSI overbought decline (< 70)

## Performance Optimization

### Window Update Efficiency
The system optimizes performance by:
- **New Bar Detection**: Updates only occur on new bar formation
- **Selective Updates**: Only modified indicators trigger window redraws
- **Memory Management**: Proper cleanup prevents memory leaks
- **Handle Reuse**: Indicator handles are created once and reused

### Resource Management
- **CPU Usage**: Minimized through efficient new bar detection
- **Memory Usage**: Controlled through proper object lifecycle management
- **Network Usage**: No external dependencies or data feeds required

## Customization Options

### Visual Customization
Users can modify:
- Window heights (via MetaTrader 5 chart properties)
- Color schemes (through MT5 color settings)
- Line styles and widths
- Signal arrow sizes and colors

### Technical Parameters
Adjustable parameters include:
- DMI period and threshold levels
- Didi Index MA periods (3, 8, 20 default)
- Stochastic %K and %D periods
- TRIX smoothing period
- RSI calculation period

## Best Practices

### Chart Setup
1. **Timeframe Selection**: Works on all timeframes, recommended H1 or H4
2. **Symbol Compatibility**: Compatible with all Forex pairs and CFDs
3. **Chart Size**: Ensure adequate screen space for 6 windows

### Analysis Workflow
1. **Primary Analysis**: Start with main chart price action
2. **Trend Confirmation**: Check DMI window for trend strength
3. **Entry Timing**: Use Didi Index window for precise entry points
4. **Momentum Check**: Verify with Stochastic and TRIX windows
5. **Overbought/Oversold**: Confirm with RSI window

### Risk Management
- Always use proper position sizing
- Set stop losses based on ATR calculations
- Monitor multiple timeframes for confirmation
- Never rely on single indicator signals

## System Requirements

### MetaTrader 5 Requirements
- MetaTrader 5 build 3640 or higher
- Minimum 4GB RAM for smooth operation
- Graphics card supporting multiple chart windows

### Supported Platforms
- ✅ Windows (fully supported)
- ✅ macOS (native support)
- ✅ Linux (via Wine)
- ✅ VPS hosting compatible

## Next Steps

After successful installation:
1. Review the troubleshooting guide for common issues
2. Practice with demo account before live trading
3. Understand all signal types before relying on automation
4. Regular monitoring of system performance

For advanced configuration options, see the Configuration Guide.
For troubleshooting, see the Troubleshooting Guide.
