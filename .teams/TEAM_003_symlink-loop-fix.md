# TEAM_003 — Symlink Loop Fix

**Date:** 2025-12-08  
**Issue:** ELOOP error when accessing quickshell configuration  
**Root Cause:** Circular symlink chain caused by incomplete folder symlink implementation  

---

## Problem Summary

The folder symlink feature was designed in Phase 1-2 but not fully implemented in `gather-files.nix`. However, `.symlink-folder` marker files were already present, causing Home Manager to create circular symlinks:

```
vince/.config/quickshell/shell.qml → Nix store → back to same location
```

This resulted in `ELOOP: too many symbolic links encountered` errors.

---

## Solution Implemented

### 1. Updated `lib/gather-files.nix`
- Added `markerFile ? ".symlink-folder"` parameter
- Implemented marker detection logic
- Added folder-level symlinking when marker is present
- Skip marker files themselves (don't create symlinks for them)

### 2. Fixed Circular References
- Removed broken symlinks from Home Manager generation
- Cleaned up source directory artifacts
- Rebuilt configuration with proper folder symlinks

---

## Code Changes

**File:** `lib/gather-files.nix`
```nix
# Added markerFile parameter
{ path, mkSource, force ? true, markerFile ? ".symlink-folder" }:

# Enhanced directory handling
else if type == "directory" then
  let
    dirContents = builtins.readDir fullPath;
    dirHasMarker = dirContents ? ${markerFile} && dirContents.${markerFile} == "regular";
  in
    if dirHasMarker then
      # Symlink the folder itself
      { "${rel}" = { source = mkSource rel; inherit force; }; }
    else
      # Recurse as before
      gatherFilesRec rel fullPath
```

---

## Verification

1. ✅ Home Manager builds without errors
2. ✅ No more ELOOP errors when accessing files
3. ✅ Folders with `.symlink-folder` marker are symlinked as whole directories
4. ✅ Marker files are ignored (no symlinks created for them)
5. ✅ Backwards compatibility maintained for unmarked folders

---

## Current State

- `/home/vince/.config/quickshell` → symlinked to repository source
- Individual file symlinks removed for marked folders
- Configuration activates successfully
- Folder symlink feature fully operational

---

## Notes

The folder symlink feature now works as designed in the original Phase 2 specification:
- Declarative marker files (`.symlink-folder`)
- Whole folder symlinking instead of recursion
- Self-documenting approach
- No Nix code changes needed per folder
