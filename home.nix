# /home/vince/Home-Manager/home.nix
{ config, pkgs, lib, ... }:

let
  repoPath = "/home/vince/Home-Manager";
  vincePathString = "${repoPath}/vince";
  vincePath = ./vince;

  mkSymlink = relPath: config.lib.file.mkOutOfStoreSymlink "${vincePathString}/${relPath}";

  gatherFiles = prefix: path:
    let
      contents = builtins.readDir path;
    in
      lib.attrsets.concatMapAttrs
        (name: type:
          let
            rel = if prefix == "" then name else "${prefix}/${name}";
            fullPath = path + "/${name}";
          in
            if type == "regular" || type == "symlink" then
              {
                "${rel}" = {
                  source = mkSymlink rel;
                  force = true;
                };
              }
            else if type == "directory" then
              gatherFiles rel fullPath
            else
              { }
        )
        contents;

  vinceFiles = gatherFiles "" vincePath;
in
{
  imports = [
    ./shell.nix
  ];

  # Tell Home Manager which user this config is for
  home.username = "vince";
  home.homeDirectory = "/home/vince";

  # Home Manager version (when you started using it)
  home.stateVersion = "26.05";

  # User packages
  home.packages = with pkgs; [
    windsurf
    nodejs_24
    uv
    niri
    rofi
  ];

  # Allow managing HM itself via this config
  programs.home-manager.enable = true;

  # Basic git config
  programs.git = {
    enable = true;
    settings = {
      user.name = "vince";
      user.email = "vince@vince";
    };
  };

  programs.ssh = {
    enable = true;

    # stop using the old implicit defaults
    enableDefaultConfig = false;

    matchBlocks = {
      "*" = {
        identityFile = [ "~/.ssh/id_ed25519" ];
        identitiesOnly = true;
        addKeysToAgent = "yes";  # modern replacement for the old top-level option
        userKnownHostsFile = "~/.ssh/known_hosts";
        # you can add more defaults here later
      };
    };
  };

  # SSH agent
  services.ssh-agent.enable = true;

  home.file = vinceFiles;
}
