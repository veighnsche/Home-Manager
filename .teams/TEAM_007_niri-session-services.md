# TEAM_007: niri Session Services Implementation

**Status:** Planning  
**Date:** 2025-12-08  
**Directive:** Implement session-level services for niri following System AI handoff

---

## Objective

Implement the following for niri sessions:
1. Polkit authentication agent
2. Network tray applet (nm-applet)
3. Secret agent (GNOME Keyring) for WiFi credential storage

---

## Planning Artifacts

All planning documents are located in:
```
.plans/niri-session-services/
```

---

## Progress Log

| Date | Action | Status |
|------|--------|--------|
| 2025-12-08 | Received directive from System AI | ✅ |
| 2025-12-08 | Created refactor plan | ✅ Complete |
| 2025-12-08 | Phase 1 — Discovery and Safeguards | ✅ Complete |
| 2025-12-08 | Phase 2 — Structural Extraction (planned) | ✅ Complete |
| 2025-12-08 | Phase 3 — Implementation (planned) | ✅ Complete |
| 2025-12-08 | Phase 4 — Verification (planned) | ✅ Complete |
| 2025-12-08 | Cleaned up obsolete TEAM_005 plan | ✅ Complete |
| 2025-12-08 | Plan reviewed by TEAM_008 | ✅ Approved |
| 2025-12-08 | Implementation complete | ✅ Complete |

---

## Handoff Checklist

- [x] Project builds cleanly (`nix flake check` passes)
- [x] Build includes new packages (`polkit-gnome-agent`, `networkmanagerapplet`, `gnome-keyring`)
- [ ] WiFi connects without KDE running (requires manual test after `hm`)
- [ ] Polkit prompts appear for privileged operations (requires manual test)
- [ ] Network tray icon is visible (requires manual test)
- [x] Team file updated with final status

## Files Modified

| File | Change |
|------|--------|
| `wlroots.nix` | Added polkit-gnome-agent wrapper, networkmanagerapplet, gnome-keyring service |
| `vince/.config/niri/config.kdl` | Added spawn-at-startup for polkit-gnome-agent and nm-applet |
