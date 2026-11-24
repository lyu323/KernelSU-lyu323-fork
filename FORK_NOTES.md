# Fork notes - tiann/KernelSU -> lyu323/KernelSU-lyu323-fork

## Identity

* **Upstream**: https://github.com/tiann/KernelSU
* **Base commit**: `2a60b2893b8d0d885d1ceff2287d8ad854f0e0f4` (2026-11-21, `fix(kernel): Allow logd to get root process attributes (#4019)`)
* **Fork created**: 2026-11-24
* **Relationship**: real GitHub fork (the repo shows "forked from tiann/KernelSU", full upstream history preserved).
* **Status**: UNOFFICIAL. Not affiliated with, endorsed by, or published by the KernelSU authors. The name contains "lyu323 Fork" everywhere it appears.

> This fork is a *source-level customization* of the Manager UI plus a
> compliance documentation set. It is NOT a "full modded KernelSU APK":
> root functionality lives in the kernel module and the Rust userspace
> daemon, both of which are kept verbatim from upstream.

## Why there is no APK in this repo

A "complete KernelSU" is kernel module (`kernel/`, GPL-2.0-only) +
`userspace/ksud` + `userspace/ksuinit` (Rust, cross-compiled for
aarch64-linux-android) + the Kotlin/Compose Manager APK. Building the
Manager requires Gradle 8.x + AGP + Kotlin/Compose + Android SDK/NDK +
Rust/`cross`; the kernel side requires your device's GKI KMI / kernel
source and a boot image to patch. The environment used to prepare this
fork had JDK 17 and `android.jar` only, so:

* no APK was compiled, no APK is uploaded, no APK is claimed to work;
* no kernel module or boot image was built;
* nothing here has been verified on a real device.

Use `scripts/build-fork.sh` on a proper toolchain to reproduce a Manager
APK. Official, unmodified binaries: https://github.com/tiann/KernelSU/releases/tag/v3.3.1

## Exact changes (file by file)

Every modified file also carries a prominent `Modified for lyu323 fork
(2026-11-24)` header so the diff satisfies GPL-2.0 §2(a) / GPL-3.0 §5(a).

### Commit 2 - Manager UI / theme / branding (6 modified files)

| File | Change | Why it is safe |
| --- | --- | --- |
| `manager/app/build.gradle.kts` | default `managerName` becomes `KernelSU (lyu323 Fork)`; added fork header comment | one Kotlin DSL string; `app_name` is generated via `resValue`, so the launcher label and About screen change |
| `manager/build.gradle.kts` | `getVersionName()` appends `-lyu323-fork1` to `git describe` | pure string concat; visible in About / version row |
| `manager/app/src/main/res/values/strings.xml` | `about_source_code` text states this is an unofficial fork, points to upstream + FORK_NOTES.md; **format placeholders `%1$s` / `%2$s` kept exactly** so `extractLinks()` still gets 2 links | resource-only, no Kotlin/Compose change |
| `manager/app/src/main/res/values/colors.xml` | launcher bg/fg and splash bg recolored to a dark-cyan palette | resource-only |
| `manager/app/src/main/res/values/themes.xml` | splash window background now uses `@color/ic_splash_background` | resource-only |
| `manager/app/src/main/java/me/weishu/kernelsu/ui/theme/Colors.kt` | added one extra key color to `keyColorOptions` -> one more selectable theme color in the palette screen | adding one element to an existing `listOf(...)` |

### Commit 1 - compliance / docs / build (6 new files)

`README.md`, `FORK_NOTES.md`, `CHANGELOG_FORK.md`, `NOTICE`,
`LICENSE-COMPLIANCE.md`, `scripts/build-fork.sh`.

### NOT changed (verbatim upstream)

`kernel/**` (all root logic), `userspace/**` (ksud/ksuinit), `uapi/**`,
`js/**`, `website/**`, `.github/**`, `Cargo.toml` / `Cargo.lock`,
`manager/gradle/libs.versions.toml`, all translated `values-*/strings.xml`,
`LICENSE`, `kernel/LICENSE`, `SECURITY.md`, `AGENTS.md`, `justfile`,
`repack_apk.py`. No su / App Profile / module / SELinux / signature-check
logic was touched.

## How to audit

