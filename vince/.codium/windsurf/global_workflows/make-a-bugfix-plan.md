---
description: make a bugfix plan
auto_execution_mode: 3
---

## 0. Artifacts and Naming

All planning for a single bugfix lives under one logical planning root for that bug.

Use this naming pattern:

- **Phase file (context + structure, no work):**  
  `phase-1.md`, `phase-2.md`, …

- **Phase step file (context + structure; may contain a single UoW if small enough):**  
  `phase-2-step-1.md`, `phase-2-step-2.md`, …

- **Unit-of-work file (contains exactly one UoW to be executed by an SLM):**  
  `phase-2-step-2-uow-1.md`, `phase-2-step-2-uow-2.md`, …

Rules:

1. If a **phase** is too big for a single SLM session → split into **steps**.
2. If a **step** is too big for a single SLM session → split into **UoW files**.
3. If a **step** is small enough for one session → keep everything in `phase-N-step-M.md` and do **not** create UoW files.
4. Every UoW file references its parent step and phase in its header.

All files live in the project’s SSOT planning space for this bug.

---

## 1. Pre-Planning Checklist

Before writing any plan files:

### 1.1 Register Your Team (Rule 2)

1. **Find the highest existing team number:**
   ```bash
   grep -r "TEAM_" .teams/ --include="*.md" | grep -oE "TEAM_[0-9]+" | sort -t_ -k2 -n | tail -1
   ```

2. **Your team number = highest + 1.**

3. **Create your team file:**
   ```
   .teams/TEAM_XXX_bugfix_<bug-summary>.md
   ```

4. **Your team ID is permanent** for this entire conversation.

### 1.2 Identify the Bug

- Copy the user report / issue description.
- Note environment, platform, versions, and any relevant configuration.
- Capture any error messages, stack traces, screenshots, or logs.

### 1.3 Verify Reproducibility

- Confirm whether the bug can be reproduced.
- If reproducible:
  - Write down exact reproduction steps.
  - Note expected vs actual behavior.
- If not reproducible:
  - Capture all attempted reproduction scenarios.
  - Note uncertainties and missing information.

### 1.4 Check Existing Project Context

- Read the **main project overview**.
- Read the **current active phase**.
- Scan recent **team logs** relevant to the affected area.
- Look for existing **questions** about this bug or related areas.
- Run the test suite:
  - Confirm whether tests pass or already fail because of this bug.

Only then start writing the bugfix plan.

---

## 2. Phase Structure for Bugfix Planning

Use phases to represent **high-level intent** for the bugfix work. A typical structure:

1. **Phase 1 – Understanding and Scoping**
2. **Phase 2 – Root Cause Analysis**
3. **Phase 3 – Fix Design and Validation Plan**
4. **Phase 4 – Implementation and Tests**
5. **Phase 5 – Cleanup, Regression Protection, and Handoff**

You can adjust, merge, or split phases as needed, but **every plan** should have:

- A phase that focuses on **understanding + scoping**.
- A phase that focuses on **root cause**.
- A phase that defines the **fix strategy + tests**.
- A phase that captures **implementation + verification work**.
- A phase that ensures **cleanup + regression protection + handoff**.

Each phase gets its own `phase-N.md` file.

---

## 3. Phase 1 — Understanding and Scoping

**File:** `phase-1.md`  
**Purpose:** Make the bug understandable and bounded before touching code.

### 3.1 Contents of `phase-1.md`

Include:

- **Bug Summary**
  - Short description (1–3 sentences).
  - Severity and impact (user-facing, data corruption risk, performance degradation, etc.).
- **Reproduction Status**
  - Reproducible? (yes/no/uncertain).
  - Detailed reproduction steps.
  - Expected vs actual behavior.
- **Context**
  - Code areas suspected (modules, features, main components).
  - Recent changes that might be related.
  - Links to logs, traces, screenshots, or monitoring data.
- **Constraints**
  - Time sensitivity.
  - Backwards compatibility requirements.
  - Platforms/environments that must be protected.
- **Open Questions**
  - Anything that is unclear about the bug report or scope.

### 3.2 Steps and UoWs in Phase 1

Typical steps:

