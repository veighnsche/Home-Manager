# TEAM_002 Questions: Folder Symlink Feature Design

**Related Plan:** `.plans/folder-symlink-feature/phase-2.md`

---

## Q1: Marker file name

What should the marker file be called?

- [ ] `.symlink-folder` (descriptive, recommended)
- [ ] `.no-recurse` (describes behavior)
- [ ] `.link` (short)
- [ ] Other: _______________

---

## Q2: Should marker file name be configurable?

- [ ] Yes, add `markerFile` parameter with default
- [ ] No, hardcode it

---

## Q3: Root folder marker behavior

What if `./vince/.symlink-folder` exists?

- [ ] A) Error — this is probably a mistake (recommended)
- [ ] B) Symlink the entire root
- [ ] C) Ignore the marker at root level

---

## Q4: Marker file content

- [ ] A) Must be empty
- [ ] B) Can contain metadata (TOML/JSON)
- [ ] C) Ignore contents for now, allow future metadata (recommended)
