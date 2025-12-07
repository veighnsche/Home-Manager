---
description: review an implementation
auto_execution_mode: 3
---

## 0. Purpose

This workflow is for **reviewing an implementation** against its plan.

The goal is to determine:

1. **Is the implementation complete or still WIP?**
2. **Are there gaps between the plan and the implementation?**
3. **Are there overlooked TODOs, stubs, or incomplete work?**
4. **Are there architectural issues that need early intervention?**
5. **Does the development need to change direction?**

---

## 1. Pre-Review Checklist

Before reviewing:

### 1.1 Register Your Team (Rule 2)

1. **Find the highest existing team number:**
   ```bash
   grep -r "TEAM_" .teams/ --include="*.md" | grep -oE "TEAM_[0-9]+" | sort -t_ -k2 -n | tail -1
   ```

2. **Your team number = highest + 1.**

3. **Create your team file:**
   ```
   .teams/TEAM_XXX_review_impl_<summary>.md
   ```

4. **Your team ID is permanent** for this entire conversation.

### 1.2 Locate the Plan

- Find the plan in the project's SSOT.
- Read all phase files, step files, and UoW files.
- Note which UoWs are marked as complete vs. pending.

### 1.3 Locate the Implementation

- Identify which code was written for this plan.
- Check recent commits, team files, or PR descriptions.

### 1.4 Read Recent Team Logs

- What did previous teams report?
- Are there known blockers or issues?

Only then start the review.

---

## 2. Review Structure

The review follows a **diagnostic approach**:

1. **Phase 1 – Determine Implementation Status**
2. **Phase 2 – Gap Analysis (Plan vs. Reality)**
3. **Phase 3 – Code Quality Scan**
4. **Phase 4 – Architectural Assessment**
5. **Phase 5 – Direction Check**
6. **Phase 6 – Document Findings and Recommendations**

---

## 3. Phase 1 — Determine Implementation Status

**Purpose:** Figure out if the implementation is complete, WIP, or abandoned.

### 3.1 Status Indicators

**Signs of COMPLETE (intended to be done):**

- Team file says "implementation complete" or similar.
- All UoWs in the plan are marked done.
- PR is merged or ready for review.
- No active work in progress.

**Signs of WIP (work in progress):**

- Team file shows ongoing work.
- Some UoWs are marked in-progress or pending.
- Recent commits are still being made.
- Active conversation or questions.

**Signs of ABANDONED or STALLED:**

- No recent activity (days/weeks).
- Team file ends abruptly without handoff.
- Open questions with no answers.
- Incomplete work with no TODO tracking.

### 3.2 Tasks

1. **Read the team file(s)** for this implementation.
   - What is the reported status?
   - When was the last update?

2. **Check the plan files:**
   - Which UoWs are marked complete?
   - Which are pending or blocked?

3. **Check git history** (if available):
   - When was the last commit?
   - Is there active development?

4. **Make a determination:**
   - COMPLETE (intended to be done)
   - WIP (actively being worked on)
   - STALLED (no recent progress, unclear status)
   - ABANDONED (clearly stopped, no handoff)

### 3.3 Outputs

- Status determination with evidence.
- Timeline of recent activity.

---

## 4. Phase 2 — Gap Analysis (Plan vs. Reality)

**Purpose:** Compare what the plan said to do vs. what was actually done.

### 4.1 Tasks

1. **For each UoW in the plan:**
   - Was it implemented?
   - Was it implemented correctly (per the spec)?
   - Was it implemented completely?

2. **Check for missing pieces:**
   - Features described but not implemented.
   - Edge cases mentioned but not handled.
   - Tests specified but not written.

3. **Check for extra pieces:**
   - Code that wasn't in the plan.
   - Scope creep or unplanned additions.
   - "While I was here" changes.

4. **Check behavioral contracts:**
   - Does the implementation match the behavioral decisions from the design phase?
   - Are all edge cases handled as specified?

### 4.2 Outputs

- List of implemented UoWs (with correctness assessment).
- List of missing UoWs or incomplete work.
- List of unplanned additions.
- Behavioral contract compliance status.

---

