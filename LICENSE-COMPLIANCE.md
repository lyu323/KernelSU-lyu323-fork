# License compliance (read before distributing anything)

Upstream: https://github.com/tiann/KernelSU (base commit `2a60b2893b8d0d885d1ceff2287d8ad854f0e0f4`).
This fork is unofficial and is not affiliated with the upstream project.

## 1. Two licenses, two directories

| Path | License | License text in this repo |
| --- | --- | --- |
| `kernel/**` | **GPL-2.0-only** | `kernel/LICENSE` (verbatim, unchanged) |
| everything else (Manager, userspace/ksud, scripts, docs) | **GPL-3.0-or-later** | `LICENSE` (verbatim, unchanged) |

Both texts are kept exactly as upstream ships them. Upstream copyright
headers and credits were not removed. The fork's own additions live in
root-level docs and `scripts/`, and are offered under GPL-3.0-or-later.

## 2. What your compliance background implies in practice

> "KernelSU upstream is GPL; any modified version that is redistributed must
> ship the corresponding source and preserve the license; a private repo is
> only suitable for keeping your own build artifacts, not for distributing a
> closed-source binary to others."

Concretely:

1. **Corresponding source**: if you publish a Manager APK built from this
   fork, you must publish the exact source tree (including your modified
   files, build scripts, version catalog, and the exact commit) that produced
   THAT APK. A link to the upstream tag is not enough - the diff must be
   included. This public repo already is that corresponding source for any
   build made straight from its `main`.
2. **License preservation**: `LICENSE` and `kernel/LICENSE` must travel with
   every binary and every source redistribution, unchanged.
3. **Prominent modification notices**: GPL-2.0 §2(a) / GPL-3.0 §5(a) require
   modified files to carry notices stating that they were changed and when.
   Every source/resource file modified by this fork has such a header, and
   `FORK_NOTES.md` lists them file by file with the change summary.
4. **No additional restrictions**: you may not add EULA, anti-copy, "do not
   redistribute", or proprietary terms on top of GPL-covered binaries.
5. **Private repo**: perfectly fine for your own build outputs (APK, .ko,
   boot.img). It does NOT satisfy the GPL if you then hand those binaries to
   other people without giving them the corresponding source. Distribution
   triggers the obligation, not publicity of the repository.
6. **Kernel side**: a `kernelsu.ko` / patched boot image built against a
   device kernel is GPL-2.0-only and additionally interacts with the Linux
   kernel's own GPL-2.0; keep the module source and build instructions
   available (this repo contains `kernel/` verbatim).
7. **Signature / branding**: the Manager verifies APK signatures and the
   kernel's allowlist is built around the official package name. This fork
   keeps `me.weishu.kernelsu` for source compatibility; if you change
   `KSU_PACKAGE_NAME`, you must also rebuild the kernel side with
   `KSU_MANAGER_PACKAGE` accordingly, or the Manager will not be recognized.

## 3. What this repository actually distributes

* Complete upstream source (real GitHub fork, full history) + this fork's
  commits, publicly readable.
* Documentation, notices and a reproducible build script.
* **No APK, no .ko, no ksud binary, no boot image.** Official unmodified
  binaries are only linked from `https://github.com/tiann/KernelSU/releases/tag/v3.3.1`.

## 4. Building it yourself

See `scripts/build-fork.sh`. It only wraps the upstream `just bm` /
`./gradlew aDebug` flow, checks prerequisites, and refuses to produce a
file when the toolchain is incomplete. This sandbox had JDK 17 and an
`android.jar` only (no Gradle/Kotlin/Compose/Rust/NDK/kernel source), so
**no APK was compiled and none is claimed to exist**. Build status:
NOT VERIFIED ON DEVICE. Do not flash anything you cannot rebuild and verify.
