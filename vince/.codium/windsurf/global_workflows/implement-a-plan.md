---
description: implement a plan
auto_execution_mode: 3
---

## 0. Mindset

**You are here to execute a plan, not to improvise.**

The plan exists for a reason. It was designed, reviewed, and approved. Your job is to:

1. Follow the plan faithfully.
2. Update the plan if reality diverges from expectations.
3. Never silently deviate — document everything.

If the plan is wrong, fix the plan first, then implement.

---

## 1. Before Starting Work (Rule 3)

Before writing any code:

### 1.1 Register Your Team (Rule 2)

1. **Find the highest existing team number:**
   ```bash
   grep -r "TEAM_" .teams/ --include="*.md" | grep -oE "TEAM_[0-9]+" | sort -t_ -k2 -n | tail -1
   ```

2. **Your team number = highest + 1.**

3. **Create your team file:**
   ```
   .teams/TEAM_XXX_implement_<plan-summary>.md
   ```

4. **Your team ID is permanent** for this entire conversation.

### 1.2 Read Project Context

- Read the **main project overview**.
- Read the **current active phase**.
- Check recent **team logs** — what did previous teams do?
- Check **open questions** — are there unresolved blockers?

### 1.3 Verify Test Baseline (Rule 4)

- Run the test suite **before making any changes**.
- All tests must pass.
- If tests fail, **stop** — investigate or ask for guidance.

### 1.4 Locate the Plan

- Find the plan in the project's SSOT.
- Read all phase files, step files, and UoW files.
- Identify which UoW you are implementing.

---

## 2. Executing the Plan

### 2.1 Work in Order

Execute UoWs in the order specified by the plan.

If no order is specified:
1. Dependencies first (types, interfaces, contracts).
2. Core logic second.
3. Integration third.
4. Tests fourth.
5. Cleanup last.

### 2.2 One UoW at a Time

- Read the UoW file completely before starting.
- Understand the **objective**, **scope**, and **exit criteria**.
- Implement exactly what the UoW specifies.
- Do not add extra work — if you see something else to fix, note it for later.

### 2.3 Comment Your Changes (Rule 2)

Every code change must include a comment with your team number:

```
// TEAM_XXX: <short description of what you changed and why>
```

This ensures traceability for future teams.

### 2.4 Verify After Each UoW

After completing a UoW:

1. Run the test suite.
2. Confirm all tests pass.
3. Confirm the exit criteria from the UoW are met.
4. Update your team file with progress.

---

## 3. When Reality Diverges from the Plan

### 3.1 The Plan is Too Simple

If the implementation is **more complex than planned**:

1. **Stop implementing.**
2. **Update the plan:**
   - Split the current UoW into smaller UoWs.
   - Add missing steps or phases.
   - Reference the appropriate workflow:
     - `/make-a-bugfix-plan` for bugfixes
     - `/make-a-new-feature-plan` for features
     - `/make-a-refactor-plan` for refactors
3. **Document why** the plan needed updating in your team file.
4. **Resume implementation** with the updated plan.

### 3.2 The Plan is Wrong

If the plan contains **incorrect assumptions**:

1. **Stop implementing.**
2. **Document the discrepancy** in your team file.
3. **Create a question** in `.questions/` if user input is needed.
4. **Update the plan** once the issue is resolved.
5. **Resume implementation.**

### 3.3 You Discover a Bug During Implementation

If you find a bug unrelated to the current plan:

1. **Do not fix it inline** — this causes scope creep.
2. **Leave a breadcrumb** in the code:
   ```
   // TEAM_XXX BREADCRUMB: SUSPECT - <description of the bug>
   ```
3. **Log it** in your team file for future investigation.
4. **Continue with the plan.**

---

## 4. Bugfix Implementation Rules

When implementing a bugfix plan:

### 4.1 Follow the Reversal Strategy

Every bugfix plan should have a **reversal strategy** (see Phase 3 of `/make-a-bugfix-plan`).

Before implementing:
- Know how to revert the fix.
- Know what signals indicate the fix should be reverted.

### 4.2 Never Silently Regress

**CRITICAL:** Do not implement a "fix" that silently breaks something else.

- If your fix causes test failures → investigate, don't disable tests.
- If your fix changes behavior → confirm this is intended.
- If your fix adds a fallback → ensure the fallback doesn't hide bugs.

Bad:
```
// Silently swallow the error to "fix" the crash
try { riskyOperation(); } catch (e) { /* ignore */ }
```

Good:
```
// TEAM_XXX: Handle the specific error case that was causing the crash
try { riskyOperation(); } catch (e) {
  if (e instanceof SpecificError) {
    handleSpecificCase();
  } else {
    throw e; // Re-throw unexpected errors
  }
}
```

### 4.3 If the Fix Doesn't Work

If after implementing the fix, the bug is **not actually fixed**:

1. **Revert the fix** — do not leave broken code in place.
2. **Update breadcrumbs** in the code:
   ```
   // TEAM_XXX BREADCRUMB: RULED_OUT - Fix attempt X did not resolve the bug
   // Reverted in commit <hash>. See team file for details.
   ```
3. **Return to investigation** — use `/investigate-a-bug` workflow.
4. **Update previous breadcrumbs** with the latest status.
5. **Document everything** in your team file.

### 4.4 If the Fix Causes New Issues

If the fix introduces **new bugs or regressions**:

1. **Revert the fix immediately.**
2. **Document what went wrong** in your team file.
3. **Update the bugfix plan** with the new information.
4. **Re-investigate** if the root cause was misidentified.

---

## 5. Refactor Implementation Rules

When implementing a refactor plan:

