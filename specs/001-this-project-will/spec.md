# Feature Specification: MT5 Trading Robot based on Didi Strategy

**Feature Branch**: `001-this-project-will`
**Created**: 2025-09-09
**Status**: Draft
**Input**: User description: "this project will be a trading robot for metatrader 5..."

## Execution Flow (main)
```
1. Parse user description from Input
   → If empty: ERROR "No feature description provided"
2. Extract key concepts from description
   → Identify: actors, actions, data, constraints
3. For each unclear aspect:
   → Mark with [NEEDS CLARIFICATION: specific question]
4. Fill User Scenarios & Testing section
   → If no clear user flow: ERROR "Cannot determine user scenarios"
5. Generate Functional Requirements
   → Each requirement must be testable
   → Mark ambiguous requirements
6. Identify Key Entities (if data involved)
7. Run Review Checklist
   → If any [NEEDS CLARIFICATION]: WARN "Spec has uncertainties"
   → If implementation details found: ERROR "Remove tech details"
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
As a trader, I want to deploy an automated trading robot on MetaTrader 5 that strictly follows the Didi indicator strategy, so that I can execute trades with discipline and without emotional interference, based on a predefined set of graphical signals.

### Acceptance Scenarios
1. **Given** the robot is running and monitoring a currency pair, **When** the DMI indicates a trend, the Didi Index gives an "agulhada" buy signal, and Bollinger Bands are opening, **Then** the robot MUST execute a buy order.
2. **Given** the robot is in a buy trade, **When** the DMI ADX line "kicks", the Stochastic and Trix indicators invert to sell, and Bollinger Bands begin to close, **Then** the robot MUST close the buy position.
3. **Given** the robot is configured for "indexing" between Asset A and Asset B, **When** the indexed chart signals a buy, **Then** the robot MUST buy Asset A and sell Asset B with financially equivalent lots.
4. **Given** a Didi Index alert occurs, **When** the breaking line is moving in the same direction as the line it is crossing, **Then** the robot MUST identify this as a false point and NOT execute a trade.

### Edge Cases
- What happens if the connection to the broker is lost mid-trade? [NEEDS CLARIFICATION]
- How does the system handle partial fills of an order? [NEEDS CLARIFICATION]
- What is the expected behavior during a market flash crash or extreme volatility event? [NEEDS CLARIFICATION]

## Requirements *(mandatory)*

### Functional Requirements
- **FR-001**: The system MUST execute trades based on the "imbecil" philosophy, strictly adhering to graphical signals without interpretation.
- **FR-002**: The system MUST use the following indicators with their specified roles: DMI, Didi Index, Bollinger Bands, Stochastic, Trix, IFR, and Candlestick patterns.
- **FR-003**: The system MUST validate trade entry based on the simultaneous confirmation of: DMI (trend), Didi Index (signal), and Bollinger Bands (timing).
- **FR-004**: The system MUST validate trade exit based on the simultaneous confirmation of: DMI (kick), Stochastic (inversion), Trix (inversion), and Bollinger Bands (closing).
- **FR-005**: The system MUST implement a mandatory, automatic stop-loss for every trade. [NEEDS CLARIFICATION: How is the stop-loss level determined? E.g., fixed pips, based on volatility, or a specific indicator level?]
- **FR-006**: The system MUST allow configuration of trading time frames (e.g., 1m, 5m, 15m, 1H, Daily).
- **FR-007**: The system MUST support "indexing" (long/short) strategy, including the calculation of a financial adjustment factor for lot sizes.
- **FR-008**: The system MUST use the default calibration parameters for all indicators as specified in the description.
- **FR-009**: The system MUST allow for optimization by adjusting calibration parameters.
- **FR-010**: The system MUST be able to identify and ignore "false points" in the Didi Index.
- **FR-011**: The system MUST monitor and use Force Numbers and Trend Lines for identifying price targets, support, and resistance. [NEEDS CLARIFICATION: How are these lines/numbers input or calculated by the robot?]

### Key Entities *(include if feature involves data)*
- **Trade**: Represents a single market operation (buy or sell). Attributes: Entry Price, Exit Price, Lot Size, Stop-Loss Level, Take-Profit Level, Status (Open/Closed).
- **IndicatorSignal**: Represents a signal generated by a technical indicator. Attributes: Indicator Name, Signal Type (Buy/Sell/Exit/Trend), Timestamp, Strength.
- **RobotConfiguration**: Represents the settings for the trading robot. Attributes: Time Frame, Asset Pair, Indicator Parameters (Calibrations), Risk Settings (Lot Size, Stop-Loss strategy).

---

## Review & Acceptance Checklist
*GATE: Automated checks run during main() execution*

### Content Quality
- [X] No implementation details (languages, frameworks, APIs)
- [X] Focused on user value and business needs
- [X] Written for non-technical stakeholders
- [X] All mandatory sections completed

### Requirement Completeness
- [ ] No [NEEDS CLARIFICATION] markers remain
- [ ] Requirements are testable and unambiguous
- [ ] Success criteria are measurable
- [ ] Scope is clearly bounded
- [ ] Dependencies and assumptions identified

---

## Execution Status
*Updated by main() during processing*

- [X] User description parsed
- [X] Key concepts extracted
- [ ] Ambiguities marked
- [ ] User scenarios defined
- [ ] Requirements generated
- [ ] Entities identified
- [ ] Review checklist passed

---