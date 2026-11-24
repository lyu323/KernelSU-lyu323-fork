# KernelSU (lyu323 community fork) - source-only, UNOFFICIAL

> **This is NOT the official KernelSU.** It is an unofficial, source-level
> fork of [tiann/KernelSU](https://github.com/tiann/KernelSU) created for Manager UI/theme/branding
> customization and GPL compliance documentation. It is not affiliated
> with, endorsed by, or published by the KernelSU authors.
>
> **No modified APK is distributed here.** This repository contains the
> complete corresponding source code (real fork, full upstream history),
> notices, and a reproducible build script. Official unmodified binaries:
> https://github.com/tiann/KernelSU/releases/tag/v3.3.1

Base upstream commit: `2a60b2893b8d0d885d1ceff2287d8ad854f0e0f4` (2026-11-21). Fork changes: `git log 2a60b2893b8d0d885d1ceff2287d8ad854f0e0f4..HEAD`.

## License (inherited, unchanged)

| Path | License | Text |
| --- | --- | --- |
| `kernel/**` | **GPL-2.0-only** | `kernel/LICENSE` |
| everything else | **GPL-3.0-or-later** | `LICENSE` |

Both license texts are preserved verbatim. Modified files carry dated
prominent notices. If you distribute a binary built from this fork, you
must ship the exact corresponding source and both license texts with it;
a private repository is only fine for your own build artifacts, not for
handing a closed-source binary to others. See [NOTICE](NOTICE),
[LICENSE-COMPLIANCE.md](LICENSE-COMPLIANCE.md) and [FORK_NOTES.md](FORK_NOTES.md).

## What is actually different

Only the **Manager** (Android app) is customized, at the resource /
build-config level:

* app label `KernelSU (lyu323 Fork)` and version suffix `-lyu323-fork1`
* About screen states it is an unofficial fork and links upstream + notes
* dark-cyan launcher/splash colors, one extra theme key color
* every modified file has a dated modification notice

Kernel module, `ksud`/`ksuinit`, su/App Profile/module/SELinux logic,
dependency manifests, translations, `LICENSE` and `kernel/LICENSE` are
**verbatim upstream**. The exact file-by-file list is in
[FORK_NOTES.md](FORK_NOTES.md) and [CHANGELOG_FORK.md](CHANGELOG_FORK.md).

This is a *source customization*, not a "full modded KernelSU APK": root
is provided by the kernel side, which must be built or injected for your
device's GKI KMI. The Manager APK alone shows "Not installed".

## Build (reproduce it yourself)

```bash
git clone https://github.com/lyu323/KernelSU-lyu323-fork.git
cd KernelSU-lyu323-fork
bash scripts/build-fork.sh
```

The script checks for JDK/Gradle/Kotlin/Compose/AGP, Android SDK + NDK,
Rust + `cross`, and the upstream `just`/`gradlew` flow; it refuses to emit
an APK when prerequisites are missing. Upstream build docs:
`justfile`, `AGENTS.md`, https://kernelsu.org/guide/installation.html.

> The environment that prepared this fork had only JDK 17 + `android.jar`
> (no Gradle/Kotlin/Compose/Rust/NDK/kernel source), so **nothing was
> compiled here and no APK is claimed**. Build status: NOT VERIFIED.

## Install / official binaries

For a working root solution use the **official** upstream release:
https://github.com/tiann/KernelSU/releases/tag/v3.3.1 (Manager APK, per-KMI LKM `.ko`, ksud, source zip), and read
https://kernelsu.org/guide/installation.html first. Kernel work requires
an unlocked bootloader and the correct boot image for YOUR device; back
up the stock image and never flash an artifact you cannot rebuild.

## Security / feedback

Keep upstream's [SECURITY.md](SECURITY.md). This fork has issues disabled;
please do not report fork-specific build problems upstream.
