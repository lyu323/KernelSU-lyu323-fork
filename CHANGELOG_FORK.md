# Fork changelog

## lyu323-fork-1 (2026-11-24)

Based on upstream `2a60b2893b8d0d885d1ceff2287d8ad854f0e0f4` (2026-11-21).

### Added

* `README.md` - fork identity, non-official warning, license partition, build & official-binary links
* `FORK_NOTES.md` - base commit, exact per-file diff, audit commands, verbatim-file list
* `CHANGELOG_FORK.md` - this file
* `NOTICE` - copyright / dual-GPL / third-party / distribution-rule notice
* `LICENSE-COMPLIANCE.md` - what "ship corresponding source + keep license" means in practice
* `scripts/build-fork.sh` - reproducible build wrapper for the upstream `just bm` / `./gradlew aDebug` flow, with prerequisite checks and a hard failure instead of a fake APK

### Changed (Manager UI / branding / theme)

* App label: `KernelSU (lyu323 Fork)` (launcher + About screen)
* Version name: upstream `git describe` + `-lyu323-fork1`
* About screen text: explicitly says "unofficial community fork", links upstream and FORK_NOTES.md; link placeholders preserved
* Launcher / splash colors: dark-cyan palette (colors.xml, themes.xml)
* Theme palette: one additional selectable key color (`Colors.kt`)
* Every modified source/resource file carries a dated modification notice

### Not changed / not built

* kernel/, userspace/, uapi/, js/, website/, .github/, dependency manifests, LICENSE, kernel/LICENSE
* **No APK / .ko / ksud / boot image was compiled or uploaded.** Binaries linked from https://github.com/tiann/KernelSU/releases/tag/v3.3.1 are official upstream builds.

## lyu323-fork-1 build workflow (2026-11-24)

### Added

* `.github/workflows/build-fork-manager.yml` - reproducible `workflow_dispatch` cloud build: full source checkout, upstream-pinned SDK/NDK, Rust `ksud` -> `jniLibs`, `./gradlew :app:assembleDebug`, artifact = fork APK + `LICENSE` + `kernel/LICENSE`. Official upstream APK is downloaded alongside it only as a clearly-labelled reference.
* Documents the signature caveat: a debug-signed fork Manager is not accepted by a stock official kernel; the kernel module must be rebuilt with the matching certificate.

### Still true

* No APK is committed to the repository; binaries live in Actions artifacts / official upstream Releases.
* Kernel module, ksud upstream logic, su/App Profile/SELinux logic remain verbatim; the workflow only builds the existing GPL source.

### Build workflow fix (2026-11-24, commit 4)

* Removed the third-party `android-actions/setup-android` step (it failed on the runner) - the workflow now uses the runner's preinstalled Android SDK + `sdkmanager` directly.
* ksud / Gradle build steps are `continue-on-error`: if the full native+Kotlin toolchain cannot be assembled, the job still uploads the clearly-labelled official upstream APK together with `LICENSE` + `kernel/LICENSE`, and no fake "fork APK" is claimed.

### Build workflow fix 2 (2026-11-24, commit 5)

* The Gradle build (commit 4 run) succeeded and produced the fork Manager debug APK, but the dist collection step returned non-zero and skipped the upload. Collection and upload are now `if: always()` and fully fault-tolerant (`find` instead of a glob, separate names for the two LICENSE files, explicit `exit 0`). No source logic changed.

### Artifact publishing (2026-11-24, commit 6)

* NEW `.github/workflows/publish-fork-build.yml`: downloads the already-built `fork-manager-apk` artifact (no recompilation), pushes it to the `builds` branch together with both GPL license texts, and creates Release `lyu323-fork-1-build1` with the APKs + licenses. The Release notes name the exact source commit and repeat the signature caveat.
* The `builds` branch contains build OUTPUTS only, clearly separated from source on `main`. Every binary there is tied to a named source commit and both license texts.

### Artifact publishing fix (2026-11-24, commit 7)

