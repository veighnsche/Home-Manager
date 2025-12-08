#!/usr/bin/env bash
set -euo pipefail

# TEAM_001: Root niri-session wrapper
# Define the variables to import explicitly
IMPORT_VARS="DISPLAY WAYLAND_DISPLAY XDG_SESSION_TYPE XDG_CURRENT_DESKTOP PATH HOME USER SHELL LANG LC_ALL XDG_RUNTIME_DIR DBUS_SESSION_BUS_ADDRESS"

log() {
  printf '[niri-session] %s\n' "$*" >&2
}

die() {
  log "ERROR: $*"
  exit 1
}

# Ensure niri exists early
if ! command -v niri >/dev/null 2>&1; then
  die "niri binary not found in PATH"
fi

# Detect if being run as a user service
if [ -n "${MANAGERPID:-}" ] && [ "${SYSTEMD_EXEC_PID:-}" = "$$" ]; then
  case "$(ps -p "$MANAGERPID" -o cmd= 2>/dev/null || true)" in
    *systemd*--user*)
      exec niri --session
      ;;
  esac
fi

# Re-exec via the user's login shell (if valid) to get a full login environment
# Relaunch via user's login shell through bash for POSIX consistency
if [ -n "${SHELL:-}" ] &&
   grep -Fx "${SHELL}" /etc/shells 2>/dev/null &&
   ! printf '%s\n' "$SHELL" | grep -qE '(false|nologin)'; then
  if [ "${1:-}" != "-l" ]; then
    exec bash -c 'exec -l "$SHELL" -c "$0 -l $*"' niri-session "$@"
  else
    shift
  fi
fi


# Prefer systemd user instance if available
if command -v systemctl >/dev/null 2>&1; then
  log "Using systemd user session"

  # Check that systemd user instance is reachable
  if ! systemctl --user show-environment >/dev/null 2>&1; then
    die "systemd user instance not reachable; is it running?"
  fi

  if systemctl --user -q is-active niri.service; then
    die "A niri session is already running."
  fi

  systemctl --user reset-failed || true

  # Only import variables that are set in this environment
  env_args=()
  for var in $IMPORT_VARS; do
    if [ -n "${!var-}" ]; then
      env_args+=("$var")
    fi
  done

  if [ "${#env_args[@]}" -gt 0 ]; then
    systemctl --user import-environment "${env_args[@]}"
  else
    log "No environment variables to import to systemd user environment"
  fi

  if command -v dbus-update-activation-environment >/dev/null 2>&1; then
    dbus-update-activation-environment --all || log "dbus-update-activation-environment failed (non-fatal)"
  fi

  # Optional: make sure niri.service stops if we are interrupted
  trap 'log "Interrupted; asking systemd to stop niri.service"; systemctl --user stop niri.service || true' INT TERM

  if ! systemctl --user --wait start niri.service; then
    die "Failed to start niri.service"
  fi

  systemctl --user start --job-mode=replace-irreversibly niri-shutdown.target || \
    log "Failed to start niri-shutdown.target (non-fatal)"

  systemctl --user unset-environment WAYLAND_DISPLAY DISPLAY XDG_SESSION_TYPE XDG_CURRENT_DESKTOP NIRI_SOCKET || \
    log "Failed to unset some environment variables (non-fatal)"

# Fallback to dinit user instance
elif command -v dinitctl >/dev/null 2>&1; then
  log "Using dinit user session"

  if ! pgrep -xu "$(id -u)" dinit >/dev/null 2>&1; then
    die "dinit user daemon is not running."
  fi

  if dinitctl --user is-started niri >/dev/null 2>&1; then
    die "A niri session is already running."
  fi

  dinitctl --user start niri || die "Failed to start niri (dinit)"

else
  die "No systemd or dinit detected; please use 'niri --session' directly."
fi
