# TEAM_018: scrcpy Black Screen Fix - Intel Iris Xe VAAPI

## Problem
User reported scrcpy showing dark/black screen while mirroring Android device.

## Root Cause
- GPU: Intel Alder Lake-P GT2 Iris Xe Graphics (8086:46a6)
- Missing `intel-media-driver` for VAAPI hardware video decoding
- `vainfo` showed: `va_openDriver() returns -1` for both `iHD_drv_video.so` and `i965_drv_video.so`
- scrcpy uses FFmpeg which relies on VAAPI for hardware decoding

## Solution
Added to `/etc/nixos/configuration.nix`:
```nix
hardware.graphics = {
  enable = true;
  extraPackages = with pkgs; [
    intel-media-driver    # VAAPI driver (iHD) for Broadwell+ (required for Iris Xe)
    vpl-gpu-rt            # Intel VPL for Quick Sync Video
    intel-ocl             # OpenCL support
  ];
};
```

## Verification
After rebuild, run:
```bash
nix-shell -p libva-utils --run "vainfo"
```
Should show: `libva info: Found init function __vaDriverInit_1_*` and list supported profiles.

## References
- https://github.com/Genymobile/scrcpy/issues/3229
- https://wiki.nixos.org/wiki/Intel_Graphics
- https://nixos.wiki/wiki/Accelerated_Video_Playback

## Workarounds (if VAAPI still fails)
```bash
# Force software rendering
scrcpy --render-driver=software

# Use different video codec
scrcpy --video-codec=h264

# Disable hardware decoding (scrcpy 2.0+)
scrcpy --video-source=display --no-video-playback --record=file.mkv
# Then play file.mkv with a software player
```

## Status
- [x] Configuration added
- [ ] System rebuild required
- [ ] Verification pending
