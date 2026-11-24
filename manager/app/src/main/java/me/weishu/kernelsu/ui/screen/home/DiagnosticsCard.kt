// Modified for lyu323 fork (2026-11-24). NEW FILE.
// SPDX-License-Identifier: GPL-3.0-or-later
// Read-only diagnostics. This screen NEVER attempts to grant root, patch a
// partition or invoke an exploit. It only reports objective facts so the user
// can tell "manager was found" apart from "kernel side actually has root".
package me.weishu.kernelsu.ui.screen.home

import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Card
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalUriHandler
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import me.weishu.kernelsu.R
import java.io.File
import java.security.MessageDigest

private val KMI_LIST = listOf(
    "android12-5.10", "android13-5.10", "android13-5.15", "android14-5.15",
    "android14-6.1", "android15-6.6", "android16-6.12", "android17-6.18",
)

private fun sha256Short(bytes: ByteArray): String =
    MessageDigest.getInstance("SHA-256").digest(bytes)
        .joinToString("") { "%02x".format(it) }.take(16)

private fun readOneLine(path: String): String = try {
    File(path).readText().trim()
} catch (_: Throwable) {
    "n/a"
}

private fun collectDiagnostics(context: Context): String {
    val sb = StringBuilder()
    val pkg = context.packageName
    sb.appendLine("== lyu323 fork - read-only diagnostics ==")
    sb.appendLine("package: $pkg")
    try {
        val pi = context.packageManager.getPackageInfo(pkg, 0)
        sb.appendLine("version: ${pi.versionName} (${pi.longVersionCode})")
        val si = context.packageManager
            .getPackageInfo(pkg, PackageManager.GET_SIGNING_CERTIFICATES).signingInfo
        val signer = si?.apkContentsSigners?.firstOrNull()?.toByteArray()
        sb.appendLine("signer sha256: ${signer?.let { sha256Short(it) } ?: "n/a"}")
    } catch (_: Throwable) {
        sb.appendLine("version / signer: unavailable")
    }

    val nlib = context.applicationInfo.nativeLibraryDir
    val so = File(nlib, "libksud.so")
    sb.appendLine("nativeLibraryDir: $nlib")
    sb.appendLine("libksud.so: exists=${so.exists()} size=${if (so.exists()) so.length() else 0}")
    if (so.exists()) {
        try {
            val bytes = so.readBytes()
            val isElf = bytes.size >= 4 && bytes[0] == 0x7f.toByte() &&
                bytes[1] == 'E'.code.toByte() && bytes[2] == 'L'.code.toByte() &&
                bytes[3] == 'F'.code.toByte()
            val text = String(bytes, Charsets.ISO_8859_1)
            val hit = KMI_LIST.count { text.contains("${it}_kernelsu.ko") }
            sb.appendLine("  ELF=$isElf  embeddedKMI=$hit/8  ksuinit=${text.contains("ksuinit")}")
            sb.appendLine("  officialPackageInSo=${text.contains("me.weishu.kernelsu")}  coexistPackageInSo=${text.contains("me.lyu323.kernelsu")}")
        } catch (_: Throwable) {
            sb.appendLine("  (could not read libksud.so)")
        }
    }

    val kernelSu = File("/dev/kernel_su").exists()
    sb.appendLine("kernel KSU device (/dev/kernel_su): $kernelSu")
    sb.appendLine("ksu data dir (/data/adb/ksu): ${File("/data/adb/ksu").exists()}")
    sb.appendLine("SELinux enforce: ${readOneLine("/sys/fs/selinux/enforce")}")
    sb.appendLine("device: ${Build.BRAND} ${Build.MODEL} / Android ${Build.VERSION.RELEASE} / ${Build.SUPPORTED_ABIS.firstOrNull() ?: "?"}")
    sb.appendLine("kernel: ${readOneLine("/proc/version").take(90)}")
    sb.appendLine("")
    if (kernelSu) {
        sb.appendLine("CONCLUSION: kernel side has KernelSU loaded.")
    } else {
        sb.appendLine("CONCLUSION: NO kernel-side KSU -> Manager correctly shows 'Not installed'")
        sb.appendLine("            and this app has NO root. A Manager APK never grants root by")
        sb.appendLine("            itself; root comes from a kernel module / patched boot image.")
        sb.appendLine("            A third-party tool finding and launching this Manager is NOT")
        sb.appendLine("            the same as a successful temporary-root exploit. This app does")
        sb.appendLine("            not flash partitions, tune exploits or bypass security patches.")
    }
    return sb.toString().trimEnd()
}

@Composable
fun DiagnosticsCard() {
    val context = LocalContext.current
    val uriHandler = LocalUriHandler.current
    val report = remember { collectDiagnostics(context) }

    Card(modifier = Modifier.fillMaxWidth()) {
        Column(modifier = Modifier.padding(16.dp)) {
            Text(
                text = stringResource(R.string.diag_title),
                style = MaterialTheme.typography.titleMedium,
            )
            Spacer(Modifier.height(6.dp))
            Text(
                text = report,
                style = MaterialTheme.typography.bodySmall,
            )
            Spacer(Modifier.height(6.dp))
            TextButton(onClick = {
                val cm = context.getSystemService(ClipboardManager::class.java)
                cm.setPrimaryClip(ClipData.newPlainText("ksu-diagnostics", report))
            }) { Text(stringResource(R.string.diag_copy)) }
            TextButton(onClick = {
                uriHandler.openUri(
                    "https://github.com/lyu323/KernelSU-lyu323-fork/blob/main/COMPATIBILITY.md"
                )
            }) { Text(stringResource(R.string.diag_guide)) }
        }
    }
}
