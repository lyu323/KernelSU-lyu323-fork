// Modified for lyu323 fork (2026-11-24): one extra selectable key color.
// See FORK_NOTES.md for the full diff and GPL notices.

package me.weishu.kernelsu.ui.theme

import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.toArgb

val keyColorOptions = listOf(
    Color(0xFFF44336).toArgb(),
    Color(0xFFE91E63).toArgb(),
    Color(0xFF9C27B0).toArgb(),
    Color(0xFF673AB7).toArgb(),
    Color(0xFF3F51B5).toArgb(),
    Color(0xFF2196F3).toArgb(),
    Color(0xFF00BCD4).toArgb(),
    Color(0xFF009688).toArgb(),
    Color(0xFF4FAF50).toArgb(),
    Color(0xFFFFEB3B).toArgb(),
    Color(0xFFFFC107).toArgb(),
    Color(0xFFFF9800).toArgb(),
    Color(0xFF795548).toArgb(),
    Color(0xFF607D8F).toArgb(),
    Color(0xFFFF9CA8).toArgb(),
    // lyu323 fork: extra cyan key color
    Color(0xFF26C6DA).toArgb(),
)
