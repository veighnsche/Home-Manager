# TEAM_005: Conditional Window Manager Packages

## Team Summary
**Feature:** Conditional package installation based on window manager (Niri vs KDE)  
**Problem:** Some packages (like polkit authenticator) work on KDE but need different implementations for Niri  
**Goal:** Install appropriate packages/services only when using Niri, avoid conflicts with KDE defaults  

## Team Members
- Cascade (AI Assistant)

## Progress Log
### 2025-12-08 - Initial Planning
- Registered team as TEAM_005
- Analyzed current Home Manager structure
- Identified need for conditional package installation
- Smart friend suggested using explicit config flags (`config.myConfig.windowManager`)
- Planning to use `mkIf` for conditional logic

### 2025-12-08 - Superseded by TEAM_007
- **REASON:** System AI audit revealed the issue wasn't conditional packages, but missing session services
- **OUTCOME:** Plan deleted, approach changed from conditional imports to adding niri-specific services
- **SUPERSEDED BY:** TEAM_007 niri-session-services implementation
- **STATUS:** ABANDONED - see `.teams/TEAM_007_niri-session-services.md`

## Handoff Notes
- ~~Need to examine existing `kde.nix` and `wlroots.nix` files~~ → **DONE**
- ~~Consider systemd user services for polkit agents~~ → **DECIDED: use spawn-at-startup instead**
- ~~Use explicit configuration rather than runtime detection~~ → **CHANGED: not needed, configs can coexist**

## Lessons Learned
1. **Root cause analysis is crucial** - The initial assumption about conditional packages was wrong
2. **System-level audit revealed the real issue** - Missing session services, not package conflicts
3. **Simpler solution emerged** - Add services to niri rather than conditionally exclude packages
