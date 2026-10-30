#!/system/bin/sh
# GMS fix, run by TWRP on Reboot -> System (not on "adb reboot").
# The stock kernel has no EROFS, so the Play services APEX of MindTheGapps 17
# (com.google.android.gmssystem, EROFS payload) cannot be activated. This moves the
# unmodified GmsCore APK and its permission files from the APEX to /product/priv-app.
# Does nothing unless all of these hold: the kernel lacks EROFS, the APEX is present,
# its payload is EROFS. Disable with /sdcard/TWRP/.no_gmsfix. Log: "gmsfix:" lines.

log() { echo "gmsfix: $*"; }
FSCK=/system/bin/fsck.erofs
P=/tmp/gmsfix/product
W=/tmp/gmsfix/work

[ -e /sdcard/TWRP/.no_gmsfix ] || [ -e /data/media/0/TWRP/.no_gmsfix ] && { log "disabled (.no_gmsfix present)"; exit 0; }
grep -qw erofs /proc/filesystems && { log "kernel supports EROFS, not needed"; exit 0; }
DEV=/dev/block/mapper/product$(getprop ro.boot.slot_suffix)
[ -b "$DEV" ] || { log "no $DEV, skipping"; exit 0; }

rm -rf /tmp/gmsfix
mkdir -p $P $W/x
mount -o ro "$DEV" $P 2>/dev/null || { log "cannot mount product, skipping"; exit 0; }
APEX=$(ls $P/apex/com.google.android.gmssystem*.apex 2>/dev/null | head -1)
if [ -z "$APEX" ]; then
  umount $P; rm -rf /tmp/gmsfix
  exit 0
fi
# EROFS magic 0xE0F5E1E2 at offset 1024
MAGIC=$(unzip -qp "$APEX" apex_payload.img 2>/dev/null | head -c 1028 | tail -c 4 | od -An -tx1 | tr -d ' \n')
if [ "$MAGIC" != "e2e1f5e0" ]; then
  log "$(basename "$APEX"): payload is not EROFS ($MAGIC), skipping"
  umount $P; rm -rf /tmp/gmsfix
  exit 0
fi

log "found $(basename "$APEX") with EROFS payload, moving Play services to /product/priv-app"
umount $P
umount /product 2>/dev/null
blockdev --setrw "$DEV" 2>/dev/null
mount -o rw "$DEV" $P || { log "ERROR: cannot mount product read-write, skipping"; exit 0; }
fail() { log "ERROR: $*"; umount $P 2>/dev/null; rm -rf /tmp/gmsfix; exit 0; }

unzip -qo "$APEX" apex_payload.img -d $W || fail "cannot unzip apex_payload.img"
"$FSCK" --extract=$W/x $W/apex_payload.img >/dev/null 2>&1 || fail "fsck.erofs --extract failed"
rm -f $W/apex_payload.img
APKDIR=$(ls -d $W/x/priv-app/* 2>/dev/null | head -1)
[ -n "$APKDIR" ] && ls "$APKDIR"/*.apk >/dev/null 2>&1 || fail "no priv-app/*.apk in APEX"
NAME=$(basename "$APKDIR" | sed 's/@.*//')

# Free space in product: remove the APEX before copying the APK
rm -f "$APEX"
mkdir -p $P/priv-app/$NAME $P/etc/permissions $P/etc/sysconfig
cp "$APKDIR"/*.apk $P/priv-app/$NAME/ || fail "copying APK failed (not enough space in product?)"
cp $W/x/etc/permissions/*.xml $P/etc/permissions/ 2>/dev/null
cp $W/x/etc/sysconfig/*.xml $P/etc/sysconfig/ 2>/dev/null
chown -R 0:0 $P/priv-app/$NAME
chmod 755 $P/priv-app/$NAME
chmod 644 $P/priv-app/$NAME/*.apk $P/etc/permissions/*.xml $P/etc/sysconfig/*.xml
chcon -R u:object_r:system_file:s0 $P/priv-app/$NAME $P/etc/permissions $P/etc/sysconfig
sync
log "done: /product/priv-app/$NAME/$(basename "$APKDIR"/*.apk)"
umount $P
rm -rf /tmp/gmsfix
exit 0
