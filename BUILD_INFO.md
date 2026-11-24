<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
# Build artifacts (binary) - NOT source

These files are build OUTPUTS of the Actions run named in the commit message.
The corresponding source is the full repository at the exact source commit
recorded in the commit message / Release notes (also published as a source
zip). Both GPL license texts travel with every binary here:

* `LICENSE` = GPL-3.0-or-later (root / Manager / docs)
* `kernel-LICENSE` = GPL-2.0-only (`kernel/` directory)

They are verbatim copies of the upstream license files; they were not changed.

If you redistribute any APK from this branch you must ship that exact source
tree and both license texts with it. A private repository is only suitable for
keeping your own build artifacts; it cannot be used to hand a closed-source
binary to other people.

**Signature caveat:** the fork APK is DEBUG-SIGNED. A stock official KernelSU
kernel validates the Manager APK signature and will normally reject it (the
Manager will report "Not installed" / unauthorized). To actually use it you
must rebuild the kernel module with this APK's certificate hash and, if you
change `KSU_PACKAGE_NAME`, with `KSU_MANAGER_PACKAGE` as well.

`upstream-official.apk` is the official, unmodified v3.3.1 Manager APK from
https://github.com/tiann/KernelSU/releases/tag/v3.3.1 and is included only as
a clearly-labelled reference. It is not a product of this fork.

No kernel module, standalone ksud binary or boot image is distributed here.
Nothing has been verified on a real device.
