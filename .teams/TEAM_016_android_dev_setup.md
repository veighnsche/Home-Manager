# TEAM_016: Android Development Environment Setup

## Objective
1. Create `dev.nix` with Android SDK and development tools
2. Migrate dev-related packages from `home.nix` to `dev.nix`
3. Import `dev.nix` from `home.nix`

## Context
- User wants to develop an Android app for system monitoring on a phone connected via USB
- Need Android SDK, ADB, and related tooling
- Dev packages in `home.nix` to migrate: nodejs, python, gcc, uv, libffi, pkg-config, openssl, rustc, cargo, nixd, nil

## Changes Made
- Created `dev.nix` with:
  - Android SDK via `androidenv.composeAndroidPackages`
  - Android Studio (optional, commented)
  - ADB tools
  - All dev packages migrated from `home.nix`
  - Environment variables for Python compilation
- Updated `home.nix`:
  - Removed dev packages (moved to `dev.nix`)
  - Added import for `dev.nix`
  - Removed zsh initContent for PKG_CONFIG_PATH (moved to `dev.nix`)

## Notes
- User needs `programs.adb.enable = true` in NixOS configuration.nix
- User needs to be in `adbusers` group for unprivileged ADB access
- License acceptance: `nixpkgs.config.android_sdk.accept_license = true`

## Status
- [x] Create team file
- [x] Create dev.nix with Android SDK
- [x] Migrate dev packages from home.nix
- [x] Import dev.nix in home.nix
- [x] Build verified successfully

## Required NixOS System Changes
Add to your `/etc/nixos/configuration.nix`:

```nix
# Android ADB access
programs.adb.enable = true;
users.users.vince.extraGroups = [ "adbusers" ];

# Accept Android SDK license
nixpkgs.config.android_sdk.accept_license = true;
```

Then run: `sudo nixos-rebuild switch`
