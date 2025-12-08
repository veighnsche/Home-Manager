# /home/vince/Home-Manager/lib/gather-files.nix
#
# Recursively gathers files from a directory and creates symlink entries
# for home.file. Isolated for easier upgrades and reuse.
#
# Usage:
#   let
#     gatherFiles = import ./lib/gather-files.nix { inherit lib; };
#   in
#     gatherFiles {
#       path = ./vince;
#       mkSource = relPath: config.lib.file.mkOutOfStoreSymlink "/absolute/path/${relPath}";
#     }

{ lib }:

{ path, mkSource, force ? true }:

let
  gatherFilesRec = prefix: currentPath:
    let
      contents = builtins.readDir currentPath;
    in
      lib.attrsets.concatMapAttrs
        (name: type:
          let
            rel = if prefix == "" then name else "${prefix}/${name}";
            fullPath = currentPath + "/${name}";
          in
            if type == "regular" || type == "symlink" then
              {
                "${rel}" = {
                  source = mkSource rel;
                  inherit force;
                };
              }
            else if type == "directory" then
              gatherFilesRec rel fullPath
            else
              { }
        )
        contents;
in
  gatherFilesRec "" path
