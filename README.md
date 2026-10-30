# TWRP device tree for BALMUDA Phone (A101BM / X01A)

TWRP 3.7.1 (twrp-12.1) for BALMUDA Phone, Qualcomm SM7250 (`lito`).
One image works on both models, A101BM and X01A.

Prebuilt images are on the [Releases](../../releases) page.

## Features

- Decryption of `/data` (FBE v2 + metadata encryption): stock ROM and LineageOS,
  with or without a PIN or pattern.
- MTP, ADB, sideload, fastbootd, USB OTG (FAT32; exFAT and NTFS via FUSE).
- Backup and restore; boot, dtbo, vbmeta, persist and EFS are available as image partitions.
- Correct battery level, screen off on timeout.
- Format Data keeps the logical partitions mapped, so ROM, GApps and Magisk zips
  can be installed right after it.
- GMS fix for MindTheGapps 17: the stock kernel has no EROFS, so on
  Reboot → System TWRP moves Play services from their APEX to `/product/priv-app`.
  It runs only when needed; create `/sdcard/TWRP/.no_gmsfix` to disable it.

## Notes

- **Boot image header.** Keymaster binds the encryption keys to the OS version and
  patch level in the boot image header. This TWRP uses the stock values
  (`11.0.0` / `2023-09`). A ROM whose boot image has other values cannot be decrypted;
  TWRP says so, and Wipe → Format Data is the way out. LineageOS for BALMUDA Phone
  uses the stock values in its boot image header.
- **A/B.** The phone has separate `recovery_a` / `recovery_b` partitions.
  Flash TWRP to the recovery partition of the active slot.
- The bootloader must be unlocked.

## Install

```
fastboot boot TWRP-3.7.1_12-BALMUDA_Phone-<date>.img
```

To keep it, flash it from TWRP (Install → Install Image → Recovery), or:

```
fastboot flash recovery_b TWRP-3.7.1_12-BALMUDA_Phone-<date>.img   # or recovery_a if slot a is active
```

## Build

```
repo init --depth=1 -u https://github.com/minimal-manifest-twrp/platform_manifest_twrp_aosp.git -b twrp-12.1
repo sync
git clone -b twrp-12.1 https://github.com/glebn2/twrp_device_balmuda_A101BM device/balmuda/A101BM
device/balmuda/A101BM/patches/apply.sh
. build/envsetup.sh
lunch twrp_A101BM-eng
mka recoveryimage
```

The image is `out/target/product/A101BM/recovery.img`.

`patches/` holds fixes for `bootable/recovery` and `system/vold` (see the commit
messages in each patch).

## Prebuilts

- `prebuilt/kernel`, `prebuilt/dtb/stock.dtb`, `prebuilt/dtbo.img`: stock kernel,
  DTB and DTBO from the recovery image of firmware 1.280 (not rebuilt from source).
- `recovery/root`: stock vendor binaries needed for decryption, battery and
  boot control, listed with their origin and SHA-256 in `proprietary-files-recovery.csv`.
- `recovery/root/system/bin/fsck.erofs`: built from `external/erofs-utils`
  (`fsck.erofs.recovery`) of LineageOS 24, used by the GMS fix.

## License

The device tree is licensed under Apache-2.0. TWRP and the patches in `patches/`
follow the licenses of the projects they apply to. Proprietary files belong to
their respective owners.
