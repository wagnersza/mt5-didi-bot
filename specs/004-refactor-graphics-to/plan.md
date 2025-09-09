# Implementation Plan: Refactor Graphics to Separate Indicator Windows

## Overview
Refactor the existing GraphicManager system to display indicators in separate windows instead of a unified visualization approach.

## Technical Stack
- **Language**: MQL5
- **Platform**: MetaTrader 5 (macOS native)
- **Architecture**: Multi-window indicator display system
- **Dependencies**: Existing SignalEngine.mqh indicator classes

## Target Architecture

### Window Layout
1. **Main Chart Window (0)**: Price action + Bollinger Bands
2. **DMI Window (1)**: ADX, +DI, -DI indicators  
3. **Didi Index Window (2)**: Short, Medium, Long MA crossovers
4. **Stochastic Window (3)**: %K and %D oscillator lines
5. **Trix Window (4)**: TRIX indicator with signal line
6. **IFR Window (5)**: Relative Strength Index (0-100 scale)

### Core Components

#### 1. Window Manager Class (`WindowManager.mqh`)
New class to handle window creation and management:
- Window index tracking and assignment
- Indicator attachment to specific windows
- Window cleanup and destruction
- Window properties configuration (height, colors, scales)

#### 2. Refactored GraphicManager (`GraphicManager.mqh`)
Update existing class to work with multiple windows:
- Window-specific drawing methods
- Maintain object naming conventions with window prefixes
- Coordinate drawing across multiple windows
- Handle window-specific cleanup

#### 3. Indicator-Specific Display Classes
Create specialized display handlers for each window:
- `DmiDisplay`: Handle DMI window visualization
- `DidiDisplay`: Handle Didi Index window visualization  
- `StochasticDisplay`: Handle Stochastic window visualization
- `TrixDisplay`: Handle Trix window visualization
- `IfrDisplay`: Handle IFR window visualization
- `MainChartDisplay`: Handle price action and Bollinger Bands

## Implementation Strategy

### Phase 1: Window Management Infrastructure
- Create WindowManager class for window lifecycle management
- Implement window creation, indexing, and cleanup
- Add window configuration methods (height, scaling, colors)

### Phase 2: Indicator Window Displays
- Create individual display classes for each indicator window
- Implement window-specific drawing methods
- Add proper scaling and axis management for each indicator type
- Ensure thread-safe window operations

### Phase 3: GraphicManager Refactoring
- Update GraphicManager to coordinate multiple display classes
- Implement window assignment logic
- Add unified cleanup for all windows
- Maintain backward compatibility for signal drawing

### Phase 4: Integration and Testing
- Integrate new window system with existing EA
- Update DidiBot.mq5 initialization to create indicator windows
- Test window management during EA startup/shutdown
- Validate proper display across all indicator windows

## File Structure Changes

### New Files
```
experts/mt5-didi-bot/include/
├── WindowManager.mqh           # Window lifecycle management
├── displays/
│   ├── DmiDisplay.mqh         # DMI window visualization
│   ├── DidiDisplay.mqh        # Didi Index window visualization
│   ├── StochasticDisplay.mqh  # Stochastic window visualization
│   ├── TrixDisplay.mqh        # Trix window visualization
│   ├── IfrDisplay.mqh         # IFR window visualization
│   └── MainChartDisplay.mqh   # Main chart + Bollinger Bands
```

### Modified Files
```
experts/mt5-didi-bot/include/GraphicManager.mqh  # Multi-window coordination
experts/mt5-didi-bot/experts/DidiBot.mq5         # Window initialization
```

## MQL5 Technical Considerations

### Window Management
- Use `ChartIndicatorAdd()` for creating indicator windows
- Track window indexes for proper object placement
- Implement proper window cleanup in `OnDeinit()`
- Handle window resize and property changes

### Drawing Coordination
- Window-specific object naming: `[prefix]_[window]_[object]`
- Coordinate drawing timing across multiple windows
- Manage different scaling for each indicator type
- Ensure proper layering and z-order

### Memory Management
- Create window handles once in `OnInit()`
- Proper cleanup of all window objects in `OnDeinit()`
- Avoid memory leaks with proper object destruction
- Handle EA recompilation scenarios

## Dependencies
- Existing `SignalEngine.mqh` indicator classes (CDmi, CDidiIndex, etc.)
- Current `GraphicManager.mqh` functionality
- MT5 Chart object management APIs
- Standard MQL5 drawing and window functions

## Success Criteria
- Each indicator displays in its dedicated window
- Bollinger Bands remain on main price chart
- All existing signal functionality preserved
- Proper window cleanup on EA termination
- No performance degradation from multiple windows
- Clean, organized visual presentation