## 5. Phase 3 — Code Quality Scan

**Purpose:** Find overlooked TODOs, stubs, and incomplete work.

### 5.1 Search for Incomplete Work

Run these searches in the implementation code:

```bash
# Find TODOs
grep -rn "TODO" --include="*.ts" --include="*.tsx" --include="*.js" --include="*.py" --include="*.rs"

# Find FIXMEs
grep -rn "FIXME" --include="*.ts" --include="*.tsx" --include="*.js" --include="*.py" --include="*.rs"

# Find stubs and placeholders
grep -rn "stub\|placeholder\|not implemented\|throw.*NotImplemented" --include="*.ts" --include="*.tsx" --include="*.js" --include="*.py" --include="*.rs"

# Find breadcrumbs from investigation
grep -rn "BREADCRUMB" --include="*.ts" --include="*.tsx" --include="*.js" --include="*.py" --include="*.rs"

# Find incomplete error handling
grep -rn "// ignore\|catch.*{}\|catch.*{ }" --include="*.ts" --include="*.tsx" --include="*.js" --include="*.py" --include="*.rs"
```

### 5.2 Categorize Findings

For each TODO/stub/incomplete item:

1. **Is it tracked?**
   - In the team file?
   - In the global TODO list?
   - In the plan as a pending UoW?

2. **Is it blocking?**
   - Does other code depend on this?
   - Will the feature work without it?

3. **Is it intentional?**
   - Planned for a future phase?
   - Out of scope for this plan?
   - Or just forgotten?

### 5.3 Check for Silent Regressions

Look for patterns that hide bugs:

```bash
# Empty catch blocks
grep -rn "catch.*{[ ]*}" --include="*.ts" --include="*.tsx" --include="*.js"

# Swallowed errors
grep -rn "catch.*console.log\|catch.*console.error" --include="*.ts" --include="*.tsx" --include="*.js"

# Disabled tests
grep -rn "skip\|xdescribe\|xit\|@Ignore\|@Disabled" --include="*.test.*" --include="*.spec.*"
```

### 5.4 Outputs

- List of all TODOs with tracking status.
- List of stubs and placeholders.
- List of potential silent regressions.
- List of untracked incomplete work (needs documentation).

---

## 6. Phase 4 — Architectural Assessment

**Purpose:** Identify architectural issues early before they become expensive.

### 6.1 Check Against Global Rules

- [ ] **Rule 0 (Quality > Speed):** Are there shortcuts or hacks?
- [ ] **Rule 5 (Breaking Changes):** Are there compatibility shims or `fooV2` functions?
- [ ] **Rule 6 (No Dead Code):** Is there unused code left behind?
- [ ] **Rule 7 (Modular Refactoring):** Are modules well-scoped? File sizes reasonable?

### 6.2 Pattern Analysis

Look for architectural red flags:

**Duplication:**
- Is there copy-pasted code?
- Are there parallel implementations of the same thing?
- Are there `V2` or `_new` or `_fixed` suffixes?

**Coupling:**
- Are modules tightly coupled when they shouldn't be?
- Are there circular dependencies?
- Are there god objects or god modules?

**Abstraction:**
- Is there over-engineering (unnecessary abstractions)?
- Is there under-engineering (missing abstractions)?
- Are responsibilities clearly separated?

**Consistency:**
- Does the new code follow existing patterns?
- Are naming conventions consistent?
- Is error handling consistent?

### 6.3 Performance and Scalability

- Are there obvious performance issues?
- Are there N+1 queries or similar patterns?
- Will this scale with expected usage?

### 6.4 Outputs

- List of architectural concerns.
- Severity assessment (critical/important/minor).
- Suggested remediation for each concern.

---

## 7. Phase 5 — Direction Check

**Purpose:** Determine if the development needs to change direction.

### 7.1 Questions to Answer

1. **Is the current approach working?**
   - Is progress being made?
   - Are blockers being resolved?
   - Is the code quality acceptable?

2. **Is the plan still valid?**
   - Have requirements changed?
   - Have constraints changed?
   - Is the design still appropriate?

