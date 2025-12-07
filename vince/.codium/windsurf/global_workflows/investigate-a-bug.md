---
description: investigate a bug
auto_execution_mode: 3
---

## 0. Mindset

**Take a step back. Take a deep breath.**

Before touching anything:

- Do not assume you know the root cause.
- Do not assume the bug is where it appears to be.
- Do not assume the first suspicious code is the culprit.

Your job is to **investigate**, not to fix. Fixing comes later — either immediately (if small) or via a bugfix plan (if large).

---

## 1. Pre-Investigation Checklist

Before investigating:

### 1.1 Register Your Team (Rule 2)

1. **Find the highest existing team number:**
   ```bash
   grep -r "TEAM_" .teams/ --include="*.md" | grep -oE "TEAM_[0-9]+" | sort -t_ -k2 -n | tail -1
   ```

2. **Your team number = highest + 1.**

3. **Create your team file:**
   ```
   .teams/TEAM_XXX_investigate_<bug-summary>.md
   ```

4. **Your team ID is permanent** for this entire conversation.

### 1.2 Gather the Bug Report

- Copy the user report / issue description.
- Note environment, platform, versions, and configuration.
- Capture error messages, stack traces, screenshots, or logs.

### 1.3 Check Existing Context

- Read the **main project overview**.
- Scan recent **team logs** — has anyone investigated this before?
- Check `.questions/` — are there related open questions?
- Look for **breadcrumbs** in the code (see Section 7).

### 1.4 Confirm Reproducibility

- Can you reproduce the bug?
- If yes: document exact reproduction steps.
- If no: document what you tried and note the uncertainty.

Only then start the investigation.

---

## 2. Investigation Structure

The investigation follows a **hypothesis-driven approach**:

1. **Phase 1 – Understand the Symptom**
2. **Phase 2 – Form Hypotheses**
3. **Phase 3 – Test Hypotheses with Evidence**
4. **Phase 4 – Narrow Down to Root Cause**
5. **Phase 5 – Decision: Fix or Plan**

Use **sequential thinking** throughout. Reason through each step before acting.

---

## 3. Phase 1 — Understand the Symptom

**Purpose:** Know exactly what is wrong before guessing why.

### 3.1 Tasks

1. **Describe the symptom precisely:**
   - What is the expected behavior?
   - What is the actual behavior?
   - What is the delta (difference)?

2. **Locate the symptom in the system:**
   - Where does the bug manifest? (UI, API, logs, data)
   - What is the user-visible impact?

3. **Trace backwards from the symptom:**
   - What code path leads to this output?
   - What inputs trigger the bug?

4. **Use tools to gather evidence:**
   - Read relevant source files.
   - Search for error messages in the codebase.
   - Check logs, traces, or monitoring data.

### 3.2 Outputs

- Clear symptom description in your team file.
- List of code areas involved in the symptom.
- Initial trace of the execution path.

---

## 4. Phase 2 — Form Hypotheses

**Purpose:** Generate candidate explanations before diving into code.

### 4.1 Tasks

1. **Brainstorm possible causes:**
   - What could produce this symptom?
   - List at least 2–3 hypotheses.

2. **For each hypothesis, note:**
   - What evidence would confirm it?
   - What evidence would refute it?
   - Confidence level (low/medium/high).

3. **Prioritize hypotheses:**
   - Start with the most likely or easiest to test.

4. **Use sequential thinking:**
   - Reason through each hypothesis step by step.
   - Ask: "If this were true, what else would I expect to see?"

### 4.2 Outputs

- Numbered list of hypotheses in your team file.
- For each: evidence needed, confidence level.

---

## 5. Phase 3 — Test Hypotheses with Evidence

**Purpose:** Gather concrete evidence to confirm or refute each hypothesis.

### 5.1 Tasks

1. **For each hypothesis (in priority order):**
   - Identify the specific code to inspect.
   - Read the code carefully — do not skim.
   - Use `grep_search`, `code_search`, `read_file` to explore.

2. **Add logging or instrumentation if needed:**
   - Temporary debug output to trace values.
   - Remove after investigation (or mark for removal).

3. **Run the reproduction scenario:**
   - Observe the behavior with your instrumentation.
   - Compare to expected behavior.

4. **Document findings:**
   - What did you observe?
   - Does it confirm or refute the hypothesis?

5. **Leave breadcrumbs (see Section 7).**

### 5.2 Outputs

- For each hypothesis: confirmed, refuted, or inconclusive.
- Evidence supporting each conclusion.
- Breadcrumbs placed in code.

---

## 6. Phase 4 — Narrow Down to Root Cause

**Purpose:** Isolate the exact location and reason for the bug.

### 6.1 Tasks

1. **Follow the confirmed hypothesis:**
   - Trace deeper into the code.
   - Identify the exact line(s) causing the issue.

