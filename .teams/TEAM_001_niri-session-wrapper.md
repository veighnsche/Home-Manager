# TEAM_001 – Niri session wrapper refactor

- **Goal**: Move inline `niri-session` wrapper from `wlroots.nix` into `scripts/niri-wrapper.sh` and wire it via `writeShellScriptBin`.
- **Context**: Avoid deprecated `systemctl --user import-environment` usage while keeping behavior identical.
- **Changes**:
  - Use `builtins.readFile ./scripts/niri-wrapper.sh` in `wlroots.nix`.
  - Fix shell quoting in `scripts/niri-wrapper.sh` so it runs outside Nix string context.
- **Status**: In progress.
