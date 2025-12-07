---
description: document for future teams
auto_execution_mode: 3
---

## 0. Purpose

This workflow is for **documenting knowledge for future teams**.

When you discover something useful during implementation — a pattern, a gotcha, a verification technique, or project-specific knowledge — you should document it so future teams don't have to rediscover it.

**This is NOT about documenting your specific task.** That goes in your team file.

**This IS about documenting reusable knowledge** that applies across tasks.

---

## 1. When to Use This Workflow

Use this workflow when you:

1. **Discover a verification technique** that future teams should use
2. **Find a gotcha or edge case** that isn't obvious from the code
3. **Establish a pattern** that should be followed consistently
4. **Learn something about the project** that isn't documented anywhere

Do NOT use this workflow for:

- Task-specific progress (use team files)
- Bug reports (use `.questions/` or breadcrumbs)
- Plans (use `.plans/`)

---

## 2. Documentation Locations

### 2.1 Verification Scripts

If you create or extend a verification script (e.g., `scripts/vm-verify.sh`):

1. **Add comments explaining what each section verifies**
2. **Use team comments** to trace who added what:
   ```bash
   # TEAM_XXX: Phase 4 Package Verification
   ```
3. **Make verification output clear** with pass/fail indicators:
   ```bash
   echo "✓ $pkg"      # success
   echo "✗ $pkg NOT FOUND"  # failure
   ```

### 2.2 Project README or Docs

For high-level knowledge that affects how people work with the project:

- Update `README.md` or create docs in a `docs/` folder
- Keep it concise — link to code rather than duplicating

### 2.3 Inline Code Comments

For gotchas that are specific to a code location:

```nix
# TEAM_XXX: Note - rofi-wayland has been merged into rofi in nixpkgs
rofi  # Launcher
```

### 2.4 Workflow Files

If you discover a **repeatable process** that future teams should follow:

- Create or update a workflow in `.windsurf/workflows/`
- Follow the existing workflow format (YAML frontmatter + markdown)

---

## 3. Documentation Format

### 3.1 Team Attribution

Always include your team number:

```
# TEAM_XXX: <description>
```

This allows future teams to trace back to your team file for context.

### 3.2 Be Specific

Bad:
```
# This is important
```

Good:
```
# TEAM_443: libnotify provides notify-send command (not included by default)
```

### 3.3 Explain the "Why"

Bad:
```
rofi  # use this
```

Good:
```
rofi  # Launcher (krunner doesn't work in niri)
```

---

## 4. Verification Script Pattern

When adding automated verification to scripts like `vm-verify.sh`:

### 4.1 Structure

```bash
echo ""
echo "=== TEAM_XXX: <Phase/Feature> Verification ==="

# Define what to check
ITEMS="item1 item2 item3"

# Check each item
for item in $ITEMS; do
    if $SSH_CMD "which $item" &>/dev/null; then
        echo "✓ $item"
    else
        echo "✗ $item NOT FOUND"
    fi
done
```

### 4.2 Benefits

- **Self-documenting**: The script shows what should be present
- **Automated**: Future teams can verify without manual testing
- **Traceable**: Team comments show who added what and why

---

## 5. Checklist Before Finishing

Before ending your session, ask yourself:

- [ ] Did I discover anything that future teams should know?
- [ ] Is there a verification step that should be automated?
- [ ] Did I find a gotcha that isn't obvious from the code?
- [ ] Should this knowledge be in a script, comment, or doc?

If yes to any, document it using the appropriate location from Section 2.

---

## 6. Examples

### 6.1 Adding Package Verification

```bash
# In scripts/vm-verify.sh
echo ""
echo "=== TEAM_443: Phase 4 Package Verification ==="
PHASE4_PACKAGES="waybar rofi mako notify-send swaybg swaylock swayidle wl-copy grim slurp"
for pkg in $PHASE4_PACKAGES; do
    if $SSH_CMD "which $pkg" &>/dev/null; then
        echo "✓ $pkg"
    else
        echo "✗ $pkg NOT FOUND"
    fi
done
```

### 6.2 Documenting a Gotcha in Code

```nix
# TEAM_443: Wayland essentials for niri (Phase 4)
waybar        # Status bar
rofi          # Launcher (krunner doesn't work in niri)
mako          # Notifications
libnotify     # notify-send command (not included by default!)
```

### 6.3 Documenting in Team File

In your team file, include a "Notes" section:

```markdown
## Notes
- `rofi-wayland` has been merged into `rofi` in nixpkgs
- `libnotify` provides `notify-send` command
- Mod+D captured by host VM (Fedora KDE) - can't test in nested VM
```

---

## 7. Summary

1. **Document reusable knowledge**, not task-specific progress
2. **Use the right location**: scripts, code comments, docs, or workflows
3. **Always attribute with team number** for traceability
4. **Automate verification** when possible
5. **Explain the "why"**, not just the "what"
