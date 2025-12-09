# /home/vince/Home-Manager/dev.nix
# TEAM_016: Development environment - Android SDK, languages, and tooling
{ config, pkgs, lib, ... }:

let
  # Android SDK composition
  androidComposition = pkgs.androidenv.composeAndroidPackages {
    # Command line tools
    cmdLineToolsVersion = "11.0";
    
    # Platform tools (adb, fastboot)
    platformToolsVersion = "35.0.2";
    
    # Build tools versions
    buildToolsVersions = [ "34.0.0" "35.0.0" ];
    
    # Android platform versions (API levels)
    platformVersions = [ "34" "35" ];
    
    # ABI versions for emulator/native code
    abiVersions = [ "x86_64" "arm64-v8a" ];
    
    # Include emulator
    includeEmulator = true;
    
    # Include NDK for native development
    includeNDK = true;
    ndkVersions = [ "26.3.11579264" ];
    
    # Include system images for emulator
    includeSystemImages = true;
    systemImageTypes = [ "google_apis" ];
    
    # Extra packages
    extraLicenses = [
      "android-googletv-license"
      "android-sdk-arm-dbt-license"
      "android-sdk-license"
      "android-sdk-preview-license"
      "google-gdk-license"
      "intel-android-extra-license"
      "intel-android-sysimage-license"
      "mips-android-sysimage-license"
    ];
  };

  androidSdk = androidComposition.androidsdk;
in
{
  # Development packages
  home.packages = with pkgs; [
    # Android development
    androidSdk
    android-tools  # Additional Android tools (adb, fastboot standalone)
    scrcpy  # Screen mirroring/control for Android
    # android-studio  # Uncomment if you want the full IDE
    
    # Languages & runtimes
    nodejs_24
    python314
    
    # Build tools
    gcc
    uv
    libffi
    libffi.dev
    pkg-config
    openssl.dev
    
    # Rust
    rustc
    cargo
    
    # Nix language servers
    nixd
    nil
    
    # Java (required for Android development)
    jdk17
  ];

  # Environment variables for development
  home.sessionVariables = {
    ANDROID_HOME = "${androidSdk}/libexec/android-sdk";
    ANDROID_SDK_ROOT = "${androidSdk}/libexec/android-sdk";
  };

  # Add Android SDK tools to PATH and set up Python compilation env
  programs.zsh.initContent = lib.mkAfter ''
    # Android SDK
    export PATH="$ANDROID_HOME/platform-tools:$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin:$PATH"
    
    # Python package compilation
    export PKG_CONFIG_PATH="${pkgs.libffi.dev}/lib/pkgconfig:${pkgs.openssl.dev}/lib/pkgconfig"
    export NIX_CFLAGS_COMPILE="-I${pkgs.libffi.dev}/include -I${pkgs.openssl.dev}/include"
  '';
}
