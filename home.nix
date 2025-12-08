# /home/vince/Home-Manager/home.nix
{ config, pkgs, lib, ... }:

let
  repoPath = "/home/vince/Home-Manager";
  vincePathString = "${repoPath}/vince";

  gatherFiles = import ./lib/gather-files.nix { inherit lib; };

  vinceFiles = gatherFiles {
    path = ./vince;
    mkSource = relPath: config.lib.file.mkOutOfStoreSymlink "${vincePathString}/${relPath}";
  };
in
{
  imports = [
    ./shell.nix
    ./wlroots.nix
    ./kde.nix
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

    libreoffice-qt-fresh

    hunspell
    hunspellDicts.en_US
    hunspellDicts.nl_NL
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
