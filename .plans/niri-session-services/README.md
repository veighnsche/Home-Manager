# niri Session Services Implementation

**Team:** TEAM_007  
**Created:** 2025-12-08  
**Status:** Planning Complete — Ready for Implementation

---

## Overview

This refactor implements session-level services for niri to enable independent operation without KDE Plasma.

### Problem
- WiFi doesn't work in niri (credentials stored in KWallet, inaccessible without KDE)
- No polkit prompts for privileged operations
- No network tray icon

### Solution
- Add polkit-gnome authentication agent
- Add nm-applet network tray
- Add GNOME Keyring for secret storage

---

## Phase Summary

| Phase | Description | Status |
|-------|-------------|--------|
| [Phase 1](phase-1.md) | Discovery and Safeguards | ✅ Complete |
| [Phase 2](phase-2.md) | Structural Extraction | 📋 Ready |
| [Phase 3](phase-3.md) | Implementation | 📋 Ready |
| [Phase 4](phase-4.md) | Verification and Cleanup | ⏳ Pending |

---

## Files to Modify

| File | Change |
|------|--------|
| `wlroots.nix` | Add packages and gnome-keyring service |
| `vince/.config/niri/config.kdl` | Add spawn-at-startup entries |

---

## Quick Implementation Guide

### Step 1: Update `wlroots.nix`

Add polkit-gnome-agent wrapper:
```nix
polkit-gnome-agent = pkgs.writeShellScriptBin "polkit-gnome-agent" ''
  exec ${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1 "$@"
'';
```

Add to packages:
```nix
home.packages = with pkgs; [
  # ... existing ...
  polkit-gnome-agent
  networkmanagerapplet
];
```

Add service:
```nix
services.gnome-keyring = {
  enable = true;
  components = [ "secrets" ];
};
```

### Step 2: Update `config.kdl`

Add after `spawn-at-startup "waybar"`:
```kdl
spawn-at-startup "polkit-gnome-agent"
spawn-at-startup "nm-applet"
```

### Step 3: Apply and Test

```bash
hm  # Apply configuration
# Then log into niri and verify:
pkexec echo "test"  # Should show auth dialog
pgrep nm-applet     # Should be running
```

---

## Rollback

```bash
git checkout HEAD -- wlroots.nix vince/.config/niri/config.kdl
hm
```

---

## Related Documents

- Team file: `.teams/TEAM_007_niri-session-services.md`
- System AI audit: (external, from TEAM_007 System AI)
- Previous audit: `.teams/TEAM_006_session-scope-audit.md`
