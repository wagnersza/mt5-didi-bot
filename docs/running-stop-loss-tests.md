# Running Stop Loss Tests - Instructions

## Overview
We have successfully implemented comprehensive Test-Driven Development (TDD) tests for the configurable stop losses feature. These tests are designed to **FAIL initially** until the implementation is completed.

## Test Files Created

### 1. `test_stop_losses.mq5` (T004, T005, T006)
**Location**: `experts/mt5-didi-bot/tests/test_stop_losses.mq5`

**Test Categories**:
- **ATR Calculation Tests** (T004): 6 test cases
- **Fixed Pip Stop Loss Tests** (T004): 4 test cases  
- **Broker Validation Tests** (T004): 3 test cases
- **Trailing Stop Tests** (T005): 12 test cases
- **Stop Limit Order Tests** (T006): 9 test cases

**Total**: 34 individual test cases

### 2. `test_integration_stops.mq5` (T007)
**Location**: `experts/mt5-didi-bot/tests/test_integration_stops.mq5`

**Test Categories**:
- **Didi Signal Integration**: 4 test cases
- **Position Sizing Integration**: 6 test cases
- **Chart Visualization**: 6 test cases
- **Trade Lifecycle**: 6 test cases

**Total**: 22 individual test cases

## How to Run Tests in MetaTrader 5

### Prerequisites
- MetaTrader 5 installed on macOS
- MetaEditor available (Press F4 in MT5)

### Step-by-Step Instructions

1. **Open MetaTrader 5**
   ```
   Applications → MetaTrader 5
   ```

2. **Open MetaEditor**
   ```
   Press F4 or File → MetaEditor
   ```

3. **Navigate to Test Files**
   ```
   File → Open → Navigate to:
   ~/Library/Mobile Documents/com~apple~CloudDocs/git/mt5-didi-bot/experts/mt5-didi-bot/tests/
   ```

4. **Open Test Files**
   - `test_stop_losses.mq5`
   - `test_integration_stops.mq5`

5. **Compile Tests**
   ```
   Press F7 or Build → Compile
   ```

6. **Run Tests**
   - Right-click in Navigator → Scripts
   - Select the compiled test script
   - Drag to chart or double-click to run

### Expected Results (TDD Approach)

#### ✅ **All Tests Should FAIL Initially**
```
=== TEST RESULTS SUMMARY ===
Total Tests: 56 (34 + 22)
Passed: 0
Failed: 56
Success Rate: 0.0%
```

#### Sample Output
```
[FAIL] ATR_MULTIPLIER_TESTS_1.5x: Test ATR-based stop loss with 1.5x multiplier - NOT IMPLEMENTED YET
[FAIL] TRAILING_ACTIVATION_BUY_FAVORABLE: Test trailing stop activation when buy trade moves favorably upward - NOT IMPLEMENTED YET
[FAIL] STOP_LIMIT_PLACEMENT_LIMIT_INSTEAD_MARKET: Test that stop limit order is placed instead of market order when stop is triggered - NOT IMPLEMENTED YET
[FAIL] DIDI_SIGNAL_INTEGRATION_BUY_SIGNAL_STOP: Test stop loss application when Didi generates buy signal - NOT IMPLEMENTED YET
```

## Test Implementation Details

### Test Framework Features
- **Configurable Input Parameters**: Flexible test configuration
- **Result Tracking**: Pass/fail status with detailed messages
- **Comprehensive Logging**: Each test logs its status immediately
- **Summary Reports**: Complete test results with success rates

### Test Categories Explained

#### **T004: ATR Calculation Tests**
- Various ATR multipliers (0.8x, 1.5x, 2.0x)
- Edge cases (zero ATR, high ATR, invalid multipliers)
- Fixed pip calculations
- Broker minimum distance validation
- Maximum stop loss cap enforcement

#### **T005: Trailing Stop Tests**
- Activation during favorable movement
- Distance maintenance (constant ATR distance)
- Prevention of adverse movement
- Different ATR multipliers in trailing scenarios

#### **T006: Stop Limit Order Tests**
- Stop limit order placement instead of market orders
- Slippage control during execution
- Fallback mechanisms (stop limit → market order)
- Timeout and error handling

#### **T007: Integration Tests**
- Integration with Didi Index signals
- Position sizing with stop loss distance
- Chart visualization
- Complete trade lifecycle scenarios
- Multiple concurrent trades

## What Happens Next

### Phase 1: Implementation Required
The following components need to be implemented for tests to pass:

1. **SignalEngine.mqh**: ATR indicator integration
2. **RiskManager.mqh**: Stop loss calculation methods
3. **TradeManager.mqh**: Stop placement and trailing logic
4. **DidiBot.mq5**: Configuration and initialization

### Phase 2: Iterative Testing
As each component is implemented:
1. Run tests to see which pass
2. Fix any failing tests
3. Repeat until all tests pass

### Phase 3: Success Criteria
When implementation is complete, expect:
```
=== TEST RESULTS SUMMARY ===
Total Tests: 56
Passed: 56
Failed: 0
Success Rate: 100.0%
```

## Alternative: Test Simulation
If MetaTrader 5 is not available, you can run our simulation:

```bash
cd "/path/to/mt5-didi-bot"
./scripts/run-tests-simulation.sh
```

This shows the expected test structure and demonstrates the TDD approach.

## Key Benefits of This TDD Approach

1. **Clear Requirements**: Tests define exactly what needs to be implemented
2. **Regression Prevention**: Future changes won't break existing functionality
3. **Documentation**: Tests serve as executable documentation
4. **Quality Assurance**: Implementation must satisfy all test cases
5. **Confidence**: When all tests pass, the feature is complete and working

## Troubleshooting

### Compilation Errors
- Check include paths are correct
- Ensure all required MQL5 libraries are available
- Verify MQL5 syntax compatibility

### Runtime Errors
- Check that test inputs are valid
- Ensure sufficient memory for test arrays
- Verify MetaTrader 5 permissions

### Test Failures (Expected Initially)
- This is normal and expected in TDD
- Tests should fail until implementation is complete
- Use TODO comments in tests as implementation guide

---

**Note**: These tests demonstrate professional Test-Driven Development practices and will guide the implementation to ensure all requirements are met correctly.
