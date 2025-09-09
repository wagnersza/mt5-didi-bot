# Tasks: MT5 Trading Robot

**Input**: Design documents from `/specs/001-this-project-will/`
**Prerequisites**: plan.md, research.md, data-model.md

## Format: `[ID] [P?] Description`
- **[P]**: Can run in parallel (different files, no dependencies)

## Phase 3.1: Setup
- [x] T001 [P] Create the project structure in `experts/mt5-didi-bot/` as defined in `plan.md`.
- [x] T002 [P] Create the main EA file `experts/mt5-didi-bot/experts/DidiBot.mq5`.

## Phase 3.2: Indicators Implementation & Testing

### DMI (Directional Movement Index)
- [x] T003 [P] Implement the DMI indicator logic in `experts/mt5-didi-bot/include/SignalEngine.mqh`.
- [x] T004 [P] Create a test for the DMI indicator in `tests/test_indicators.mq5`.

### Didi Index
- [x] T005 [P] Implement the Didi Index logic in `experts/mt5-didi-bot/include/SignalEngine.mqh`.
- [x] T006 [P] Create a test for the Didi Index in `tests/test_indicators.mq5`.

### Bollinger Bands
- [x] T007 [P] Implement the Bollinger Bands logic in `experts/mt5-didi-bot/include/SignalEngine.mqh`.
- [x] T008 [P] Create a test for the Bollinger Bands in `tests/test_indicators.mq5`.

### Stochastic
- [x] T009 [P] Implement the Stochastic indicator logic in `experts/mt5-didi-bot/include/SignalEngine.mqh`.
- [x] T010 [P] Create a test for the Stochastic indicator in `tests/test_indicators.mq5`.

### Trix
- [x] T011 [P] Implement the Trix indicator logic in `experts/mt5-didi-bot/include/SignalEngine.mqh`.
- [x] T012 [P] Create a test for the Trix indicator in `tests/test_indicators.mq5`.

### IFR (Relative Strength Index)
- [x] T013 [P] Implement the IFR (RSI) indicator logic in `experts/mt5-didi-bot/include/SignalEngine.mqh`.
- [x] T014 [P] Create a test for the IFR (RSI) indicator in `tests/test_indicators.mq5`.

## Phase 3.3: Core Logic Implementation & Testing
- [x] T015 Implement the main trading logic in `experts/mt5-didi-bot/experts/DidiBot.mq5` to integrate all indicators.
- [x] T016 Implement the trade entry logic based on DMI, Didi Index, and Bollinger Bands signals in `experts/mt5-didi-bot/include/TradeManager.mqh`.
- [x] T017 Implement the trade exit logic based on DMI, Stochastic, Trix, and Bollinger Bands signals in `experts/mt5-didi-bot/include/TradeManager.mqh`.
- [x] T018 Implement the risk management module for stop-loss and lot size calculation in `experts/mt5-didi-bot/include/RiskManager.mqh`.
- [x] T019 Implement the logic to handle connection loss and partial fills in `DidiBot.mq5`.
- [x] T020 Implement the logic to read trend lines and force numbers from chart objects in `DidiBot.mq5`.
- [x] T021 Create tests for the core logic in `tests/test_core.mq5`.

## Phase 3.4: Polish
- [x] T022 [P] Add detailed comments and documentation to all `.mqh` and `.mq5` files.
- [x] T023 [P] Refine the code for readability and performance.
- [x] T024 Create a `README.md` file with instructions on how to use and configure the robot.

## Dependencies
- T003-T014 can be done in parallel.
- T015 depends on T003-T014.
- T016-T020 depend on T015.
- T021 depends on T016-T020.
- T022-T024 can be done after all other tasks are complete.