3. **Are there fundamental issues?**
   - Wrong technology choice?
   - Wrong architectural approach?
   - Misunderstood requirements?

4. **Should we continue, pivot, or stop?**
   - **Continue:** Plan is good, implementation is on track.
   - **Pivot:** Plan needs significant changes, but goal is still valid.
   - **Stop:** Fundamental issues require re-planning from scratch.

### 7.2 Warning Signs That Direction Change is Needed

- Implementation is fighting the architecture.
- Every change causes unexpected breakage.
- The "simple" fix keeps getting more complex.
- Tests are being disabled to make things "work."
- Workarounds are accumulating.
- The team file shows repeated failed attempts.

### 7.3 Outputs

- Direction recommendation: CONTINUE / PIVOT / STOP.
- If PIVOT: what needs to change and why.
- If STOP: what fundamental issues need to be resolved.

---

## 8. Phase 6 — Document Findings and Recommendations

**Purpose:** Create actionable output for the implementation team.

### 8.1 Structure Your Report

In your team file, document:

**1. Implementation Status**
- Current status: COMPLETE / WIP / STALLED / ABANDONED
- Evidence for this determination.

**2. Gap Analysis Summary**
- UoWs completed: X of Y
- Missing or incomplete work (list).
- Unplanned additions (list).

**3. Untracked Work**
- TODOs that need to be added to the plan or TODO list.
- Stubs that need implementation.
- Incomplete error handling that needs fixing.

**4. Architectural Concerns**
- Critical issues (must fix before continuing).
- Important issues (should fix soon).
- Minor issues (fix when convenient).

**5. Direction Recommendation**
- CONTINUE / PIVOT / STOP
- Rationale.
- Next steps.

**6. Action Items for Implementation Team**
- Prioritized list of what to do next.
- Which UoWs to complete.
- Which issues to address.

### 8.2 If Status is "COMPLETE" but Issues Found

If the implementation is marked complete but you found:

- **Untracked TODOs:** Document them for the implementation team.
- **Missing UoWs:** Flag as incomplete, not complete.
- **Architectural issues:** Recommend follow-up work.
- **Silent regressions:** Flag as critical, require immediate fix.

### 8.3 If Status is WIP

If the implementation is ongoing:

- **Gaps:** Note them but don't alarm — they may be planned.
- **Architectural issues:** Flag early so they can be addressed.
- **Direction concerns:** Raise them now before more work is done.

---

## 9. Handoff Checklist

Before closing the review:

- [ ] Status determination is documented with evidence.
- [ ] Gap analysis is complete (plan vs. reality).
- [ ] All TODOs/stubs are catalogued and tracked.
- [ ] Architectural concerns are documented with severity.
- [ ] Direction recommendation is clear.
- [ ] Action items are prioritized for the implementation team.
- [ ] Team file is complete and ready for handoff.

---

## 10. Quick Reference: What to Look For

| Category | Look For |
|----------|----------|
| **Status** | Team file updates, UoW completion, recent commits |
| **Gaps** | Missing UoWs, unhandled edge cases, missing tests |
| **TODOs** | `TODO`, `FIXME`, `stub`, `placeholder`, `not implemented` |
| **Regressions** | Empty catch blocks, disabled tests, swallowed errors |
| **Architecture** | Duplication, `V2` functions, tight coupling, god objects |
| **Direction** | Fighting the architecture, accumulating workarounds, repeated failures |

---

## 11. Questions and Uncertainties

If any ambiguity, unresolved assumption, or missing requirement remains at any time:

1. Create or update a **question file** under `.questions/`:
   - Include:
     - Implementation reference.
     - Short summary of the uncertainty.
     - Current hypotheses or options.
     - Suggested decision or clarifications needed.

2. **Questions should focus on behaviors, not implementation details:**
   - Good: "Is this feature supposed to handle the empty case?"
   - Good: "Was this TODO intentionally left for a future phase?"
   - Bad: "Should this use async/await or promises?"
   - Bad: "Should this be refactored into smaller functions?"

3. Pause any risky work that depends on the answer.

4. Continue only after the user has answered or refined the question.

This keeps implementation reviews explicit, traceable, and safe for future teams to continue.
