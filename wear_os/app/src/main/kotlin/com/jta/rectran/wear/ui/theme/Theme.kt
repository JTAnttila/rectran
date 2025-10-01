package com.jta.rectran.wear.ui.theme

import androidx.compose.runtime.Composable
import androidx.wear.compose.material.MaterialTheme

@Composable
fun RectranWatchTheme(
    content: @Composable () -> Unit
) {
    MaterialTheme(
        colors = WatchColorPalette,
        content = content
    )
}
