{
  description = "Vince's standalone Home Manager config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager";

    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs = { nixpkgs, home-manager, plasma-manager, ... }:
    let
      system = "x86_64-linux";

      overlays = [
        (final: prev: {
          windsurf = final.callPackage ./pkgs/windsurf/package.nix {
            inherit (final) nixosTests;
            vscode-generic = nixpkgs + "/pkgs/applications/editors/vscode/generic.nix";
          };
        })
      ];
      
      pkgs = import nixpkgs { 
        inherit system; 
        config.allowUnfree = true; 
        overlays = overlays;
      };
    in {
      homeConfigurations."vince" =
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            # plasma-manager.homeManagerModules.plasma-manager the homeManagerModules is the old name
            plasma-manager.homeModules.plasma-manager
            ./home.nix
          ];
        };
    };
}
