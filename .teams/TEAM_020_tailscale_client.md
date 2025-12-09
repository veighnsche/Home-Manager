# TEAM_020: Tailscale Client Configuration

## Task
Configure Tailscale VPN client to connect to:
- IPv4: 100.110.232.5
- IPv6: fd7a:115c:a1e0::4a34:e805
- Hostname: debian.tail5bea38.ts.net

## Changes

### NixOS (`/etc/nixos/configuration.nix`)
1. **Enable Tailscale service** - `services.tailscale.enable = true`
2. **Firewall** - Allow Tailscale traffic

## Status
- [x] Team file created
- [x] Add Tailscale configuration
- [ ] nixos-rebuild switch
- [ ] Authenticate with `sudo tailscale up`
- [ ] Verify connection to debian.tail5bea38.ts.net

## Handoff
After `sudo nixos-rebuild switch`:
1. `sudo tailscale up` - Authenticate (opens browser)
2. `tailscale status` - Check connection
3. `ping debian.tail5bea38.ts.net` or `ping 100.110.232.5`
