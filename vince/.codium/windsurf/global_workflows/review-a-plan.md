---
description: review and refine a plan
auto_execution_mode: 3
---

## 0. Purpose

This workflow is for **critically reviewing and refining** an existing plan (bugfix, feature, or refactor).

The goal is to ensure the plan is:

- **Not overengineered** — no unnecessary complexity, phases, or abstractions.
- **Not oversimplified** — all necessary work is captured, nothing swept under the rug.
- **Architecturally sound** — respects existing codebase structure and conventions.
- **Behaviorally complete** — all user-answered questions are reflected in the plan.
- **Rule-compliant** — follows the global rules.
- **Verifiable** — claims can be checked against references, docs, or MCP calls.

---

## 1. Pre-Review Checklist

Before reviewing any plan:

### 1.1 Register Your Team (Rule 2)

1. **Find the highest existing team number:**
   ```bash
   grep -r "TEAM_" .teams/ --include="*.md" | grep -oE "TEAM_[0-9]+" | sort -t_ -k2 -n | tail -1
   ```

2. **Your team number = highest + 1.**

3. **Create your team file:**
   ```
   .teams/TEAM_XXX_review_plan_<plan-summary>.md
   ```

4. **Your team ID is permanent** for this entire conversation.

### 1.2 Locate the Plan

- Identify the plan root folder in the project's SSOT.
- List all phase files, step files, and UoW files.

### 1.3 Read the Global Rules