* Fixed the publish workflow YAML (an unindented heredoc inside a `run: |` block made GitHub fail to register its `workflow_dispatch` trigger). Release notes and binary-build info are now plain repository files (`RELEASE_NOTES_BUILD.md`, `BUILD_INFO.md`) instead of shell heredocs.

## lyu323-fork-2 (2026-11-24, commit 8)

### Fixed

* **Same package name**: `applicationId` changed to `me.lyu323.kernelsu`; fork and official Manager can coexist (were conflicting on `me.weishu.kernelsu`).
* **`libksud.so` not visible to external tooling**: `android:extractNativeLibs="true"`.
* **No kernel module inside ksud**: build now bundles official v3.3.1 aarch64 LKMs for 8 KMI variants + `ksuinit` before compiling ksud, and exports `KSU_PACKAGE_NAME` to the Rust build.
* Version suffix -> `-lyu323-fork2`.

### Added / changed (UI, docs)

* About page explains "Not installed", the debug-signature limit, and the KernelSU/Magisk switching reality (no fake toggle).
* Status/navigation bars now follow the dark-cyan palette.
* `ROOT_GUIDE.md`: read-only diagnostics, safe pre-switch checklist, neutral note on the third-party exploit timeout.

### Explicitly NOT added

* No one-tap KSU/Magisk switch, no automatic boot-image flashing, no exploit/temporary-root helper. Both root solutions replace boot/init_boot and cannot be active at once; switching needs a matching image + reboot. The app does not touch any partition.

### XML fix (commit 9)

Moved the explanatory comment out of the `<application>` attribute list (XML forbids comments between attributes). `android:extractNativeLibs="true"` itself is unchanged.

### Publish workflow parametrized (commit 10)

`publish-fork-build.yml` now takes a `release_tag` input (default `lyu323-fork-2-build1`), downloads the exact source commit zip into the Release, and appends the source commit + build run id to the notes. No source logic changed.

## lyu323-fork-3 (2026-11-24, commit 11)

### Fixed: "v1 visible / v2 invisible" in hardcoded scanners

* Default `applicationId` back to official `me.weishu.kernelsu` -> **Compat** variant, visible to DIRTYFRAGX-style scanners.
* Kept `android:extractNativeLibs="true"` and embedded official v3.3.1 LKMs -> the scanner can now actually read `libksud.so` (v1 failed on this).
* Added a **Coexist** variant (`me.lyu323.kernelsu`) in the SAME CI run -> the previous "no same-package conflict" capability is not lost. Both APKs are shipped side by side.
* `userspace/ksud/build.rs`: always forward `KSU_PACKAGE_NAME` to rustc + `rerun-if-env-changed`, so the two variants get correct, different `libksud.so` instead of a cached one. Only userspace source file changed; no root logic touched.

### Added / UI

* `COMPATIBILITY.md` - full explanation of the v1/v2 difference and the trade-off.
* `scripts/verify-manager-apk.sh` - read-only APK self-check (package, label, extractNativeLibs, libksud.so, 8 embedded KMIs, ksuinit, cert, expected conclusion).
* About page: both variants + self-check instructions; `%1$s`/`%2$s` preserved.
* New `ksu_accent` / `android:colorAccent`, two-tone launcher foreground, `values-night/colors.xml` for night-mode system bars.
* Publish workflow default tag -> `lyu323-fork-3-build1`.

### Still NOT added

* No one-tap KSU/Magisk switch, no boot flashing, no exploit/temporary-root helper, no fake "switched" state.

### Self-check script fix (commit 12, no APK change)

* `scripts/verify-manager-apk.sh`: corrected the ELF magic literal (`b'\x7fELF'`, previously double-escaped so it never matched) and removed an unused `zipinfo` call from the package-name extraction. Verified locally against both built APKs.
* This commit only touches a read-only helper script and the changelog. **The APKs in Release `lyu323-fork-3-build1` were built from commit `226f4609ad` (commit 11)**; the source zip attached to that Release is exactly that commit.