```bash
git clone https://github.com/lyu323/KernelSU-lyu323-fork.git
cd KernelSU-lyu323-fork
git diff 2a60b2893b8d0d885d1ceff2287d8ad854f0e0f4..HEAD --stat
git diff 2a60b2893b8d0d885d1ceff2287d8ad854f0e0f4..HEAD -- manager/
git log --oneline 2a60b2893b8d0d885d1ceff2287d8ad854f0e0f4..HEAD
```

You can also compare directly with the upstream tree at `2a60b2893b8d0d885d1ceff2287d8ad854f0e0f4` using
`git diff 2a60b2893b8d0d885d1ceff2287d8ad854f0e0f4 HEAD -- . ':(exclude)README.md' ...` or GitHub's
compare view.

## License partition (unchanged)

* `kernel/**` -> GPL-2.0-only, text in `kernel/LICENSE`
* everything else -> GPL-3.0-or-later, text in `LICENSE`

See `NOTICE` and `LICENSE-COMPLIANCE.md` before redistributing any binary.

### Commit 3 - reproducible cloud build (1 new file, 2 docs updated)

| File | Change |
| --- | --- |
| `.github/workflows/build-fork-manager.yml` | NEW: `workflow_dispatch` job that checks out this fork, installs the upstream-pinned SDK/NDK, cross-compiles `ksud` (Rust) into `jniLibs`, runs `./gradlew :app:assembleDebug`, and uploads the APK together with `LICENSE` + `kernel/LICENSE`. Also downloads the official upstream APK as a reference/fallback, clearly named `upstream-official.apk`. |
| `FORK_NOTES.md`, `CHANGELOG_FORK.md` | document commit 3 |

The workflow produces a **real APK built from this fork's source** (debug-signed, arm64). It is not a repack of the official binary. Because the kernel side of official KernelSU validates the Manager APK signature, a debug-signed fork Manager will normally be rejected by a stock official kernel (it will show "Not installed" / unauthorized). To actually use it you must rebuild the kernel module with this APK's certificate hash (`KSU_MANAGER_PACKAGE` + expected signature) - see `LICENSE-COMPLIANCE.md` §2.7. No such kernel module is built here.

If the cloud build fails, the repository still contains the complete source and no APK is claimed. Build status is recorded in the GitHub Actions run, not asserted in a README.

### Commit 8 - independent package name, native lib extraction, bundled LKM, UI + root guide

| File | Change |
| --- | --- |
| `manager/gradle.properties` | NEW `KSU_PACKAGE_NAME=me.lyu323.kernelsu` + `KSU_NAME`. Fixes the same-package-name conflict: fork and official Manager can now coexist. |
| `manager/app/src/main/AndroidManifest.xml` | NEW `android:extractNativeLibs="true"` so `libksud.so` is a real file in `nativeLibraryDir` (fixes external tooling reporting no manager with libksud.so). |
| `manager/build.gradle.kts` | version suffix `lyu323-fork1` -> `lyu323-fork2`. |
| `manager/app/src/main/res/values/strings.xml` | About text now also explains the "Not installed" state, the debug-signature limit, and why KernelSU/Magisk cannot be switched with an in-app toggle. `%1$s`/`%2$s` preserved. |
| `manager/app/src/main/res/values/colors.xml`, `themes.xml` | status/navigation bar colors + light-bar flags follow the dark-cyan palette (visible UI polish). |
| `.github/workflows/build-fork-manager.yml` | downloads official v3.3.1 aarch64 LKM modules for 8 KMI variants and `ksuinit-aarch64` into `userspace/ksud/bin/aarch64/` before `cargo build`, so ksud actually embeds kernel modules; exports `KSU_PACKAGE_NAME` for the Rust build too. |
| `ROOT_GUIDE.md` | NEW Chinese guide: why "Not installed", the three fixes, why a one-tap KSU/Magisk switch is not possible, pre-switch checklist, and a neutral explanation of the third-party exploit timeout. |
| `FORK_NOTES.md`, `CHANGELOG_FORK.md` | document commit 8 |

**The `.ko` binaries are GPL-2.0-only**, sourced from the official v3.3.1 Release;
their corresponding source is the verbatim `kernel/` tree in this repository.
Both license texts are shipped with every APK.

**No in-app root-solution switch was added.** Magisk and KernelSU both replace
boot/init_boot and cannot be active simultaneously; switching requires re-flashing
a matching image and rebooting. This fork deliberately does not flash, patch or
replace any partition and does not present a fake "switched" state. `ROOT_GUIDE.md`
contains the read-only checklist instead.
