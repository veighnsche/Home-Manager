{
  description = "Vince's standalone Home Manager config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      # strongly recommended so you don't get mismatched nixpkgs
      inputs.nixpkgs.follows = "nixpkgs";
    };

    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    quickshell = {
      # add ?ref=<tag> to pin if you want
      url = "git+https://git.outfoxxed.me/quickshell/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    codex-cli-nix = {
      url = "github:sadjow/codex-cli-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, plasma-manager, quickshell, codex-cli-nix, ... }:
    let
      codexOverlay = final: prev: {
        codex = codex-cli-nix.packages.${final.stdenv.hostPlatform.system}.default;
      };

      overlays = [
        # Quickshell overlay so pkgs.quickshell exists
        quickshell.overlays.default

        # Codex overlay so pkgs.codex is our custom flake package
        codexOverlay

        # Your Windsurf overlay
        (final: prev: {
          windsurf = final.callPackage ./pkgs/windsurf/package.nix {
            inherit (final) nixosTests;
            vscode-generic =
              nixpkgs + "/pkgs/applications/editors/vscode/generic.nix";
          };
        })
      ];

      pkgs = import nixpkgs {
        system = "x86_64-linux";
        inherit overlays;
        config = {
          allowUnfree = true;
          android_sdk.accept_license = true;
        };
      };
    in {
      homeConfigurations."vince" =
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;

          modules = [
            plasma-manager.homeModules.plasma-manager
            ./home.nix
          ];
        };
    };
}
