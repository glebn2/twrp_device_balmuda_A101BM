# TWRP device tree for BALMUDA Phone (A101BM / X01A)

**English** | [Русский](#русский)

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
- The bootloader must be unlocked. One-button tool: [balmunlock](https://github.com/glebn2/balmunlock).

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

`patches/` holds fixes for `bootable/recovery`, `system/vold` and `external/lptools` (see the commit
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

---

## Русский

TWRP 3.7.1 (twrp-12.1) для BALMUDA Phone, Qualcomm SM7250 (`lito`).
Один образ подходит для обеих моделей, A101BM и X01A.

Готовые образы — на странице [Releases](../../releases).

### Возможности

- Расшифровка `/data` (FBE v2 + шифрование метаданных): стоковая прошивка и LineageOS,
  с PIN-кодом или графическим ключом и без них.
- MTP, ADB, sideload, fastbootd, USB OTG (FAT32; exFAT и NTFS через FUSE).
- Резервное копирование и восстановление; boot, dtbo, vbmeta, persist и EFS доступны как разделы-образы.
- Правильный уровень заряда, экран гаснет по таймауту.
- Format Data сохраняет логические разделы подключёнными, поэтому zip прошивки, GApps и Magisk
  можно ставить сразу после него.
- GMS fix для MindTheGapps 17: в штатном ядре нет EROFS, поэтому при
  Reboot → System TWRP переносит Play services из их APEX в `/product/priv-app`.
  Срабатывает только когда нужно; чтобы отключить, создайте `/sdcard/TWRP/.no_gmsfix`.

### Примечания

- **Заголовок boot-образа.** Keymaster привязывает ключи шифрования к версии ОС и уровню
  патчей из заголовка boot-образа. Этот TWRP использует стоковые значения (`11.0.0` / `2023-09`).
  Прошивку, у которой в boot-образе другие значения, расшифровать нельзя; TWRP об этом сообщает,
  выход — Wipe → Format Data. LineageOS для BALMUDA Phone использует стоковые значения.
- **A/B.** В телефоне отдельные разделы `recovery_a` / `recovery_b`.
  Прошивайте TWRP в recovery активного слота.
- Загрузчик должен быть разблокирован. Утилита разблокировки в одну кнопку:
  [balmunlock](https://github.com/glebn2/balmunlock).

### Установка

```
fastboot boot TWRP-3.7.1_12-BALMUDA_Phone-<дата>.img
```

Чтобы оставить его насовсем, прошейте его из TWRP (Install → Install Image → Recovery) или так:

```
fastboot flash recovery_b TWRP-3.7.1_12-BALMUDA_Phone-<дата>.img   # или recovery_a, если активен слот a
```

### Сборка

Команды — в разделе [Build](#build). Образ: `out/target/product/A101BM/recovery.img`.

В `patches/` — исправления для `bootable/recovery`, `system/vold` и `external/lptools`
(подробности — в описании коммита каждого патча).

### Готовые файлы

- `prebuilt/kernel`, `prebuilt/dtb/stock.dtb`, `prebuilt/dtbo.img`: штатные ядро,
  DTB и DTBO из recovery-образа прошивки 1.280 (не пересобраны из исходников).
- `recovery/root`: штатные бинарники vendor для расшифровки, батареи и управления загрузкой,
  с происхождением и SHA-256 в `proprietary-files-recovery.csv`.
- `recovery/root/system/bin/fsck.erofs`: собран из `external/erofs-utils`
  (`fsck.erofs.recovery`) LineageOS 24, используется GMS fix.

### Лицензия

Дерево устройства распространяется по лицензии Apache-2.0. TWRP и патчи в `patches/`
следуют лицензиям проектов, к которым они применяются. Проприетарные файлы принадлежат
их правообладателям.
