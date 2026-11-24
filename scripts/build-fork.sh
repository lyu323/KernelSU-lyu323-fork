#!/usr/bin/env bash
# KernelSU (lyu323 fork) - reproducible Manager build wrapper.
# Copyright (C) 2026 lyu323. Licensed GPL-3.0-or-later (same as scripts/).
#
# This script DOES NOT invent an APK. It checks the real upstream toolchain
# and then runs the upstream "just bm" / "./gradlew aDebug" flow. If any
# prerequisite is missing it prints what to install and exits non-zero.
#
# Upstream build docs: justfile, AGENTS.md,
# https://kernelsu.org/guide/installation.html

set -euo pipefail
cd "$(dirname "$0")/.."
FORK_URL="https://github.com/lyu323/KernelSU-lyu323-fork"
OFFICIAL="https://github.com/tiann/KernelSU/releases/tag/v3.3.1"

echo "== KernelSU lyu323 fork - reproducible Manager build =="
echo "   source: $FORK_URL"
echo "   official unmodified binaries: $OFFICIAL"
echo "   NOTE: this builds the MANAGER APP only; kernel module + ksud are"
echo "         built/patched separately for your device's GKI KMI."
echo

missing=0
need() {
  if command -v "$1" >/dev/null 2>&1; then
    printf "  OK      %-12s %s\n" "$1" "$(command -v "$1")"
  else
    printf "  MISSING %-12s -> %s\n" "$1" "$2"
    missing=1
  fi
}

need git   "https://git-scm.com"
need java  "JDK 21 (upstream uses JavaVersion.VERSION_21)"
need rustc "https://rustup.rs ; rustup target add aarch64-linux-android"
need cargo "comes with rustup"
need cross "cargo install cross (or docker + cross)"
need just  "https://github.com/casey/just ; or run the commands manually"

if [ -z "${ANDROID_HOME:-${ANDROID_SDK_ROOT:-}}" ]; then
  echo "  MISSING ANDROID_HOME / ANDROID_SDK_ROOT -> install Android SDK (API 37 + build-tools 37.0.0)"
  missing=1
else
  echo "  OK      ANDROID_HOME=$ANDROID_HOME"
fi
if [ -z "${ANDROID_NDK_HOME:-}" ] && [ -z "${NDK_ROOT:-}" ]; then
  echo "  MISSING ANDROID_NDK_HOME -> install the NDK pinned in manager/gradle/libs.versions.toml (key: ndk)"
  missing=1
else
  echo "  OK      NDK=${ANDROID_NDK_HOME:-$NDK_ROOT}"
fi
if [ ! -x manager/gradlew ]; then
  echo "  MISSING manager/gradlew -> clone with git, do not download only a zip of sources"
  missing=1
else
  echo "  OK      manager/gradlew"
fi
if [ ! -f LICENSE ] || [ ! -f kernel/LICENSE ]; then
  echo "  MISSING LICENSE / kernel/LICENSE -> GPL texts must stay with the source"
  missing=1
else
  echo "  OK      LICENSE (GPL-3.0) + kernel/LICENSE (GPL-2.0-only)"
fi

if [ "$missing" -ne 0 ]; then
  cat <<'EOF'

== Prerequisites missing - NOT building ==
No APK was produced. Install the items above, then re-run this script.
Do not download a random prebuilt "modded KernelSU APK"; use the official
release if you just need a working root solution:
  https://github.com/tiann/KernelSU/releases/tag/v3.3.1
Any binary you build from this fork and hand to someone else MUST be
accompanied by this exact source tree and both LICENSE texts (GPL).
EOF
  exit 2
fi

echo
echo "== Generating NDK cargo config (upstream script) =="
NDK_ROOT_ARG="${ANDROID_NDK_HOME:-$NDK_ROOT}"
python3 scripts/setup_cargo_config.py --ndk-root "$NDK_ROOT_ARG"

echo
echo "== Building ksud (Rust, aarch64-linux-android) + Manager debug APK =="
# justfile: bm -> build_ksud -> cp ksud to jniLibs -> cd manager && ./gradlew aDebug
just bm

APK="manager/app/build/outputs/apk/debug/app-debug.apk"
if [ ! -f "$APK" ]; then
  echo "FAIL: upstream build finished but $APK was not found." >&2
  exit 3
fi
SHA="$(git rev-parse --short HEAD)"
OUT="KernelSU-lyu323-fork-${SHA}-debug.apk"
cp "$APK" "$OUT"
echo
echo "== Done: $OUT =="
echo "   source commit: $(git rev-parse HEAD)"
echo "   license:       LICENSE (GPL-3.0-or-later) + kernel/LICENSE (GPL-2.0-only)"
echo
echo "IMPORTANT:"
echo " * DEBUG build, signed with the debug key unless you configure"
echo "   sign.example.properties / KEYSTORE_FILE, KEYSTORE_PASSWORD,"
echo "   KEY_ALIAS, KEY_PASSWORD for a release build."
echo " * The kernel side checks the Manager signature/package name. If you"
echo "   change KSU_PACKAGE_NAME, rebuild the kernel with KSU_MANAGER_PACKAGE."
echo " * This APK alone does NOT give root: you still need the kernel module"
echo "   or a patched boot image for your exact device/KMI."
echo " * If you redistribute this APK, ship THIS exact source tree + both"
echo "   LICENSE texts with it (GPL). A private repo does not satisfy that."
