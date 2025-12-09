# TEAM_019: SMB Client Configuration for blep

## Task
Configure blep to connect to workstation for file browsing via SMB/Samba.

## Changes

### NixOS (`/etc/nixos/configuration.nix`)
1. **Avahi/mDNS** - For `.local` hostname resolution
2. **SMB Client Tools** - `cifs-utils` and `samba` for CLI/mounting

## Status
- [x] Team file created
- [x] Add Avahi configuration (line 181-185)
- [x] Add SMB client packages (line 317-319)
- [ ] nixos-rebuild switch
- [ ] Verify connection

## Handoff
Run `sudo nixos-rebuild switch` after changes, then test with:
- `ping workstation.local`
- `smbclient -L //workstation.local -U vince`
- Dolphin: `smb://workstation.local/`
