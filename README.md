# MT5 Didi Bot

This is a trading robot for MetaTrader 5 that implements the Didi Index trading strategy, as described by Brazilian trader and analyst Odir Aguiar (Didi).

## Trading Strategy

The core of the strategy is the "Didi Needle" (Agulhada do Didi), which is a specific alignment of three moving averages (3, 8, and 20 periods). The robot uses this signal in conjunction with other indicators to filter trades and identify entry and exit points.

The following indicators are used:
- **DMI (ADX)**: To identify the trend.
- **Didi Index**: To generate the primary entry signal (the "needle").
- **Bollinger Bands**: To time the entry and exit.
- **Stochastic**: To identify overbought/oversold conditions and signal potential exits.
- **Trix**: To confirm the trend and signal exits.
- **IFR (RSI)**: To identify divergences and confirm tops and bottoms.

## How to Use

1.  **Compilation**:
    -   Open the `DidiBot.mq5` file in MetaEditor.
    -   Click the "Compile" button or press F7.

2.  **Configuration**:
    -   In the MetaTrader 5 terminal, go to `Tools > Options > Expert Advisors`.
    -   Check the "Allow automated trading" option.
    -   Attach the `DidiBot` expert advisor to a chart.
    -   In the "Inputs" tab, you can configure the following parameters:
        -   **MagicNumber**: A unique number to identify the trades of this robot.
        -   **RiskPercent**: The percentage of the account balance to risk per trade.
        -   **Indicator Parameters**: The periods and other settings for the indicators.

## Folder Structure

-   `experts/mt5-didi-bot/experts/DidiBot.mq5`: The main expert advisor file.
-   `experts/mt5-didi-bot/include/`: Include files with the logic for the indicators, trade management, and risk management.
-   `experts/mt5-didi-bot/tests/`: Test files for the indicators and core logic.
-   `specs/`: Specification and planning documents.
-   `memory/`: Constitution and other project memory files.
-   `templates/`: Templates for the specification, plan, and tasks.
-   `scripts/`: Shell scripts for automating development tasks.
