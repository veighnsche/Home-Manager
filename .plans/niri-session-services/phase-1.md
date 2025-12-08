# Phase 1 — Discovery and Safeguards

**Refactor:** niri Session Services Implementation  
**Team:** TEAM_007  
**Status:** Ready for execution

---

## 1. Refactor Summary

### What is being refactored?
The `wlroots.nix` module currently only provides the niri compositor package. It must be expanded to provide complete session services for niri, including:
- Polkit authentication agent
- Network tray applet
- Secret agent for credential storage

### Pain Points
1. **WiFi doesn't work in niri** — Credentials stored in KWallet are inaccessible without KDE running
2. **No polkit prompts** — Privileged operations fail silently or hang
3. **No network UI** — No way to manage network connections visually

### Motivation
niri must function as a fully independent session without requiring KDE Plasma to be running.

---

## 2. Success Criteria

### Before
- niri session starts with only the compositor
- WiFi requires KDE session to have run first (KWallet dependency)
- No polkit prompts for privileged operations
- No network tray icon

### After
- niri session starts with all required session services
- WiFi connects independently using GNOME Keyring
- Polkit prompts appear for privileged operations
- Network tray icon visible and functional

---

## 3. Behavioral Contracts

### Must Preserve
| Contract | Description |
|----------|-------------|
| KDE session unchanged | `kde.nix` must continue to work exactly as before |
| Plasma services isolated | KDE services must NOT start in niri |
| niri services isolated | niri services must NOT start in Plasma |
| Build success | `nix flake check` must pass |

### New Behavior
| Contract | Description |
|----------|-------------|
| Polkit agent in niri | `polkit-gnome-authentication-agent-1` starts with niri |
| nm-applet in niri | Network tray applet starts with niri |
| GNOME Keyring in niri | Secret agent available for WiFi credentials |

---

## 4. Golden/Regression Tests

### Build Verification
```bash
nix flake check
nix build .#homeConfigurations.vince.activationPackage --dry-run
```

### Session Verification (Manual)
1. Start niri session from display manager
2. Verify polkit prompt appears: `pkexec echo "polkit works"`
3. Verify nm-applet tray icon visible
4. Verify WiFi connects without prior KDE session

---

## 5. Current Architecture

### File Structure
```
/home/vince/Home-Manager/
├── home.nix          # Main entry, imports all modules
├── shell.nix         # Shell/CLI tools (session-agnostic)
├── wlroots.nix       # niri package only (TO BE EXPANDED)
├── kde.nix           # KDE/Plasma configuration
├── scripts/
│   └── niri-wrapper.sh  # niri session wrapper
└── vince/
    └── .config/
        └── niri/
            └── config.kdl  # niri configuration
```

### Current `wlroots.nix`
```nix
{ pkgs, lib, ... }:
let
  niri-session-fixed = pkgs.writeShellScriptBin "niri-session"
    (builtins.readFile ./scripts/niri-wrapper.sh);
  niri-with-fixed-session = pkgs.symlinkJoin { ... };
in
{
  home.packages = with pkgs; [
    niri-with-fixed-session
    quickshell
  ];
}
```

### Session Startup Flow
1. Display manager starts `niri-session`
2. `niri-wrapper.sh` sets up environment and starts `niri.service`
3. niri reads `config.kdl` and runs `spawn-at-startup` commands
4. Currently only `waybar` is spawned

---

## 6. Constraints

### Technical Constraints
| Constraint | Reason |
|------------|--------|
| No `polkit-kde-agent` | Requires KDE infrastructure |
| No KWallet in niri | Would require KDE services |
| Session-scoped only | Services must not pollute other sessions |

### Design Constraints
| Constraint | Reason |
|------------|--------|
| Use `spawn-at-startup` | Simplest, niri-native approach |
| GNOME Keyring for secrets | DE-agnostic, well-supported |
| Minimal changes to kde.nix | Preserve existing KDE functionality |

---

## 7. Open Questions

| # | Question | Status |
|---|----------|--------|
| 1 | Should we use systemd user services or niri's spawn-at-startup? | **Decision: spawn-at-startup** (simpler, niri-native) |
| 2 | Should existing WiFi connections be migrated to system storage? | **Decision: No** — use GNOME Keyring instead |
| 3 | Does quickshell need any of these services? | **TBD** — verify after implementation |

---

## 8. Phase 1 Steps

### Step 1: Verify Current State
- [x] Read and understand current `wlroots.nix`
- [x] Read and understand current `niri/config.kdl`
- [x] Verify build passes: `nix flake check`

### Step 2: Document Package Requirements
- [x] Identify exact package names in nixpkgs
- [x] Verify packages are available in nixpkgs-unstable
- [x] Document binary paths for spawn-at-startup

### Step 3: Create Test Plan
- [x] Document manual verification steps (see phase-4.md)
- [x] Prepare rollback procedure (see phase-2.md)

---

## 9. Exit Criteria for Phase 1

- [x] Current architecture documented
- [x] Success criteria defined
- [x] Constraints identified
- [x] Package names verified
- [x] Test plan documented
- [x] Ready to proceed to Phase 2

---

## 10. Verified Package Information

| Component | Nix Attribute | Binary Path |
|-----------|---------------|-------------|
| Polkit Agent | `pkgs.polkit_gnome` | `${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1` |
| Network Applet | `pkgs.networkmanagerapplet` | `nm-applet` (in PATH after install) |
| GNOME Keyring | `services.gnome-keyring` | Home-Manager service module |

**Phase 1 Status: ✅ COMPLETE**
