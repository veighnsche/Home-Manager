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

    # TEAM_007: niri session services
    polkit-gnome-agent     # Polkit authentication agent (wrapper)
    networkmanagerapplet   # Network tray applet (nm-applet)
  ];

  # TEAM_007: GNOME Keyring for secret storage (WiFi passwords)
  # Starts via systemd user service, triggered by graphical-session-pre.target
  services.gnome-keyring = {
    enable = true;
    components = [ "secrets" ];
  };
}