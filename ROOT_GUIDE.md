# Root 方案说明与排错（lyu323 fork）

> 本文是**说明与排错文档**，不是提权工具，也不提供任何漏洞利用步骤。
> 本 fork 不修改 boot 分区、不注入内核、不调用任何 exploit。

## 1. 为什么 Manager 显示「未安装」

KernelSU 的 root 能力来自**内核侧**（编进内核的 `CONFIG_KSU` 或可加载模块 `kernelsu.ko`），
Manager APK 只是控制面板。所以：

* 只装 Manager、内核没动 → 显示「未安装」是**正确状态**，不是 bug；
* 本 fork 的 APK 是 **debug 签名**（`CN=Android Debug`），官方内核会校验 Manager 包名与
  证书哈希，因此刷了官方 KernelSU 内核的手机会拒绝它；
* 要让本 fork 被内核认可，必须用 **本 APK 的证书哈希** 重新构建内核模块，并用
  `KSU_MANAGER_PACKAGE=me.lyu323.kernelsu` 编译（包名已改，见下）。

## 2. 本轮修复了什么

| 现象 | 原因 | 处理 |
| --- | --- | --- |
| 与官方 Manager 签名冲突、不能共存，第三方工具按包名找到的是 fork | `applicationId` 与官方同为 `me.weishu.kernelsu` | 改为独立包名 `me.lyu323.kernelsu`，两者可同时安装、互不覆盖 |
| 第三方工具提示「未找到包含 libksud.so 的管理器」 | native 库未强制解压时，外部进程读不到 `nativeLibraryDir` 里的实体文件 | `android:extractNativeLibs="true"`，`libksud.so` 会被解压为真实文件 |
| 点「越狱 / 安装」提示可能失败、拿不到内核模块 | 上一版 CI 只 `cargo build` 了 ksud，**没有把 `.ko` 塞进 `userspace/ksud/bin/aarch64/`**，ksud 里没有内嵌 LKM | 构建时下载官方 v3.3.1 的 8 个 aarch64 KMI 模块 + `ksuinit` 再编译，LKM 模式才有模块可用 |

关于 `.ko` 的合规：这些二进制来自官方 v3.3.1 Release，属 **GPL-2.0-only**，
其对应源码就是本仓库 `kernel/` 目录（逐字节未改）与官方构建配置；
`LICENSE` 与 `kernel/LICENSE` 随每个 APK 一同分发，精确 commit 源码 zip 也一并附上。

## 3. 能不能「和 Magisk 结合，自由切换 KSU / Magisk」

**不能做成一个 App 内的一键开关。** 这不是本 fork 偷懒，是结构决定的：

1. Magisk（修补 `init`/`init_boot`、magiskinit、overlay 模块系统）与 KernelSU
   （内核模块 + `ksud`、`/data/adb/ksu`）**同时只能有一个内核侧 root 生效**：
   su 路径、SELinux 策略、模块挂载、init 注入会互相打架，强行共存极易无法开机。
2. 「切换」的真实动作是：**备份当前 boot/init_boot → 刷入另一方案的镜像 → 重启**。
   必须由你确认镜像与设备匹配，任何自动替换都可能变砖。
3. 本 fork **不写**自动刷写、不替换分区、不注入 init，也不做假的「已切换」提示。

能做的、也已经做了的是**只读诊断 + 安全引导**：

* 关于页直接写明上面三条，避免误以为点一下就能切；
* 本文给出切换前的检查清单（见下）；
* 仓库里没有任何刷机/提权代码，`kernel/`、`userspace/` 逻辑均来自上游。

### 切换前检查清单（手动执行，不涉及本 App 自动操作）

- [ ] 已解锁 bootloader（未解锁什么都做不了）
- [ ] 备份原厂 `boot.img` / `init_boot.img`，并确认能用 fastboot 救回
- [ ] 确认设备 KMI（如 `android12-5.10`）与待刷镜像一致，安全补丁级别不低于当前系统
- [ ] 明确当前生效的是 Magisk 还是 KSU，先完整卸载/还原再切另一套
- [ ] 重启后先用只读命令验证（`id`、`getprop`、`su -v`），不要同时装两套模块
- [ ] 关闭自动 OTA，避免 OTA 覆盖后卡在启动循环

## 4. 关于你贴的那段提权失败日志

日志来自第三方工具（DIRTYFRAGX 一类），内容是通过 patch `crash_dump64`、
向 `libc++.so` 注入 shellcode/trampoline、把 `dfroot.ko` 写进 vendor 库来尝试
临时装载内核模块，最后 `EXPLOIT FAILED: TIMEOUT`。

中性事实：

* 设备安全补丁 **2026-08-01**、内核 `5.10.246-gki`；日志里
  `vendor release 12 / system release 16` 不一致，工具按 vendor 推断为 `android12-5.10`；
* `TIMEOUT` 说明该临时路径没有在预期时间内完成，属于该工具与这台机器/补丁级别的匹配问题；
* **这不是 Manager APK 的 bug**，改 UI、改包名、改签名都修不了它。

我不会去调这个 exploit 的参数、也不会提供替代提权链或绕过安全补丁的办法。
正规路径只有一条：**解锁 bootloader 后，用与设备 KMI 匹配的官方 GKI/LKM
修补 boot 或 init_boot 并刷入**，参考 https://kernelsu.org/guide/installation.html。
刷机前务必备份原厂镜像。

## 5. 当前这台设备能做的

按截图：vivo V2301A / iQOO Neo8、Android 16、内核 5.10.246、未 root。
在没有内核侧 KSU、且内核未用本 APK 证书重建的情况下，本 fork 的 Manager
只能作为**只读控制面板 + 状态/许可/引导查看器**使用；「未安装」会一直显示。
想要能用的 root，请装官方 v3.3.1 Manager 并按官方流程处理内核。

## 6. v3 补充：两个变体与「为什么 v2 显示不了」

见 `COMPATIBILITY.md`。一句话：**第三方工具按官方包名 `me.weishu.kernelsu` 硬编码扫描**，v1 用这个包名所以能被列出（但当时 `libksud.so` 没解压，弹「未找到」），v2 为修同包名冲突改成 `me.lyu323.kernelsu`，工具连候选都找不到，于是显示「请先选择 SU 管理器」。

v3 一次构建出两个 APK：

* **Compat**（默认，`me.weishu.kernelsu`）→ 配合这类工具用，不能与官方 Manager 共存；
* **Coexist**（`me.lyu323.kernelsu`）→ 可与官方 Manager 并存，硬编码扫描器看不到。

两个都带解压后的 `libksud.so` 与 8 个 KMI 模块。用 `scripts/verify-manager-apk.sh <apk>` 可逐项自检。这是硬编码包名决定的取舍，无法「既独立包名又被扫描器找到」；本 fork 不做任何伪装壳。
