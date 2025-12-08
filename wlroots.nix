{ pkgs, lib, ... }:

let
  # TEAM_001: Use external niri-session wrapper script to avoid inline duplication
  niri-session-fixed = pkgs.writeShellScriptBin "niri-session"
    (builtins.readFile ./scripts/niri-wrapper.sh);

  # Wrap niri to use our fixed niri-session
  niri-with-fixed-session = pkgs.symlinkJoin {
    name = "niri-with-fixed-session";
    paths = [
      niri-session-fixed
      pkgs.niri
    ];
    # Our fixed script comes first, so it shadows the original
    postBuild = ''
      rm -f $out/bin/niri-session
      ln -s ${niri-session-fixed}/bin/niri-session $out/bin/niri-session
    '';
  };

  # TEAM_007: Wrapper to put polkit agent in PATH (binary is in libexec/)
  polkit-gnome-agent = pkgs.writeShellScriptBin "polkit-gnome-agent" ''
    exec ${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1 "$@"
  '';
in
{
  home.packages = with pkgs; [
    niri-with-fixed-session
    # rofi
    # waybar
    quickshell
    qt6.qt5compat

    # TEAM_007: niri session services
    polkit-gnome-agent     # Polkit authentication agent (wrapper)
    networkmanagerapplet   # Network tray applet (nm-applet)
    
    # Blue light filtering for Wayland
    wlsunset              # Day/night gamma adjustments
    swaybg                # Wallpaper setter for Wayland
  ];

  # TEAM_007: GNOME Keyring for secret storage (WiFi passwords)
  # Starts via systemd user service, triggered by graphical-session-pre.target
  # Only enable in wlroots sessions (KDE uses kwallet)
  services.gnome-keyring = {
    enable = true;
    components = [ "secrets" ];
  };

  # TEAM_008: Make gnome-keyring conditional on wlroots sessions
  systemd.user.services.gnome-keyring.Unit.ConditionEnvironment = "XDG_CURRENT_DESKTOP=niri";

  # Blue light filtering service
  services.wlsunset = {
    enable = true;

    # Your location (approx. Amsterdam)
    latitude = 52.37;
    longitude = 4.90;

    # How strong the effect is (lower = stronger curve, but 0.8 is a nice balance)
    gamma = "0.8";

    # Colour temperatures in Kelvin
    # 6500K = normal daylight, 3000–3500K = warm evening light
    temperature = {
      day = 5500;   # slightly warm but still "normal" looking
      night = 4000; # comfortably warm at night without going orange-red
    };

    # Let wlsunset auto-calculate sunrise/sunset from lat/long
    # If you ever want fixed times instead, you can add:
    # sunrise = "07:30";
    # sunset  = "21:00";
  };

  # TEAM_008: Make wlsunset conditional on wlroots sessions
  systemd.user.services.wlsunset.Unit.ConditionEnvironment = "XDG_CURRENT_DESKTOP=niri";

  # TEAM_008: Automatic wallpaper service using swaybg (Niri only)
  systemd.user.services.swaybg = {
    Unit = {
      Description = "Wallpaper setter for Wayland";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session-pre.target" ];
      ConditionEnvironment = "XDG_CURRENT_DESKTOP=niri";
    };
    Service = {
      Type = "simple";
      ExecStart = let
        wallpaperScript = pkgs.writeShellScript "swaybg-wallpaper-setter" ''
          # Only run in Niri sessions
          if [ "$XDG_CURRENT_DESKTOP" != "niri" ]; then
            echo "Not running in Niri session, exiting"
            exit 0
          fi
          
          # Set wallpapers based on monitor names
          # Wallpaper images are named after monitor outputs (e.g., DP-1.png, HDMI-A-1.png)
          
          WALLPAPER_DIR="$HOME/Home-Manager/vince/Pictures/Wallpapers"
          COMMANDS=""
          
          # Get list of connected monitors
          MONITORS=$(niri msg outputs | grep -o '([^)]*)' | tr -d '(' | tr -d ')' | grep -E '^[A-Z]+-[A-Z]*-?[0-9]+$')
          
          for monitor in $MONITORS; do
            WALLPAPER="$WALLPAPER_DIR/$monitor.png"
            if [ -f "$WALLPAPER" ]; then
              COMMANDS="$COMMANDS -o $monitor -i $WALLPAPER"
            fi
          done
          
          # Start swaybg with all monitor wallpapers
          if [ -n "$COMMANDS" ]; then
            swaybg $COMMANDS
          else
            # Fallback: use first available wallpaper for all monitors
            FIRST_WALLPAPER=$(ls "$WALLPAPER_DIR"/*.png 2>/dev/null | head -n1)
            if [ -n "$FIRST_WALLPAPER" ]; then
              swaybg -i "$FIRST_WALLPAPER"
            fi
          fi
        '';
      in "${wallpaperScript}";
      Restart = "on-failure";
      RestartSec = "5s";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

}