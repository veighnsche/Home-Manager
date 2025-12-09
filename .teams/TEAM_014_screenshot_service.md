# TEAM_014: Screenshot Service for Wayland

## Task
Implement a screenshot service for niri/wlroots that:
- Captures region by dragging a selection box
- Automatically copies to clipboard without prompts
- Also saves to `~/Pictures/Screenshots/`

## Changes Made

### 1. Added packages to `wlroots.nix`
- `grim` - Screenshot capture tool for Wayland
- `slurp` - Region selection tool
- `wl-clipboard` - Clipboard support (`wl-copy`)
- `jq` - JSON parsing for window geometry
- `libnotify` - Desktop notifications

### 2. Created `vince/bin/screenshot` script
Modes:
- `region` (default): Drag to select area → clipboard + file
- `screen`: Full screen capture
- `window`: Focused window (with fallback to region)

### 3. Updated `vince/.config/niri/config.kdl` keybindings
- `Print` → Region screenshot (drag to select)
- `Mod+Shift+S` → Region screenshot (alternative)
- `Mod+Print` → Full screen
- `Mod+Ctrl+Print` → Focused window

## Handoff Checklist
- [x] Script created with proper modes
- [x] Packages added to wlroots.nix
- [x] Keybindings updated in niri config
- [ ] User needs to rebuild: `home-manager switch`
- [ ] User needs to reload niri config: `Mod+Shift+C`
