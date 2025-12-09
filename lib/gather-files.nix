# /home/vince/Home-Manager/lib/gather-files.nix
#
# Recursively gathers files from a directory and produces an attrset suitable
# for use with `home.file`.
#
# Features:
# - Supports a marker file (e.g. ".symlink-folder") to symlink a whole folder.
# - Skips the marker file itself.
# - Optional filtering of relative paths.
# - Optional recursion into non-marked directories.
#
# Usage:
#   let
#     gatherFiles = import ./lib/gather-files.nix { inherit lib; };
#   in
#     gatherFiles {
#       path = ./vince;
#       mkSource = relPath:
#         config.lib.file.mkOutOfStoreSymlink "/absolute/path/${relPath}";
#     }

{ lib }:

{ path
, mkSource
, force ? true
, markerFile ? ".symlink-folder"
, includeDirsWithoutMarker ? true
, filterRelPath ? (_: true)
}:

let
  inherit (lib) concatMapAttrs assertMsg;

  # Simple sanity check so failures are easier to debug
  _ = assertMsg (builtins.pathExists path)
    "gather-files: path '${builtins.toString path}' does not exist";

  gatherFilesRec = prefix: currentPath:
    let
      contents = builtins.readDir currentPath;
    in
    concatMapAttrs
      (name: type:
        let
          rel = if prefix == "" then name else "${prefix}/${name}";
          fullPath = currentPath + "/${name}";
        in
        # Skip the marker file itself anywhere
        if markerFile != null && name == markerFile then
          { }
        else if type == "regular" || type == "symlink" then
          if filterRelPath rel then
            {
              "${rel}" = {
                source = mkSource rel;
                inherit force;
              };
            }
          else
            { }
        else if type == "directory" then
          let
            dirContents = builtins.readDir fullPath;
            hasMarker =
              markerFile != null
              && builtins.hasAttr markerFile dirContents
              && dirContents.${markerFile} == "regular";
          in
          if hasMarker then
            # Symlink the folder itself
            if filterRelPath rel then
              {
                "${rel}" = {
                  source = mkSource rel;
                  inherit force;
                };
              }
            else
              { }
          else if includeDirsWithoutMarker then
            # Recurse into non-marked directories
            gatherFilesRec rel fullPath
          else
            { }
        else
          # Ignore other file types (sockets, fifos, etc.)
          { }
      )
      contents;
in
  gatherFilesRec "" path
