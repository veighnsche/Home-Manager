# Phase 2 — Design: Folder Symlink Feature

**Team:** TEAM_002  
**Parent:** phase-1.md

---

## Proposed Solution

Add a **marker file** mechanism: if a directory contains a special file (e.g., `.symlink-folder`), the directory itself is symlinked instead of recursing into it.

### User-Facing Behavior

1. User creates an empty marker file in folders they want symlinked whole:
   ```
   touch vince/.config/Windsurf/.symlink-folder
   touch vince/.config/rofi/.symlink-folder
   ```

2. `gather-files.nix` detects the marker and symlinks the folder instead of recursing.

3. Result in `home.file`:
   ```nix
   ".config/Windsurf" = { source = mkOutOfStoreSymlink "..."; };
   # Instead of:
   # ".config/Windsurf/settings.json" = ...;
   # ".config/Windsurf/keybindings.json" = ...;
   ```

### System Behavior

```
gatherFilesRec encounters directory
  → check if marker file exists in directory
  → if YES: emit single symlink entry for the directory, do NOT recurse
  → if NO: recurse as before
```

---

## API Design

### Option A: Marker File (Recommended)

```nix
# No API change needed
# Detection is automatic based on marker file presence
gatherFiles {
  path = ./vince;
  mkSource = relPath: ...;
  force ? true;
  markerFile ? ".symlink-folder";  # NEW: configurable marker name
}
```

**Pros:**
- Declarative — marker is visible in repo
- No Nix code changes per folder
- Self-documenting

**Cons:**
- Adds a file to each marked folder
- Marker file itself should NOT be symlinked

### Option B: Explicit List

```nix
gatherFiles {
  path = ./vince;
  mkSource = relPath: ...;
  symlinkWholeFolders = [ ".config/Windsurf" ".config/rofi" ];
}
```

**Pros:**
- No marker files in repo
- Centralized control

**Cons:**
- Must update Nix code for each new folder
- Easy to forget / get out of sync

### Option C: Naming Convention

Folders ending in `.d` or prefixed with `@` are symlinked whole.

**Pros:**
- No extra files
- No Nix code changes

**Cons:**
- Constrains folder naming
- Not intuitive

---

## Recommended: Option A (Marker File)

The marker file approach is:
- **Declarative** — visible in the repo
- **Self-documenting** — presence of `.symlink-folder` explains intent
- **Extensible** — could add metadata to the marker file later
- **No Nix changes per folder** — just touch a file

---

## Behavioral Decisions

### Edge Cases

| Scenario | Proposed Behavior |
|----------|-------------------|
| Marker file in root `./vince/.symlink-folder` | Symlink entire `vince/` folder (probably not desired — should we error?) |
| Marker file in nested folder | Symlink that folder, parent folders still recurse |
| Empty folder with marker | Symlink the empty folder |
| Empty folder without marker | Skip (no files to symlink) — current behavior |
| Marker file itself | Do NOT create a symlink entry for the marker file |

### Error States

| Scenario | Proposed Behavior |
|----------|-------------------|
| Marker file is not readable | Fail evaluation with clear error |
| Marker file is a directory | Ignore (only regular files count as markers) |

### Defaults

| Setting | Default | Rationale |
|---------|---------|-----------|
| `markerFile` | `".symlink-folder"` | Descriptive, hidden (dot-prefix), unlikely to conflict |

---

## Implementation Sketch

```nix
# lib/gather-files.nix
{ lib }:

{ path, mkSource, force ? true, markerFile ? ".symlink-folder" }:

let
  gatherFilesRec = prefix: currentPath:
    let
      contents = builtins.readDir currentPath;
      hasMarker = contents ? ${markerFile} && contents.${markerFile} == "regular";
    in
      lib.attrsets.concatMapAttrs
        (name: type:
          let
            rel = if prefix == "" then name else "${prefix}/${name}";
            fullPath = currentPath + "/${name}";
          in
            # Skip the marker file itself
            if name == markerFile then
              { }
            else if type == "regular" || type == "symlink" then
              { "${rel}" = { source = mkSource rel; inherit force; }; }
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
            else
              { }
        )
        contents;
in
  gatherFilesRec "" path
```

---

## Open Questions

### Q1: Marker file name

**Question:** What should the marker file be called?

**Options:**
- `.symlink-folder` (descriptive)
- `.no-recurse` (describes behavior)
- `.link` (short)
- `.folder` (ambiguous)

**Recommendation:** `.symlink-folder` — clear and unlikely to conflict.

**Status:** ⏳ Awaiting user input

---

### Q2: Should marker file be configurable?

**Question:** Should users be able to override the marker file name via a parameter?

**Options:**
- Yes, add `markerFile ? ".symlink-folder"` parameter
- No, hardcode it

**Recommendation:** Yes, make it configurable with a sensible default.

**Status:** ⏳ Awaiting user input

---

### Q3: Root folder marker behavior

**Question:** What should happen if the root folder (`./vince/`) contains a marker?

**Options:**
- A) Error — this is probably a mistake
- B) Symlink the entire root (user knows what they're doing)
- C) Ignore the marker at root level

**Recommendation:** Option A — error with a clear message. Symlinking the entire root defeats the purpose of `gather-files.nix`.

**Status:** ⏳ Awaiting user input

---

### Q4: Marker file content

**Question:** Should the marker file be empty, or could it contain metadata (e.g., `force = false`)?

**Options:**
- A) Must be empty (simple)
- B) Can contain TOML/JSON metadata (extensible)
- C) Ignored for now, but don't preclude future metadata

**Recommendation:** Option C — keep it simple now, but don't read/validate contents so we can add metadata later.

**Status:** ⏳ Awaiting user input

---

### Q5: Recursive markers

**Question:** If a marked folder contains subfolders that also have markers, what happens?

**Example:**
```
.config/
  Windsurf/
    .symlink-folder    # marker
    extensions/
      .symlink-folder  # nested marker (never seen because parent is symlinked)
```

**Answer:** The nested marker is irrelevant — the parent folder is symlinked as a whole, so we never recurse into it. No special handling needed.

**Status:** ✅ Resolved (no action needed)

---

## Next Steps

1. Get user answers to Q1-Q4
2. Finalize design
3. Proceed to Phase 3 (Implementation)
