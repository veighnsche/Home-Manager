# Phase 3 — Implementation

**Refactor:** niri Session Services Implementation  
**Team:** TEAM_007  
**Status:** Ready for execution

---

## 1. Implementation Order

1. Update `wlroots.nix` with packages and services
2. Update `config.kdl` with spawn-at-startup entries
3. Verify build passes
4. Apply configuration

---

## 2. Step 1: Update `wlroots.nix`

### Current Content
```nix
{ pkgs, lib, ... }:

let
  niri-session-fixed = pkgs.writeShellScriptBin "niri-session"
    (builtins.readFile ./scripts/niri-wrapper.sh);

  niri-with-fixed-session = pkgs.symlinkJoin {
    name = "niri-with-fixed-session";
    paths = [
      niri-session-fixed
      pkgs.niri
    ];
    postBuild = ''
      rm -f $out/bin/niri-session
      ln -s ${niri-session-fixed}/bin/niri-session $out/bin/niri-session
    '';
  };
in
{
  home.packages = with pkgs; [
    niri-with-fixed-session
    quickshell
  ];
}
```

### Target Content
```nix
{ pkgs, lib, ... }:

let
  # TEAM_001: Use external niri-session wrapper script
  niri-session-fixed = pkgs.writeShellScriptBin "niri-session"
    (builtins.readFile ./scripts/niri-wrapper.sh);

  niri-with-fixed-session = pkgs.symlinkJoin {
    name = "niri-with-fixed-session";
    paths = [
      niri-session-fixed
      pkgs.niri
    ];
    postBuild = ''
      rm -f $out/bin/niri-session
      ln -s ${niri-session-fixed}/bin/niri-session $out/bin/niri-session
    '';
  };

  # TEAM_007: Wrapper to put polkit agent in PATH
  polkit-gnome-agent = pkgs.writeShellScriptBin "polkit-gnome-agent" ''
    exec ${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1 "$@"
  '';
in
{
  home.packages = with pkgs; [
    niri-with-fixed-session
    quickshell

    # TEAM_007: niri session services
    polkit-gnome-agent     # Polkit authentication agent (wrapper)
    networkmanagerapplet   # Network tray applet
  ];

  # TEAM_007: GNOME Keyring for secret storage (WiFi passwords)
  services.gnome-keyring = {
    enable = true;
    components = [ "secrets" ];
  };
}
```

---

## 3. Step 2: Update `config.kdl`

### Location
`vince/.config/niri/config.kdl`

### Change
After existing `spawn-at-startup "waybar"` (line 173), add:

```kdl
// TEAM_007: Session services for niri
spawn-at-startup "polkit-gnome-agent"
spawn-at-startup "nm-applet"
```

---

## 4. Step 3: Verify Build

```bash
cd /home/vince/Home-Manager
nix flake check
nix build .#homeConfigurations.vince.activationPackage --dry-run
```

---

## 5. Step 4: Apply Configuration

```bash
nix run home-manager/master -- switch --flake /home/vince/Home-Manager#vince -b backup
```

Or use the alias:
```bash
hm
```

---

## 6. Exit Criteria

- [ ] `wlroots.nix` contains polkit-gnome-agent wrapper
- [ ] `wlroots.nix` contains networkmanagerapplet
- [ ] `wlroots.nix` enables gnome-keyring service
- [ ] `config.kdl` spawns polkit-gnome-agent at startup
- [ ] `config.kdl` spawns nm-applet at startup
- [ ] Build passes
- [ ] Configuration applied successfully
