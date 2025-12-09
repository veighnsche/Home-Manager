{ config, pkgs, ... }:

let
  nixified-ai = builtins.getFlake "github:nixified-ai/flake";
in
{
  # =====================================================================
  # IMPORTS
  # =====================================================================
  imports = [
    ./hardware-configuration.nix
    nixified-ai.nixosModules.comfyui
  ];

  # =====================================================================
  # NIX
  # =====================================================================
  nix.settings = {
    trusted-users = [ "root" "vince" ];
    experimental-features = [ "nix-command" "flakes" ];
    # nixified.ai + friends, as recommended in their flake.nix
    trusted-substituters = [
      "https://ai.cachix.org"
      "https://cache.nixos.org/"
      "https://nix-community.cachix.org"
      "https://cuda-maintainers.cachix.org"
      "https://numtide.cachix.org"
    ];
    trusted-public-keys = [
      "ai.cachix.org-1:N9dzRK+alWwoKXQlnn0H6aUx0lU/mspIoz8hMvGvbbc="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
      "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
    ];
  };

  nixpkgs.config.allowUnfree = true;

  # =====================================================================
  # BOOTLOADER
  # =====================================================================
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  # =====================================================================
  # NETWORKING
  # =====================================================================
  networking = {
    hostName = "workstation";
    networkmanager.enable = true;
  };

  # =====================================================================
  # TIMEZONE & LOCALIZATION
  # =====================================================================
  time.timeZone = "Europe/Amsterdam";

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "nl_NL.UTF-8";
      LC_IDENTIFICATION = "nl_NL.UTF-8";
      LC_MEASUREMENT = "nl_NL.UTF-8";
      LC_MONETARY = "nl_NL.UTF-8";
      LC_NAME = "nl_NL.UTF-8";
      LC_NUMERIC = "nl_NL.UTF-8";
      LC_PAPER = "nl_NL.UTF-8";
      LC_TELEPHONE = "nl_NL.UTF-8";
      LC_TIME = "nl_NL.UTF-8";
    };
  };

  # =====================================================================
  # GRAPHICAL ENVIRONMENT
  # =====================================================================
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  hardware.graphics.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = false;

    # For now, stick with the proprietary driver (more stable than "open")
    open = false;

    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # =====================================================================
  # USERS
  # =====================================================================
  users.users.vince = {
    isNormalUser = true;
    description = "vince";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];
  };

  # =====================================================================
  # SYSTEM PACKAGES
  # =====================================================================
  environment.defaultPackages = with pkgs; [
    uutils-coreutils-noprefix
    uutils-findutils
    pfetch
  ];

  security.sudo-rs.enable = true;

  # =====================================================================
  # PROGRAMS & SERVICES
  # =====================================================================
  # Enable the OpenSSH daemon
  services.openssh.enable = true;

  # Allow generic Linux binaries (like Windsurf's remote server) to run
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc
      zlib
      curl
      openssl
    ];
  };

  # =====================================================================
  # COMFYUI (nixified.ai)
  # =====================================================================
  services.comfyui = {
    enable = true;
    package = nixified-ai.packages.${pkgs.system}.comfyui-nvidia;

    # Listen on all interfaces so other machines on your LAN can reach it
    host = "0.0.0.0";
    port = 8188; # default, but explicit is nice

    # Let NixOS open the firewall for the configured port
    openFirewall = true;

    # Optional: restrict to TCP only (default), no need to touch UDP
  };

  # =====================================================================
  # SHELL
  # =====================================================================
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      ll = "eza -alh";
      ls = "eza";
      la = "eza -a";
      lt = "eza --tree";
      gs = "git status";
      gd = "git diff";
      gc = "git commit";
      gp = "git push";
      gl = "git log --oneline -20";
      cat = "bat";
      ping = "prettyping --nolegend";
    };

    ohMyZsh = {
      enable = true;
      theme = "robbyrussell";  # Overridden by Starship
      plugins = [
        "git"
        "sudo"
        "command-not-found"
        "colored-man-pages"
        "history"
      ];
    };
  };

  # ════════════════════════════════════════════════════════════════
  # Starship Prompt
  # ════════════════════════════════════════════════════════════════
  programs.starship = {
    enable = true;
    # enableZshIntegration = true;

    settings = {
      add_newline = false;

      palette = "darkwall";
      palettes.darkwall = {
        bg     = "#1a1a1a";
        fg     = "#e0e0e0";
        accent = "#7aa2f7";
        error  = "#f7768e";
        subtle = "#565f89";
      };

      # 1st line: directory (so `~`)
      # 2nd line: vince@blep >
      format = "$directory$line_break$username@$hostname $character";

      username = {
        show_always = true;
        format = "[$user](fg:fg)";
      };

      hostname = {
        ssh_only = false; # show even when not over SSH
        format = "[$hostname](fg:accent)";
      };

      character = {
        success_symbol = "[>](fg:accent)";
        error_symbol   = "[>](fg:error)";
      };

      battery.disabled = true;
    };
  };

  # ════════════════════════════════════════════════════════════════
  # Zoxide (smart cd)
  # ════════════════════════════════════════════════════════════════
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  # =====================================================================
  # FIREWALL
  # =====================================================================
  # Open ports in the firewall
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether
  # networking.firewall.enable = false;

  # =====================================================================
  # SYSTEM VERSION
  # =====================================================================
  system.stateVersion = "26.05"; # Did you read the comment?
}
