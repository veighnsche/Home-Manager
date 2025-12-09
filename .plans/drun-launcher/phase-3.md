# Phase 3 — Implementation (Quickshell drun-style launcher)

## Goals
- Add a minimal, working app launcher component to the Quickshell config.
- Integrate it with `shell.qml` and `TopBar.qml`.
- Keep the implementation small but structured for later refinements.

## Planned Tasks
1. **Create AppLauncher component**
   - Add `vince/.config/quickshell/AppLauncher.qml`.
   - Implement `DesktopEntries` + `ScriptModel` + basic `PopupWindow` UI.
   - Implement `open()` / `close()` helpers and a `visible` property.

2. **Wire launcher into shell root**
   - Update `vince/.config/quickshell/shell.qml` to instantiate `AppLauncher { id: appLauncher }`.
   - Ensure it does not interfere with existing `TopBar {}` behavior.

3. **Add trigger in TopBar**
   - Update `TopBar.qml` to add a simple launcher button/icon.
   - On click, call `appLauncher.open()`.

4. **Basic UX behaviors**
   - Ensure search field auto-focuses when launcher opens.
   - Ensure Enter launches the selected entry and closes the launcher.
   - Ensure Escape cancels and closes the launcher.

## Non-Goals for First Iteration
- Advanced fuzzy matching or ranking.
- MRU or usage-based ordering.
- Full-blown theming.
- Complex multi-monitor logic.

## Outputs
- New QML file: `vince/.config/quickshell/AppLauncher.qml`.
- Updated: `vince/.config/quickshell/shell.qml`.
- Updated: `vince/.config/quickshell/TopBar.qml`.
