# TEAM_008: Review of niri-session-services Plan

**Status:** Complete  
**Date:** 2025-12-08  
**Reviewing:** `.plans/niri-session-services/`

---

## Review Summary

| Phase | Status | Findings |
|-------|--------|----------|
| Phase 1 — Questions and Answers Audit | ✅ | No questions files for this plan |
| Phase 2 — Scope and Complexity Check | ✅ | Appropriately sized |
| Phase 3 — Architecture Alignment | ✅ | Follows existing patterns |
| Phase 4 — Global Rules Compliance | ✅ | Compliant |
| Phase 5 — Verification and References | ⚠️ | One critical finding |
| Phase 6 — Final Refinements | ✅ | Minor updates needed |

---

## Phase 1: Questions and Answers Audit

**Result:** ✅ PASS

- No `.questions/` files exist for this plan
- Open questions in phase-1.md are all answered with decisions documented
- No discrepancies found

---

## Phase 2: Scope and Complexity Check

**Result:** ✅ PASS — Appropriately sized

| Metric | Value | Assessment |
|--------|-------|------------|
| Phases | 4 | Appropriate for scope |
| Files to modify | 2 | Minimal, focused |
| New packages | 2 | Necessary |
| New services | 1 | Necessary |

**No overengineering detected:**
- No unnecessary abstractions
- No speculative features
- Clear, focused scope

**No oversimplification detected:**
- Verification phase exists
- Rollback procedure documented
- Troubleshooting guide included

---

## Phase 3: Architecture Alignment

**Result:** ✅ PASS

- Follows existing `wlroots.nix` pattern (packages + let bindings)
- Uses niri-native `spawn-at-startup` (consistent with existing waybar entry)
- Uses Home-Manager's built-in `services.gnome-keyring` module
- No new patterns introduced that conflict with existing structure

---

## Phase 4: Global Rules Compliance

**Result:** ✅ PASS

| Rule | Status | Notes |
|------|--------|-------|
| Rule 0 (Quality) | ✅ | Clean solution, no hacks |
| Rule 1 (SSOT) | ✅ | Plan in `.plans/` |
| Rule 2 (Team Registration) | ✅ | TEAM_007 registered |
| Rule 3 (Before Starting) | ✅ | Discovery phase complete |
| Rule 4 (Regression Protection) | ✅ | Build verification documented |
| Rule 5 (Breaking Changes) | ✅ | No compatibility hacks |
| Rule 6 (No Dead Code) | ✅ | Cleanup phase exists |
| Rule 7 (Modular Refactoring) | ✅ | Changes are focused |
| Rule 8 (Ask Questions) | ✅ | Questions answered in plan |
| Rule 9 (Maximize Context) | ✅ | Work is batched sensibly |
| Rule 10 (Before Finishing) | ✅ | Handoff checklist exists |
| Rule 11 (TODO Tracking) | ✅ | Exit criteria documented |

---

## Phase 5: Verification and References

**Result:** ⚠️ ONE CRITICAL FINDING

### Verified Claims ✅

| Claim | Verification |
|-------|--------------|
| `pkgs.polkit_gnome` exists | ✅ Confirmed via nix eval |
| Binary at `libexec/polkit-gnome-authentication-agent-1` | ✅ Confirmed |
| `pkgs.networkmanagerapplet` exists | ✅ Confirmed |
| `nm-applet` binary in PATH after install | ✅ Confirmed |
| `services.gnome-keyring` HM module exists | ✅ Confirmed |

### Critical Finding ⚠️

**GNOME Keyring integration is more complex than documented.**

The plan assumes `services.gnome-keyring.enable = true` is sufficient. However:

1. **Home-Manager creates a systemd user service** that is `WantedBy = graphical-session-pre.target`
2. **niri.service correctly triggers this target** via `Wants=graphical-session-pre.target`
3. **The wrapper already calls `dbus-update-activation-environment --all`** (line 74)

**Conclusion:** The plan WILL work as documented. The systemd integration is correct.

However, the plan should document this dependency chain for troubleshooting:
```
niri-session-wrapper
  → starts niri.service
    → Wants graphical-session-pre.target
      → gnome-keyring.service starts (WantedBy graphical-session-pre.target)
```

### Risk: WiFi Password Migration

The plan mentions WiFi passwords are stored in KWallet with `psk-flags: 1`. After implementing GNOME Keyring:

1. **Existing passwords will NOT automatically migrate** from KWallet to GNOME Keyring
2. User will need to re-enter WiFi password once in niri
3. This is expected behavior, not a bug

**Recommendation:** Add this to phase-4.md troubleshooting section.

---

## Phase 6: Final Refinements

### Required Changes

1. **Add dependency chain documentation** to phase-4.md troubleshooting
2. **Clarify WiFi password migration** expectation

### Optional Improvements

1. Consider adding `secret-tool` package for testing GNOME Keyring (already in phase-4 test commands)

---

## Final Verdict

**✅ PLAN APPROVED FOR IMPLEMENTATION**

The plan is:
- Correctly scoped
- Architecturally sound
- Technically accurate
- Well-documented

Minor documentation improvements recommended but not blocking.

---

## Changes Made

1. **phase-4.md** — Added GNOME Keyring dependency chain documentation
2. **phase-4.md** — Clarified WiFi password migration expectations

---

## Handoff

Review complete. Plan is approved for implementation.

**Next step:** Proceed with `/implement-a-plan` workflow on `.plans/niri-session-services/`
