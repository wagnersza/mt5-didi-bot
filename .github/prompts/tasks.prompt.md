---
description: Break down the plan into executable tasks. This is the third step in the Spec-Driven Development lifecycle.
mode: agent
tools: ['codebase', 'search']
---

# Create Implementation Tasks - Spec-Driven Development Step 3

Break down the implementation plan into specific, executable tasks with proper dependencies and parallel execution guidance.

## Context
This is the **third step** in the MT5 Didi Bot's Spec-Driven Development lifecycle. You have completed specification and planning phases, now create actionable tasks.

## Your Task
Transform the implementation plan into a comprehensive task breakdown that developers can execute immediately.

## Execution Steps

### 1. Check Prerequisites
```bash
./scripts/check-task-prerequisites.sh --json
```
- Parse JSON for FEATURE_DIR and AVAILABLE_DOCS list
- Ensure all paths are absolute

### 2. Analyze Available Design Documents
Read and analyze what's available:

**Always Read:**
- `plan.md` - tech stack, libraries, architecture decisions

**Conditionally Read (if exists):**
- `data-model.md` - entities, class structures, indicator parameters
- `contracts/` - API endpoints, interfaces
- `research.md` - technical decisions, implementation notes
- `quickstart.md` - test scenarios, integration testing

### 3. Generate Task Breakdown
Using `templates/tasks-template.md` as base, create tasks following these patterns:

**Setup Tasks (Sequential)**
- Project initialization
- Dependency setup
- Linting/formatting configuration
- Build system setup

**Test Tasks [P] (Parallel)**
- One task per contract file
- One task per integration scenario  
- Unit test setup for each component

**Core Implementation Tasks**
- **Models [P]**: One per entity in data-model (if different files)
- **Services**: One per major component (SignalEngine, TradeManager, RiskManager)
- **Indicators [P]**: One per indicator class (if separate files)
- **Strategy Logic**: Entry/exit signal implementation

**Integration Tasks**
- Component integration
- Chart object integration
- Risk management integration
- Error handling and logging

**Polish Tasks [P] (Parallel)**
- Performance optimization
- Documentation updates
- Additional unit tests
- Code review preparation

### 4. Apply MQL5-Specific Task Patterns

**Indicator Development Tasks:**
```
T001: Implement [IndicatorName] class in SignalEngine.mqh
- Add class definition with proper buffer arrays
- Implement Init() method with handle creation
- Add data access methods (e.g., Adx(), PlusDi())
- Include proper handle cleanup in destructor
Files: experts/mt5-didi-bot/include/SignalEngine.mqh
```

**Trade Management Tasks:**
```
T002: Enhance TradeManager for [feature]
- Add new signal evaluation methods
- Implement magic number management
- Add chart object integration
- Update entry/exit logic
Files: experts/mt5-didi-bot/include/TradeManager.mqh
```

**Main EA Tasks:**
```
T003: Update DidiBot.mq5 for [feature]
- Add indicator initialization in OnInit()
- Update OnTick() logic for new signals
- Add proper error handling
Files: experts/mt5-didi-bot/experts/DidiBot.mq5
```

### 5. Task Organization Rules

**Dependency Ordering:**
1. Setup tasks first
2. Tests before implementation (TDD)
3. Models before services
4. Services before integration
5. Core before polish

**Parallel Execution [P]:**
- Different files = can be parallel
- Same file = must be sequential
- Independent components = parallel

**Task Numbering:**
- T001, T002, T003... in dependency order
- Include file paths for each task
- Note dependencies explicitly

### 6. Create Parallel Execution Examples
```
# Phase 1: Setup (Sequential)
T001: Project setup
T002: Test framework setup

# Phase 2: Models (Parallel)
[P] T003: Update CDmi class
[P] T004: Update CDidiIndex class  
[P] T005: Update CBollingerBands class

# Phase 3: Integration (Sequential)
T006: Integrate new indicators in TradeManager
T007: Update main EA logic
```

### 7. Ensure Task Completeness
Each task must include:
- **Clear objective**: What exactly to implement
- **Specific files**: Absolute paths to modify
- **MQL5 patterns**: Which patterns to follow
- **Dependencies**: What must be done first
- **Success criteria**: How to verify completion

### 8. Write to tasks.md
Create `FEATURE_DIR/tasks.md` with:
- Feature name from implementation plan
- Numbered tasks with clear descriptions
- File paths and dependencies
- Parallel execution guidance
- Ready-to-execute instructions

## MQL5 Development Patterns Reference

### Key File Structure
```
experts/mt5-didi-bot/experts/DidiBot.mq5     # Main EA
experts/mt5-didi-bot/include/SignalEngine.mqh # Indicators
experts/mt5-didi-bot/include/TradeManager.mqh # Trading
experts/mt5-didi-bot/include/RiskManager.mqh  # Risk
experts/mt5-didi-bot/tests/test_*.mq5         # Tests
```

### Common Task Types
- **Indicator tasks**: Add/modify indicator classes in SignalEngine.mqh
- **Trading tasks**: Update trade logic in TradeManager.mqh  
- **Risk tasks**: Modify position sizing in RiskManager.mqh
- **Integration tasks**: Update main EA in DidiBot.mq5
- **Test tasks**: Create test files in tests/ directory

## Usage
Type `/tasks` in chat after completing the planning phase.
