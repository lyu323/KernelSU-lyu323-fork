<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
## lyu323 fork - built Manager APK (UNOFFICIAL)

This Release contains a **real APK compiled from this fork's source** by
GitHub Actions (`Build fork Manager APK` workflow), plus the official
upstream v3.3.1 Manager APK as a clearly-labelled reference.

* Exact source commit: `2b0dbe0b7e` (see `FORK_NOTES.md` / `CHANGELOG_FORK.md`; the full source zip of that commit accompanies this APK, and the repository itself is the corresponding source).
* `LICENSE` (GPL-3.0-or-later) and `kernel-LICENSE` (GPL-2.0-only) are attached unchanged. **`kernel/**` is GPL-2.0-only; everything else is GPL-3.0-or-later.**

> If you redistribute any APK from here, you must ship the exact corresponding source tree and both license texts with it. A private repository is fine for your own build artifacts, but cannot be used to hand a closed-source binary to others.

### Caveats (read before installing)

1. **This is NOT the official KernelSU.** Unofficial fork of https://github.com/tiann/KernelSU, not affiliated with the upstream authors.
2. **The fork APK is DEBUG-SIGNED.** The official kernel side validates the Manager APK signature, so a stock official KernelSU kernel will normally reject it. To use it, rebuild the kernel module with this APK's certificate hash (and `KSU_MANAGER_PACKAGE` if the package name is changed). No such kernel module is provided here.
3. **The Manager APK alone does NOT give root.** It needs the kernel module / patched boot image built for your exact device GKI KMI. Back up your stock boot image before flashing anything.
4. `upstream-official.apk` is the official, unmodified v3.3.1 Manager - the one that actually works with official kernels. Use that if you just need a working root solution.
5. Built on a CI runner, **not verified on any real device**.

### What was customized (Manager only)

App label `KernelSU (lyu323 Fork)`, version suffix `-lyu323-fork1`, About text marking it as an unofficial fork, dark-cyan launcher/splash palette, one extra selectable theme color. Kernel module, ksud/ksuinit source, su/App Profile/module/SELinux logic, dependency manifests and translations are verbatim upstream; every modified file carries a dated GPL prominent notice.

Build run: https://github.com/lyu323/KernelSU-lyu323-fork/actions
