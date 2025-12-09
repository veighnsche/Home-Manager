# TEAM_017 — Investigate `currentSystem` Missing Error

## Bug Report

**Error:**
```
error: attribute 'currentSystem' missing
at /nix/store/cd6v80pj9h7r2prxx9a71y92zq88p1xx-source/pkgs/top-level/impure.nix:17:29:
    16|   localSystem ? {
    17|     system = args.system or builtins.currentSystem;
```

**Context:**
- Occurs after Home Manager activation completes successfully
- Warning: `'system' has been renamed to/replaced by 'stdenv.hostPlatform.system'`
- Git tree is dirty

## Investigation Status

- [ ] Phase 1: Understand the Symptom
- [ ] Phase 2: Form Hypotheses
- [ ] Phase 3: Test Hypotheses
- [ ] Phase 4: Narrow Down Root Cause
- [ ] Phase 5: Decision

## Phase 1 — Symptom Analysis

### Expected Behavior
Home Manager activation completes without errors.

### Actual Behavior
Activation succeeds but then a second evaluation fails with `currentSystem` missing.

### Key Observations
1. The deprecation warning about `system` → `stdenv.hostPlatform.system` suggests outdated pattern usage
2. `builtins.currentSystem` is an impure builtin that may not be available in pure evaluation mode
3. The error occurs in nixpkgs `impure.nix` — something is importing nixpkgs without specifying `system`

## Root Cause

**CONFIRMED**: The flake was using `hostPlatform = "x86_64-linux"` instead of `system = "x86_64-linux"`.

- `hostPlatform` is for `nixpkgs.legacyPackages.${system}` pattern
- `import nixpkgs {}` requires `system` parameter
- Without `system`, nixpkgs falls back to `builtins.currentSystem` which doesn't exist in pure flake evaluation

## Fix

Changed line 55 in `flake.nix`:
```nix
# Before (broken)
hostPlatform = "x86_64-linux";

# After (working)
system = "x86_64-linux";
```

The deprecation warning about `system` is harmless — it's just suggesting to use `stdenv.hostPlatform.system` when *accessing* the system string, not when *passing* it to nixpkgs.

## Status: FIXED