### 5.1 Rule 5: Breaking Changes > Fragile Compatibility

**Prefer clean breaks over compatibility hacks.**

Do NOT:
- Add wrapper functions to "keep old code working."
- Create `fooV2()` alongside `foo()`.
- Add shims, adapters, or compatibility layers.
- Silently maintain two code paths.

DO:
- Move or rename the type/function.
- Let the compiler fail.
- Fix import sites one by one.
- Remove the old code completely.

Bad:
```
// Keep the old function for "backwards compatibility"
function oldFunction() { return newFunction(); }
function newFunction() { /* actual implementation */ }
```

Good:
```
// TEAM_XXX: Renamed oldFunction to newFunction, updated all 12 call sites
function newFunction() { /* actual implementation */ }
```

### 5.2 Let Call Sites Scream

When you make a breaking change:

1. **Make the change.**
2. **Let the build fail.**
3. **Fix each call site** — do not add compatibility shims.
4. **Confirm all call sites are updated.**
5. **Remove any temporary scaffolding.**

This is better than silent technical debt.

### 5.3 No Dead Code (Rule 6)

After refactoring:

- Delete unused functions.
- Delete unused modules.
- Delete commented-out code.
- Delete "kept for reference" logic — git history exists.

The repository must contain only living, active code.

---

## 6. Testing and Verification

### 6.1 Run Tests Frequently

- After every UoW.
- After every significant change.
- Before committing.

### 6.2 Behavioral Regression Protection (Rule 4)

If the project has golden tests, snapshots, or baseline outputs:

1. Run them **before** making changes.
2. Run them **after** making changes.
3. If results differ → **this is a regression** → fix it.

**Never modify baseline data unless the USER explicitly approves.**

### 6.3 If Tests Fail

1. **Do not disable or delete the test.**
2. **Investigate why** the test fails.
3. If your change is correct and the test is wrong → **ask the user** before modifying the test.
4. If your change is wrong → **fix your change**.

---

## 7. Documentation and Handoff

### 7.1 Update Your Team File (Rule 10)

Throughout implementation, keep your team file updated with:

- What you've completed.
- What's in progress.
- What's blocked.
- Any issues or surprises.

### 7.2 TODO Tracking (Rule 11)

Any incomplete work must be recorded:

**In code:**
```
// TODO(TEAM_XXX): <what is missing>
```

**In global TODO list:**
- File
- Line
- Description

### 7.3 Before Finishing (Rule 10)

Before ending your session:

- [ ] Project builds cleanly.
- [ ] All tests pass.
- [ ] Behavioral regression tests pass.
- [ ] Team file is updated with progress.
- [ ] Remaining TODOs are documented.
- [ ] Handoff notes are written for the next team.

---

## 8. Handoff Checklist

Before closing the implementation:

- [ ] All UoWs in the plan are completed (or documented as blocked).
- [ ] All code changes have `// TEAM_XXX:` comments.
- [ ] All tests pass.
- [ ] No silent regressions introduced.
- [ ] No dead code left behind.
- [ ] No compatibility shims added (unless explicitly approved).
- [ ] Team file documents:
  - What was implemented.
  - What was changed from the plan (if anything).
  - What remains to be done (if anything).
  - Any breadcrumbs left for future teams.
- [ ] If bugfix: reversal procedure is documented and tested.
- [ ] If refactor: all call sites are updated, no `fooV2` functions.

---

## 9. Quick Reference

| Rule | Summary |
|------|---------|
| **Rule 0** | Quality > Speed. No shortcuts. |
| **Rule 1** | SSOT. All planning in one place. |
| **Rule 2** | Team ID. Comment all changes with `TEAM_XXX`. |
| **Rule 3** | Before starting: read context, verify tests pass. |
| **Rule 4** | Behavioral regression protection. Never modify baselines without approval. |
| **Rule 5** | Breaking changes > fragile compatibility. Let call sites scream. |
| **Rule 6** | No dead code. Delete unused code. |
| **Rule 7** | Modular refactoring. Each module owns its state. |
| **Rule 8** | Ask questions early. Never guess on major decisions. |
| **Rule 9** | Maximize context window. Do as much aligned work as possible. |
| **Rule 10** | Before finishing: update team file, ensure tests pass, write handoff. |
| **Rule 11** | TODO tracking. Record all incomplete work. |

---

## 10. Emergency Procedures

### If You Break Something

1. **Stop.**
2. **Revert to last known good state.**
3. **Document what happened** in your team file.
4. **Investigate** before trying again.

### If You're Stuck

1. **Document where you're stuck** in your team file.
2. **Create a question** in `.questions/`.
3. **Do not guess** on major decisions.
4. **Wait for user input** or hand off to the next team.

### If the Plan is Fundamentally Wrong

1. **Stop implementing.**
2. **Document the issues** in your team file.
3. **Create questions** for the user.
4. **Do not continue** with a broken plan.

The goal is always: **leave the codebase better than you found it.**

---

## 11. Questions and Uncertainties

If any ambiguity, unresolved assumption, or missing requirement remains at any time:

1. Create or update a **question file** under `.questions/`:
   - Include:
     - Plan reference.
     - Short summary of the uncertainty.
     - Current hypotheses or options.
     - Suggested decision or clarifications needed.

2. **Questions should focus on behaviors, not implementation details:**
   - Good: "Should this error be logged or thrown?"
   - Good: "Is it acceptable for this operation to fail silently?"
   - Bad: "Should I use a for loop or map?"
   - Bad: "Should this be async or sync?"

3. Pause any risky work that depends on the answer.

4. Continue only after the user has answered or refined the question.

This keeps implementation explicit, traceable, and safe for future teams to continue.
