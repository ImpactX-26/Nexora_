package com.leads.cybersecurity.ui.screens.home

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowForward
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.leads.cybersecurity.ui.components.*
import com.leads.cybersecurity.ui.theme.*

@Composable
fun HomeDashboardScreen(
    viewModel: HomeDashboardViewModel,
    onNavigateToThreatDetails: (String) -> Unit,
    onNavigateToThreatCenter: () -> Unit,
    onNavigateToInvestigate: () -> Unit,
    onNavigateToScanner: (String) -> Unit
) {
    val incident by viewModel.incident.collectAsState()
    val score by viewModel.securityScore.collectAsState()

    Scaffold(
        containerColor = CyberBackground,
        topBar = {
            CyberHeader(
                title = "LEADS",
                subtitle = "Your Personal Cybersecurity Agent",
                trailingAction = {
                    Surface(
                        shape = RoundedCornerShape(20.dp),
                        color = SeveritySafe.copy(alpha = 0.12f),
                        border = androidx.compose.foundation.BorderStroke(1.dp, SeveritySafe.copy(alpha = 0.35f))
                    ) {
                        Row(
                            modifier = Modifier.padding(horizontal = 10.dp, vertical = 5.dp),
                            verticalAlignment = Alignment.CenterVertically,
                            horizontalArrangement = Arrangement.spacedBy(6.dp)
                        ) {
                            Box(
                                modifier = Modifier
                                    .size(7.dp)
                                    .clip(CircleShape)
                                    .background(SeveritySafe)
                            )
                            Text(
                                text = "SHIELD ACTIVE",
                                color = SeveritySafe,
                                style = MaterialTheme.typography.labelSmall.copy(
                                    fontWeight = FontWeight.Bold,
                                    fontSize = 10.sp
                                )
                            )
                        }
                    }
                }
            )
        }
    ) { innerPadding ->
        LazyColumn(
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding),
            contentPadding = PaddingValues(16.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            // 1. Security Status Card (SECURE, 92 / 100)
            item {
                GlassCard(
                    borderColor = SeveritySafe.copy(alpha = 0.35f)
                ) {
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Column(modifier = Modifier.weight(1f)) {
                            Surface(
                                shape = RoundedCornerShape(6.dp),
                                color = SeveritySafe.copy(alpha = 0.15f)
                            ) {
                                Text(
                                    text = "DEVICE STATUS: SECURE",
                                    color = SeveritySafe,
                                    style = MaterialTheme.typography.labelSmall.copy(
                                        fontSize = 10.sp,
                                        fontWeight = FontWeight.Bold,
                                        letterSpacing = 0.8.sp
                                    ),
                                    modifier = Modifier.padding(horizontal = 8.dp, vertical = 3.dp)
                                )
                            }
                            Spacer(modifier = Modifier.height(6.dp))
                            Text(
                                text = "Personal Defense Layer",
                                style = MaterialTheme.typography.titleMedium.copy(
                                    fontWeight = FontWeight.Bold,
                                    color = TextPrimary
                                )
                            )
                            Spacer(modifier = Modifier.height(2.dp))
                            Text(
                                text = "Autonomous correlation active on incoming SMS, links & APK payloads.",
                                style = MaterialTheme.typography.bodySmall.copy(
                                    color = TextSecondary,
                                    fontSize = 12.sp
                                )
                            )
                        }

                        CyberGauge(
                            score = score.overallScore,
                            maxScore = score.maxScore,
                            healthStatus = score.healthStatus,
                            size = 110.dp,
                            strokeWidth = 9.dp
                        )
                    }
                }
            }

            // 2. Protection Insight Banner
            item {
                Surface(
                    modifier = Modifier.fillMaxWidth(),
                    shape = RoundedCornerShape(12.dp),
                    color = CyberSurfaceVariant.copy(alpha = 0.8f),
                    border = androidx.compose.foundation.BorderStroke(1.dp, BorderCyber.copy(alpha = 0.5f))
                ) {
                    Row(
                        modifier = Modifier.padding(12.dp),
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(10.dp)
                    ) {
                        Icon(
                            imageVector = Icons.Default.Info,
                            contentDescription = null,
                            tint = CyberCyan,
                            modifier = Modifier.size(20.dp)
                        )
                        Text(
                            text = "LEADS detected and investigated 3 suspicious interactions this week.",
                            style = MaterialTheme.typography.bodySmall.copy(
                                color = TextPrimary,
                                fontWeight = FontWeight.Medium,
                                fontSize = 12.sp
                            )
                        )
                    }
                }
            }

            // 3. Primary Coordinated Threat Card (Hero Alert)
            item {
                SectionHeader(title = "Active Threat Investigation", trailingText = "1 Campaign")
                Spacer(modifier = Modifier.height(4.dp))
                ThreatCard(
                    incident = incident,
                    onClick = { onNavigateToThreatDetails(incident.id) }
                )
            }

            // 4. Quick Actions
            item {
                SectionHeader(title = "Quick Actions")
                Spacer(modifier = Modifier.height(4.dp))
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    QuickActionTile(
                        title = "Scan URL",
                        icon = Icons.Default.Link,
                        tint = CyberCyan,
                        onClick = { onNavigateToScanner("URL") },
                        modifier = Modifier.weight(1f)
                    )
                    QuickActionTile(
                        title = "Scan File",
                        icon = Icons.Default.InsertDriveFile,
                        tint = CyberPurple,
                        onClick = { onNavigateToScanner("FILE") },
                        modifier = Modifier.weight(1f)
                    )
                }
                Spacer(modifier = Modifier.height(8.dp))
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    QuickActionTile(
                        title = "View Threats",
                        icon = Icons.Default.Security,
                        tint = SeverityHigh,
                        onClick = onNavigateToThreatCenter,
                        modifier = Modifier.weight(1f)
                    )
                    QuickActionTile(
                        title = "Investigate",
                        icon = Icons.Default.Hub,
                        tint = SeverityCritical,
                        onClick = onNavigateToInvestigate,
                        modifier = Modifier.weight(1f)
                    )
                }
            }

            // 5. Recent Activity
            item {
                SectionHeader(title = "Recent Activity")
                Spacer(modifier = Modifier.height(4.dp))
                GlassCard {
                    Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
                        RecentActivityRow(
                            title = "Suspicious SMS analyzed",
                            timestamp = "10:42 AM",
                            icon = Icons.Default.ChatBubbleOutline,
                            tint = SeverityCritical
                        )
                        HorizontalDivider(color = BorderCyber.copy(alpha = 0.4f))
                        RecentActivityRow(
                            title = "URL investigated (wellsfarg0-secure.xyz)",
                            timestamp = "10:44 AM",
                            icon = Icons.Default.Link,
                            tint = SeverityCritical
                        )
                        HorizontalDivider(color = BorderCyber.copy(alpha = 0.4f))
                        RecentActivityRow(
                            title = "APK scan completed (wf-verify-auth.apk)",
                            timestamp = "10:47 AM",
                            icon = Icons.Default.Download,
                            tint = SeverityCritical
                        )
                    }
                }
            }
        }
    }
}

