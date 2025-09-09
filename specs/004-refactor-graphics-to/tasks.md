# Tasks: Refactor Graphics to Separate Indicator Windows

**Input**: Design documents from `/specs/004-refactor-graphics-to/`
**Prerequisites**: plan.md (completed)

## Execution Flow Overview

The graphics refactoring will split the current unified GraphicManager into a multi-window system where each indicator displays in its dedicated window. This follows MQL5 window management patterns and maintains the existing signal functionality.

## Task Breakdown

### Phase 1: Setup and Infrastructure ✅ COMPLETED

#### T001: ✅ Create WindowManager class foundation
- ✅ Create new file `experts/mt5-didi-bot/include/WindowManager.mqh`
- ✅ Implement basic class structure with window index tracking
- ✅ Add window creation and cleanup methods
- ✅ Include proper MQL5 window management APIs
- **Files**: `experts/mt5-didi-bot/include/WindowManager.mqh` (new)
- **Dependencies**: None
- **Status**: COMPLETED - WindowManager class implemented with full window lifecycle management

#### T002: ✅ Create displays directory structure
- ✅ Create `experts/mt5-didi-bot/include/displays/` directory
- ✅ Set up modular structure for indicator-specific display classes
- **Files**: Directory structure, README.md placeholder
- **Dependencies**: None
- **Status**: COMPLETED - Directory structure created and ready for display classes

### Phase 2: Test Framework Setup (TDD Approach) ✅ COMPLETED

#### T003: ✅ [P] Create unit tests for WindowManager
- ✅ Create `experts/mt5-didi-bot/tests/test_window_manager.mq5`
- ✅ Test window creation, indexing, and cleanup functionality
- ✅ Test window properties configuration
- ✅ Test error handling and validation scenarios
- **Files**: `experts/mt5-didi-bot/tests/test_window_manager.mq5` (new)
- **Dependencies**: T001
- **Status**: COMPLETED - Comprehensive unit test suite with 7 test scenarios

#### T004: ✅ [P] Create integration tests for multi-window display
- ✅ Create `experts/mt5-didi-bot/tests/test_multi_window_display.mq5`
- ✅ Test indicator window coordination and drawing
- ✅ Test window-specific object management
- ✅ Test multi-window lifecycle and synchronization
- **Files**: `experts/mt5-didi-bot/tests/test_multi_window_display.mq5` (new)
- **Dependencies**: T001
- **Status**: COMPLETED - Integration test suite covering window coordination and data flow

### Phase 3: Display Classes Implementation (Parallel) ✅ COMPLETED

#### T005: ✅ [P] Implement DmiDisplay class
- ✅ Create `experts/mt5-didi-bot/include/displays/DmiDisplay.mqh`
- ✅ Implement DMI-specific window visualization (ADX, +DI, -DI)
- ✅ Add proper scaling for oscillator values (0-100 range)
- ✅ Include DMI signal visualization methods
- **Files**: `experts/mt5-didi-bot/include/displays/DmiDisplay.mqh` (new)
- **Dependencies**: T001, T002
- **Status**: COMPLETED - DMI display class with ADX threshold levels and DI crossover signals

#### T006: ✅ [P] Implement DidiDisplay class
- ✅ Create `experts/mt5-didi-bot/include/displays/DidiDisplay.mqh`
- ✅ Implement Didi Index window visualization (Short, Medium, Long MA)
- ✅ Add agulhada signal highlighting in dedicated window
- ✅ Include proper MA crossover visualization
- **Files**: `experts/mt5-didi-bot/include/displays/DidiDisplay.mqh` (new)
- **Dependencies**: T001, T002
- **Status**: COMPLETED - Didi display class with agulhada detection and MA crossover signals

#### T007: ✅ [P] Implement StochasticDisplay class
- ✅ Create `experts/mt5-didi-bot/include/displays/StochasticDisplay.mqh`
- ✅ Implement Stochastic oscillator window (%K and %D lines)
- ✅ Add overbought/oversold level lines (20, 80)
- ✅ Include stochastic crossover signals
- **Files**: `experts/mt5-didi-bot/include/displays/StochasticDisplay.mqh` (new)
- **Dependencies**: T001, T002
- **Status**: COMPLETED - Stochastic display class with OB/OS levels and crossover detection

