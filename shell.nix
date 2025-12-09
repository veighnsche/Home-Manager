# TEAM_426: Shell configuration for vince
{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    # Better CLI tools (upgrades from common/)
    bat # cat with syntax highlighting
    eza # ls replacement
    ripgrep # fast grep
    fd # find replacement
    fzf # fuzzy finder
    jq # JSON processor
    yq-go # YAML processor

    # Remote access
    mosh

    # Network tools
    prettyping
    httpie

    btop
  ];

  # ════════════════════════════════════════════════════════════════
  # ZSH
  # ════════════════════════════════════════════════════════════════
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    history = {
      size = 10000;
      path = "${config.xdg.dataHome}/zsh/history";
    };

    initContent = ''
      # Autosuggestion color (WCAG-compliant on dark background)
      ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#94a3b8'

      # History behavior
      setopt HIST_IGNORE_DUPS
      setopt HIST_IGNORE_ALL_DUPS
      setopt HIST_REDUCE_BLANKS
      setopt SHARE_HISTORY
      setopt APPEND_HISTORY
    '';

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

      # TEAM_017: Force OpenGL renderer to fix black screen on Wayland
      scrcpy = "scrcpy --render-driver=opengl";

      hm = "nix run home-manager/master -- switch --flake /home/vince/Home-Manager#vince -b backup";
      hmn = "nix run home-manager/master -- news --flake /home/vince/Home-Manager#vince -b backup";
    };

    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell"; # Overridden by Starship
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
    enableZshIntegration = true;

    settings = {
      add_newline = false;

      palette = "darkwall";
      palettes.darkwall = {
        bg = "#1a1a1a";
        fg = "#e0e0e0";
        accent = "#7aa2f7";
        error = "#f7768e";
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
        error_symbol = "[>](fg:error)";
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

  # ════════════════════════════════════════════════════════════════
  # Direnv
  # ════════════════════════════════════════════════════════════════
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  programs.ssh = {
    enable = true;

    # stop using the old implicit defaults
    enableDefaultConfig = false;

    matchBlocks = {
      # Global defaults for all hosts
      "*" = {
        identityFile = [ "~/.ssh/id_ed25519" ];
        identitiesOnly = true;
        addKeysToAgent = "yes";
        userKnownHostsFile = "~/.ssh/known_hosts";
      };

      # Specific override for workstation
      workstation = {
        hostname = "192.168.178.29";
        user = "vince";
        forwardAgent = true;
        # inherits identityFile etc from "*" unless you override them here
      };
    };
  };

}
