# /home/vince/Home-Manager/scripts.nix
# TEAM_015: Package ~/bin scripts as proper Nix derivations
# This ensures they're in PATH for ALL services (systemd, niri, etc.)
{ pkgs, ... }:

let
  # Screenshot tool for Wayland
  screenshot = pkgs.writeShellApplication {
    name = "screenshot";
    runtimeInputs = with pkgs; [
      grim
      slurp
      wl-clipboard
      jq
      coreutils
      libnotify
    ];
    text = ''
      # Usage: screenshot [region|screen|window]
      # Default: region (drag to select area, copies to clipboard)

      MODE="''${1:-region}"
      SCREENSHOTS_DIR="''${HOME}/Pictures/Screenshots"
      mkdir -p "$SCREENSHOTS_DIR"

      TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
      FILENAME="''${SCREENSHOTS_DIR}/screenshot_''${TIMESTAMP}.png"

      case "$MODE" in
          region)
              grim -g "$(slurp)" - | tee "$FILENAME" | wl-copy --type image/png
              ;;
          screen)
              grim - | tee "$FILENAME" | wl-copy --type image/png
              ;;
          window)
              if command -v niri &>/dev/null; then
                  GEOMETRY=$(niri msg -j focused-window 2>/dev/null | jq -r '"\(.x),\(.y) \(.width)x\(.height)"' 2>/dev/null || echo "")
                  if [[ -n "$GEOMETRY" && "$GEOMETRY" != "null,null nullxnull" ]]; then
                      grim -g "$GEOMETRY" - | tee "$FILENAME" | wl-copy --type image/png
                  else
                      grim -g "$(slurp)" - | tee "$FILENAME" | wl-copy --type image/png
                  fi
              else
                  grim -g "$(slurp)" - | tee "$FILENAME" | wl-copy --type image/png
              fi
              ;;
          *)
              echo "Usage: screenshot [region|screen|window]" >&2
              exit 1
              ;;
      esac

      notify-send -t 2000 "Screenshot" "Saved to clipboard and $FILENAME" || true
    '';
  };

  # Wallpaper setter for niri/swaybg
  swaybg-wallpaper-setter = pkgs.writeShellApplication {
    name = "swaybg-wallpaper-setter";
    runtimeInputs = with pkgs; [
      swaybg
      jq
      coreutils
      findutils
      procps
    ];
    text = ''
      # swaybg wallpaper setter for Niri sessions

      log() {
        printf '[niri-wallpaper] %s\n' "$*" >&2
      }

      case "''${XDG_CURRENT_DESKTOP:-}" in
        niri|wlroots) : ;;
        *)
          log "Not running in niri or wlroots session (XDG_CURRENT_DESKTOP=''${XDG_CURRENT_DESKTOP:-unset}), exiting"
          exit 0
          ;;
      esac

      WALLPAPER_DIR="''${HOME}/Home-Manager/vince/Pictures/Wallpapers"

      if [ ! -d "$WALLPAPER_DIR" ]; then
        log "Wallpaper dir not found: $WALLPAPER_DIR"
        exit 0
      fi

      mapfile -t MONITORS < <(
        niri msg --json outputs \
          | jq -r 'keys[]' 2>/dev/null \
          || true
      )

      if [ "''${#MONITORS[@]}" -eq 0 ]; then
        log "No monitors detected from 'niri msg --json outputs'"
      fi

      declare -a ARGS=()

      for monitor in "''${MONITORS[@]}"; do
        for ext in png jpg jpeg; do
          candidate="''${WALLPAPER_DIR}/''${monitor}.''${ext}"
          if [ -f "$candidate" ]; then
            log "Assigning $candidate -> $monitor"
            ARGS+=(-o "$monitor" -i "$candidate")
            break
          fi
        done
      done

      if [ "''${#ARGS[@]}" -eq 0 ]; then
        FIRST_WALLPAPER=$(
          find "$WALLPAPER_DIR" -maxdepth 1 -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' \) \
            | sort \
            | head -n1
        )

        if [ -n "''${FIRST_WALLPAPER:-}" ]; then
          log "Using fallback wallpaper for all monitors: $FIRST_WALLPAPER"
          ARGS=(-i "$FIRST_WALLPAPER")
        else
          log "No wallpapers found in $WALLPAPER_DIR"
          exit 0
        fi
      fi

      pkill -x swaybg 2>/dev/null || true

      log "Starting swaybg: swaybg ''${ARGS[*]}"
      exec swaybg "''${ARGS[@]}"
    '';
  };

  # URL to QR code converter
  url-to-qr = pkgs.writeShellApplication {
    name = "url-to-qr";
    runtimeInputs = with pkgs; [
      qrencode
    ];
    text = ''
      # Share URL to Android via QR code
      # Usage: url-to-qr "https://example.com/video"

      if [ -z "''${1:-}" ]; then
          echo "Usage: url-to-qr <URL>"
          echo "Example: url-to-qr \"https://youtube.com/watch?v=...\""
          exit 1
      fi

      URL="$1"

      echo "QR code for: $URL"
      echo "Scan with your Android tablet camera or QR scanner app"
      echo ""
      qrencode -t ANSI "$URL"

      echo ""
      echo "QR code displayed above. If you need a PNG file, run:"
      echo "qrencode -o qr.png \"$URL\""
    '';
  };

in
{
  home.packages = [
    screenshot
    swaybg-wallpaper-setter
    url-to-qr
  ];
}
