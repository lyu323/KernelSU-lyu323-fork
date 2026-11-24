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
