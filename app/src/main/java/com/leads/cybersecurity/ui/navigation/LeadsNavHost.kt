package com.leads.cybersecurity.ui.navigation

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.navigation.NavGraph.Companion.findStartDestination
import androidx.navigation.NavHostController
import androidx.navigation.compose.*
import com.leads.cybersecurity.data.repository.SecurityRepository
import com.leads.cybersecurity.ui.screens.chat.AgentChatScreen
import com.leads.cybersecurity.ui.screens.chat.AgentChatViewModel
import com.leads.cybersecurity.ui.screens.dashboard.DashboardScreen
import com.leads.cybersecurity.ui.screens.dashboard.DashboardViewModel
import com.leads.cybersecurity.ui.screens.scanner.ScannerScreen
import com.leads.cybersecurity.ui.screens.scanner.ScannerViewModel
import com.leads.cybersecurity.ui.screens.settings.SettingsScreen
import com.leads.cybersecurity.ui.screens.settings.SettingsViewModel
import com.leads.cybersecurity.ui.screens.tools.ThreatToolsScreen
import com.leads.cybersecurity.ui.screens.tools.ToolsViewModel
import com.leads.cybersecurity.ui.theme.*

@Composable
fun LeadsNavHost(
    repository: SecurityRepository,
    navController: NavHostController = rememberNavController()
) {
    val dashboardViewModel = remember { DashboardViewModel(repository) }
    val scannerViewModel = remember { ScannerViewModel(repository) }
    val chatViewModel = remember { AgentChatViewModel(repository) }
    val toolsViewModel = remember { ToolsViewModel(repository) }
    val settingsViewModel = remember { SettingsViewModel(repository) }

    val navBackStackEntry by navController.currentBackStackEntryAsState()
    val currentDestination = navBackStackEntry?.destination

    var toolsInitialTab by remember { mutableIntStateOf(0) }

    Scaffold(
        containerColor = CyberBackground,
        bottomBar = {
            NavigationBar(
                containerColor = CyberSurface,
                contentColor = CyberCyan,
                tonalElevation = 8.dp
            ) {
                Screen.bottomNavItems.forEach { screen ->
                    val isSelected = currentDestination?.route == screen.route
                    NavigationBarItem(
                        selected = isSelected,
                        onClick = {
                            navController.navigate(screen.route) {
                                popUpTo(navController.graph.findStartDestination().id) {
                                    saveState = true
                                }
                                launchSingleTop = true
                                restoreState = true
                            }
                        },
                        icon = {
                            Icon(
                                imageVector = screen.icon,
                                contentDescription = screen.title,
                                modifier = Modifier.size(22.dp)
                            )
                        },
                        label = {
                            Text(
                                text = screen.title,
                                fontSize = 10.sp,
                                fontWeight = if (isSelected) FontWeight.Bold else FontWeight.Normal
                            )
                        },
                        colors = NavigationBarItemDefaults.colors(
                            selectedIconColor = CyberCyan,
                            selectedTextColor = CyberCyan,
                            unselectedIconColor = TextMuted,
                            unselectedTextColor = TextMuted,
                            indicatorColor = CyberCyanDark.copy(alpha = 0.6f)
                        )
                    )
                }
            }
        }
    ) { innerPadding ->
        NavHost(
            navController = navController,
            startDestination = Screen.Dashboard.route,
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding)
        ) {
            composable(Screen.Dashboard.route) {
                DashboardScreen(
                    viewModel = dashboardViewModel,
                    onNavigateToScanner = {
                        navController.navigate(Screen.Scanner.route) {
                            popUpTo(navController.graph.findStartDestination().id) { saveState = true }
                            launchSingleTop = true
                            restoreState = true
                        }
                    },
                    onNavigateToChat = {
                        navController.navigate(Screen.ChatAgent.route) {
                            popUpTo(navController.graph.findStartDestination().id) { saveState = true }
                            launchSingleTop = true
                            restoreState = true
                        }
                    },
                    onNavigateToTools = { tabIndex ->
                        toolsInitialTab = tabIndex
                        navController.navigate(Screen.Tools.route) {
                            popUpTo(navController.graph.findStartDestination().id) { saveState = true }
                            launchSingleTop = true
                            restoreState = true
                        }
                    }
                )
            }

            composable(Screen.Scanner.route) {
                ScannerScreen(viewModel = scannerViewModel)
            }

            composable(Screen.ChatAgent.route) {
                AgentChatScreen(viewModel = chatViewModel)
            }

            composable(Screen.Tools.route) {
                ThreatToolsScreen(
                    viewModel = toolsViewModel,
                    initialTab = toolsInitialTab
                )
            }

            composable(Screen.Settings.route) {
                SettingsScreen(viewModel = settingsViewModel)
            }
        }
    }
}
