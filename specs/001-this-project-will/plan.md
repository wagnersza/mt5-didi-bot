# Implementation Plan: MT5 Trading Robot

**Branch**: `001-this-project-will` | **Date**: 2025-09-09 | **Spec**: [./spec.md](./spec.md)
**Input**: Feature specification from `/specs/001-this-project-will/spec.md`

## Execution Flow (/plan command scope)
```
1. Load feature spec from Input path
   → If not found: ERROR "No feature spec at {path}"
2. Fill Technical Context (scan for NEEDS CLARIFICATION)
   → Detect Project Type from context (web=frontend+backend, mobile=app+api)
   → Set Structure Decision based on project type
3. Evaluate Constitution Check section below
   → If violations exist: Document in Complexity Tracking
   → If no justification possible: ERROR "Simplify approach first"
   → Update Progress Tracking: Initial Constitution Check
4. Execute Phase 0 → research.md
   → If NEEDS CLARIFICATION remain: ERROR "Resolve unknowns"
5. Execute Phase 1 → contracts, data-model.md, quickstart.md, agent-specific template file (e.g., `CLAUDE.md` for Claude Code, `.github/copilot-instructions.md` for GitHub Copilot, or `GEMINI.md` for Gemini CLI).
6. Re-evaluate Constitution Check section
   → If new violations: Refactor design, return to Phase 1
   → Update Progress Tracking: Post-Design Constitution Check
7. Plan Phase 2 → Describe task generation approach (DO NOT create tasks.md)
8. STOP - Ready for /tasks command
```

## Summary
The primary goal is to develop an automated trading robot for MetaTrader 5. The robot will implement a strict, non-discretionary trading strategy based on a confluence of signals from DMI, Didi Index, and Bollinger Bands for entries, and a similar set of indicators for exits. The technical approach will be a single-project structure written in MQL5, the native language for MT5, and will adhere to the best practices for native macOS development.

## Technical Context
**Language/Version**: MQL5
**Primary Dependencies**: MetaTrader 5 native libraries
**Storage**: MQL5 file system for logging and configuration
**Testing**: MetaTrader 5 Strategy Tester
**Target Platform**: Native macOS MetaTrader 5
**Project Type**: Single Project
**Performance Goals**: [NEEDS CLARIFICATION: What is the acceptable trade execution delay?]
**Constraints**: Must run within the MT5 environment. No external code libraries (.dylib files) can be used.
**Scale/Scope**: To be used by a single trader on their MT5 terminal.

## Constitution Check
*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

**Simplicity**:
- Projects: [1] (the robot itself)
- Using framework directly? Yes, direct use of MQL5 and MT5 libraries.
- Single data model? Yes.
- Avoiding patterns? Yes, no complex patterns anticipated.

**Architecture**:
- EVERY feature as library? Yes, the code will be organized into modular `.mqh` files (TradeManager, SignalEngine, RiskManager).
- Libraries listed: N/A
- CLI per library: N/A
- Library docs: N/A

**Testing (NON-NEGOTIABLE)**:
- RED-GREEN-Refactor cycle enforced? Yes, will use the MT5 Strategy Tester to validate logic before live trading.
- Git commits show tests before implementation? Yes.
- Order: Contract→Integration→E2E→Unit strictly followed? Will adapt for MQL5 development.
- Real dependencies used? Yes, the MT5 Strategy Tester is a real environment.
- Integration tests for: new libraries, contract changes, shared schemas? N/A
- FORBIDDEN: Implementation before test, skipping RED phase. Yes.

**Observability**:
- Structured logging included? Yes, will implement logging.
- Frontend logs → backend? N/A
- Error context sufficient? Yes.

**Versioning**:
- Version number assigned? 1.0.0
- BUILD increments on every change? Yes.
- Breaking changes handled? N/A

## Project Structure

### Documentation (this feature)
```
specs/001-this-project-will/
├── plan.md              # This file (/plan command output)
├── research.md          # Phase 0 output (/plan command)
├── data-model.md        # Phase 1 output (/plan command)
├── quickstart.md        # Phase 1 output (/plan command)
├── contracts/           # Phase 1 output (/plan command)
└── tasks.md             # Phase 2 output (/tasks command - NOT created by /plan)
```

### Source Code (repository root)
```
# MQL5 Project Structure
experts/
└── mt5-didi-bot/
    ├── experts/
    │   └── DidiBot.mq5
    ├── include/
    │   ├── TradeManager.mqh
    │   ├── SignalEngine.mqh
    │   └── RiskManager.mqh
    └── tests/
        └── test_main.mq5
```

**Structure Decision**: MQL5 project structure.

## Phase 0: Outline & Research
1. **Extract unknowns from Technical Context** above:
   - Research acceptable trade execution delay for this strategy.

2. **Consolidate findings** in `research.md`.

**Output**: `research.md` with all NEEDS CLARIFICATION resolved.

## Phase 1: Design & Contracts
*Prerequisites: research.md complete*

1. **Extract entities from feature spec** → `data-model.md`.
2. **Generate API contracts** → N/A for MQL5 project.
3. **Generate contract tests** → N/A for MQL5 project.
4. **Extract test scenarios** from user stories → `tests/test_main.mq5`.

**Output**: `data-model.md`, `tests/test_main.mq5`

## Phase 2: Task Planning Approach
*This section describes what the /tasks command will do - DO NOT execute during /plan*

**Task Generation Strategy**:
- Load `/templates/tasks-template.md` as base.
- Generate tasks from Phase 1 design docs.
- Each entity → model creation task.
- Each user story → integration test task.
- Implementation tasks to make tests pass.

**Ordering Strategy**:
- TDD order: Tests before implementation.
- Dependency order: Models before services before experts.

**Estimated Output**: 15-20 numbered, ordered tasks in `tasks.md`.

## Phase 3+: Future Implementation
*These phases are beyond the scope of the /plan command*

**Phase 3**: Task execution (/tasks command creates tasks.md)
**Phase 4**: Implementation (execute tasks.md)
**Phase 5**: Validation (run tests in MT5 Strategy Tester)

## Complexity Tracking
| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
|           |            |                                     |

## Progress Tracking
*This checklist is updated during execution flow*

**Phase Status**:
- [ ] Phase 0: Research complete (/plan command)
- [ ] Phase 1: Design complete (/plan command)
- [ ] Phase 2: Task planning complete (/plan command - describe approach only)
- [ ] Phase 3: Tasks generated (/tasks command)
- [ ] Phase 4: Implementation complete
- [ ] Phase 5: Validation passed

**Gate Status**:
- [X] Initial Constitution Check: PASS
- [ ] Post-Design Constitution Check: PASS
- [ ] All NEEDS CLARIFICATION resolved
- [ ] Complexity deviations documented

---
*Based on Constitution v2.1.1 - See `/memory/constitution.md`*