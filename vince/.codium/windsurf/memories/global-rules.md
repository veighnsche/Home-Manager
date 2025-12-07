## **Rule 0 — Quality Over Speed**

**Take the correct architectural path, never the shortcut.**

* Prefer clean designs over quick fixes
* Avoid wrappers, shims, indirection unless truly necessary
* Leave the codebase better than you found it
* Future teams inherit your decisions — choose debt-free solutions

**Good > Fast. Always.**

---

## **Rule 1 — Single Source of Truth (SSOT)**

Every project must define one canonical location for:

* Plans
* Architecture documents
* Team logs
* Questions
* Phase definitions

**Rule:** All planning and coordination must happen in that SSOT location.
Never fragment planning across multiple places.

---

## **Rule 2 — Team Registration & Identity**

Every distinct AI conversation = one team.

### **Your Team ID**

1. Determine highest existing team number
2. Your number = highest + 1
3. Team ID is permanent for the lifetime of the conversation

### **Your Team File**

Create a log file:

```
.teams/TEAM_XXX_<summary>.md
```

### **Code Comments**

When modifying code:

```
// TEAM_XXX: Reason for change
```

This ensures long-term traceability.

---

## **Rule 3 — Before Starting Work**

Every team must:

* Read the main project overview
* Read the current active phase
* Check recent team logs
* Check open questions
* Claim a team number and create a team file
* Ensure all tests pass before making changes
* Only then begin implementation

---

## **Rule 4 — Behavioral Regression Protection**

Every project must define baseline outputs for behavior-critical logic:

* Snapshots
* Golden files
* Deterministic logs
* Fixtures
* Reference outputs

### **Before modifying critical logic:**

1. Run baseline tests → they must pass
2. Make changes
3. Re-run baseline tests
4. If results differ → *this is a regression* → fix it

**Never modify baseline data unless the USER explicitly approves.**

---

## **Rule 5 — Breaking Changes > Fragile Compatibility**

Favor clean breaks over compatibility hacks.

### **Workflow**

* Move or rename the type/function
* Let the compiler fail
* Fix import sites one by one
* Remove temporary re-exports or legacy names

If you are writing adapters to “keep old code working,” stop — fix the actual sites.

---

## **Rule 6 — No Dead Code**

Remove:

* Unused functions
* Unused modules
* Commented-out code
* “Kept for reference” logic (git history exists for this)

**The repository must contain only living, active code.**

---

## **Rule 7 — Modular Refactoring**

When splitting large modules:

* Each module owns its own state
* Keep fields private — expose intentional APIs
* Avoid deep relative imports
* Keep file sizes human-readable

  * < 1000 lines preferred
  * < 500 ideal
* Organize by responsibility, not convenience

---

## **Rule 8 — Ask Questions Early**

If **any** of the following occur:

* A decision is ambiguous
* Requirements conflict
* Plans seem incomplete
* Something feels “off”

Create a question file:

```
.questions/TEAM_XXX_*
```

Ask the USER.
**Never guess on major decisions.**

---

## **Rule 9 — Maximize Context Window**

While the team still remembers the state:

* Perform as much aligned work as possible
* Don’t stop mid-task if more progress is obvious
* Minimize context re-initialization for next teams

If a task grows too large, split it into sub-tasks inside the team directory.

---

## **Rule 10 — Before Finishing**

Every team must:

* Update their team file with progress
* Ensure project builds
* Ensure all tests pass
* Ensure baseline/golden tests pass
* Document remaining problems or blockers
* Write handoff notes

### **Handoff Checklist**

* [ ] Project builds cleanly
* [ ] All tests pass
* [ ] Behavioral regression tests pass
* [ ] Team file updated
* [ ] Remaining TODOs documented

---

## **Rule 11 — TODO Tracking**

Any incomplete work must be recorded:

### **In Code**

```
TODO(TEAM_XXX): what is missing
```

### **In Global TODO List**

Add items with:

* file
* line
* description

This guarantees future teams know what remains.

---

## **Rule 12 — Universal Quick Reference**

| Concept              | Description                                      |
| -------------------- | ------------------------------------------------ |
| **SSOT**             | The single place where planning/logs/phases live |
| **Team Files**       | `.teams/TEAM_XXX_*`                              |
| **Questions**        | `.questions/TEAM_XXX_*`                          |
| **Current Phase**    | Defines what teams should be working on          |
| **Regression Tests** | Any project-defined baseline outputs             |
| **TODO.md**          | Global tracking of incomplete tasks              |
