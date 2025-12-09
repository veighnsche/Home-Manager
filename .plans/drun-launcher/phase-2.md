# Phase 2 — Design (Quickshell drun-style launcher)

## Proposed Solution (High-Level)
Implement a new Quickshell component (e.g. `AppLauncher.qml`) that:
- Uses `DesktopEntries.applications` as the source of installed apps.
- Wraps that list in a `ScriptModel` filtered by a `filterText` property.
- Displays a simple launcher window (`PopupWindow`/`FloatingWindow`) with:
  - A text input for search.
  - A list of matching applications with name (and optionally icon).
- Launches the chosen app via `DesktopEntry.execute()`.
- Is toggled from existing UI (e.g. a button in `TopBar.qml`).

## User-Facing Behavior
- **Open launcher:**
  - Click a launcher icon in the top bar (initial behavior).
  - (Optional later) Bind a compositor key (e.g. Super+Space) to toggle it.
- **Search:**
  - Typing in the search field filters apps by name (case-insensitive substring or prefix match to start).
- **Selection & Launch:**
  - Arrow keys or mouse move between entries.
  - Enter / click launches the selected app.
  - Launcher closes after launching.
- **Cancel:**
  - Pressing Escape or clicking outside closes the launcher without launching anything.

## System Behavior / Architecture
- **New component:** `AppLauncher.qml` (name can be adjusted):
  - Imports `Quickshell`, `QtQuick`, and `Quickshell.ScriptModel`.
  - Contains:
    - `DesktopEntries { id: desktopEntries }`
    - A `property string filterText: ""`.
    - `ScriptModel { id: filteredApps; values: desktopEntries.applications.values.filter(fn(entry) => matches(filterText, entry)) }`
    - A `PopupWindow` or `FloatingWindow` that:
      - Binds its `visible` to a property (exposed so `TopBar` / `shell.qml` can toggle it).
      - Holds a `Column` with a `TextField` + `ListView`.
      - `ListView.model: filteredApps` and a minimal delegate using `modelData.name`.
- **Integration:**
  - `shell.qml` instantiates `AppLauncher { id: appLauncher }` alongside `TopBar {}`.
  - `TopBar.qml` gets a launcher button that calls `appLauncher.open()` / toggles visibility.

## API Design (Internal to Config)
- **AppLauncher API (proposed):**
  - `property bool visible` — controls window visibility.
  - `function open()` — sets `visible = true` and focuses the search field.
  - `function close()` — sets `visible = false` and clears selection (optionally clears filter).

## Behavioral Decisions / Questions
- **Search matching strategy:**
  - Initial: case-insensitive substring on `DesktopEntry.name` (and optionally `genericName`).
  - Later refinement: add fuzzy scoring and sort by best match.
- **Sorting:**
  - Initial: keep the natural order of `DesktopEntries.applications`.
  - Later: add optional alphabetical or frequency-based sorting.
- **Icon handling:**
  - Initial: text-only list, or simple icon via standard Qt icon lookups.
  - Later: full theming and icon fallbacks.
- **Multi-monitor behavior:**
  - Initial: show on a single, chosen screen (e.g. primary).
  - Later: refine to center on focused screen or follow pointer.
- **Keyboard focus:**
  - Ensure the search field automatically gets focus on open.
  - Ensure Esc/Enter behavior is intuitive.

## Design Alternatives Considered
1. **Use external drun launcher (rofi/wofi/fuzzel) only:**
   - Pros: simple, battle-tested, good features out of the box.
   - Cons: not visually integrated into Quickshell; requires external tools and compositor keybinds.

2. **Native Quickshell launcher via `DesktopEntries` (chosen):
   - Pros: integrated, themeable, entirely within Quickshell code; leverages documented APIs.
   - Cons: need to implement filtering UI and behavior ourselves.

## Open Questions for the User
- Do you prefer the launcher window centered on screen or at a fixed position (e.g. under the top bar)?
- Should the search filter also match `genericName` and `keywords`, or just the human-readable name?
- Is text-only acceptable for the first iteration, or do you want icons from day one?
- Which keybinding (if any) should we plan to wire from the compositor to open the launcher?

## Next Steps
- Once the above questions are answered, finalize the small AppLauncher API and layout.
- Move to Phase 3 to implement `AppLauncher.qml` and integrate it with `shell.qml` and `TopBar.qml`.
