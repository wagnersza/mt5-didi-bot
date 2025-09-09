# MT5 Didi Bot - AI Coding Agent Instructions

## Project Overview
This is a **MetaTrader 5 Expert Advisor** implementing the Didi Index trading strategy using multiple technical indicators. The project follows a **structured development workflow** with specifications, planning, and memory management for trading algorithm development.

## Architecture & Key Components

### Core Trading Components
- **`experts/mt5-didi-bot/experts/DidiBot.mq5`**: Main EA entry point with `OnInit()`, `OnTick()`, and `OnDeinit()` lifecycle
- **`experts/mt5-didi-bot/include/SignalEngine.mqh`**: Indicator classes (CDmi, CDidiIndex, CBollingerBands, CStochastic, CTrix, CIfr)
- **`experts/mt5-didi-bot/include/TradeManager.mqh`**: Trade execution logic using `CTrade` class with magic number management
- **`experts/mt5-didi-bot/include/RiskManager.mqh`**: Position sizing and risk calculation based on account percentage

### Project Organization Pattern
The codebase uses a **specification-driven development** approach:
- **`specs/`**: Feature specifications following structured templates
- **`memory/constitution.md`**: MQL5 development best practices for native macOS
- **`scripts/`**: Shell automation for feature creation and workflow management
- **`templates/`**: Standardized templates for specs, plans, and tasks

## Critical MQL5 Patterns

### Indicator Initialization Pattern
All indicators follow this lifecycle in `OnInit()`:
```cpp
if(!g_dmi.Init(_Symbol,_Period,8))
{
    Print("OnInit: DMI initialization failed!");
    return(INIT_FAILED);
}
```

### New Bar Detection Pattern
Core strategy executes once per bar using this pattern in `OnTick()`:
```cpp
static datetime prev_bar_time=0;
datetime current_bar_time=(datetime)SeriesInfoInteger(_Symbol,_Period,SERIES_LASTBAR_DATE);
if(current_bar_time>prev_bar_time) {
    prev_bar_time=current_bar_time;
    // Execute trading logic here
}
```

### Trade Management Pattern
All trades use magic numbers for identification and the `CTrade` class for execution:
```cpp
m_trade.SetExpertMagicNumber(m_magic_number);
m_trade.SetTypeFilling(ORDER_FILLING_FOK);
```

## Development Workflow

### Feature Creation Process
Use `./scripts/create-new-feature.sh "description"` which:
1. Creates numbered feature directory in `specs/`
2. Generates structured spec from templates
3. Sets up planning and task files

### Testing Approach
- Test files located in `experts/mt5-didi-bot/tests/`
- Follow pattern: `test_*.mq5` for component testing
- Currently minimal - opportunity for expansion

### File Compilation
EAs compile in MetaEditor with F7, producing `.ex5` files from `.mq5` sources

## Platform-Specific Considerations

### macOS Native MT5 Constraints
- **No external DLL support**: All code must be self-contained MQL5
- **File paths**: Use `File > Open Data Folder` in MT5 to locate `~/Library/Application Support/MetaTrader 5/`
- **Python integration**: Native `MetaTrader5` library works with macOS Python

### Memory Management
- Create indicator handles once in `OnInit()`
- Release handles in `OnDeinit()`
- Avoid recreating handles on every tick

## Coding Conventions

### Class Organization
- One indicator class per class in `SignalEngine.mqh`
- Each class has `Init()`, data access methods, and proper handle management
- Use descriptive buffer arrays (e.g., `m_adx_buffer[]`, `m_plus_di_buffer[]`)

### Error Handling
- Always check indicator handle validity with `INVALID_HANDLE`
- Use `Print()` statements for debugging with component prefixes
- Return appropriate status codes from `OnInit()`

### Risk Management Integration
- Calculate position sizes using `CRiskManager::CalculateLotSize()`
- Base risk on account percentage, not fixed lots
- Implement stop-loss calculation based on ATR or technical levels

## Key Integration Points

### Signal Flow
1. **SignalEngine** generates entry/exit signals from multiple indicators
2. **TradeManager** coordinates signal evaluation and trade execution
3. **RiskManager** determines position sizing and stop-loss levels

### Chart Object Integration
- `TradeManager::ReadChartObjects()` processes manual chart annotations
- Supports hybrid manual/automated trading approach

## When Working on This Codebase

1. **Follow the specification workflow**: Create specs before implementing features
2. **Respect the modular architecture**: Keep indicator logic in SignalEngine, trade logic in TradeManager
3. **Use the new bar pattern**: Don't execute strategy logic on every tick
4. **Test indicator initialization**: Always verify handles are valid before use
5. **Follow magic number patterns**: Ensure trade identification works correctly
6. **Consider macOS limitations**: No external libraries - pure MQL5 only

## Common Pitfalls to Avoid
- Creating indicator handles on every tick (performance killer)
- Not checking for broker connection before trading
- Mixing strategy logic across multiple files instead of using the established separation
- Ignoring the magic number system for trade management
