# Phase 4 — Verification and Cleanup

**Refactor:** niri Session Services Implementation  
**Team:** TEAM_007  
**Status:** Pending (after Phase 3)

---

## 1. Verification Tests

### 1.1 Build Verification
```bash
nix flake check
nix build .#homeConfigurations.vince.activationPackage
```

### 1.2 Service Verification (in niri session)

#### Polkit Agent
```bash
# Should show authentication dialog
pkexec echo "Polkit works!"
```

#### Network Applet
```bash
# Should show nm-applet in system tray
# Visual verification required
pgrep -a nm-applet
```

#### GNOME Keyring
```bash
# Should show gnome-keyring-daemon running
pgrep -a gnome-keyring

# Should be able to store/retrieve secrets
secret-tool store --label="test" test key <<< "value"
secret-tool lookup test key
```

### 1.3 WiFi Connectivity Test

1. Log out of all sessions
2. Log into niri session only (no prior KDE session)
3. Attempt to connect to WiFi
4. Verify password prompt appears (GNOME Keyring)
5. Verify connection succeeds

---

## 2. Expected Results

| Test | Expected Result |
|------|-----------------|
| `pkexec echo test` | Authentication dialog appears |
| `pgrep nm-applet` | Process running |
| `pgrep gnome-keyring` | Process running |
| WiFi connect | Prompts for password, connects successfully |
| Network tray | Icon visible in waybar/quickshell |

---

## 3. Troubleshooting

### Polkit agent not starting
```bash
# Check if binary exists
which polkit-gnome-agent

# Try manual start
polkit-gnome-agent &
```

### nm-applet not showing
```bash
# Check if running
pgrep -a nm-applet

# Check for errors
nm-applet 2>&1 | head -20
```

### GNOME Keyring not working

**Understanding the dependency chain:**
```
niri-session-wrapper
  → starts niri.service
    → Wants graphical-session-pre.target
      → gnome-keyring.service starts (WantedBy graphical-session-pre.target)
```

```bash
# Check service status
systemctl --user status gnome-keyring-daemon

# Check if the target was reached
systemctl --user status graphical-session-pre.target

# Check if socket exists
ls -la $XDG_RUNTIME_DIR/keyring/
```

### WiFi still not working

**Important:** Existing WiFi passwords stored in KWallet will NOT automatically migrate to GNOME Keyring. This is expected behavior.

**First-time connection in niri:**
1. Click on WiFi network in nm-applet
2. Enter password when prompted
3. Password will be stored in GNOME Keyring
4. Future connections will work automatically

**If password prompt doesn't appear:**
```bash
# Check connection flags
nmcli connection show "Ziggo9423778" | grep psk-flags

# If still agent-owned (1) and no prompt appears, migrate to system storage:
sudo nmcli connection modify "Ziggo9423778" 802-11-wireless-security.psk-flags 0
sudo nmcli connection modify "Ziggo9423778" 802-11-wireless-security.psk "YOUR_PASSWORD"
```

---

## 4. Cleanup

### Remove any temporary test files
```bash
secret-tool clear test key  # Remove test secret
```

### Verify no dead code
- No unused packages in wlroots.nix
- No commented-out spawn entries in config.kdl

---

## 5. Documentation Update

Update team file with:
- Final status
- Test results
- Any remaining issues

---

## 6. Exit Criteria

- [ ] All verification tests pass
- [ ] WiFi connects without KDE
- [ ] Polkit prompts work
- [ ] Network tray visible
- [ ] Team file updated
- [ ] Ready for handoff
