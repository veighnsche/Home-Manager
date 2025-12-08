{ config, lib, ... }:

{
  options.myConfig.enableWlroots = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Enable wlroots-specific configuration (Niri, swaybg, etc.)";
  };
}
