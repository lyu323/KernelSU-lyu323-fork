## lyu323 fork 2 - built Manager APK (UNOFFICIAL)

**What is fixed in this build**

* Independent package name `me.lyu323.kernelsu` - the fork and the official Manager can coexist (no more same-package-name signature conflict).
* `android:extractNativeLibs="true"` - `libksud.so` is extracted as a real file into `nativeLibraryDir`, so external tooling can actually see it.
* ksud now embeds the official v3.3.1 aarch64 LKM modules for 8 KMI variants plus `ksuinit`; the previous build had no kernel module inside ksud, which is why "install / jailbreak" could not supply one.
* About page explains the "Not installed" state, the debug-signature limit, and why KernelSU and Magisk cannot be toggled with an in-app switch.
* Status/navigation bars follow the dark-cyan palette; version suffix `-lyu323-fork2`.
* `ROOT_GUIDE.md` documents the read-only checklist and a neutral explanation of the third-party exploit timeout.

**Not a one-tap KSU/Magisk switch.** Both replace boot/init_boot and cannot be active at the same time; switching requires re-flashing a matching image and rebooting. This app does not flash, patch or replace any partition and does not show a fake "switched" state.

### Caveats

1. **UNOFFICIAL fork** of https://github.com/tiann/KernelSU. Not affiliated with upstream.
2. **DEBUG-SIGNED**. A stock official KernelSU kernel validates the Manager package name + certificate hash and will reject this build. To use it, rebuild the kernel module with this APK's certificate and `KSU_MANAGER_PACKAGE=me.lyu323.kernelsu`.
3. **The Manager APK alone does NOT grant root.** It needs the kernel module / patched boot image for your exact device KMI. Back up your stock image before flashing.
4. `upstream-official.apk` is the official, unmodified v3.3.1 Manager - use that if you just need a working root solution.
5. Built on a CI runner, **not verified on a real device**.

### License / corresponding source

* `kernel/**` = **GPL-2.0-only** (`kernel-LICENSE`, verbatim); everything else = **GPL-3.0-or-later** (`LICENSE`, verbatim).
* `KernelSU-lyu323-fork-source.zip` is the complete source tree of the exact commit named below. Both license texts are attached.
* Distribute any APK from here together with that exact source tree and both license texts. A private repository is fine for your own build artifacts, but cannot be used to hand a closed-source binary to others.
* The bundled `.ko` binaries come from the official v3.3.1 Release; their corresponding source is this repository's verbatim `kernel/` tree.

Build run: https://github.com/lyu323/KernelSU-lyu323-fork/actions
