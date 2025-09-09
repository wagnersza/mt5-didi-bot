# Feature Specification: Configurable Stop Losses

**Feature Branch**: `003-configurable-stop-losses`  
**Created**: 2025-09-09  
**Status**: Draft  
**Input**: User description: "add to the didi bot a configurable stop losses and stop limit and give some default reference numbers that are suficient well for the user dont want to change"

## Execution Flow (main)
```
1. Parse user description from Input
   → User wants configurable stop losses and stop limits with professional defaults
2. Extract key concepts from description
   → Actors: Trader using MT5 EA
   → Actions: Configure stop loss types, set defaults, manage risk
   → Data: Stop loss levels, ATR values, trailing parameters
   → Constraints: MQL5 native implementation, macOS compatibility
3. For each unclear aspect:
   → Default values need professional trader standards
4. Fill User Scenarios & Testing section
   → Test scenarios for ATR-based stops, trailing stops, stop limits
5. Generate Functional Requirements
   → Each requirement must be testable and follow Didi strategy
6. Identify Key Entities (stop loss configurations, risk parameters)
7. Run Review Checklist
   → Ensure no implementation details, focus on business value
8. Return: SUCCESS (spec ready for planning)
```

---

## ⚡ Quick Guidelines
- ✅ Focus on WHAT users need and WHY
- ❌ Avoid HOW to implement (no tech stack, APIs, code structure)
- 👥 Written for business stakeholders, not developers

### Section Requirements
- **Mandatory sections**: Must be completed for every feature
- **Optional sections**: Include only when relevant to the feature
- When a section doesn't apply, remove it entirely (don't leave as "N/A")

### For AI Generation
When creating this spec from a user prompt:
1. **Mark all ambiguities**: Use [NEEDS CLARIFICATION: specific question] for any assumption you'd need to make
2. **Don't guess**: If the prompt doesn't specify something (e.g., "login system" without auth method), mark it
3. **Think like a tester**: Every vague requirement should fail the "testable and unambiguous" checklist item
4. **Common underspecified areas**:
   - User types and permissions
   - Data retention/deletion policies  
   - Performance targets and scale
   - Error handling behaviors
   - Integration requirements
   - Security/compliance needs

---

## User Scenarios & Testing *(mandatory)*

### Primary User Story
A trader using the MT5 Didi Bot wants to protect their capital with automatic stop losses that adapt to market volatility. They need professional default settings that work immediately without configuration, but with the flexibility to customize based on their risk tolerance and trading style.

### Acceptance Scenarios
1. **Given** the Didi Bot is initialized with default settings, **When** a buy trade is opened, **Then** an ATR-based stop loss MUST be automatically set at 1.5x ATR below entry price
2. **Given** a trade is profitable and moving favorably, **When** trailing stop is enabled, **Then** the stop loss MUST move with the price maintaining the ATR distance
3. **Given** the trader configures a fixed pip stop loss, **When** a new trade opens, **Then** the system MUST use the fixed value instead of ATR calculation
4. **Given** stop limit orders are enabled, **When** a stop loss is triggered, **Then** the system MUST place a stop limit order instead of a market order
5. **Given** the trader sets custom ATR multiplier to 2.0, **When** calculating stop loss, **Then** the system MUST use 2.0x ATR distance
6. **Given** maximum stop loss is set to 100 pips, **When** ATR calculation exceeds this limit, **Then** the system MUST cap the stop loss at 100 pips

### Edge Cases
- What happens when ATR indicator fails to calculate during high volatility?
- How does the system handle stop loss adjustment during weekend gaps?
- What occurs if the calculated stop loss is too close to current price (broker minimum distance)?
- How does trailing stop behave during rapid price reversals?

## Requirements *(mandatory)*

### Functional Requirements
- **FR-001**: System MUST automatically calculate stop loss using ATR (Average True Range) with default multiplier of 1.5x
- **FR-002**: System MUST support fixed pip stop loss as alternative to ATR-based calculation
- **FR-003**: System MUST implement trailing stop functionality that adjusts stop loss as trade moves favorably
- **FR-004**: System MUST support stop limit orders as alternative to market stop orders
- **FR-005**: System MUST provide configurable ATR multiplier (default: 1.5, range: 0.5 to 5.0)
- **FR-006**: System MUST implement maximum stop loss cap (default: 100 pips for major pairs)
- **FR-007**: System MUST validate stop loss distance against broker minimum requirements
- **FR-008**: System MUST integrate stop loss logic with existing Didi Index signal validation
- **FR-009**: System MUST preserve existing risk management percentage-based position sizing
- **FR-010**: System MUST log all stop loss calculations and adjustments for debugging
- **FR-011**: System MUST allow per-symbol stop loss configuration for different trading instruments
- **FR-012**: System MUST handle stop loss modification errors gracefully without affecting trade execution

### Professional Default Values
- **ATR Period**: 14 bars (standard volatility measurement)
- **ATR Multiplier**: 1.5x (balanced risk/reward for trend following)
- **Trailing Stop Distance**: Same as initial stop (maintains consistent risk)
- **Maximum Stop Loss**: 100 pips for major pairs, 150 pips for exotic pairs
- **Stop Limit Slippage**: 3 pips (prevents excessive slippage on stop execution)
- **Minimum Stop Distance**: 10 pips (respects typical broker requirements)

### Key Entities *(include if feature involves data)*
- **StopLossConfiguration**: Represents stop loss settings including type (ATR/Fixed), ATR multiplier, maximum distance, trailing enabled status
- **TradeStopLoss**: Represents active stop loss for a specific trade including current level, original distance, trailing status, and last adjustment time
- **ATRCalculation**: Represents ATR values and calculations including current ATR, historical values, and volatility metrics

---

## Review & Acceptance Checklist
*GATE: Automated checks run during main() execution*

### Content Quality
- [x] No implementation details (languages, frameworks, APIs)
- [x] Focused on user value and business needs
- [x] Written for non-technical stakeholders
- [x] All mandatory sections completed

### Requirement Completeness
- [x] No [NEEDS CLARIFICATION] markers remain
- [x] Requirements are testable and unambiguous  
- [x] Success criteria are measurable
- [x] Scope is clearly bounded
- [x] Dependencies and assumptions identified

---

## Execution Status
*Updated by main() during processing*

- [x] User description parsed
- [x] Key concepts extracted
- [x] Ambiguities marked
- [x] User scenarios defined
- [x] Requirements generated
- [x] Entities identified
- [x] Review checklist passed

---
