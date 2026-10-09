package com.leads.cybersecurity.ui.theme

import android.app.Activity
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.SideEffect
import androidx.compose.ui.graphics.toArgb
import androidx.compose.ui.platform.LocalView
import androidx.core.view.WindowCompat

private val DarkColorScheme = darkColorScheme(
    primary = CyberCyan,
    onPrimary = CyberBackground,
    primaryContainer = CyberCyanDark,
    onPrimaryContainer = CyberCyan,
    secondary = CyberPurple,
    onSecondary = CyberBackground,
    secondaryContainer = CyberPurpleDark,
    onSecondaryContainer = CyberPurple,
    tertiary = CyberGreen,
    onTertiary = CyberBackground,
    tertiaryContainer = CyberGreenDark,
    onTertiaryContainer = CyberGreen,
    error = CyberRed,
    onError = CyberBackground,
    errorContainer = CyberRedDark,
    onErrorContainer = CyberRed,
    background = CyberBackground,
    onBackground = TextPrimary,
    surface = CyberSurface,
    onSurface = TextPrimary,
    surfaceVariant = CyberSurfaceVariant,
    onSurfaceVariant = TextSecondary,
    outline = BorderCyber,
    outlineVariant = CyberSurfaceLight
)

@Composable
fun LEADSTheme(
    darkTheme: Boolean = true, // Cyberpunk dark aesthetic is default for security
    content: @Composable () -> Unit
) {
    val colorScheme = DarkColorScheme
    val view = LocalView.current
    if (!view.isInEditMode) {
        SideEffect {
            val window = (view.context as Activity).window
            window.statusBarColor = colorScheme.background.toArgb()
            window.navigationBarColor = colorScheme.background.toArgb()
            WindowCompat.getInsetsController(window, view).isAppearanceLightStatusBars = false
            WindowCompat.getInsetsController(window, view).isAppearanceLightNavigationBars = false
        }
    }

    MaterialTheme(
        colorScheme = colorScheme,
        typography = Typography,
        shapes = Shapes,
        content = content
    )
}
