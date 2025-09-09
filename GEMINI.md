# GEMINI.md

## Project Overview
This project is an automated trading robot for MetaTrader 5 (MT5) that implements the Didi Index trading strategy. It uses various technical indicators (DMI, Didi Index, Bollinger Bands, Stochastic, Trix, IFR) to generate entry and exit signals. The robot is developed in MQL5 and adheres to best practices for native macOS development.

## Building and Running
-   **Compilation**: Open the `DidiBot.mq5` file in MetaEditor and compile it (F7).
-   **Configuration**:
    -   Enable "Allow automated trading" in MT5 settings.
    -   Attach `DidiBot` to a chart.
    -   Configure parameters like `MagicNumber`, `RiskPercent`, and indicator settings in the "Inputs" tab.
-   **Running**: Once compiled and configured, the EA will run automatically on the attached chart.

## Development Conventions
-   **Spec-Driven Development**: The project follows a Spec-Driven Development lifecycle, with clear specifications (`specs/001-this-project-will/spec.md`), implementation plans (`specs/001-this-project-will/plan.md`), research documents (`specs/001-this-project-will/research.md`), data models (`specs/001-this-project-will/data-model.md`), and detailed tasks (`specs/001-this-project-will/tasks.md`).
-   **Modular Code**: Code is organized into modular `.mqh` include files for indicators (`experts/mt5-didi-bot/include/SignalEngine.mqh`), trade management (`experts/mt5-didi-bot/include/TradeManager.mqh`), and risk management (`experts/mt5-didi-bot/include/RiskManager.mqh`).
-   **Testing**: Basic tests are provided for indicators (`experts/mt5-didi-bot/tests/test_indicators.mq5`) and core logic (`experts/mt5-didi-bot/tests/test_core.mq5`). The MT5 Strategy Tester is used for backtesting and optimization.
-   **Error Handling**: Explicit error checking is implemented after trading and data functions using `GetLastError()` and `Print()`.
-   **New Bar Logic**: The `OnTick()` function uses a "new bar" check to ensure logic executes once per bar, improving efficiency.
-   **Magic Numbers**: Unique magic numbers are used to identify trades managed by the EA.
-   **No External Libraries (macOS)**: Due to limitations on native macOS MT5, no external DLLs or `.dylib` files are used. The entire codebase is self-contained within MQL5.
