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
in
{
  home.packages = with pkgs; [
    niri-with-fixed-session
    # rofi
    # waybar
    quickshell
  ];

}