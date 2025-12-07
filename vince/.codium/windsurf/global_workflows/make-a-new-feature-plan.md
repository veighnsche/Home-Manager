---
description: make a new feature plan
auto_execution_mode: 3
---

## 0. Artifacts and Naming

All planning for a single feature lives under one logical planning root.

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

All files live in the project's SSOT planning space for this feature.

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
   .teams/TEAM_XXX_feature_<feature-summary>.md
   ```

4. **Your team ID is permanent** for this entire conversation.

### 1.2 Clarify the Feature

- What problem does it solve?
- Who/what depends on it?
- How do we know it's "done" (acceptance criteria)?

### 1.3 Check Existing Project Context

- Read the **main project overview**.
- Read the **current active phase**.
- Scan recent **team logs** relevant to the affected area.
- Look for existing **questions** about this feature or related areas.
- Run the test suite:
  - Confirm all tests pass before starting work.

Only then start writing the feature plan.

---

## 2. Phase Structure for Feature Planning

Use phases to represent **high-level intent** for the feature work. A typical structure:

1. **Phase 1 – Discovery** (understand the problem and codebase)
2. **Phase 2 – Design** (define the solution — THIS IS WHERE MOST QUESTIONS ARISE)
3. **Phase 3 – Implementation**
4. **Phase 4 – Integration and Testing**
5. **Phase 5 – Polish, Docs, and Cleanup**

You can adjust, merge, or split phases as needed, but **every plan** should have:

- A phase that focuses on **discovery** (problem + codebase understanding).
- A phase that focuses on **design** (solution definition + behavioral questions).
- A phase that focuses on **implementation**.
- A phase that covers **integration + regression protection**.
- A phase that ensures **polish + documentation + handoff**.

**Important:** The design phase (Phase 2) should generate most of the questions. Do not rush past design to get to implementation. A well-designed feature with answered questions is faster to implement than a poorly-designed one.

Each phase gets its own `phase-N.md` file.

---

## 3. Phase 1 — Discovery

**File:** `phase-1.md`  
**Purpose:** Understand the problem and the codebase before designing anything.

### 3.1 Contents of `phase-1.md`

Include:

- **Feature Summary**
  - Short description (1–3 sentences).
  - Problem statement: what pain does this solve?
  - Who benefits from this feature?
- **Success Criteria**
  - How we know the feature is "done".
  - Acceptance criteria list (user-observable behaviors).
- **Current State Analysis**
  - How does the system work today without this feature?
  - What workarounds exist (if any)?
  - What are users doing instead?
- **Codebase Reconnaissance**
  - Code areas likely touched (modules, features, main components).
  - Public APIs involved.
  - Tests or golden snapshots that may be impacted (Rule 4).
  - Non-obvious constraints (e.g., "This module is tightly coupled to X").
- **Constraints**
  - Performance, compatibility, or UX requirements.
  - Platforms/environments that must be protected.

### 3.2 Steps and UoWs in Phase 1

Typical steps:

1. **Step 1 – Capture Feature Intent**
   - Write down the problem statement.
   - List who benefits and how.

2. **Step 2 – Analyze Current State**
   - Document how the system works today.
   - Note existing workarounds or gaps.

3. **Step 3 – Source Code Reconnaissance**
   - Identify modules, APIs, and tests involved.
   - Document seams for extension.

Each UoW might contain tasks like:

- "Interview the user (or read the issue) to clarify the problem."
- "Trace the current code path for related functionality."
- "List all modules that will be touched by this feature."

Each UoW file should clearly state:

- **Goal of the UoW**
- **Input context (which phase/step to read first)**
- **Concrete tasks** to be performed
- **Expected outputs** (e.g., problem statement, module list, constraint notes).

**Note:** Phase 1 should produce few questions. If you have many questions here, you may not understand the problem yet — keep investigating.

---

## 4. Phase 2 — Design (Question-Heavy Phase)

**File:** `phase-2.md`  
**Purpose:** Define the solution. This is where most behavioral questions should emerge.

> **THIS IS THE MOST IMPORTANT PHASE.**  
> Do not rush to implementation. A well-designed feature with answered questions is faster to implement than a poorly-designed one with surprises.

### 4.1 Contents of `phase-2.md`

Include:

- **Proposed Solution**
  - High-level description of how the feature will work.
  - User-facing behavior: what will users see/experience?
  - System behavior: what will the system do internally?
- **API Design** (if applicable)
  - New endpoints, functions, or interfaces.
  - Input/output contracts.
  - Error handling behavior.
- **Data Model Changes** (if applicable)
  - New types, schemas, or storage.
  - Migration strategy for existing data.
- **Behavioral Decisions** (THIS GENERATES QUESTIONS)
  - Edge cases: what happens when X?
  - Error states: what happens when Y fails?
  - Defaults: what is the default behavior for Z?
  - Backwards compatibility: does this break existing behavior?
- **Design Alternatives Considered**
  - What other approaches were considered?
  - Why was this approach chosen?
- **Open Questions** (EXPECT MANY HERE)
  - List all behavioral uncertainties.
  - For each, note the options and your recommendation.

### 4.2 Generating Questions During Design

As you design, actively ask yourself:

- "What should happen if the input is invalid?"
- "What should happen if this operation fails?"
- "What should the default value be?"
- "Is this behavior consistent with existing features?"
- "Will this break any existing workflows?"
- "What happens at the boundaries (empty, null, max, min)?"

**Every behavioral uncertainty becomes a question.** Do not assume answers — ask the user.

### 4.3 Steps and UoWs in Phase 2

Typical steps:

1. **Step 1 – Draft Initial Design**
   - Sketch the solution at a high level.
   - Identify major components and their responsibilities.

2. **Step 2 – Define Behavioral Contracts**
   - Specify what the feature does in all cases.
   - Document edge cases and error handling.
   - **Generate questions for every uncertainty.**

3. **Step 3 – Review Design Against Architecture**
   - Does this fit the existing codebase?
   - Does this follow existing patterns?
   - Does this respect Rule 5 (breaking changes > compatibility hacks)?

4. **Step 4 – Finalize Design After Questions Answered**
   - Incorporate user answers into the design.
   - Update behavioral contracts.
   - Confirm design is complete before moving to implementation.

Each UoW might contain tasks like:

- "Draft the API contract for feature X."
- "List all edge cases and propose handling for each."
- "Write questions for all behavioral uncertainties."
- "Update design based on user answers to questions Q1-Q5."

**Do not proceed to Phase 3 until all critical questions are answered.**

---

## 5. Phase 3 — Implementation

**File:** `phase-3.md`  
**Purpose:** Build the feature according to the design from Phase 2.

### 5.1 Contents of `phase-3.md`

Include:

- **Implementation Overview**
  - Key files and functions to create or modify.
  - Order of implementation.
- **Design Reference**
  - Link to Phase 2 design decisions.
  - Summary of behavioral contracts to implement.
- **Dependencies**
  - New packages or modules required.
  - Integration points with existing code.

### 5.2 Steps and UoWs in Phase 3

Typical steps:

1. **Step 1 – Add New Domain Types and Interfaces**
   - Define data structures, types, and contracts.

2. **Step 2 – Implement Core Logic**
   - Build the main functionality.
   - Follow the behavioral contracts from Phase 2.

3. **Step 3 – Wire Feature into Main Execution Pipeline**
   - Connect the new code to existing flows.

If any step is too large, split it into UoWs. Examples:

- `phase-3-step-1-uow-1.md`: "Define the new data types for feature X."
- `phase-3-step-2-uow-1.md`: "Implement the core algorithm for feature X."
- `phase-3-step-3-uow-1.md`: "Add entry point for feature X in the main router."

Every UoW file:

- States the **objective** clearly.
- References the **design decision** it implements.
- Describes **exit criteria** (tests pass, build succeeds, specific behavior works).

---

## 6. Phase 4 — Integration and Testing

**File:** `phase-4.md`  
**Purpose:** Ensure the feature works correctly with the rest of the system.

### 6.1 Contents of `phase-4.md`

Include:

- **Integration Points**
  - How the feature connects to existing modules.
  - API or behavior changes.
- **Test Strategy**
  - New tests to add.
  - Existing tests to update (only if explicitly approved).
  - Golden/regression tests to run.
- **Impact Analysis**
  - Downstream modules affected.
  - Performance, memory, or resource considerations.

### 6.2 Steps and UoWs in Phase 4

Typical steps:

1. **Step 1 – Add Unit Tests**
   - Cover the new functionality.
   - Test edge cases defined in Phase 2.

2. **Step 2 – Add Integration Tests**
   - Test feature in context with other modules.

3. **Step 3 – Run Full Test Suite and Verify**
   - Confirm no regressions.
   - Run golden/regression tests as defined by project rules.

Split into UoWs only if needed:

- `phase-4-step-1-uow-1.md`: "Add unit tests for the new data types."
- `phase-4-step-2-uow-1.md`: "Add integration test for feature X end-to-end flow."

At the end of Phase 4:

- All tests pass.
- No regressions introduced.
- The feature is functionally complete.

---

## 7. Phase 5 — Polish, Docs, and Cleanup

**File:** `phase-5.md`  
**Purpose:** Finalize the feature for release.

### 7.1 Contents of `phase-5.md`

Include:

- **Cleanup Tasks**
  - Remove dead code.
  - Remove debug logging and temporary instrumentation.
  - Tighten visibility/encapsulation.
- **Documentation Updates**
  - Code comments.
  - User-facing docs, READMEs, or changelogs.
- **Final Verification**
  - Evidence that the feature works as intended.
  - Performance checks if applicable.
- **Handoff Notes**
  - Remaining risks or edge cases.
  - Suggestions for future improvements.

### 7.2 Handoff Checklist

Before closing the feature plan:

- [ ] Project builds cleanly.
- [ ] All tests pass.
- [ ] Behavioral regression tests pass (if applicable).
- [ ] The team file (`.teams/TEAM_XXX_*.md`) is updated with:
  - What changed.
  - Where the feature lives.
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
     - Feature reference.
     - Short summary of the uncertainty.
     - Current hypotheses or options.
     - Suggested decision or clarifications needed.

2. **Questions should focus on behaviors, not implementation details:**
   - Good: "Should the API return paginated results or all at once?"
   - Good: "Is it acceptable for this feature to require a restart?"
   - Bad: "Should we use React Query or SWR?"
   - Bad: "Should this be a class or a function?"

3. Pause any risky work that depends on the answer.

4. Continue only after the user has answered or refined the question.

This keeps feature planning explicit, traceable, and safe for future teams to continue.
