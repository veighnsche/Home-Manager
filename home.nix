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
    ./kde.nix
    ./wlroots.nix
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
    python314
    gcc
    uv
    libffi
    libffi.dev
    pkg-config
    openssl.dev
    rustc
    cargo

    libreoffice-qt-fresh

    kdePackages.kdeconnect-kde

    hunspell
    hunspellDicts.en_US
    hunspellDicts.nl_NL

    # QR code generation for URL sharing
    qrencode
  ];

  # Environment variables for Python package compilation
  programs.zsh.initContent = ''
    export PKG_CONFIG_PATH="${pkgs.libffi.dev}/lib/pkgconfig:${pkgs.openssl.dev}/lib/pkgconfig"
    export NIX_CFLAGS_COMPILE="-I${pkgs.libffi.dev}/include -I${pkgs.openssl.dev}/include"
  '';

  # Add ~/bin to PATH for global script access
  home.sessionVariables = {
    PATH = "$HOME/bin:$PATH";
  };

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
