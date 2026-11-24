#!/usr/bin/env bash
# Copyright (C) 2026 lyu323
# SPDX-License-Identifier: GPL-3.0-or-later
# Added for lyu323 fork (2026-11-24). See COMPATIBILITY.md / FORK_NOTES.md.
#
# Read-only self-check for a built Manager APK. Prints the objective facts a
# third-party scanner typically needs. Does NOT install, patch or flash anything.

set -u
APK="${1:-}"
if [ -z "$APK" ] || [ ! -f "$APK" ]; then
  echo "usage: bash scripts/verify-manager-apk.sh <manager.apk>" >&2
  exit 2
fi
echo "== lyu323 fork Manager APK self-check =="
echo "   file: $APK"
echo "   size: $(stat -c%s "$APK") bytes"
echo "   sha256: $(sha256sum "$APK" | cut -d' ' -f1)"
echo

AAPT="${AAPT:-aapt}"
APKSIGNER="${APKSIGNER:-apksigner}"
if ! command -v "$AAPT" >/dev/null 2>&1; then
  echo "[!] aapt not found (set AAPT=/path/to/aapt or ANDROID_HOME). XML checks skipped."
else
  echo "--- package / label ---"
  "$AAPT" dump badging "$APK" 2>/dev/null | grep -E "^package:|sdkVersion:|targetSdkVersion:" | head -4
  "$AAPT" dump badging "$APK" 2>/dev/null | grep -m1 "^application-label:"
  echo "--- extractNativeLibs ---"
  "$AAPT" dump xmltree "$APK" AndroidManifest.xml 2>/dev/null \
    | grep -i 'extractNativeLibs' | head -2 \
    || echo "  (not present)"
fi

echo
echo "--- libksud.so ---"
python3 - "$APK" <<'PY'
import sys, zipfile
p = sys.argv[1]
z = zipfile.ZipFile(p)
ks = [n for n in z.namelist() if n.endswith('libksud.so')]
if not ks:
    print("  MISSING: no libksud.so in APK")
else:
    for n in ks:
        d = z.read(n)
        print(f"  {n}: {len(d)} bytes, ELF={d[:4] == b'\x7fELF'}")
    d = z.read(ks[0])
    kmis = [
        'android12-5.10_kernelsu.ko', 'android13-5.10_kernelsu.ko',
        'android13-5.15_kernelsu.ko', 'android14-5.15_kernelsu.ko',
        'android14-6.1_kernelsu.ko', 'android15-6.6_kernelsu.ko',
        'android16-6.12_kernelsu.ko', 'android17-6.18_kernelsu.ko',
    ]
    hit = [k for k in kmis if k.encode() in d]
    print(f"  embedded KMI modules: {len(hit)}/8 -> {', '.join(hit) if hit else 'NONE'}")
    print("  ksuinit embedded:", b'ksuinit' in d)
PY

echo
echo "--- signing certificate ---"
if command -v "$APKSIGNER" >/dev/null 2>&1; then
  "$APKSIGNER" verify --print-certs "$APK" 2>/dev/null \
    | grep -E 'certificate DN|SHA-256 digest' | head -3
else
  echo "  apksigner not found (set APKSIGNER=/path/to/apksigner)"
fi

echo
echo "--- expected conclusion ---"
PKG=$(
  if command -v "$AAPT" >/dev/null 2>&1; then
    "$AAPT" dump badging "$APK" 2>/dev/null \
      | sed -n "s/^package: name='\([^']*\)'.*/\1/p" | head -1
  fi
)
case "$PKG" in
  me.weishu.kernelsu)
    echo "  Compat variant: package name matches hardcoded scanners."
    echo "  -> Cannot be installed alongside the official Manager."
    ;;
  me.lyu323.kernelsu)
    echo "  Coexist variant: independent package, invisible to hardcoded scanners."
    echo "  -> Can be installed alongside the official Manager."
    ;;
  *) echo "  Unknown package '$PKG' - compare with COMPATIBILITY.md." ;;
esac
echo
echo "This script only reports facts. It cannot fix a third-party tool's private"
echo "checks, a debug-signed APK being rejected by a stock kernel, or an"
echo "exploit timeout on a patched device. See COMPATIBILITY.md / ROOT_GUIDE.md."