1. **Step 1 – Consolidate Bug Information**
2. **Step 2 – Confirm or Improve Reproduction**
3. **Step 3 – Identify Suspected Code Areas**

For each step:

- If step work fits in a single SLM session → keep it in `phase-1-step-N.md`.
- If not, split into UoWs:  
  `phase-1-step-2-uow-1.md`, `phase-1-step-2-uow-2.md`, …

Each UoW might contain tasks like:

- “Rerun the app with debug logging enabled and capture logs for the failing scenario.”
- “Reduce the reproduction steps to a minimal case.”
- “Search the codebase for the error message and list all occurrences.”

Each UoW file should clearly state:

- **Goal of the UoW**
- **Input context (which phase/step to read first)**
- **Concrete tasks** to be performed
- **Expected outputs** (e.g., updated notes, list of files, hypotheses).

---

## 4. Phase 2 — Root Cause Analysis

**File:** `phase-2.md`  
**Purpose:** Isolate where and why the bug occurs.

### 4.1 Contents of `phase-2.md`

Include:

- **Hypotheses List**
  - List candidate explanations for the bug.
  - For each hypothesis, note evidence and confidence level.
- **Key Code Areas**
  - Functions, modules, or components suspected.
  - Relevant data flows and invariants.
- **Investigation Strategy**
  - Which hypotheses will be tested first and why.
  - Planned techniques: logging, breakpoints, instrumentation, snapshot tests, etc.

### 4.2 Steps and UoWs in Phase 2

Typical steps:

1. **Step 1 – Map the Execution Path**
   - Trace inputs → outputs.
   - Identify where the observable misbehavior appears.

2. **Step 2 – Narrow Down Faulty Region**
   - Use logging or breakpoints to confine the bug to a small set of functions or operations.

3. **Step 3 – Validate or Eliminate Hypotheses**
   - For each hypothesis, perform targeted checks.

If any step is too large, split it into UoWs. Examples:

- `phase-2-step-1-uow-1.md`: “Trace the flow from user input to API layer and document all functions involved.”
- `phase-2-step-1-uow-2.md`: “Trace from API layer to persistence layer and document all functions involved.”
- `phase-2-step-3-uow-1.md`: “For hypothesis H1, add temporary logging and run the repro scenario.”

Every UoW file:

- States the **hypothesis or question** being tested.
- Describes **what data to collect**.
- Describes **what conclusion to write back** into the phase/step context file.

The phase ends when:

- There is a **clear root cause** (a specific piece of logic, interaction, or invariant violation).
- Any remaining unknowns are documented for the next phase.

---

## 5. Phase 3 — Fix Design and Validation Plan

**File:** `phase-3.md`  
**Purpose:** Decide *how* to fix the bug and *how* to prove it stays fixed.

### 5.1 Contents of `phase-3.md`

Include:

- **Root Cause Summary**
  - Short description of what is actually wrong.
  - Where in the code it lives.
- **Fix Strategy**
  - High-level approach to fix the bug.
  - Explanation of tradeoffs and risks.
- **Reversal Strategy**
  - How to revert the fix if it doesn't work or causes new issues.
  - What signals indicate the fix should be reverted.
  - Steps to cleanly undo the changes.
- **Test Strategy**
  - Regression tests to add or fix.
  - Existing tests to adjust (only if explicitly approved).
  - How to cover edge cases revealed by the bug.
- **Impact Analysis**
  - API or behavior changes.
  - Impact on downstream modules.
  - Performance, memory, or resource considerations.

### 5.2 Steps and UoWs in Phase 3

Typical steps:

1. **Step 1 – Define Fix Requirements**
   - Clarify what “correct behavior” is.
   - Enumerate invariants that must hold.

2. **Step 2 – Propose Fix Options**
   - List 1–3 possible approaches.
   - Compare complexity, risk, and impact.
   - For each option, note how easily it can be reversed.

3. **Step 3 – Choose Fix and Define Test Changes**
   - Pick the approach.
   - List all tests to add or adjust.

Split into UoWs only if needed:

- `phase-3-step-2-uow-1.md`: “Draft at least two fix approaches with pros/cons.”
- `phase-3-step-3-uow-1.md`: “List all new regression tests to add.”

