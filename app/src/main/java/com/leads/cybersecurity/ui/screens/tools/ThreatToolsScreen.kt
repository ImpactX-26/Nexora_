package com.leads.cybersecurity.ui.screens.tools

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.material3.TabRowDefaults.tabIndicatorOffset
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.leads.cybersecurity.ui.components.CyberHeader
import com.leads.cybersecurity.ui.theme.*

@Composable
fun ThreatToolsScreen(
    viewModel: ToolsViewModel,
    initialTab: Int = 0
) {
    var selectedTabIndex by remember(initialTab) { mutableIntStateOf(initialTab.coerceIn(0, 3)) }

    val tabs = listOf(
        TabItem("Phishing", Icons.Default.Link),
        TabItem("App Privacy", Icons.Default.Lock),
        TabItem("Dark Web", Icons.Default.Visibility),
        TabItem("Wi-Fi Audit", Icons.Default.Wifi)
    )

    Scaffold(
        containerColor = CyberBackground,
        topBar = {
            Column {
                CyberHeader(
                    title = "DEFENSE HUB",
                    subtitle = "Specialized Cyber Instruments"
                )

                ScrollableTabRow(
                    selectedTabIndex = selectedTabIndex,
                    containerColor = CyberBackground,
                    contentColor = CyberCyan,
                    edgePadding = 16.dp,
                    indicator = { tabPositions ->
                        Box(
                            Modifier
                                .tabIndicatorOffset(tabPositions[selectedTabIndex])
                                .height(3.dp)
                                .clip(RoundedCornerShape(topStart = 3.dp, topEnd = 3.dp))
                                .background(CyberCyan)
                        )
                    },
                    divider = {
                        HorizontalDivider(color = BorderCyber.copy(alpha = 0.5f))
                    }
                ) {
                    tabs.forEachIndexed { index, tab ->
                        Tab(
                            selected = selectedTabIndex == index,
                            onClick = { selectedTabIndex = index },
                            text = {
                                Text(
                                    text = tab.title,
                                    fontSize = 12.sp,
                                    fontWeight = if (selectedTabIndex == index) FontWeight.Bold else FontWeight.Normal,
                                    color = if (selectedTabIndex == index) CyberCyan else TextMuted
                                )
                            },
                            icon = {
                                Icon(
                                    imageVector = tab.icon,
                                    contentDescription = tab.title,
                                    tint = if (selectedTabIndex == index) CyberCyan else TextMuted,
                                    modifier = Modifier.size(18.dp)
                                )
                            }
                        )
                    }
                }
            }
        }
    ) { innerPadding ->
        Box(
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding)
        ) {
            when (selectedTabIndex) {
                0 -> PhishingAnalyzerView(viewModel = viewModel)
                1 -> AppPrivacyGuardView(viewModel = viewModel)
                2 -> DarkWebMonitorView(viewModel = viewModel)
                3 -> WifiAuditorView(viewModel = viewModel)
            }
        }
    }
}

private data class TabItem(val title: String, val icon: ImageVector)
