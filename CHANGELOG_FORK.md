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
