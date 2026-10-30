#!/bin/bash
# Apply the BALMUDA Phone patches to a twrp-12.1 source tree.
# Run from the top of the source tree after "repo sync".
set -e
DIR=$(dirname "$(readlink -f "$0")")
for pair in bootable/recovery:bootable_recovery system/vold:system_vold; do
  repo_dir=${pair%%:*}
  patch_dir=$DIR/${pair##*:}
  for p in "$patch_dir"/*.patch; do
    if git -C "$repo_dir" apply --reverse --check "$p" 2>/dev/null; then
      echo "already applied: $repo_dir $(basename "$p")"
    else
      git -C "$repo_dir" apply "$p"
      echo "applied: $repo_dir $(basename "$p")"
    fi
  done
done