#### T008: ✅ [P] Implement TrixDisplay class
- ✅ Create `experts/mt5-didi-bot/include/displays/TrixDisplay.mqh`
- ✅ Implement TRIX indicator window with signal line
- ✅ Add zero-line crossover visualization
- ✅ Include TRIX momentum signals
- **Files**: `experts/mt5-didi-bot/include/displays/TrixDisplay.mqh` (new)
- **Dependencies**: T001, T002
- **Status**: COMPLETED - TRIX display class with zero-line crossovers and momentum detection

#### T009: ✅ [P] Implement IfrDisplay class
- ✅ Create `experts/mt5-didi-bot/include/displays/IfrDisplay.mqh`
- ✅ Implement IFR (RSI) window with 0-100 scale
- ✅ Add overbought/oversold levels (30, 70)
- ✅ Include divergence detection visualization
- **Files**: `experts/mt5-didi-bot/include/displays/IfrDisplay.mqh` (new)
- **Dependencies**: T001, T002
- **Status**: COMPLETED - IFR display class with OB/OS levels and divergence signals

#### T010: ✅ [P] Implement MainChartDisplay class
- ✅ Create `experts/mt5-didi-bot/include/displays/MainChartDisplay.mqh`
- ✅ Handle price action visualization on main chart
- ✅ Implement Bollinger Bands display on main chart
- ✅ Maintain existing entry/exit signal arrows
- **Files**: `experts/mt5-didi-bot/include/displays/MainChartDisplay.mqh` (new)
- **Dependencies**: T001, T002
- **Status**: COMPLETED - Main chart display class with Bollinger Bands and trade signals

### Phase 4: Core Integration ✅ COMPLETED

#### T011: ✅ Refactor GraphicManager for multi-window coordination
- ✅ Update `experts/mt5-didi-bot/include/GraphicManager.mqh`
- ✅ Integrate WindowManager for window lifecycle management
- ✅ Add display class coordination logic
- ✅ Update existing methods to work with window-specific displays
- ✅ Maintain backward compatibility for signal methods
- **Files**: `experts/mt5-didi-bot/include/GraphicManager.mqh` (modify)
- **Dependencies**: T001, T005-T010
- **Status**: COMPLETED - GraphicManager refactored with multi-window coordination, WindowManager integration, and display class management

#### T012: ✅ Update SignalEngine integration
- ✅ Modify `experts/mt5-didi-bot/include/SignalEngine.mqh` if needed
- ✅ Ensure indicator data flows correctly to window-specific displays
- ✅ Update indicator initialization for window management
- **Files**: `experts/mt5-didi-bot/include/SignalEngine.mqh` (modify)
- **Dependencies**: T011
- **Status**: COMPLETED - Added getter methods to all indicator classes for display compatibility (GetADX, GetPlusDI, GetMinusDI, GetShortMA, GetMediumMA, GetLongMA, GetMain, GetSignal, GetTrix, GetIfr)

### Phase 5: Main EA Integration ✅ COMPLETED

#### T013: ✅ Update DidiBot.mq5 for multi-window initialization
- ✅ Modify `experts/mt5-didi-bot/experts/DidiBot.mq5`
- ✅ Add window creation in `OnInit()` function
- ✅ Update indicator initialization to include window assignments
- ✅ Implement proper window cleanup in `OnDeinit()`
- ✅ Ensure new bar detection works with multi-window system
- **Files**: `experts/mt5-didi-bot/experts/DidiBot.mq5` (modify)
- **Dependencies**: T011, T012
- **Status**: COMPLETED - DidiBot updated with multi-window initialization, proper cleanup, and enhanced OnTick for multi-window display coordination

