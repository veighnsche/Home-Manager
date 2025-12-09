# /home/vince/Home-Manager/lib/gather-files.nix
#
# Recursively gathers files from a directory and produces an attrset suitable
# for use with `home.file`.
#
# Conceptually:
# - Think: a pure function `Dir -> { "relative/path" = { source = ...; force = ...; }; ... }`
# - You pass in:
#     - `path`: root directory to scan (Nix path)
#     - `mkSource`: function `relPath -> sourceValue` (you decide what "source" means)
#     - some options (marker file name, whether to recurse into dirs, filter function)
#
# Features:
# - Supports a marker file (e.g. ".symlink-folder") to symlink a whole folder.
# - Skips the marker file itself.
# - Optional filtering of relative paths.
# - Optional recursion into non-marked directories.
#
# Example usage (inside a Home Manager module):
#
#   let
#     gatherFiles = import ./lib/gather-files.nix { inherit lib; };
#   in
#   {
#     home.file = gatherFiles {
#       path = ./vince;
#       mkSource = relPath:
#         # You decide how to turn the relative path into a source.
#         # For example: use an out-of-store symlink from some absolute path:
#         config.lib.file.mkOutOfStoreSymlink "/absolute/path/${relPath}";
#     };
#   }
#
# NOTE:
# - This file exports a *function factory*:
#     ({ lib }: { path, mkSource, ... } -> attrset)
# - First call: provide `lib` from Nixpkgs.
# - Second call: provide your parameters (path, mkSource, etc).

{ lib }:

# Second function: takes a single attribute set with parameters.
{ path
, mkSource
, force ? true
, markerFile ? ".symlink-folder"
, includeDirsWithoutMarker ? true
, filterRelPath ? (_: true)
}:

let
  # Pull a few helpers from `lib` into scope.
  # - `concatMapAttrs` ~ "flatMap" over attribute sets
  # - `assertMsg`      ~ assertion with a custom error message
  inherit (lib) concatMapAttrs assertMsg;

  # --- Sanity check ------------------------------------------------------
  #
  # At evaluation time (not at runtime like in Rust/TS), we check if
  # the given `path` actually exists. If it doesn't, we fail early
  # with a readable error message. This helps a lot when debugging.
  #
  # `_` is a throwaway binding; we don't use it, we just force
  # the assertion to be evaluated.
  _ = assertMsg (builtins.pathExists path)
    "gather-files: path '${builtins.toString path}' does not exist";

  # --- Recursive worker function ----------------------------------------
  #
  # gatherFilesRec : String -> Path -> Attrset
  #
  # - `prefix`:
  #     - relative path from the *root `path`* to the current directory
  #     - used as the key prefix ("sub/dir/file.txt")
  # - `currentPath`:
  #     - the absolute Nix path we are currently reading (`path` or a subdir)
  #
  # This function returns an attrset of the shape:
  #   {
  #     "relative/path" = {
  #       source = mkSource "relative/path";
  #       force  = force;
  #     };
  #     ...
  #   }
  #
  gatherFilesRec = prefix: currentPath:
    let
      # `builtins.readDir` returns an attribute set:
      #   { "<name>" = "<type>"; ... }
      #
      # where <type> is a string such as:
      #   "regular"  - normal file
      #   "directory"
      #   "symlink"
      #   "socket", "fifo", ...
      contents = builtins.readDir currentPath;
    in
    # `concatMapAttrs`:
    # - Like `Array.prototype.flatMap` but for attribute sets:
    #   (name: value: Attrset) -> Attrset
    # - We traverse all entries in `contents`, and each entry
    #   can return either:
    #     - an empty attrset `{}` (skip)
    #     - or a single/multiple entries to be merged into the final result.
    concatMapAttrs
      (name: type:
        let
          # rel : String
          # - `name` relative to the *root* `path`
          # - If `prefix == ""`, we are at the root; otherwise we nest.
          rel =
            if prefix == "" then
              name
            else
              "${prefix}/${name}";

          # fullPath : Path
          # - actual filesystem path to this entry
          fullPath = currentPath + "/${name}";
        in
        # === Case 1: marker file itself ==================================
        #
        # If this file is the marker (e.g. ".symlink-folder"),
        # we *always* skip it. We never create a home.file entry for it.
        if markerFile != null && name == markerFile then
          { }

        # === Case 2: normal files (regular or symlink) ===================
        else if type == "regular" || type == "symlink" then
          # First apply the user-provided filter on the relative path.
          if filterRelPath rel then
            {
              # Create one entry in the attrset:
              #   "<rel>" = { source = ...; force = ...; }
              "${rel}" = {
                # `mkSource rel` is caller-controlled:
                # they decide how the relative path maps to a "source".
                source = mkSource rel;

                # `force` is passed through to `home.file.<name>.force`.
                inherit force;
              };
            }
          else
            # If filter says "no", skip this file.
            { }

        # === Case 3: directories =========================================
        else if type == "directory" then
          let
            # Read contents of the directory so we can see if
            # it has a marker file in it.
            dirContents = builtins.readDir fullPath;

            # hasMarker : Bool
            # - true if:
            #   - markerFile is not null
            #   - the directory has an entry with that name
            #   - and that entry is a regular file
            hasMarker =
              markerFile != null
              && builtins.hasAttr markerFile dirContents
              && dirContents.${markerFile} == "regular";
          in
          # --- Case 3a: directory with marker file -----------------------
          #
          # We treat the *directory itself* as a single home.file entry,
          # i.e. we do NOT recurse into it.
          if hasMarker then
            if filterRelPath rel then
              {
                "${rel}" = {
                  # Again, caller decides what this means.
                  # Typically you'd symlink the whole folder.
                  source = mkSource rel;
                  inherit force;
                };
              }
            else
              # Directory is marked, but filtered out -> skip entirely.
              { }

          # --- Case 3b: directory without marker file --------------------
          #
          # If `includeDirsWithoutMarker` is true, recurse into it.
          else if includeDirsWithoutMarker then
            # NOTE:
            # - We pass `rel` as the new prefix (so nested paths are built up).
            # - `fullPath` is the actual filesystem location.
            gatherFilesRec rel fullPath
          else
            # If recursion into unmarked dirs is disabled, skip the directory.
            { }

        # === Case 4: everything else (sockets, fifos, etc.) ==============
        else
          # Ignore special files; they don't map nicely to `home.file`.
          { }
      )
      contents;
in
  # Start recursion at the root:
  # - `prefix = ""` (no relative path yet)
  # - `currentPath = path` (caller-supplied root)
  gatherFilesRec "" path
