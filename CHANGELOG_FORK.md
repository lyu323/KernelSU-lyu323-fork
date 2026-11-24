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
