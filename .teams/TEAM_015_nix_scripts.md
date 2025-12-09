# TEAM_015: Nix-Packaged Scripts

## Task
Make `~/bin` scripts available in PATH for all services (systemd, niri, etc.)

## Problem
`home.sessionPath` only works for interactive shells. Systemd services don't inherit it.

## Solution
Created `scripts.nix` which packages the scripts as proper Nix derivations using `pkgs.writeShellApplication`. This:

1. Places them in `~/.nix-profile/bin` which IS in PATH for all services
2. Wraps dependencies automatically (grim, slurp, wl-clipboard, etc.)
3. Removes need for absolute paths in configs

## Changes Made
- **Created**: `/home/vince/Home-Manager/scripts.nix` - packages `screenshot`, `swaybg-wallpaper-setter`, `url-to-qr`
- **Modified**: `/home/vince/Home-Manager/home.nix` - imported scripts.nix, removed duplicate qrencode
- **Modified**: `/home/vince/Home-Manager/vince/.config/niri/config.kdl` - simplified absolute paths to just command names

## Handoff
- [ ] User runs `home-manager switch --flake .#vince` to apply
- [ ] Old scripts in `~/bin/` can be deleted (now managed by Nix)
- [ ] Test screenshot keybindings
- [ ] Test wallpaper service starts correctly after reboot/re-login
