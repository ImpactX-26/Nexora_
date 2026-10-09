package com.leads.cybersecurity.ui.navigation

import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.ui.graphics.vector.ImageVector

sealed class Screen(
    val route: String,
    val title: String,
    val icon: ImageVector
) {
    object Dashboard : Screen("dashboard", "Dashboard", Icons.Default.Shield)
    object Scanner : Screen("scanner", "AI Scanner", Icons.Default.Radar)
    object ChatAgent : Screen("chat", "Cyber Agent", Icons.Default.SmartToy)
    object Tools : Screen("tools", "Defense Hub", Icons.Default.Security)
    object Settings : Screen("settings", "Settings", Icons.Default.Tune)

    companion object {
        val bottomNavItems = listOf(Dashboard, Scanner, ChatAgent, Tools, Settings)
    }
}
