# Tasks: Configurable Stop Losses

**Input**: Design documents from `/specs/003-configurable-stop-losses/`  
**Prerequisites**: plan.md (required), spec.md (available)

## Execution Flow (main)

```
1. Load plan.md from feature directory
   → Tech stack: MQL5, MetaTrader 5 native libraries
   → Architecture: Extend RiskManager, TradeManager, SignalEngine
2. Load optional design documents:
   → spec.md: Extract user requirements → functional tasks
   → plan.md: Extract technical decisions → implementation tasks
3. Generate tasks by category:
   → Setup: input parameters, configuration structures
   → Tests: stop loss calculation tests, trailing tests
   → Core: ATR calculation, stop management, trailing logic
   → Integration: trade integration, chart visualization
   → Polish: performance optimization, documentation
4. Apply task rules:
   → Different files = mark [P] for parallel
   → Same file = sequential (no [P])
   → Tests before implementation (TDD)
5. Number tasks sequentially (T001, T002...)
6. Generate dependency graph
7. Create parallel execution examples
8. Validate task completeness
9. Return: SUCCESS (tasks ready for execution)
```

## Format: `[ID] [P?] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- Include exact file paths in descriptions

## Path Conventions

- **MQL5 Project**: `experts/mt5-didi-bot/experts/`, `experts/mt5-didi-bot/include/`, `experts/mt5-didi-bot/tests/`
- Paths are absolute from repository root

## Phase 3.1: Setup

- [x] T001 Add stop loss input parameters to DidiBot.mq5
  - Add ENUM_STOP_TYPE enumeration (ATR_BASED, FIXED_PIPS)
  - Add input variables for ATR multiplier, fixed pips, trailing enabled
  - Add input variables for max stop pips, stop limit slippage
  - Initialize default values as specified in requirements
  - Files: `experts/mt5-didi-bot/experts/DidiBot.mq5`

- [x] T002 Create StopLossConfig structure in RiskManager.mqh
  - Define StopLossConfig struct with all configuration fields
  - Add validation methods for configuration parameters
  - Add getter/setter methods for configuration access
  - Files: `experts/mt5-didi-bot/include/RiskManager.mqh`

- [x] T003 [P] Create ActiveStopLoss tracking structure in TradeManager.mqh
  - Define ActiveStopLoss struct for trade tracking
  - Add methods for tracking multiple concurrent stop losses
  - Add cleanup methods for closed trades
  - Files: `experts/mt5-didi-bot/include/TradeManager.mqh`

## Phase 3.2: Tests First (TDD) ⚠️ MUST COMPLETE BEFORE 3.3

**CRITICAL: These tests MUST be written and MUST FAIL before ANY implementation**

- [x] T004 [P] Create test_stop_losses.mq5 for ATR calculation testing
  - Test ATR-based stop loss calculation with various multipliers
  - Test fixed pip stop loss calculation
  - Test broker minimum distance validation
  - Test maximum stop loss cap enforcement
  - Files: `experts/mt5-didi-bot/tests/test_stop_losses.mq5`

- [x] T005 [P] Create trailing stop test scenarios in test_stop_losses.mq5
  - Test trailing stop activation during favorable movement
  - Test trailing stop distance maintenance
  - Test trailing stop prevention of adverse movement
  - Test trailing stop with different ATR multipliers
  - Files: `experts/mt5-didi-bot/tests/test_stop_losses.mq5`

- [x] T006 [P] Create stop limit order test scenarios in test_stop_losses.mq5
  - Test stop limit order placement when triggered
  - Test slippage control during stop execution
  - Test fallback to market order if stop limit fails
  - Files: `experts/mt5-didi-bot/tests/test_stop_losses.mq5`

- [x] T007 [P] Create integration test for stop loss with Didi strategy
  - Test stop loss integration with existing trade signals
  - Test position sizing integration with stop loss distance
  - Test chart visualization of stop loss levels
  - Files: `experts/mt5-didi-bot/tests/test_integration_stops.mq5`

## Phase 3.3: Core Implementation (ONLY after tests are failing)

- [ ] T008 Implement ATR integration in SignalEngine.mqh
  - Add ATR indicator handle creation and management
  - Add ATR value retrieval methods
  - Add ATR calculation wrapper with error handling
  - Integrate with existing indicator initialization pattern
  - Files: `experts/mt5-didi-bot/include/SignalEngine.mqh`

- [ ] T009 Implement stop loss calculation methods in RiskManager.mqh
  - Add CalculateATRStopLoss() method with multiplier parameter
  - Add CalculateFixedPipStopLoss() method
  - Add ValidateStopDistance() method for broker compliance
  - Add ApplyMaxStopCap() method for risk control
  - Files: `experts/mt5-didi-bot/include/RiskManager.mqh`

- [ ] T010 Implement stop loss placement in TradeManager.mqh
  - Add PlaceStopLoss() method for new trades
  - Add ModifyStopLoss() method for adjustments
  - Add stop limit order placement logic
  - Add error handling for broker rejections
  - Files: `experts/mt5-didi-bot/include/TradeManager.mqh`

- [ ] T011 Implement trailing stop logic in TradeManager.mqh
  - Add CheckTrailingStops() method for price monitoring
  - Add AdjustTrailingStop() method for stop modification
  - Add ShouldTrailStop() logic for favorable movement detection
  - Add trailing stop state management
  - Files: `experts/mt5-didi-bot/include/TradeManager.mqh`

- [ ] T012 Integrate configuration validation in RiskManager.mqh
  - Add ValidateStopLossConfig() method
  - Add range validation for ATR multiplier (0.5-5.0)
  - Add validation for maximum stop pips
  - Add error logging for invalid configurations
  - Files: `experts/mt5-didi-bot/include/RiskManager.mqh`

