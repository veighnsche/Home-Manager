# Phase 4 — Integration and Testing (Quickshell drun-style launcher)

## Goals
- Verify that the launcher works reliably in normal use.
- Ensure no regressions to existing Quickshell behavior (top bar, widgets).

## Test Plan (Manual for now)
1. **Smoke tests**
   - Start Quickshell with the updated config.
   - Open the launcher via the top-bar button.
   - Type a few letters of a known app; confirm list filters correctly.
   - Launch the app; confirm it starts and the launcher closes.

2. **Edge cases**
   - Empty search: list shows all apps.
   - Search with no matches: list empty; no crash.
   - Rapid open/close: no visual glitches or errors.

3. **Regression checks**
   - Confirm clock and system widgets still behave as before.
   - Confirm Quickshell logs show no new errors/warnings related to the launcher.

## Baseline / Regression Protection (Rule 4)
- Define a minimal behavioral baseline:
  - Screens: top bar appears correctly; system widgets render; no launcher yet.
- After change:
  - All of the above still hold, plus the launcher behaviors pass the test plan.

## Outputs
- Informal checklist in this file, optionally expanded into automated tests later if the project adds a testing harness.
