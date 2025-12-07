---
description: make a refactor plan
auto_execution_mode: 3
---

## 0. Artifacts and Naming

All planning for a single refactor lives under one logical planning root.

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

All files live in the project's SSOT planning space for this refactor.

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
   .teams/TEAM_XXX_refactor_<refactor-summary>.md
   ```

4. **Your team ID is permanent** for this entire conversation.

### 1.2 Clarify the Refactor Intent

- What is being refactored and why?
- What are the pain points (messy structure, tangled responsibilities, duplicated code)?
- What does "success" look like?

### 1.3 Check Existing Project Context

- Read the **main project overview**.
- Read the **current active phase**.
- Scan recent **team logs** relevant to the affected area.
- Look for existing **questions** about this area.
- Run the test suite:
  - Confirm all tests pass before starting work.

Only then start writing the refactor plan.

---

## 2. Phase Structure for Refactor Planning

Use phases to represent **high-level intent** for the refactor work. A typical structure:

1. **Phase 1 – Discovery and Safeguards**
2. **Phase 2 – Structural Extraction**
3. **Phase 3 – Migration**
4. **Phase 4 – Cleanup**
5. **Phase 5 – Hardening and Handoff**

You can adjust, merge, or split phases as needed, but **every plan** should have:

- A phase that focuses on **understanding + locking in tests**.
- A phase that focuses on **extracting new structure**.
- A phase that covers **migrating call sites**.
- A phase that ensures **cleanup + dead code removal**.
- A phase that ensures **final verification + handoff**.

Each phase gets its own `phase-N.md` file.

---

## 3. Phase 1 — Discovery and Safeguards

**File:** `phase-1.md`  
**Purpose:** Understand what must not break and lock in regression protection.

### 3.1 Contents of `phase-1.md`

Include:

- **Refactor Summary**
  - Short description (1–3 sentences).
  - Pain points and motivation.
- **Success Criteria**
  - What "good" looks like after the refactor.
  - Before vs After description.
- **Behavioral Contracts**
  - API endpoints, public functions, CLI interfaces.
  - File formats, schemas, protocols.
- **Golden/Regression Tests**
  - Snapshots, fixtures, logs that protect this refactor.
  - Explicitly list which baselines must pass.
- **Current Architecture Notes**
  - Dependency graph sketch.
  - Cyclic deps, god modules, or layers that leak.
  - Known couplings ("If we touch X, Y will break unless…").
- **Constraints**
  - Behavior must remain identical vs. acceptable change windows.
  - Performance/latency ceilings.
  - API/public surface compatibility requirements.
- **Open Questions**
  - Anything unclear about the refactor scope.

### 3.2 Steps and UoWs in Phase 1

Typical steps:

1. **Step 1 – Map Current Behavior and Boundaries**
2. **Step 2 – Lock in Golden Tests**
3. **Step 3 – Increase Test Coverage Where Missing**

For each step:

- If step work fits in a single SLM session → keep it in `phase-1-step-N.md`.
- If not, split into UoWs:  
  `phase-1-step-2-uow-1.md`, `phase-1-step-2-uow-2.md`, …

Each UoW might contain tasks like:

- "List all public APIs that must remain stable."
- "Run existing tests and capture baseline outputs."
- "Add missing test coverage for module X."

Each UoW file should clearly state:

- **Goal of the UoW**
- **Input context (which phase/step to read first)**
- **Concrete tasks** to be performed
- **Expected outputs** (e.g., test results, baseline files, coverage reports).

---

## 4. Phase 2 — Structural Extraction

**File:** `phase-2.md`  
**Purpose:** Extract new types, modules, or APIs in parallel with old ones.

### 4.1 Contents of `phase-2.md`

Include:

- **Target Design**
  - New module/type layout.
  - Which responsibilities move where.
  - Desired layering (e.g., `domain` → `application` → `infrastructure`).
- **Extraction Strategy**
  - What gets extracted first.
  - How new APIs coexist with old ones temporarily.
- **Modular Refactoring Rules (Rule 7)**
  - Each module owns its state.
  - Private fields, intentional APIs.
  - No deep relative imports.
  - Human-readable file sizes.

### 4.2 Steps and UoWs in Phase 2

Typical steps:

1. **Step 1 – Define New Module Boundaries**
   - Create new files/modules with clear responsibilities.

2. **Step 2 – Extract Types and Interfaces**
   - Move types to their new homes.

3. **Step 3 – Introduce New APIs**
   - Create new entry points in parallel with old ones.

If any step is too large, split it into UoWs. Examples:

- `phase-2-step-1-uow-1.md`: "Create the new `parsing` module with its public interface."
- `phase-2-step-2-uow-1.md`: "Move type X from old module to new module."
- `phase-2-step-3-uow-1.md`: "Add new API function that wraps the extracted logic."

Every UoW file:

- States the **objective** clearly.
- Describes **what code to create or move**.
- Describes **exit criteria** (tests pass, build succeeds, old and new coexist).

---

## 5. Phase 3 — Migration

**File:** `phase-3.md`  
**Purpose:** Move call sites to the new structure and remove old paths.

### 5.1 Contents of `phase-3.md`

Include:

- **Migration Strategy**
  - Order of call site migration.
  - How to handle breaking changes (Rule 5: prefer clean breaks).
- **Call Site Inventory**
  - List of all places that use the old structure.
  - Priority order for migration.
- **Rollback Plan**
  - What to do if migration causes issues.

### 5.2 Steps and UoWs in Phase 3

Typical steps:

1. **Step 1 – Migrate High-Priority Call Sites**
   - Start with the most critical or most used.

2. **Step 2 – Migrate Remaining Call Sites**
   - Work through the inventory.

3. **Step 3 – Remove Old APIs**
   - Once all call sites are migrated, delete the old paths.

Split into UoWs only if needed:

- `phase-3-step-1-uow-1.md`: "Migrate call sites in module A to use new API."
- `phase-3-step-2-uow-1.md`: "Migrate call sites in module B to use new API."
- `phase-3-step-3-uow-1.md`: "Delete old API function X and its tests."

At the end of Phase 3:

- All call sites use the new structure.
- Old APIs are removed.
- All tests pass.

---

## 6. Phase 4 — Cleanup

**File:** `phase-4.md`  
**Purpose:** Remove dead code, temporary adapters, and tighten encapsulation.

### 6.1 Contents of `phase-4.md`

Include:

- **Dead Code Removal (Rule 6)**
  - Unused functions, modules, commented-out code.
- **Temporary Adapter Removal**
  - Any shims or compatibility layers introduced during extraction.
- **Encapsulation Tightening**
  - Make fields private.
  - Remove unnecessary exports.
- **File Size Check (Rule 7)**
  - Ensure files are human-readable (<1000 lines preferred, <500 ideal).

### 6.2 Steps and UoWs in Phase 4

Typical steps:

1. **Step 1 – Remove Dead Code**
   - Delete unused functions and modules.

2. **Step 2 – Remove Temporary Adapters**
   - Delete shims and compatibility layers.

3. **Step 3 – Tighten Visibility**
   - Make internal fields private, remove unnecessary exports.

As always:

- If a step is small → keep it in `phase-4-step-N.md`.
- If a step is big → create UoW files like `phase-4-step-1-uow-1.md`.

Each UoW contains concrete, code-level tasks, such as:

- "Delete function X in file Y (confirmed unused by grep)."
- "Remove the compatibility shim in module Z."
- "Change field A from public to private and fix compile errors."

---

## 7. Phase 5 — Hardening and Handoff

**File:** `phase-5.md`  
**Purpose:** Final verification, documentation, and handoff.

### 7.1 Contents of `phase-5.md`

Include:

- **Final Verification**
  - All tests pass.
  - Golden/regression tests pass.
  - Performance checks if applicable.
- **Documentation Updates**
  - Code comments.
  - Architecture docs, READMEs, or changelogs.
- **Handoff Notes**
  - Remaining risks or edge cases.
  - Suggestions for future improvements.

### 7.2 Handoff Checklist

Before closing the refactor plan:

- [ ] Project builds cleanly.
- [ ] All tests pass.
- [ ] Behavioral regression tests pass (if applicable).
- [ ] The team file (`.teams/TEAM_XXX_*.md`) is updated with:
  - What changed.
  - Where the refactor lives.
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
     - Refactor reference.
     - Short summary of the uncertainty.
     - Current hypotheses or options.
     - Suggested decision or clarifications needed.

2. **Questions should focus on behaviors, not implementation details:**
   - Good: "Should the old API continue to work during migration, or can we break it immediately?"
   - Good: "Is it acceptable for this refactor to change error messages?"
   - Bad: "Should we use a trait or an enum?"
   - Bad: "Should this module be split into two files or three?"

3. Pause any risky work that depends on the answer.

4. Continue only after the user has answered or refined the question.

This keeps refactor planning explicit, traceable, and safe for future teams to continue.