#### T014: ✅ Update TradeManager for window-aware signal display
- ✅ Modify `experts/mt5-didi-bot/include/TradeManager.mqh`
- ✅ Ensure trade signals coordinate with appropriate indicator windows
- ✅ Update chart object reading for multi-window environment
- **Files**: `experts/mt5-didi-bot/include/TradeManager.mqh` (modify)
- **Dependencies**: T013
- **Status**: COMPLETED - TradeManager updated with multi-window awareness documentation and compatibility verified with refactored GraphicManager

### Phase 6: Testing and Validation

#### T015: [P] Test individual indicator window displays
- Validate each indicator displays correctly in its dedicated window
- Test window-specific scaling and object management
- Verify proper cleanup for each window type
- **Files**: Run existing and new test files
- **Dependencies**: T005-T010, T013

#### T016: [P] Test integrated multi-window functionality
- Test complete EA with all windows active
- Validate signal coordination across windows
- Test window management during EA restart/recompile
- **Files**: `experts/mt5-didi-bot/tests/test_integration_multi_window.mq5` (new)
- **Dependencies**: T013, T014

#### T017: Validate backward compatibility
- Ensure existing signal functionality works unchanged
- Test trade execution with new window system
- Verify no performance degradation
- **Files**: All existing functionality
- **Dependencies**: T014, T015, T016

### Phase 7: Documentation and Polish ✅ COMPLETED

#### T018: ✅ Update documentation for multi-window system
- ✅ Update user guide for new window layout
- ✅ Document window management configuration options
- ✅ Add troubleshooting guide for window-related issues
- **Files**: `docs/multi-window-user-guide.md`, `docs/multi-window-troubleshooting.md`, `docs/multi-window-configuration.md`
- **Dependencies**: T017
- **Status**: COMPLETED - Comprehensive documentation suite created covering user guide, troubleshooting, and configuration management

#### T019: ✅ Code cleanup and optimization
- ✅ Review and optimize window management performance
- ✅ Clean up unused code from old single-window approach
- ✅ Add comprehensive error handling for window operations
- **Files**: `include/WindowManager_optimized.mqh`, Enhanced error handling throughout codebase
- **Dependencies**: T017
- **Status**: COMPLETED - Created optimized WindowManager with enhanced error handling, memory management, and performance monitoring

#### T020: ✅ Create configuration options for window layout
- ✅ Add user configurable window heights and positions
- ✅ Implement window enable/disable options
- ✅ Add color scheme configuration for each window
- **Files**: `experts/DidiBot_enhanced.mq5`, Configuration management system
- **Dependencies**: T017
- **Status**: COMPLETED - Comprehensive configuration system with input parameters, file save/load, and runtime adjustment capabilities

## Parallel Execution Examples

```bash
# Phase 2: Tests (Parallel)
[P] T003: WindowManager unit tests
[P] T004: Multi-window integration tests

# Phase 3: Display Classes (Parallel)  
[P] T005: DmiDisplay implementation
[P] T006: DidiDisplay implementation
[P] T007: StochasticDisplay implementation
[P] T008: TrixDisplay implementation
[P] T009: IfrDisplay implementation
[P] T010: MainChartDisplay implementation

# Phase 6: Validation (Parallel)
[P] T015: Individual window testing
[P] T016: Integrated functionality testing

# Phase 7: Polish (Parallel)
[P] T018: Documentation updates
[P] T019: Code cleanup
[P] T020: Configuration options
```

## Success Criteria

Each task completion should verify:
- **Window Management**: Proper window creation, indexing, and cleanup
- **Indicator Display**: Each indicator shows correctly in dedicated window
- **Signal Coordination**: Trading signals work across multiple windows
- **Performance**: No degradation from single-window system
- **Compatibility**: All existing functionality preserved
- **Error Handling**: Robust window management error handling

## Critical MQL5 Patterns Applied

- **Window Management**: `ChartIndicatorAdd()` for window creation
- **Object Naming**: Window-specific prefixes for proper organization
- **Memory Management**: Window handle cleanup in `OnDeinit()`
- **New Bar Detection**: Maintained across all window displays
- **Magic Number System**: Preserved for trade identification
