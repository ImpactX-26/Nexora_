package com.leads.cybersecurity.ui.screens.threats

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Shield
import androidx.compose.material3.*
import androidx.compose.material3.TabRowDefaults.tabIndicatorOffset
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.leads.cybersecurity.ui.components.CyberHeader
import com.leads.cybersecurity.ui.components.GlassCard
import com.leads.cybersecurity.ui.components.ThreatCard
import com.leads.cybersecurity.ui.theme.*

@Composable
fun ThreatCenterScreen(
    viewModel: ThreatCenterViewModel,
    onOpenThreatDetails: (String) -> Unit
) {
    val selectedTab by viewModel.selectedTab.collectAsState()
    val incidents by viewModel.filteredIncidents.collectAsState()

    val tabs = listOf("Active Campaigns", "Isolated Anomalies", "Resolved")

    Scaffold(
        containerColor = CyberBackground,
        topBar = {
            Column {
                CyberHeader(
                    title = "THREAT CENTER",
                    subtitle = "Correlated Attacks & Anomaly Triage"
                )

                TabRow(
                    selectedTabIndex = selectedTab,
                    containerColor = CyberBackground,
                    contentColor = CyberCyan,
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
                    tabs.forEachIndexed { index, tabTitle ->
                        Tab(
                            selected = selectedTab == index,
                            onClick = { viewModel.selectTab(index) },
                            text = {
                                Text(
                                    text = tabTitle,
                                    fontSize = 12.sp,
                                    fontWeight = if (selectedTab == index) FontWeight.Bold else FontWeight.Normal,
                                    color = if (selectedTab == index) CyberCyan else TextMuted
                                )
                            }
                        )
                    }
                }
            }
        }
    ) { innerPadding ->
        LazyColumn(
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding),
            contentPadding = PaddingValues(16.dp),
            verticalArrangement = Arrangement.spacedBy(14.dp)
        ) {
            if (incidents.isEmpty()) {
                item {
                    GlassCard(borderColor = SeveritySafe.copy(alpha = 0.3f)) {
                        Row(
                            verticalAlignment = Alignment.CenterVertically,
                            horizontalArrangement = Arrangement.spacedBy(12.dp)
                        ) {
                            Icon(
                                imageVector = Icons.Default.Shield,
                                contentDescription = null,
                                tint = SeveritySafe,
                                modifier = Modifier.size(28.dp)
                            )
                            Column {
                                Text(
                                    text = "No Threats in this Category",
                                    style = MaterialTheme.typography.titleSmall.copy(
                                        fontWeight = FontWeight.Bold,
                                        color = TextPrimary
                                    )
                                )
                                Text(
                                    text = "Perimeter filters report no active anomalous payloads in this buffer.",
                                    style = MaterialTheme.typography.bodySmall.copy(color = TextMuted)
                                )
                            }
                        }
                    }
                }
            } else {
                items(incidents, key = { it.id }) { item ->
                    ThreatCard(
                        incident = item,
                        onClick = { onOpenThreatDetails(item.id) }
                    )
                }
            }
        }
    }
}
