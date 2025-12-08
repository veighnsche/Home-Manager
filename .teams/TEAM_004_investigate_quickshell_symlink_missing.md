# TEAM_004 — Investigate: quickshell folder not symlinked

**Bug:** `/home/vince/.config/quickshell` does not exist, should be symlinked to `~/Home-Manager/vince/.config/quickshell`

---

## Symptom

- **Expected:** `~/.config/quickshell` → symlink to `~/Home-Manager/vince/.config/quickshell`
- **Actual:** `~/.config/quickshell` does not exist
- **Evidence:** Home Manager generation 42 does NOT contain `quickshell` in `.config/`

---

## Investigation

### Phase 1 — Understand the Symptom

The `.symlink-folder` marker exists in:
```
/home/vince/Home-Manager/vince/.config/quickshell/.symlink-folder
```

But the folder is NOT appearing in the Home Manager generation output.

### Hypotheses

1. **H1:** `gather-files.nix` is not detecting the marker correctly
2. **H2:** The marker file format/content is wrong
3. **H3:** There's a path issue in how the folder is being processed

---

## Progress

- [ ] Test gather-files.nix output directly
- [ ] Verify marker detection logic
- [ ] Identify root cause
