# TEAM_009: WiFi Password Persistence Fix

**Status:** Complete  
**Date:** 2025-12-08  
**Issue:** WiFi password not persisting across reboots in niri session

---

## Problem Statement

User reports:
- WiFi works in niri without KDE
- After reboot, WiFi password is requested again
- Expected: Enter password once, saved forever

---

## Root Cause

**GNOME Keyring is not being unlocked at login.**

The Home-Manager `services.gnome-keyring` module starts the daemon, but:
1. The keyring database is **locked** because PAM didn't unlock it
2. nm-applet can't store secrets to a locked keyring
3. Secrets are lost on reboot

### Why it worked in KDE
KDE uses KWallet, which is unlocked by Plasma's session startup. GNOME Keyring requires PAM integration.

---

## Solution

Add to `/etc/nixos/configuration.nix`:

```nix
# Enable GNOME Keyring system service
services.gnome.gnome-keyring.enable = true;

# Unlock keyring at SDDM login
security.pam.services.sddm.enableGnomeKeyring = true;
```

Then rebuild:
```bash
sudo nixos-rebuild switch
```

**Note:** The keyring password must match your login password. If they differ, you'll get a prompt to unlock the keyring after login.

---

## Progress Log

| Date | Action | Status |
|------|--------|--------|
| 2025-12-08 | Created team file | ✅ |
| 2025-12-08 | Identified root cause: PAM not unlocking keyring | ✅ |
| 2025-12-08 | Solution: Add PAM + gnome-keyring to system config | ✅ |

