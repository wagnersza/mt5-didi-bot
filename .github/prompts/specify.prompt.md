---
description: Start a new feature by creating a specification and feature branch. This is the first step in the Spec-Driven Development lifecycle.
mode: agent
tools: ['codebase', 'usages', 'vscodeAPI', 'think', 'problems', 'changes', 'testFailure', 'terminalSelection', 'terminalLastCommand', 'openSimpleBrowser', 'fetch', 'findTestFiles', 'searchResults', 'githubRepo', 'extensions', 'editFiles', 'runNotebooks', 'search', 'new', 'runCommands', 'runTasks', 'context7', 'sequentialthinking']
---

# Specify Feature - Spec-Driven Development Step 1

Start a new feature by creating a specification and feature branch based on the user's feature description.

## Context
This is the **first step** in the MT5 Didi Bot's Spec-Driven Development lifecycle. You're working with a **MetaTrader 5 Expert Advisor** project that implements the Didi Index trading strategy using MQL5.

## Your Task
Create a feature specification following the project's established workflow.

## Execution Steps

### 1. Run Feature Creation Script
```bash
./scripts/create-new-feature.sh --json "${input:featureDescription}"
```
- Parse the JSON output for BRANCH_NAME and SPEC_FILE paths
- Ensure all paths are absolute

### 2. Load Specification Template
- Read `templates/spec-template.md` to understand required sections
- Preserve section order and headings exactly as defined

### 3. Generate Feature Specification
Write to the SPEC_FILE with these key sections:

**Mandatory Sections:**
- **Feature Description**: Clear, concise description from user input
- **User Scenarios**: Step-by-step user workflows
- **Functional Requirements**: Testable, specific requirements
- **Success Criteria**: Measurable acceptance criteria

**When Relevant:**
- **Technical Constraints**: MQL5/MT5-specific limitations
- **Key Entities**: If data structures are involved
- **Non-Functional Requirements**: Performance, security, etc.

### 4. Follow Specification Guidelines
- Focus on **WHAT** users need and **WHY** (avoid implementation details)
- Mark ambiguities with `[NEEDS CLARIFICATION: specific question]`
- Ensure all requirements are testable and unambiguous
- Written for business stakeholders, not developers
- Remove sections that don't apply (don't leave as "N/A")

### 5. Project-Specific Context
Remember this is for:
- **MetaTrader 5 Expert Advisor** using MQL5
- **Native macOS MT5** (no external DLLs allowed)
- **Modular architecture** (SignalEngine, TradeManager, RiskManager)
- **Didi Index trading strategy** with multiple technical indicators

### 6. Report Results
Provide:
- Branch name created
- Spec file path
- Summary of what was specified
- Any clarifications needed before planning phase

## Important Notes
- The script automatically creates and checks out the new branch
- Don't guess at unclear requirements - mark them for clarification
- Focus on user value and business requirements
- Avoid technical implementation details
- Prepare specifications for the planning phase

## Input Variables
- `${input:featureDescription}`: The feature description provided by the user

## Usage
Type `/specify` in chat and provide the feature description when prompted.