At the end of Phase 3:

- The selected fix strategy is written down.
- The test plan is explicit.
- The next phases can be executed by SLMs with minimal guessing.

---

## 6. Phase 4 — Implementation and Tests

**File:** `phase-4.md`  
**Purpose:** Implement the fix and ensure tests and regressions are handled.

### 6.1 Contents of `phase-4.md`

Include:

- **Implementation Overview**
  - Key files and functions to touch.
  - Order of modifications.
- **Test Execution Plan**
  - Which test suites to run.
  - Which golden/regression tests must pass.
- **Reversal Plan**
  - Exact steps to revert the fix if it doesn't work.
  - Git commands or manual steps to undo changes.
  - How to verify the reversal was successful.
  - What to do if the bug reappears after reversal (investigation breadcrumbs to follow).

### 6.2 Steps and UoWs in Phase 4

Typical steps:

1. **Step 1 – Prepare the Codebase**
   - Ensure a clean working state.
   - Confirm all tests pass before changes.

2. **Step 2 – Implement the Fix**
   - Apply changes following the Phase 3 design.

3. **Step 3 – Update or Add Tests**
   - Create or modify tests according to the test strategy.

4. **Step 4 – Run Tests and Verify**
   - Run full test suite.
   - Run golden/regression tests as defined by project rules.

5. **Step 5 – Document Reversal Procedure**
   - Write down exact reversal steps.
   - Test the reversal procedure if possible (apply fix, revert, verify clean state).
   - Note any side effects of reversal (e.g., data migrations that can't be undone).

As always:

- If a step is small → keep it in `phase-4-step-N.md`.
- If a step is big → create UoW files like `phase-4-step-2-uow-1.md`.

Each UoW contains concrete, code-level tasks, such as:

- “Modify function X in file Y to enforce invariant Z.”
- “Add regression test covering scenario S using existing test harness T.”
- “Run tests suite U and record results in the step file.”

---

## 7. Phase 5 — Cleanup, Regression Protection, and Handoff

**File:** `phase-5.md`  
**Purpose:** Ensure the fix is stable, clean, and well-documented.

### 7.1 Contents of `phase-5.md`

Include:

- **Post-Fix Verification Summary**
  - Final test status.
  - Evidence that the bug is fixed (repro steps now pass).
- **Regression Safeguards**
  - New or updated regression tests.
  - Any baseline/golden outputs updated *with explicit user approval*.
- **Cleanup**
  - Removed dead code.
  - Removed debug logging and temporary instrumentation.
  - Removed any compatibility hacks used during analysis.
- **Documentation Updates**
  - Code comments.
  - Changelogs, release notes, or user-facing docs if needed.
- **Handoff Notes**
  - Remaining risks or edge cases.
  - Suggestions for future monitoring or follow-up tasks.

### 7.2 Handoff Checklist

Before closing the bugfix plan:

- [ ] Project builds cleanly.
- [ ] All tests pass.
- [ ] Behavioral regression tests pass (if applicable).
- [ ] The team file (`.teams/TEAM_XXX_*.md`) is updated with:
  - What changed.
  - Where the fix lives.
  - Links to the plan files.
- [ ] Any remaining TODOs are:
  - Tagged in code: `TODO(TEAM_XXX): ...`
  - Added to the global TODO list with file + line + description.
- [ ] All open questions are either resolved or recorded in `.questions/` for explicit user review.

---

## 8. Questions and Uncertainties

If any ambiguity, unresolved assumption, or missing requirement remains at any time:

1. Create or update a **question file** under `.questions/`:
   - Include:
     - Bug reference.
     - Short summary of the uncertainty.
     - Current hypotheses or options.
     - Suggested decision or clarifications needed.

2. **Questions should focus on behaviors, not implementation details:**
   - Good: "Should the function return an error or silently skip invalid input?"
   - Good: "Is it acceptable for this operation to be slower if it's more correct?"
   - Bad: "Should we use a HashMap or a Vec?"
   - Bad: "Should this be a separate function or inline?"

3. Pause any risky work that depends on the answer.

4. Continue only after the user has answered or refined the question.

This keeps bugfix planning explicit, traceable, and safe for future teams to continue.
