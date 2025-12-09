# Phase 1 — Discovery (Quickshell drun-style launcher)

## Feature Summary
A basic Quickshell-based application launcher that behaves like `rofi -show drun`:
- Shows installed graphical applications from `.desktop` files.
- Lets the user search by name and launch an app.
- Runs as a Quickshell window/overlay, integrated with the existing `shell.qml` / `TopBar.qml`.

## Problem Statement
Currently there is no integrated app launcher inside this Quickshell config. Users must rely on external launchers or compositor keybinds. We want a native, minimal launcher that:
- Fits visually and behaviorally into the Quickshell-based desktop.
- Provides a straightforward path to later refinements (sorting, fuzzy search, theming).

## Who Benefits
- The primary user of this Home-Manager/Quickshell setup.
- Any future configs cloned or adapted from this repo.

## Success Criteria
- A new Quickshell component can be toggled (e.g. from the top bar) to open a launcher window.
- The launcher lists installed apps based on `DesktopEntries.applications`.
- Typing into a search field filters the list by app name.
- Pressing Enter or clicking an entry launches the correct application via `DesktopEntry.execute()`.
- The launcher closes after launching an app or when cancelled.

## Current State Analysis
- Quickshell config root: `vince/.config/quickshell/`.
  - `shell.qml` defines a `Scope` that instantiates `TopBar {}`.
  - `TopBar.qml` defines a panel with clock and system widgets; no launcher yet.
- No existing DesktopEntries- or launcher-related QML components.
- Likely external launchers (e.g. rofi/wofi/fuzzel) may exist but are not wired through Quickshell.

## Codebase Reconnaissance
Likely touched areas:
- `vince/.config/quickshell/shell.qml` — to instantiate the new launcher component.
- `vince/.config/quickshell/TopBar.qml` — to add a button/icon or hook that toggles the launcher.
- New file(s), e.g. `vince/.config/quickshell/AppLauncher.qml` or a similar name.
- Possibly `Widgets/` if we factor out reusable UI pieces.

Relevant Quickshell APIs (from docs):
- `Quickshell.DesktopEntries` and `DesktopEntries.applications`.
- `Quickshell.DesktopEntry` and `DesktopEntry.execute()`.
- `Quickshell.ScriptModel` for filtered models.
- `PopupWindow` / `FloatingWindow` / `QsWindow` for launcher UI.

## Constraints & Considerations
- **Performance:** Launcher should open quickly and not block the main shell.
- **Dependencies:** Prefer using built-in Quickshell types (`DesktopEntries`, `ScriptModel`) over external binaries for the primary UI.
- **Behavioral Baseline (Rule 4):**
  - No existing tests or golden outputs for the launcher area; adding this feature should not break existing panel widgets.
  - Manual baseline: current behavior is “no launcher”; after this feature, ensure non-launcher behavior (clock, system widgets) remains unchanged.
- **UX:**
  - Start with keyboard + mouse support that feels similar to drun (type to filter, arrow keys / click to select, Enter to launch).
  - Keep layout simple; advanced theming can come later.

## Open Questions (to refine later)
- Should the launcher be opened only via a top-bar button, or also via a compositor keybinding?
- Should we support fuzzy matching for search in the initial version, or just prefix/substring?
- Do we want to hide certain system/NoDisplay entries beyond what `DesktopEntries.applications` already filters?
- How should multi-monitor setups behave (always center on focused screen, primary screen only, etc.)?
