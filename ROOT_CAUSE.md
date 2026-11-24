<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
# 为什么「工具找到了管理器、也跳转进来了，却还是没有 root」

> 这篇是**因果说明**，不是提权教程。本 fork 不调 exploit 参数、不提供替代提权链、不绕过安全补丁。

## 1. 三件事是三件不同的事

| 事件 | 由谁决定 | 本次截图里的状态 |
| --- | --- | --- |
| ① 第三方工具按硬编码包名**列出** Manager | 工具的包名扫描 | ✅ 图 39 已列出 `KernelSU (lyu323 Fork) / me.weishu.kernelsu`，状态「待命」 |
| ② 工具**跳转**到 Manager | 工具自己的 Intent | ✅ 能打开应用 |
| ③ 系统里真的有 **root / 内核侧 KSU** | 内核模块或修补过的 boot 镜像 | ❌ 图 38 显示「未安装」，SELinux 仍是强制执行 |

**① 和 ② 成功，不代表 ③ 成功。** Manager APK 只是控制面板；root 能力来自内核侧的
`kernelsu.ko` / 编进内核的 `CONFIG_KSU`。没有内核侧 KSU，Manager 必然显示「未安装」，
也不会有 `su`。这是**设计如此，不是 Manager 的 bug**，改包名、换 so、改 UI、重签名都修不了。

## 2. 上游本来就有「越狱」按钮，它不是万能的

v3.3.1 Manager 自带 `home_jailbreak` / 「越狱」入口（图 35/38 那个蓝色按钮），
用于在**未解锁 bootloader** 的设备上尝试临时加载内核模块。你上一轮贴的日志：

```
patch: crash_dump64 <- splicehelper
patch: /vendor/lib64/... <- dfroot.ko
patch: /system/lib64/libc++.so <- shellcode / trampoline
vendor and system releases disagree, using vendor 12 over system 16
Kernel 5.10 android12 -> Using KMI: android12-5.10
EXPLOIT FAILED: TIMEOUT: FAILED: CHECK LOGCAT & DMESG
```

`TIMEOUT` 表示这条临时路径没在预期时间内完成。你这台是 **Android 16 / 安全补丁 2026-08-01 /
vivo V2301A / 5.10.246-gki**，且 `vendor release 12` 与 `system release 16` 不一致——
这类匹配问题属于工具/漏洞链与设备补丁级别的事，不是 Manager 能补偿的。

**本 fork 明确不做**：调 exploit 参数、换注入点、找替代 CVE 链、绕过安全补丁、自动刷分区。
 Manager 里的「安装 / 越狱」是上游既有逻辑，未改动、也未增强。

## 3. 那弹窗「未找到包含 libksud.so 的管理器」呢

图 39 里工具**同时**列出了卡片又弹了这个窗，说明它按包名找到了候选，但随后的
`libksud.so` 检查没通过。工具内部校验逻辑闭源，我无法确认它查的是 so 的文件大小、
内容、可执行位还是别的。本 fork 能做的是把客观条件全部对齐：

| 条件 | v4 的处理 |
| --- | --- |
| 包名 `me.weishu.kernelsu` | Compat 变体保持（v3 起） |
| `extractNativeLibs="true"` | 已生效，aapt 实测 `0xffffffff` |
| `libksud.so` 与官方**逐字节一致** | **v4 新增**：Compat 变体三个 ABI 的 `libksud.so` 直接从官方 v3.3.1 APK 提取，不再用 CI 自编译版 |
| so 内含 8 个 KMI 模块 + ksuinit | 官方原版自带，逐字节一致 |

若对齐后工具仍报找不到，那就是它的私有校验（签名白名单、版本字符串等），
改 APK 无法保证通过；用 `scripts/verify-manager-apk.sh` 打印客观事实逐项对照即可。

## 4. 用户真正能拿到 root 的两条正规路径

1. **临时提权**：由第三方工具自己完成内核模块注入。它成功与否取决于该工具与设备/补丁的匹配，
   本 App 不参与也不干预；即使它临时成功，也应在**它自己的界面**里完成后续动作，
   而不是期待 Manager 凭空变成已 root。
2. **持久 root（正规）**：解锁 bootloader → 备份原厂 `boot.img`/`init_boot.img` →
   按设备 KMI（你这台日志推断 `android12-5.10`）用官方 GKI/LKM 修补并刷入 → 重启。
   参考 https://kernelsu.org/guide/installation.html 。刷前务必备份，核对 KMI 与安全补丁。

## 5. 本 fork 这轮实际改了什么（可验证）

- Compat 变体 `libksud.so` 换成官方原版二进制（三 ABI），Coexist 仍用自编译（需独立包名）。
- 新增 **App 内「本机诊断（只读）」卡**：显示包名、版本、签名指纹、`nativeLibraryDir`
  里 `libksud.so` 是否存在/大小/ELF、内嵌 8 个 KMI、`/dev/kernel_su` 是否存在、
  `/data/adb/ksu`、SELinux 状态、设备与内核版本，并给出明确结论；可一键复制、打开兼容性说明。
  它**只读**，不申请权限、不执行 shell、不刷任何东西。
- 关于页/文档补充「识别成功 ≠ 提权成功」。

诊断卡能让你在图 38 同一屏里直接看到「内核侧到底有没有 KSU」，不用再猜。

## 6. 合规

官方 `libksud.so` 属 userspace（GPL-3.0-or-later）并内嵌 `kernel/` 编译出的 LKM
（GPL-2.0-only）。其对应源码是本仓库逐字节未改的 `userspace/ksud` 与 `kernel/` 树，
两份许可证全文随每个 APK 分发，精确 commit 源码 zip 同时附上。私有仓库只适合自留构建产物，
不能据此对外闭源分发。
