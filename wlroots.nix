{ pkgs, ... }:

{
  home.packages = with pkgs; [
    niri
    rofi
    waybar
  ];

}