@Composable
private fun QuickActionTile(
    title: String,
    icon: ImageVector,
    tint: Color,
    onClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    Surface(
        modifier = modifier.clickable { onClick() },
        shape = RoundedCornerShape(12.dp),
        color = CyberSurfaceVariant.copy(alpha = 0.75f),
        border = androidx.compose.foundation.BorderStroke(1.dp, BorderCyber.copy(alpha = 0.5f))
    ) {
        Row(
            modifier = Modifier.padding(14.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(10.dp)
        ) {
            Surface(
                shape = RoundedCornerShape(8.dp),
                color = tint.copy(alpha = 0.15f),
                modifier = Modifier.size(32.dp)
            ) {
                Box(contentAlignment = Alignment.Center) {
                    Icon(
                        imageVector = icon,
                        contentDescription = null,
                        tint = tint,
                        modifier = Modifier.size(18.dp)
                    )
                }
            }
            Text(
                text = title,
                style = MaterialTheme.typography.titleSmall.copy(
                    fontWeight = FontWeight.Bold,
                    color = TextPrimary,
                    fontSize = 13.sp
                )
            )
        }
    }
}

@Composable
private fun RecentActivityRow(
    title: String,
    timestamp: String,
    icon: ImageVector,
    tint: Color
) {
    Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically
    ) {
        Row(
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(8.dp),
            modifier = Modifier.weight(1f)
        ) {
            Icon(
                imageVector = icon,
                contentDescription = null,
                tint = tint,
                modifier = Modifier.size(16.dp)
            )
            Text(
                text = title,
                style = MaterialTheme.typography.bodySmall.copy(
                    color = TextPrimary,
                    fontWeight = FontWeight.Medium
                ),
                maxLines = 1
            )
        }

        Text(
            text = timestamp,
            style = MaterialTheme.typography.labelSmall.copy(
                color = TextMuted,
                fontSize = 10.sp
            )
        )
    }
}