- [ ] T013 Update trade opening logic in TradeManager.mqh
  - Integrate stop loss calculation with trade execution
  - Add stop loss parameter to trade opening methods
  - Update existing trade entry points for stop loss
  - Maintain compatibility with existing Didi signals
  - Files: `experts/mt5-didi-bot/include/TradeManager.mqh`

## Phase 3.4: Integration

- [ ] T014 Initialize stop loss system in DidiBot.mq5 OnInit()
  - Initialize ATR indicator in SignalEngine
  - Load stop loss configuration from input parameters
  - Validate configuration parameters
  - Add initialization error handling
  - Files: `experts/mt5-didi-bot/experts/DidiBot.mq5`

- [ ] T015 Integrate trailing stop checks in DidiBot.mq5 OnTick()
  - Add trailing stop monitoring to main tick processing
  - Implement new bar detection for trailing adjustments
  - Add performance optimization for trailing checks
  - Maintain existing signal processing timing
  - Files: `experts/mt5-didi-bot/experts/DidiBot.mq5`

- [ ] T016 Add stop loss visualization to GraphicManager.mqh
  - Add DrawStopLoss() method for chart visualization
  - Add stop loss level lines to chart
  - Add trailing stop indication
  - Update information panel with stop loss data
  - Files: `experts/mt5-didi-bot/include/GraphicManager.mqh`

- [ ] T017 Update existing trade management for stop loss compatibility
  - Modify existing trade entry methods to include stop loss
  - Update trade exit logic to handle stop loss triggers
  - Add stop loss logging to existing trade logging
  - Ensure magic number compatibility
  - Files: `experts/mt5-didi-bot/include/TradeManager.mqh`

## Phase 3.5: Polish

- [ ] T018 [P] Add comprehensive logging for stop loss operations
  - Add detailed logging for stop loss calculations
  - Add logging for trailing stop adjustments
  - Add error logging for broker rejections
  - Add performance logging for calculation timing
  - Files: `experts/mt5-didi-bot/include/RiskManager.mqh`, `experts/mt5-didi-bot/include/TradeManager.mqh`

- [ ] T019 [P] Optimize performance for stop loss calculations
  - Optimize ATR calculation frequency
  - Implement caching for repeated calculations
  - Optimize trailing stop check frequency
  - Profile and optimize critical path performance
  - Files: `experts/mt5-didi-bot/include/SignalEngine.mqh`, `experts/mt5-didi-bot/include/TradeManager.mqh`

- [ ] T020 [P] Add error recovery for stop loss failures
  - Implement retry logic for stop modification failures
  - Add fallback strategies for broker rejections
  - Add recovery from network disconnections
  - Add graceful degradation for indicator failures
  - Files: `experts/mt5-didi-bot/include/TradeManager.mqh`

- [ ] T021 [P] Create comprehensive documentation
  - Document all new stop loss configuration parameters
  - Create user guide for stop loss setup
  - Document troubleshooting for common issues
  - Add code comments for complex calculations
  - Files: `experts/mt5-didi-bot/docs/stop-loss-guide.md`

- [ ] T022 Run comprehensive backtest validation
  - Backtest with different market conditions
  - Validate stop loss performance across timeframes
  - Test with different symbols and volatility levels
  - Verify integration with existing Didi strategy
  - Files: Strategy Tester validation

## Dependencies

- Tests (T004-T007) before implementation (T008-T013)
- T001-T003 (Setup) before T008-T013 (Core Implementation)
- T008 (ATR integration) blocks T009 (stop calculation)
- T009 (stop calculation) blocks T010-T011 (placement and trailing)
- T008-T013 (Core) before T014-T017 (Integration)
- Implementation before polish (T018-T022)

## Parallel Example

```
# Launch T004-T007 together (Test Phase):
Task: "Create test_stop_losses.mq5 for ATR calculation testing"
Task: "Create trailing stop test scenarios in test_stop_losses.mq5"
Task: "Create stop limit order test scenarios in test_stop_losses.mq5"
Task: "Create integration test for stop loss with Didi strategy"

# Launch T002-T003 together (Setup Phase):
Task: "Create StopLossConfig structure in RiskManager.mqh"
Task: "Create ActiveStopLoss tracking structure in TradeManager.mqh"

# Launch T018-T021 together (Polish Phase):
Task: "Add comprehensive logging for stop loss operations"
Task: "Optimize performance for stop loss calculations"  
Task: "Add error recovery for stop loss failures"
Task: "Create comprehensive documentation"
```

## Notes

- [P] tasks = different files, no dependencies
- Verify tests fail before implementing
- Commit after each task
- Maintain MQL5 patterns: new bar detection, handle management, magic numbers
- Follow existing EA architecture and naming conventions

## Task Generation Rules

*Applied during main() execution*

1. **From Spec Requirements**:
   - Each functional requirement → implementation task
   - Each user scenario → integration test
   
2. **From Plan Architecture**:
   - Each component → setup and implementation tasks
   - Each integration point → integration task
   
3. **From MQL5 Patterns**:
   - Indicator integration → SignalEngine task
   - Trade management → TradeManager task
   - Risk calculation → RiskManager task
   - Main EA logic → DidiBot.mq5 task

4. **Ordering**:
   - Setup → Tests → Core → Integration → Polish
   - Dependencies block parallel execution

## Validation Checklist

*GATE: Checked by main() before returning*

- [x] All functional requirements have corresponding implementation tasks
- [x] All components have setup and core implementation tasks
- [x] All tests come before implementation (TDD enforced)
- [x] Parallel tasks truly independent (different files)
- [x] Each task specifies exact file path
- [x] No task modifies same file as another [P] task
- [x] MQL5 patterns properly applied
- [x] Integration with existing EA architecture maintained
