# Phase 1 — Discovery: Folder Symlink Feature

**Team:** TEAM_002  
**Feature:** Allow `gather-files.nix` to symlink entire folders instead of recursing

---

## Feature Summary

**Problem Statement:**  
Currently `gather-files.nix` always recurses into directories, creating individual symlinks for each file. Some directories should be symlinked as a whole (e.g., `.config/Windsurf/` or `.config/rofi/`) rather than having their contents individually symlinked.

**Who Benefits:**  
Users managing dotfiles who want:
- Faster symlink creation (one link vs. many)
- Applications that expect a real directory structure (not individual file symlinks)
- Cleaner `home.file` output

---

## Success Criteria

1. User can mark specific directories as "symlink whole folder"
2. Marked directories are symlinked as a single entry, not recursed
3. Unmarked directories continue to recurse as before (backwards compatible)
4. The tagging mechanism is simple and doesn't require modifying the Nix code for each folder

---

## Current State Analysis

### How it works today

```nix
# lib/gather-files.nix (lines 30-38)
if type == "regular" || type == "symlink" then
  { "${rel}" = { source = mkSource rel; inherit force; }; }
else if type == "directory" then
  gatherFilesRec rel fullPath   # <-- ALWAYS recurses
else
  { }
```

**Current behavior:**
- Files and symlinks → create symlink entry
- Directories → always recurse into them
- No way to stop recursion

### Current directory structure example

```
vince/.config/
├── Windsurf/      (empty - would want to symlink whole folder)
├── niri/          (1 file - might want individual symlinks)
├── quickshell/    (1 file)
├── rofi/          (empty - would want to symlink whole folder)
└── waybar/        (2 files)
```

---

## Codebase Reconnaissance

### Files to modify

| File | Purpose |
|------|---------|
| `lib/gather-files.nix` | Core logic - needs to check for "no-recurse" marker |
| `home.nix` | May need to pass additional config to `gatherFiles` |

### Public API

Current:
```nix
gatherFiles {
  path = ./vince;
  mkSource = relPath: ...;
  force ? true;
}
```

Will need to add a mechanism to identify "no-recurse" folders.

### Tests / Golden Snapshots

None identified. This is a Home Manager config, not a tested library.

---

## Constraints

1. **Backwards compatible** — existing behavior must not change for unmarked folders
2. **Simple tagging** — should not require editing Nix code for each folder
3. **Nix-pure** — must work within Nix's pure evaluation (no impure reads)
4. **Declarative** — the marker should be visible in the repo, not hidden metadata

---

## Open Questions (Discovery Phase)

None yet — design phase will generate questions about the tagging mechanism.
