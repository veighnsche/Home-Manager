# TEAM_001 — Feature: Quickshell drun-style launcher

## Summary
Implement a basic application launcher inside Quickshell, similar to `rofi -show drun`:
- Uses Quickshell’s `DesktopEntries` to list installed `.desktop` apps.
- Provides a simple search box + list UI.
- Launches the selected app via `DesktopEntry.execute()`.
- Starts minimal, but is designed for later refinements (sorting, better search, theming, keybindings).

## Scope
- Only Quickshell-side UI and behavior for launching apps.
- No compositor config changes beyond possibly binding a key to toggle the launcher window.
- No complex ranking or MRU history in the first iteration.

## Links
- Planning root: `.plans/drun-launcher/`
- Phase 1 (Discovery): `.plans/drun-launcher/phase-1.md`
- Phase 2 (Design): `.plans/drun-launcher/phase-2.md`
- Phase 3 (Implementation): `.plans/drun-launcher/phase-3.md`
- Phase 4 (Integration & Testing): `.plans/drun-launcher/phase-4.md`
- Phase 5 (Polish & Docs): `.plans/drun-launcher/phase-5.md`

## Status
- Planning: complete
- Implementation: complete (TEAM_012)
- Testing: pending manual verification

## Notes
- Code lives under `vince/.config/quickshell`.
- Aim for a minimal but extensible launcher that can be iterated on without breaking changes.
