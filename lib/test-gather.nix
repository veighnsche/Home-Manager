# Temporary test file to debug gather-files.nix output
# Run: nix eval --json -f test-gather.nix | jq 'keys'
let
  pkgs = import <nixpkgs> {};
  lib = pkgs.lib;
  gatherFiles = import ./lib/gather-files.nix { inherit lib; };
  
  result = gatherFiles {
    path = ./vince;
    mkSource = relPath: "/test/${relPath}";
  };
in
  result
