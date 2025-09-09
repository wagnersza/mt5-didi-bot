# Implementation Plan: Configurable Stop Losses

**Input**: Feature specification from `003-configurable-stop-losses/spec.md`  
**Prerequisites**: Existing MT5 Didi Bot with RiskManager, TradeManager, and SignalEngine

## Technical Context

**Language/Version**: MQL5  
**Primary Dependencies**: MetaTrader 5 native libraries, existing EA architecture  
**Storage**: MQL5 input parameters and internal configuration  
**Testing**: MetaTrader 5 Strategy Tester with backtest validation  
**Target Platform**: Native macOS MetaTrader 5  
**Project Type**: Expert Advisor Enhancement  
**Performance Goals**: Stop loss calculations must complete within 10ms per trade  
**Constraints**: Must maintain compatibility with existing Didi Index strategy logic  
**Scale/Scope**: Single trader usage with multiple symbol support

## Architecture Overview

### Integration Points
- **RiskManager.mqh**: Extend existing stop loss calculation methods
- **TradeManager.mqh**: Add stop loss management and trailing functionality
- **DidiBot.mq5**: Add input parameters and initialization logic
- **SignalEngine.mqh**: Integrate ATR calculation for stop loss sizing

### Component Responsibilities
- **RiskManager**: ATR-based stop loss calculation, validation, configuration management
- **TradeManager**: Stop loss placement, trailing functionality, order management
- **Main EA**: Input parameter handling, initialization, user configuration
- **SignalEngine**: ATR indicator integration for volatility-based calculations

## Technical Decisions

### Stop Loss Calculation Strategy
- **Primary Method**: ATR-based calculation with configurable multiplier
- **Fallback Method**: Fixed pip stop loss for manual override
- **Validation**: Broker minimum distance compliance, maximum cap enforcement
- **Integration**: Seamless integration with existing percentage-based position sizing

### Trailing Stop Implementation
- **Trigger Logic**: Price movement in favorable direction beyond ATR distance
- **Adjustment Strategy**: Maintain constant ATR-based distance from current price
- **Frequency**: Check on every tick, adjust only when beneficial
- **Protection**: Prevent trailing stop from moving against the trade

### Configuration Management
- **Input Parameters**: External MQL5 input variables for user configuration
- **Default Values**: Professional trader standards as specified in requirements
- **Validation**: Real-time validation of configuration parameters
- **Persistence**: Configuration maintained throughout EA lifecycle

## Data Structures

### StopLossConfig Structure
```cpp
struct StopLossConfig {
   ENUM_STOP_TYPE type;           // ATR_BASED or FIXED_PIPS
   double atr_multiplier;         // 0.5 to 5.0 range
   int fixed_pips;               // Fixed pip distance
   bool trailing_enabled;        // Trailing stop activation
   int max_stop_pips;           // Maximum stop loss cap
   int stop_limit_slippage;     // Slippage for stop limit orders
};
```

### Active Stop Loss Tracking
```cpp
struct ActiveStopLoss {
   ulong ticket;                 // Trade ticket number
   double original_distance;     // Initial stop distance
   double current_level;         // Current stop loss level
   datetime last_trail_time;     // Last trailing adjustment
   bool is_trailing;            // Trailing status
};
```

## Implementation Phases

### Phase 1: Core Configuration (Setup)
- Add input parameters to DidiBot.mq5
- Extend RiskManager with stop loss configuration
- Implement ATR calculation integration
- Add validation logic for configuration parameters

### Phase 2: Stop Loss Calculation (Core Logic)
- Implement ATR-based stop loss calculation
- Add fixed pip stop loss alternative
- Implement broker distance validation
- Add maximum stop loss cap enforcement

### Phase 3: Trade Integration (Trading Logic)
- Integrate stop loss calculation with trade opening
- Implement stop loss placement in TradeManager
- Add stop limit order functionality
- Implement error handling for stop loss failures

### Phase 4: Trailing Functionality (Advanced Features)
- Implement trailing stop logic
- Add price monitoring for favorable movement
- Implement stop loss adjustment mechanism
- Add logging for trailing stop activities

### Phase 5: Testing and Validation (Quality Assurance)
- Create comprehensive test scenarios
- Validate with different market conditions
- Test error handling and edge cases
- Performance validation and optimization

## File Structure

```
experts/mt5-didi-bot/
├── experts/
│   └── DidiBot.mq5                 # Add input parameters, initialization
├── include/
│   ├── RiskManager.mqh             # Extend with stop loss calculations
│   ├── TradeManager.mqh            # Add stop management and trailing
│   └── SignalEngine.mqh            # Integrate ATR calculation
└── tests/
    └── test_stop_losses.mq5        # Comprehensive stop loss testing
```

## Success Criteria

### Functional Validation
- ATR-based stop losses calculated correctly for all trade types
- Trailing stops adjust properly during favorable price movement
- Fixed pip stop losses work as alternative to ATR calculation
- Stop limit orders execute properly when triggered
- Configuration validation prevents invalid parameter settings

### Integration Validation
- Existing Didi Index strategy logic remains unchanged
- Position sizing integration maintains percentage-based risk
- Chart visualization shows stop loss levels clearly
- Error handling gracefully manages broker limitations

### Performance Validation
- Stop loss calculations complete within 10ms per trade
- Trailing stop checks don't impact EA performance
- Memory usage remains within acceptable limits
- No impact on existing signal generation timing

## Risk Mitigation

### Technical Risks
- **ATR Calculation Failures**: Implement fallback to fixed pip calculation
- **Broker Rejection**: Pre-validate stop distances against broker requirements
- **Price Gaps**: Implement gap detection and stop adjustment logic
- **Network Issues**: Retry logic for stop loss modification failures

### Trading Risks
- **Over-Tight Stops**: Enforce minimum stop distance based on volatility
- **Wide Stops**: Implement maximum stop cap to control risk
- **Trailing Too Aggressive**: Conservative trailing trigger thresholds
- **Stop Hunting**: Use stop limit orders to reduce slippage impact

## Dependencies

### Existing Components
- RiskManager.mqh: Extend existing risk calculation methods
- TradeManager.mqh: Enhance with stop management capabilities
- SignalEngine.mqh: Add ATR indicator integration
- DidiBot.mq5: Add configuration and initialization logic

### New Components
- StopLossConfig data structure
- ActiveStopLoss tracking mechanism
- ATR calculation wrapper
- Trailing stop management system

### External Dependencies
- MetaTrader 5 native ATR indicator
- MQL5 CTrade class for order management
- Broker API for stop loss placement and modification
- Strategy Tester for validation and backtesting