2. **Verify the root cause:**
   - Can you explain *why* this code produces the bug?
   - Is there a clear causal chain from root cause to symptom?

3. **Check for related issues:**
   - Does this root cause affect other code paths?
   - Are there similar bugs waiting to happen?

4. **Do NOT assume you have found the root cause until:**
   - You can explain the full causal chain.
   - The user has verified your findings (if possible).
   - Or you have strong evidence (test, log, trace).

### 6.2 Outputs

- Root cause description in your team file.
- Exact location (file, line, function).
- Causal chain from root cause to symptom.
- Confidence level and remaining uncertainties.

---

## 7. Breadcrumbs

**Breadcrumbs** are comments you leave in the code during investigation.

### 7.1 Purpose

- Help future teams continue the investigation.
- Warn future teams about dead ends.
- Document your reasoning for posterity.

### 7.2 Format

```
// TEAM_XXX BREADCRUMB: <status> - <description>
// <additional context if needed>
```

**Status values:**

- `SUSPECT` — This code is suspicious, may be the bug.
- `INVESTIGATING` — Currently being investigated.
- `RULED_OUT` — Investigated and confirmed NOT the bug.
- `CONFIRMED` — This is the root cause (or part of it).
- `DEAD_END` — This path was a goose chase, do not follow.

### 7.3 Examples

```
// TEAM_425 BREADCRUMB: SUSPECT - This null check might be inverted
// The condition checks for null but the error message says "not null"

// TEAM_425 BREADCRUMB: RULED_OUT - Checked this path, data is always valid here
// Traced all callers, none pass invalid data. See team file for details.

// TEAM_425 BREADCRUMB: DEAD_END - Spent 2 hours here, not the issue
// The race condition theory was wrong. The lock is always held.
// Do not re-investigate unless new evidence appears.

// TEAM_425 BREADCRUMB: CONFIRMED - Root cause found
// The off-by-one error here causes the buffer overflow in symptom X.
```

### 7.4 Rules

1. **Always include your TEAM_XXX** in breadcrumbs.
2. **Always include a status** so future teams know the state.
3. **Be specific** — vague breadcrumbs are useless.
4. **Update breadcrumbs** if your conclusion changes.
5. **Remove breadcrumbs** only when the bug is fully fixed and verified.

---

## 8. Phase 5 — Decision: Fix or Plan

**Purpose:** Decide whether to fix immediately or create a bugfix plan.

### 8.1 Decision Criteria

**Fix immediately if ALL of the following are true:**

- The fix is **≤ 5 Units of Work**.
- The fix is **≤ 50 lines of code**.
- The fix is **low risk** (no major architectural changes).
- You have **high confidence** in the root cause.
- The fix is **easily reversible**.

**Create a bugfix plan if ANY of the following are true:**

- The fix is **> 5 Units of Work**.
- The fix is **> 50 lines of code**.
- The fix is **high risk** (touches critical paths, data, or APIs).
- You have **medium or low confidence** in the root cause.
- The fix requires **coordination** across multiple areas.

### 8.2 If Fixing Immediately

1. Implement the fix.
2. Add regression test(s).
3. Run full test suite.
4. Update breadcrumbs to `CONFIRMED` or remove them.
5. Document the fix in your team file.
6. Complete the handoff checklist.

### 8.3 If Creating a Bugfix Plan

1. Run the `/make-a-bugfix-plan` workflow.
2. Include your investigation findings in Phase 1 (Understanding and Scoping).
3. Include your root cause analysis in Phase 2.
4. Leave breadcrumbs in place for the implementing team.
5. Link your team file to the bugfix plan.

---

## 9. Handoff Checklist

Before closing the investigation:

- [ ] Team file is updated with:
  - Symptom description.
  - Hypotheses tested.
  - Root cause (if found) or remaining uncertainties.
  - Decision: fixed or plan created.
- [ ] Breadcrumbs are placed in code with correct status.
- [ ] If fixed: tests pass, fix is documented.
- [ ] If plan created: plan is linked, breadcrumbs guide future teams.
- [ ] Any open questions are recorded in `.questions/`.

---

## 10. Questions and Uncertainties

If any ambiguity, unresolved assumption, or missing requirement remains at any time:

1. Create or update a **question file** under `.questions/`:
   - Include:
     - Bug reference.
     - Short summary of the uncertainty.
     - Current hypotheses or options.
     - Suggested decision or clarifications needed.

2. **Questions should focus on behaviors, not implementation details:**
   - Good: "Does this function ever receive null input in production?"
   - Good: "Is it acceptable for this error to be silent?"
   - Bad: "Should I use a try-catch or a Result type?"
   - Bad: "Should this be a separate function or inline?"

3. Pause any risky work that depends on the answer.

4. Continue only after the user has answered or refined the question.

This keeps bug investigation explicit, traceable, and safe for future teams to continue.
