# Phase 2 — Structural Extraction

**Refactor:** niri Session Services Implementation  
**Team:** TEAM_007  
**Status:** Ready for execution

---

## 1. Target Design

### Current Structure
```
wlroots.nix
├── niri-with-fixed-session (package)
└── quickshell (package)
```

### Target Structure
```
wlroots.nix
├── Packages
│   ├── niri-with-fixed-session
│   ├── quickshell
│   ├── polkit_gnome
│   └── networkmanagerapplet
├── Services
│   └── gnome-keyring (secrets component)
└── Session Startup (via config.kdl)
    ├── polkit-gnome-authentication-agent-1
    └── nm-applet
```

---

## 2. Package Specifications

### Verified Package Names

| Component | Nix Attribute | Binary Path |
|-----------|---------------|-------------|
| Polkit Agent | `pkgs.polkit_gnome` | `${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1` |
| Network Applet | `pkgs.networkmanagerapplet` | `nm-applet` (in PATH) |
| GNOME Keyring | HM service | `services.gnome-keyring.enable` |

---

## 3. Implementation Strategy

### 3.1 Expand `wlroots.nix`

Add packages:
```nix
home.packages = with pkgs; [
  niri-with-fixed-session
  quickshell
  polkit_gnome           # NEW: Polkit authentication agent
  networkmanagerapplet   # NEW: Network tray applet
];
```

Add GNOME Keyring service:
```nix
services.gnome-keyring = {
  enable = true;
  components = [ "secrets" ];  # Only secrets, not ssh/pkcs11
};
```

### 3.2 Update `config.kdl`

Add spawn-at-startup entries:
```kdl
// TEAM_007: Session services for niri
spawn-at-startup "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"
spawn-at-startup "nm-applet"
```

**Problem:** `config.kdl` is a static dotfile, not a Nix template.

**Solution:** Use niri's shell spawn:
```kdl
spawn-sh-at-startup "polkit-gnome-authentication-agent-1"
spawn-sh-at-startup "nm-applet"
```

Wait — the binary is in `libexec`, not in PATH. We need to either:
1. Create a wrapper script
2. Use full path in config.kdl
3. Add a symlink to put it in PATH

**Decision:** Create a wrapper in `wlroots.nix` that adds the agent to PATH.

---

## 4. Detailed Changes

### 4.1 Changes to `wlroots.nix`

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

### 4.2 Changes to `vince/.config/niri/config.kdl`

Add after existing `spawn-at-startup "waybar"`:

```kdl
// TEAM_007: Session services
spawn-at-startup "polkit-gnome-agent"
spawn-at-startup "nm-applet"
```

---

## 5. Exit Criteria for Phase 2

- [ ] `wlroots.nix` updated with new packages and services
- [ ] `config.kdl` updated with spawn-at-startup entries
- [ ] `nix flake check` passes
- [ ] Build succeeds: `nix build .#homeConfigurations.vince.activationPackage`

---

## 6. Phase 2 Steps

### Step 1: Update `wlroots.nix`
- Add `polkit-gnome-agent` wrapper
- Add `networkmanagerapplet` package
- Add `services.gnome-keyring` configuration

### Step 2: Update `config.kdl`
- Add `spawn-at-startup` entries for polkit and nm-applet

### Step 3: Verify Build
- Run `nix flake check`
- Run dry-run build

---

## 7. Rollback Procedure

If issues occur:
1. Revert `wlroots.nix` to previous state
2. Revert `config.kdl` to previous state
3. Run `home-manager switch` to restore

Git provides automatic rollback via:
```bash
git checkout HEAD -- wlroots.nix vince/.config/niri/config.kdl
```
