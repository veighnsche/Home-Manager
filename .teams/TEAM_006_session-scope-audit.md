# TEAM_006: Session-Level Agent Audit

**Status:** Completed  
**Date:** 2025-12-08  
**Directive:** Formal audit in response to "Session-Level Responsibilities" letter

---

## Objective

Audit Home-Manager configuration to identify and correct any violations where:
1. Session agents (polkit, nm-applet, etc.) are auto-started globally
2. DE helpers are started that pollute both Plasma and niri sessions
3. Home-Manager oversteps by deciding when agents run rather than just providing binaries

---

## Investigation Summary

### Files Reviewed
- `home.nix` — main entry point
- `shell.nix` — shell/CLI tools
- `wlroots.nix` — niri + wlroots packages
- `kde.nix` — Plasma settings (via plasma-manager)
- `scripts/niri-wrapper.sh` — niri session wrapper
- `vince/.config/niri/config.kdl` — niri config
- `~/.config/autostart/` — XDG autostart directory

### Services Currently Enabled in Home-Manager

| Service | Status | Assessment |
|---------|--------|------------|
| `services.ssh-agent.enable = true` | ✅ Correct | Session-agnostic, works in both Plasma and niri |

### Autostart Entries Found

| File | Condition | Assessment |
|------|-----------|------------|
| `plasma-manager-autostart.desktop` | `X-KDE-autostart-condition=ksmserver` | ✅ Correct — Only runs in KDE Plasma |

### Agent Packages

| Package | In home.packages? | Auto-started? | Assessment |
|---------|-------------------|---------------|------------|
| `polkit-agent` (lxqt-policykit, etc.) | ❌ No | ❌ No | N/A |
| `network-manager-applet` (nm-applet) | ❌ No | ❌ No | N/A |
| `notification-daemon` | ❌ No | ❌ No | N/A |

### Session-Specific Startup

| Session | Agent Startup Method | Assessment |
|---------|---------------------|------------|
| **niri** | `spawn-at-startup "waybar"` in `config.kdl` | ✅ Correct — niri-specific |
| **Plasma** | Managed by ksmserver/plasmashell | ✅ Correct — KDE handles its own |

---

## Findings

### ✅ NO VIOLATIONS DETECTED

The current Home-Manager configuration is **already compliant** with the directive:

1. **No global agent auto-start**  
   - No polkit agents are installed or auto-started via HM
   - No nm-applet is installed or auto-started via HM
   - No notification daemons are globally started

2. **Packages-only role respected**  
   - `wlroots.nix` provides `niri-with-fixed-session` and `quickshell` only
   - No service enables that would auto-start session helpers

3. **Session isolation preserved**  
   - Plasma's autostart has `X-KDE-autostart-condition=ksmserver` (KDE-only)
   - niri's `config.kdl` uses `spawn-at-startup` (niri-only)
   - `niri-wrapper.sh` properly manages systemd user environment

4. **ssh-agent is acceptable**  
   - `services.ssh-agent.enable = true` is session-agnostic (works everywhere, causes no conflicts)

---

## Specification: What Home-Manager Now Provides to niri

| Category | Items |
|----------|-------|
| **Compositor** | `niri` (with fixed session wrapper) |
| **Shell** | `quickshell` |
| **Environment** | `XDG_CURRENT_DESKTOP=wlroots`, GTK/Wayland env vars |
| **Session management** | `niri-wrapper.sh` handles systemd user service |

Home-Manager does **NOT** provide or auto-start:
- Polkit agents
- Network applets  
- Notification daemons
- Any DE-specific helpers

---

## Side Effects

None detected. The configuration is clean.

---

## Confirmation

I, the Home-Manager AI (TEAM_006), confirm:

1. ✅ I am not globally starting polkit agents
2. ✅ I am not globally starting nm-applet
3. ✅ I am not globally starting notification daemons  
4. ✅ I am acting only as a provider of binaries and environment variables
5. ✅ Session-specific startup is delegated to niri's `config.kdl` and Plasma's ksmserver
6. ✅ I will not start agents globally without explicit session-scoped directives

---

## Handoff to System AI

The Home-Manager layer is compliant. The System AI may now proceed with:
- Ensuring polkit agent is started at the **system level** for niri (if needed)
- Ensuring any system-level network/auth services are properly configured

No corrections were required at the Home-Manager level.
