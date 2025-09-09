---
description: Plan how to implement the specified feature. This is the second step in the Spec-Driven Development lifecycle.
mode: agent
tools: ['codebase', 'search', 'fetch']
---

# Plan Feature Implementation - Spec-Driven Development Step 2

Plan how to implement the specified feature by generating technical design documents and implementation strategy.

## Context
This is the **second step** in the MT5 Didi Bot's Spec-Driven Development lifecycle. You have a completed specification and need to create a comprehensive implementation plan.

## Your Task
Transform the feature specification into a detailed implementation plan with technical design documents.

## Execution Steps

### 1. Get Feature Context
```bash
./scripts/setup-plan.sh --json
```
- Parse JSON output for FEATURE_SPEC, IMPL_PLAN, SPECS_DIR, BRANCH paths
- Ensure all paths are absolute

### 2. Analyze Requirements
Read and analyze:
- **Feature specification** at FEATURE_SPEC path
- **Constitution** at `memory/constitution.md` for technical requirements
- **Project architecture** from `.github/copilot-instructions.md`

Understand:
- Feature requirements and user stories
- Functional and non-functional requirements  
- Success criteria and acceptance criteria
- Technical constraints and dependencies

### 3. Execute Implementation Plan Template
Load `templates/plan-template.md` (copied to IMPL_PLAN path) and follow its Execution Flow:

**Phase 0 - Research**
- Generate `research.md` with:
  - Technical decisions and trade-offs
  - MQL5-specific implementation considerations
  - Third-party library evaluation (remember: no DLLs on macOS)
  - Architecture impact analysis

**Phase 1 - Design**
- Generate `data-model.md` with:
  - Class structures and relationships
  - Indicator parameter definitions
  - Trade management data structures
- Create `contracts/` folder if APIs needed
- Generate `quickstart.md` with testing scenarios

**Phase 2 - Task Breakdown**
- Generate `tasks.md` with:
  - Ordered, executable tasks
  - File-specific assignments
  - Dependency management
  - Parallel execution opportunities

### 4. Apply Technical Context
Incorporate these MT5 Didi Bot specifics:
- **MQL5 patterns**: Indicator initialization, new bar detection, trade management
- **Architecture constraints**: SignalEngine, TradeManager, RiskManager separation
- **Platform limitations**: Native macOS MT5, no external DLLs
- **Performance considerations**: Handle creation once in OnInit(), memory management
- **Trading specifics**: Magic numbers, CTrade class, risk management integration

### 5. Update Progress Tracking
Mark completion of each phase in the plan template.

### 6. Verify Execution
Ensure:
- All required artifacts generated in $SPECS_DIR
- No ERROR states in execution
- Progress Tracking shows complete phases
- Technical decisions align with constitution

### 7. Report Results
Provide:
- Branch name and file paths
- Generated artifacts summary
- Key technical decisions made
- Readiness for task breakdown phase

## Project Architecture Reminders

### Core Components
- `experts/mt5-didi-bot/experts/DidiBot.mq5`: Main EA entry point
- `experts/mt5-didi-bot/include/SignalEngine.mqh`: Indicator classes
- `experts/mt5-didi-bot/include/TradeManager.mqh`: Trade execution
- `experts/mt5-didi-bot/include/RiskManager.mqh`: Position sizing

### Critical Patterns
```cpp
// Indicator initialization in OnInit()
if(!g_dmi.Init(_Symbol,_Period,8)) {
    return(INIT_FAILED);
}

// New bar detection in OnTick()
static datetime prev_bar_time=0;
datetime current_bar_time=(datetime)SeriesInfoInteger(_Symbol,_Period,SERIES_LASTBAR_DATE);
if(current_bar_time>prev_bar_time) {
    // Execute strategy
}

// Trade management
m_trade.SetExpertMagicNumber(m_magic_number);
m_trade.SetTypeFilling(ORDER_FILLING_FOK);
```

## Usage
Type `/plan` in chat after completing the specification phase.
