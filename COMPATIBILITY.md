<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
# 兼容性说明：为什么 v1 能显示、v2 不能显示（lyu323 fork）

> 本文解释截图里 DIRTYFRAGX 的行为差异，并说明 v3 的处理方式。**本 fork 不修改、不适配、不逆向任何第三方工具**，只把自己这一侧的客观条件做全。

## 1. 两个版本各自只满足了一半条件

第三方工具要「看到」一个 SU 管理器，至少要同时满足两个客观条件：

| 条件 | v1（`lyu323-fork-1-build1`） | v2（`lyu323-fork-2-build1`） |
| --- | --- | --- |
| A. 包名是它硬编码扫描的 `me.weishu.kernelsu` | ✅ 满足（图 34 能列出「SU 管理器 / KernelSU (lyu323 Fork)」卡片） | ❌ 改成 `me.lyu323.kernelsu`，工具连包都找不到 → 图 36「请先选择 SU 管理器 / 尚未选择·必需」 |
| B. `libksud.so` 能被外部进程读到实体文件 | ❌ `extractNativeLibs` 未强制打开 → 图 34 弹「未找到包含 libksud.so 的管理器」 | ✅ 已加 `android:extractNativeLibs="true"`，aapt 实测 `0xffffffff` |

所以：

* **v1 能显示** = 包名对，但 so 没解压，弹窗仍报找不到 so；
* **v2 显示不了** = so 修好了，但包名被上一轮「修复同包名冲突」改掉了。DIRTYFRAGX 按官方包名遍历已安装应用，找不到就显示「尚未选择·必需」，同时那条「未找到包含 libksud.so 的管理器」是它连候选都为空时的通用提示。

> ⚠️ 工具内部的检测逻辑是闭源的，我无法确认它除「包名 + libksud.so」外是否还校验签名、版本或其它条件。下面只保证本 fork 这一侧的条件全部成立。

## 2. v3 的处理：一次构建出两个变体，而不是二选一

| 变体 | 包名 | 应用名 | 用途 |
| --- | --- | --- | --- |
| **Compat（默认）** | `me.weishu.kernelsu` | `KernelSU (lyu323 Fork)` | 给按官方包名扫描的工具用；**不能**与官方 Manager 同时安装 |
| **Coexist** | `me.lyu323.kernelsu` | `KernelSU (lyu323 Fork Coexist)` | 与官方 Manager 共存；硬编码扫描器看不到它 |

两个变体都具备：

* `android:extractNativeLibs="true"` → `lib/arm64-v8a/libksud.so` 解压为真实文件；
* ksud 内嵌官方 v3.3.1 的 **8 个 aarch64 KMI 模块** + `ksuinit`（含 `android12-5.10`，对应截图设备）；
* 同一份 GPL 许可证、同一份精确源码。

**推荐**：你的场景（配合 DIRTYFRAGX）装 **Compat**。如果你以后要同时装官方 Manager，再换 Coexist —— 但那时扫描器就找不到 fork 了，这是硬编码包名决定的，无法两者兼得。

### 为什么不能「既独立包名又被扫描器找到」

因为扫描器按字符串找包。要么用那个包名（失去共存），要么换包名（失去可见性）。任何「伪装」做法（例如在独立包里放一个同名的空壳组件）都会误导工具、也可能引入签名校验失败，本 fork 不做。

## 3. 这一轮还修了一个隐藏问题

`userspace/ksud/build.rs` 原来只在 `KSU_PACKAGE_NAME` **未设置**时才输出 `cargo:rustc-env` 默认值，且没有 `rerun-if-env-changed`。如果同一 CI 里先用官方包名、再用独立包名各构建一次，第二次可能复用第一次的 `libksud.so`，导致 so 内的 manager 包名与 APK 不一致。

v3 改成：每次都把**实际生效**的 `KSU_PACKAGE_NAME` 输出为 `cargo:rustc-env`，并声明 `cargo:rerun-if-env-changed=KSU_PACKAGE_NAME`。这是本 fork 唯一改动的 userspace 源码（3 行 + 注释，带日期声明），逻辑行为不变。

## 4. 自检（电脑上运行）

```bash
bash scripts/verify-manager-apk.sh KernelSU-lyu323-fork-compat.apk
```

脚本打印：包名、应用名、`extractNativeLibs`、`libksud.so` 是否存在且为 ELF、内嵌的 KMI 列表、签名证书 SHA-256，并给出 Compat / Coexist 的预期结论。把输出和第三方工具的要求逐项对照即可。

若 Compat 版仍被拒：请用上面的输出确认包名确实是 `me.weishu.kernelsu`、`libksud.so` 确实存在；剩下的属于工具侧私有校验或该 exploit 与设备补丁级别的匹配问题，改 APK 解决不了。

## 5. 依旧成立的硬限制

1. **debug 签名**：官方内核会校验 Manager 包名 + 证书哈希，要用本 APK 的哈希重编内核模块才认。
2. **Manager 单装不给 root**：需要匹配设备 KMI 的内核模块 / 修补过的 boot 镜像，且需解锁 bootloader。
3. **未做真机验证**；构建成功 ≠ 你的设备能提权。
4. `EXPLOIT FAILED: TIMEOUT`（上一轮日志）来自第三方临时提权路径，不是 Manager 的 bug；本 fork 不调它的参数、不提供替代提权链。

## 6. 合规

`kernel/**` = GPL-2.0-only（`kernel/LICENSE`），其余 = GPL-3.0-or-later（`LICENSE`）。
两个 APK 都随附两份许可证全文与**该次构建对应的精确源码 zip**。内嵌 `.ko` 来自官方 v3.3.1 Release，其对应源码是本仓库逐字节未改的 `kernel/` 树。
私有仓库只适合留存自己的构建产物，不能据此对外闭源分发。

## 7. v4：识别成功 ≠ 有 root（以及官方 ksud 对齐）

图 39 里工具已列出并跳转到 Compat 管理器，但图 38 仍显示「未安装」——这两件事不矛盾：
root 来自内核侧，Manager 只是面板。完整因果见 `ROOT_CAUSE.md`。

v4 把 Compat 变体的 `libksud.so` 换成**官方 v3.3.1 APK 里提取的、逐字节一致的**二进制
（arm64-v8a / x86_64 / riscv64 三个 ABI 全换）。若工具按内容或大小校验 so，现在与官方包完全一致；
Coexist 因需要独立包名，仍用自编译 ksud。同时 App 首页新增「本机诊断（只读）」卡，
可直接看到 `nativeLibraryDir/libksud.so` 的真实状态与 `/dev/kernel_su` 是否存在。

若对齐后工具仍报「未找到」，属于其私有校验；用 `scripts/verify-manager-apk.sh` 打印客观事实对照。
本 fork 不调 exploit、不刷分区、不绕过安全补丁。
