# /home/vince/Home-Manager/home.nix
{
  config,
  pkgs,
  lib,
  ...
}:

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
    ./kde.nix
    ./wlroots.nix
    ./scripts.nix  # TEAM_015: Package ~/bin scripts as Nix derivations
    ./dev.nix      # TEAM_016: Development environment (Android SDK, languages, tooling)
  ];

  # Tell Home Manager which user this config is for
  home.username = "vince";
  home.homeDirectory = "/home/vince";

  # Home Manager version (when you started using it)
  home.stateVersion = "26.05";

  # User packages (dev tools in dev.nix)
  home.packages = with pkgs; [
    fastfetch
    
    # Editors
    windsurf
    zed-editor
    helix
    codex

    # Media
    vlc

    # Office
    libreoffice-qt-fresh

    kdePackages.kdeconnect-kde
    kdePackages.qtdeclarative

    hunspell
    hunspellDicts.en_US
    hunspellDicts.nl_NL

  ];

  # TEAM_015: ~/bin in PATH for any manual scripts (main scripts are now Nix derivations in scripts.nix)
  home.sessionPath = [
    "$HOME/bin"
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
        addKeysToAgent = "yes"; # modern replacement for the old top-level option
        userKnownHostsFile = "~/.ssh/known_hosts";
        # you can add more defaults here later
      };
    };
  };

  # SSH agent
  services.ssh-agent.enable = true;

  home.file = vinceFiles;
}
