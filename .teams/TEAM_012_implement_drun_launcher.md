# TEAM_012 — Implement: drun-launcher

## Summary
Implementing the Quickshell drun-style launcher per `.plans/drun-launcher/`.

## Status
- Complete

## Design Decisions (defaults for first iteration)
Per phase-2.md "Non-Goals for First Iteration", using sensible defaults:
- **Trigger:** Top-bar button only (no compositor keybind yet)
- **Search:** Case-insensitive substring on `name` only
- **Icons:** Text-only for now
- **Position:** Centered on screen (FloatingWindow)
- **Multi-monitor:** Primary screen only (HDMI-A-1 per existing TopBar)

## Implementation Plan
1. Create `AppLauncher.qml` with:
   - `DesktopEntries` for app list
   - `ScriptModel` for filtering
   - `FloatingWindow` for overlay UI
   - `open()`/`close()` API
2. Update `shell.qml` to instantiate AppLauncher
3. Add launcher button to `TopBar.qml`

## Progress
- [x] Create AppLauncher.qml
- [x] Update shell.qml
- [x] Update TopBar.qml
- [ ] Manual smoke test (requires user)

## Files Changed
- `vince/.config/quickshell/AppLauncher.qml` — NEW
- `vince/.config/quickshell/shell.qml` — Added AppLauncher instantiation
- `vince/.config/quickshell/TopBar.qml` — Added launcher property and button

## Notes
- Used `DesktopEntries.applications.values` per Quickshell docs (ScriptModel tip)
- Home-Manager build succeeds

## Handoff
- Implementation complete
- Manual testing required: reload Quickshell and click the ⊞ button in top bar
- Future work: compositor keybind, icons, fuzzy search (see phase-5.md)