- Read `/home/vince/.codeium/windsurf/memories/global_rules.md` (or the project's equivalent).
- Keep these rules in mind throughout the review.

### 1.4 Check for Questions Files

- Look for `.questions/` files related to this plan.
- Note which questions have been answered by the user.
- Note which questions are still open.

Only then start the review.

---

## 2. Review Structure

The review follows a **checklist-driven approach**. Work through each section in order.

1. **Phase 1 – Questions and Answers Audit**
2. **Phase 2 – Scope and Complexity Check**
3. **Phase 3 – Architecture Alignment**
4. **Phase 4 – Global Rules Compliance**
5. **Phase 5 – Verification and References**
6. **Phase 6 – Final Refinements and Handoff**

Each phase produces findings that may require plan updates.

---

## 3. Phase 1 — Questions and Answers Audit

**Purpose:** Ensure all user-answered questions are reflected in the plan.

### 3.1 Tasks

1. **Read all `.questions/` files** for this plan.
   - List each question.
   - Note the user's answer (if any).
   - Note if the question is still open.

2. **For each answered question:**
   - Find where the answer should affect the plan.
   - Verify the plan reflects the answer correctly.
   - If the plan contradicts or ignores the answer → flag for correction.

3. **For each open question:**
   - Verify the plan does not assume an answer.
   - Verify affected UoWs are marked as blocked (if appropriate).

4. **Check question quality:**
   - Questions should focus on **behaviors**, not implementation details.
   - If a question is about implementation → consider rephrasing or removing it.

### 3.2 Outputs

- List of discrepancies between answers and plan.
- List of open questions that block work.
- Suggestions for question rephrasing (if needed).

---

## 4. Phase 2 — Scope and Complexity Check

**Purpose:** Ensure the plan is neither overengineered nor oversimplified.

### 4.1 Overengineering Signals

Flag if you find:

- **Too many phases** for a simple task.
- **Unnecessary abstractions** — new modules, types, or layers that don't add value.
- **Premature optimization** — performance work before correctness is proven.
- **Speculative features** — work that "might be needed later."
- **Excessive UoW splitting** — tasks that could be one UoW split into many.

### 4.2 Oversimplification Signals

Flag if you find:

- **Missing phases** — e.g., no testing phase, no cleanup phase.
- **Vague UoWs** — tasks like "implement feature X" with no breakdown.
- **Ignored edge cases** — known complexities not addressed.
- **No regression protection** — no mention of tests or baselines.
- **Handwavy handoff** — no clear exit criteria or verification.

### 4.3 Tasks

1. Count phases, steps, and UoWs.
2. Assess if the ratio makes sense for the scope.
3. Read each UoW and ask: "Is this SLM-sized? Is it too big? Too small?"
4. Check for speculative or "nice to have" work that should be deferred.

### 4.4 Outputs

- List of overengineering concerns.
- List of oversimplification concerns.
- Suggested phase/step/UoW adjustments.

---

## 5. Phase 3 — Architecture Alignment

**Purpose:** Ensure the plan respects the existing codebase structure.

### 5.1 Tasks

1. **Read the project's architecture docs** (if any).
2. **Scan the codebase** for relevant modules, patterns, and conventions.
3. **Compare plan to existing structure:**
   - Does the plan introduce new patterns that conflict with existing ones?
   - Does the plan respect module boundaries?
   - Does the plan follow existing naming conventions?
   - Does the plan avoid creating parallel/duplicate structures?

4. **Check for Rule 5 compliance (Breaking Changes > Fragile Compatibility):**
   - If the plan introduces adapters or shims → is this justified?
   - If the plan duplicates code → flag for removal.

5. **Check for Rule 7 compliance (Modular Refactoring):**
   - Are new modules well-scoped?
   - Are file sizes reasonable?
   - Are responsibilities clear?

### 5.2 Outputs

- List of architecture misalignments.
- Suggested corrections to align with existing structure.

---

## 6. Phase 4 — Global Rules Compliance

**Purpose:** Verify the plan follows all global rules.

### 6.1 Rules Checklist

For each rule, verify compliance:

- [ ] **Rule 0 (Quality Over Speed):** No hacky shortcuts baked into the plan.
- [ ] **Rule 1 (SSOT):** Plan lives in the correct location.
- [ ] **Rule 2 (Team Registration):** Team file exists for the planning team.
- [ ] **Rule 3 (Before Starting Work):** Pre-planning checklist was followed.
- [ ] **Rule 4 (Behavioral Regression Protection):** Tests/baselines are mentioned.
- [ ] **Rule 5 (Breaking Changes):** No unnecessary compatibility hacks.
- [ ] **Rule 6 (No Dead Code):** Cleanup phase exists.
- [ ] **Rule 7 (Modular Refactoring):** New structure is well-scoped.
- [ ] **Rule 8 (Ask Questions Early):** Questions file exists if needed.
- [ ] **Rule 9 (Maximize Context Window):** Work is batched sensibly.
- [ ] **Rule 10 (Before Finishing):** Handoff checklist exists.
- [ ] **Rule 11 (TODO Tracking):** TODOs are documented.

### 6.2 Outputs

- List of rule violations.
- Suggested corrections for each violation.

---

## 7. Phase 5 — Verification and References

**Purpose:** Verify claims in the plan against external references.

### 7.1 Tasks

1. **Identify verifiable claims** in the plan:
   - API behavior assumptions.
   - Library/framework capabilities.
   - Performance expectations.
   - External service contracts.

2. **Verify each claim:**
   - Use **web search** to check documentation.
   - Use **MCP calls** (if available) to query package info, NixOS options, etc.
   - Read **source code** to confirm assumptions about existing behavior.

3. **Flag unverified claims:**
   - If a claim cannot be verified → note it as a risk.
   - If a claim is wrong → flag for correction.

### 7.2 Outputs

- List of verified claims.
- List of unverified or incorrect claims.
- Suggested corrections or risk notes.

---

## 8. Phase 6 — Final Refinements and Handoff

**Purpose:** Apply corrections and finalize the review.

### 8.1 Tasks

1. **Compile all findings** from Phases 1–5.
2. **Prioritize corrections:**
   - Critical: blocks work or causes regressions.
   - Important: improves quality or clarity.
   - Minor: nice-to-have refinements.

3. **Apply corrections** to the plan files:
   - Update phase/step/UoW files as needed.
   - Update questions files if rephrasing is needed.
   - Add missing content (tests, cleanup, handoff).

4. **Update your team file** with:
   - Summary of review findings.
   - List of changes made.
   - Remaining concerns or risks.

### 8.2 Handoff Checklist

Before closing the review:

- [ ] All answered questions are reflected in the plan.
- [ ] Open questions are documented and affected UoWs are blocked.
- [ ] Plan is not overengineered.
- [ ] Plan is not oversimplified.
- [ ] Plan respects existing architecture.
- [ ] Plan complies with all global rules.
- [ ] Verifiable claims have been checked.
- [ ] Team file is updated with review summary.

---

## 9. Questions and Uncertainties

If any ambiguity, unresolved assumption, or missing requirement remains at any time:

1. Create or update a **question file** under `.questions/`:
   - Include:
     - Plan reference.
     - Short summary of the uncertainty.
     - Current hypotheses or options.
     - Suggested decision or clarifications needed.

2. **Questions should focus on behaviors, not implementation details:**
   - Good: "Should the API return an error or silently ignore invalid input?"
   - Good: "Is it acceptable for this operation to be slower if it's more correct?"
   - Bad: "Should we use a HashMap or a BTreeMap?"
   - Bad: "Should this be a class or a function?"

3. Pause any risky work that depends on the answer.

4. Continue only after the user has answered or refined the question.

This keeps plan reviews explicit, traceable, and safe for future teams to continue.
