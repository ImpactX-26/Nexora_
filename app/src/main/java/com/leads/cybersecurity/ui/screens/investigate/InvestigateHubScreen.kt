package com.leads.cybersecurity.ui.screens.investigate

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
fun InvestigateHubScreen(
    viewModel: InvestigateViewModel,
    initialTab: Int = 0,
    onNavigateToActions: () -> Unit
) {
    val selectedTab by viewModel.selectedTab.collectAsState()
    val incident by viewModel.incident.collectAsState()

    val tabs = listOf(
        InvestigateTabItem("AI Investigation", Icons.Default.SmartToy),
        InvestigateTabItem("Timeline", Icons.Default.Timeline),
        InvestigateTabItem("ScamGraph", Icons.Default.Hub),
        InvestigateTabItem("Risk Assessment", Icons.Default.Assessment)
    )

    LaunchedEffect(initialTab) {
        viewModel.selectTab(initialTab.coerceIn(0, 3))
    }

    Scaffold(
        containerColor = CyberBackground,
        topBar = {
            Column {
                CyberHeader(
                    title = "INVESTIGATION HUB",
                    subtitle = "Coordinated Scam Forensics"
                )

                ScrollableTabRow(
                    selectedTabIndex = selectedTab,
                    containerColor = CyberBackground,
                    contentColor = CyberCyan,
                    edgePadding = 16.dp,
                    indicator = { tabPositions ->
                        Box(
                            Modifier
                                .tabIndicatorOffset(tabPositions[selectedTab])
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
                            selected = selectedTab == index,
                            onClick = { viewModel.selectTab(index) },
                            text = {
                                Text(
                                    text = tab.title,
                                    fontSize = 12.sp,
                                    fontWeight = if (selectedTab == index) FontWeight.Bold else FontWeight.Normal,
                                    color = if (selectedTab == index) CyberCyan else TextMuted
                                )
                            },
                            icon = {
                                Icon(
                                    imageVector = tab.icon,
                                    contentDescription = tab.title,
                                    tint = if (selectedTab == index) CyberCyan else TextMuted,
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
            when (selectedTab) {
                0 -> AiInvestigationView(incident = incident, onNavigateToActions = onNavigateToActions)
                1 -> AttackTimelineView(incident = incident)
                2 -> ScamGraphTabContent(incident = incident)
                3 -> RiskAssessmentView(incident = incident, onNavigateToActions = onNavigateToActions)
            }
        }
    }
}

private data class InvestigateTabItem(val title: String, val icon: ImageVector)
