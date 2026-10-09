package com.leads.cybersecurity.ui.screens.dashboard

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.leads.cybersecurity.data.model.ThreatCategory
import com.leads.cybersecurity.data.model.ThreatItem
import com.leads.cybersecurity.data.model.ThreatSeverity
import com.leads.cybersecurity.ui.components.*
import com.leads.cybersecurity.ui.theme.*

@Composable
fun DashboardScreen(
    viewModel: DashboardViewModel,
    onNavigateToScanner: () -> Unit,
    onNavigateToChat: () -> Unit,
    onNavigateToTools: (Int) -> Unit // tab index
) {
    val score by viewModel.securityScoreState.collectAsState()
    val activeThreats by viewModel.activeThreatsState.collectAsState()
    var selectedThreat by remember { mutableStateOf<ThreatItem?>(null) }

    Scaffold(
        containerColor = CyberBackground,
        topBar = {
            CyberHeader(
                title = "LEADS CORE",
                subtitle = "Autonomous Personal Cyber Agent",
                trailingAction = {
                    Surface(
                        shape = RoundedCornerShape(20.dp),
                        color = CyberGreen.copy(alpha = 0.12f),
                        border = androidx.compose.foundation.BorderStroke(1.dp, CyberGreen.copy(alpha = 0.3f))
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
                                    .background(CyberGreen)
                            )
                            Text(
                                text = "ACTIVE SHIELD",
                                color = CyberGreen,
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
            // Section 1: Cyber Health Score Gauge & Sub-metrics
            item {
                GlassCard(
                    modifier = Modifier.fillMaxWidth(),
                    borderColor = CyberCyan.copy(alpha = 0.3f)
                ) {
                    Column(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalAlignment = Alignment.CenterHorizontally
                    ) {
                        CyberGauge(
                            score = score.overallScore,
                            maxScore = score.maxScore,
                            healthStatus = score.healthStatus
                        )

                        Spacer(modifier = Modifier.height(16.dp))

                        // Category sub-score indicators
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceEvenly
                        ) {
                            CategoryPill("Network", "${score.networkScore}%", CyberCyan)
                            CategoryPill("Privacy", "${score.privacyScore}%", CyberPurple)
                            CategoryPill("Identity", "${score.identityScore}%", CyberAmber)
                            CategoryPill("System", "${score.systemScore}%", CyberGreen)
                        }
                    }
                }
            }

            // Section 2: Threat Radar & Live Scan Banner
            item {
                GlassCard(
                    borderColor = if (activeThreats.isNotEmpty()) CyberRed.copy(alpha = 0.35f) else CyberCyan.copy(alpha = 0.25f)
                ) {
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.SpaceBetween
                    ) {
                        Column(modifier = Modifier.weight(1f)) {
                            Row(
                                verticalAlignment = Alignment.CenterVertically,
                                horizontalArrangement = Arrangement.spacedBy(6.dp)
                            ) {
                                Text(
                                    text = "THREAT RADAR",
                                    style = MaterialTheme.typography.titleMedium.copy(
                                        fontWeight = FontWeight.Bold,
                                        color = TextPrimary
                                    )
                                )
                                if (activeThreats.isNotEmpty()) {
                                    SeverityBadge(severity = ThreatSeverity.HIGH)
                                }
                            }

                            Spacer(modifier = Modifier.height(4.dp))
                            Text(
                                text = if (activeThreats.isEmpty())
                                    "No immediate intrusions. All defense perimeters active."
                                else
                                    "${activeThreats.size} high-risk threat vectors require mitigation.",
                                style = MaterialTheme.typography.bodySmall.copy(color = TextSecondary)
                            )

                            Spacer(modifier = Modifier.height(10.dp))
                            Button(
                                onClick = onNavigateToScanner,
                                colors = ButtonDefaults.buttonColors(
                                    containerColor = CyberCyan,
                                    contentColor = CyberBackground
                                ),
                                shape = RoundedCornerShape(10.dp),
                                contentPadding = PaddingValues(horizontal = 14.dp, vertical = 6.dp)
                            ) {
                                Icon(
                                    imageVector = Icons.Default.Radar,
                                    contentDescription = null,
                                    modifier = Modifier.size(16.dp)
                                )
                                Spacer(modifier = Modifier.width(6.dp))
                                Text(
                                    text = "Run AI Deep Scan",
                                    fontWeight = FontWeight.Bold,
                                    fontSize = 12.sp
                                )
                            }
                        }

                        ThreatRadarView(
                            threatsCount = activeThreats.size,
                            modifier = Modifier.padding(start = 8.dp)
                        )
                    }
                }
            }

            // Section 3: Quick Defense Actions Grid
            item {
                Text(
                    text = "DEFENSE CAPABILITIES",
                    style = MaterialTheme.typography.labelLarge.copy(
                        color = TextMuted,
                        letterSpacing = 1.sp,
                        fontWeight = FontWeight.Bold
                    )
                )
                Spacer(modifier = Modifier.height(8.dp))

                Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        QuickActionTile(
                            title = "Phishing Shield",
                            desc = "Analyze SMS / URLs",
                            icon = Icons.Default.Link,
                            tint = CyberCyan,
                            modifier = Modifier.weight(1f),
                            onClick = { onNavigateToTools(0) }
                        )
                        QuickActionTile(
                            title = "Privacy Guard",
                            desc = "Audit Permissions",
                            icon = Icons.Default.Lock,
                            tint = CyberPurple,
                            modifier = Modifier.weight(1f),
                            onClick = { onNavigateToTools(1) }
                        )
                    }
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        QuickActionTile(
                            title = "Dark Web Watch",
                            desc = "Compromised IDs",
                            icon = Icons.Default.Visibility,
                            tint = CyberAmber,
                            modifier = Modifier.weight(1f),
                            onClick = { onNavigateToTools(2) }
                        )
                        QuickActionTile(
                            title = "Ask AI Agent",
                            desc = "Interactive Copilot",
                            icon = Icons.Default.SmartToy,
                            tint = CyberGreen,
                            modifier = Modifier.weight(1f),
                            onClick = onNavigateToChat
                        )
                    }
                }
            }

            // Section 4: Active Vulnerabilities List
            item {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(
                        text = "ACTIVE THREATS & ANOMALIES (${activeThreats.size})",
                        style = MaterialTheme.typography.labelLarge.copy(
                            color = TextMuted,
                            letterSpacing = 1.sp,
                            fontWeight = FontWeight.Bold
                        )
                    )
                }
            }

            if (activeThreats.isEmpty()) {
                item {
                    GlassCard(borderColor = CyberGreen.copy(alpha = 0.3f)) {
                        Row(
                            verticalAlignment = Alignment.CenterVertically,
                            horizontalArrangement = Arrangement.spacedBy(12.dp)
                        ) {
                            Icon(
                                imageVector = Icons.Default.CheckCircle,
                                contentDescription = null,
                                tint = CyberGreen,
                                modifier = Modifier.size(32.dp)
                            )
                            Column {
                                Text(
                                    text = "All Defense Perimeters Clear",
                                    style = MaterialTheme.typography.titleMedium.copy(
                                        fontWeight = FontWeight.Bold,
                                        color = TextPrimary
                                    )
                                )
                                Text(
                                    text = "Autonomous filters are actively blocking incoming malicious payloads.",
                                    style = MaterialTheme.typography.bodySmall.copy(color = TextSecondary)
                                )
                            }
                        }
                    }
                }
            } else {
                items(activeThreats, key = { it.id }) { threat ->
                    ThreatItemCard(
                        threat = threat,
                        onMitigate = { viewModel.mitigateThreat(threat.id) },
                        onInspect = { selectedThreat = threat }
                    )
                }
            }
        }
    }

    // Threat Details Sheet / Dialog
    selectedThreat?.let { threat ->
        AlertDialog(
            onDismissRequest = { selectedThreat = null },
            containerColor = CyberSurface,
            title = {
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    SeverityBadge(severity = threat.severity)
                    Text(
                        text = threat.title,
                        style = MaterialTheme.typography.titleMedium.copy(
                            fontWeight = FontWeight.Bold,
                            color = TextPrimary
                        )
                    )
                }
            },
            text = {
                Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
                    Text(
                        text = threat.description,
                        style = MaterialTheme.typography.bodyMedium.copy(color = TextSecondary)
                    )
                    HorizontalDivider(color = BorderCyber)
                    Text(
                        text = "Target / Resource: ${threat.affectedResource}",
                        style = MaterialTheme.typography.bodySmall.copy(color = CyberCyan, fontWeight = FontWeight.SemiBold)
                    )
                    Text(
                        text = "AI Neural Analysis:",
                        style = MaterialTheme.typography.labelMedium.copy(color = TextMuted)
                    )
                    Text(
                        text = threat.aiExplanation,
                        style = MaterialTheme.typography.bodySmall.copy(color = TextPrimary)
                    )
                    Text(
                        text = "Remediation Checklist:",
                        style = MaterialTheme.typography.labelMedium.copy(color = TextMuted)
                    )
                    threat.remediationSteps.forEach { step ->
                        Row(
                            horizontalArrangement = Arrangement.spacedBy(6.dp),
                            verticalAlignment = Alignment.Top
                        ) {
                            Text(text = "•", color = CyberCyan)
                            Text(
                                text = step,
                                style = MaterialTheme.typography.bodySmall.copy(color = TextSecondary)
                            )
                        }
                    }
                }
            },
            confirmButton = {
                Button(
                    onClick = {
                        viewModel.mitigateThreat(threat.id)
                        selectedThreat = null
                    },
                    colors = ButtonDefaults.buttonColors(containerColor = CyberCyan, contentColor = CyberBackground)
                ) {
                    Text(text = "Neutralize Threat", fontWeight = FontWeight.Bold)
                }
            },
            dismissButton = {
                TextButton(onClick = { selectedThreat = null }) {
                    Text(text = "Dismiss", color = TextMuted)
                }
            }
        )
    }
}

@Composable
private fun CategoryPill(label: String, scoreText: String, color: Color) {
    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        Text(
            text = scoreText,
            style = MaterialTheme.typography.titleMedium.copy(
                fontWeight = FontWeight.Bold,
                color = color
            )
        )
        Text(
            text = label,
            style = MaterialTheme.typography.labelSmall.copy(
                color = TextMuted,
                fontSize = 10.sp
            )
        )
    }
}

@Composable
private fun QuickActionTile(
    title: String,
    desc: String,
    icon: ImageVector,
    tint: Color,
    onClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    Surface(
        modifier = modifier.clickable { onClick() },
        shape = RoundedCornerShape(12.dp),
        color = CyberSurfaceVariant.copy(alpha = 0.7f),
        border = androidx.compose.foundation.BorderStroke(1.dp, BorderCyber.copy(alpha = 0.5f))
    ) {
        Column(
            modifier = Modifier.padding(12.dp)
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
            Spacer(modifier = Modifier.height(8.dp))
            Text(
                text = title,
                style = MaterialTheme.typography.titleSmall.copy(
                    fontWeight = FontWeight.Bold,
                    color = TextPrimary
                )
            )
            Text(
                text = desc,
                style = MaterialTheme.typography.bodySmall.copy(
                    color = TextMuted,
                    fontSize = 10.sp
                )
            )
        }
    }
}

@Composable
private fun ThreatItemCard(
    threat: ThreatItem,
    onMitigate: () -> Unit,
    onInspect: () -> Unit
) {
    val borderColor = when (threat.severity) {
        ThreatSeverity.CRITICAL -> CyberRed.copy(alpha = 0.4f)
        ThreatSeverity.HIGH -> CyberRed.copy(alpha = 0.3f)
        ThreatSeverity.MEDIUM -> CyberAmber.copy(alpha = 0.3f)
        else -> BorderCyber
    }

    GlassCard(
        modifier = Modifier
            .fillMaxWidth()
            .clickable { onInspect() },
        borderColor = borderColor
    ) {
        Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
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
                    SeverityBadge(severity = threat.severity)
                    Text(
                        text = threat.title,
                        style = MaterialTheme.typography.titleMedium.copy(
                            fontWeight = FontWeight.Bold,
                            color = TextPrimary
                        ),
                        maxLines = 1
                    )
                }
                Text(
                    text = threat.timestamp,
                    style = MaterialTheme.typography.bodySmall.copy(color = TextMuted, fontSize = 10.sp)
                )
            }

            Text(
                text = threat.description,
                style = MaterialTheme.typography.bodySmall.copy(color = TextSecondary),
                maxLines = 2
            )

            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = threat.affectedResource,
                    style = MaterialTheme.typography.bodySmall.copy(
                        color = CyberCyan,
                        fontSize = 11.sp,
                        fontWeight = FontWeight.Medium
                    ),
                    modifier = Modifier.weight(1f),
                    maxLines = 1
                )

                Row(horizontalArrangement = Arrangement.spacedBy(6.dp)) {
                    OutlinedButton(
                        onClick = onInspect,
                        shape = RoundedCornerShape(8.dp),
                        contentPadding = PaddingValues(horizontal = 10.dp, vertical = 4.dp),
                        colors = ButtonDefaults.outlinedButtonColors(contentColor = TextPrimary),
                        border = androidx.compose.foundation.BorderStroke(1.dp, BorderCyber)
                    ) {
                        Text(text = "Details", fontSize = 11.sp)
                    }

                    Button(
                        onClick = onMitigate,
                        shape = RoundedCornerShape(8.dp),
                        contentPadding = PaddingValues(horizontal = 10.dp, vertical = 4.dp),
                        colors = ButtonDefaults.buttonColors(
                            containerColor = CyberCyan,
                            contentColor = CyberBackground
                        )
                    ) {
                        Text(text = "Neutralize", fontWeight = FontWeight.Bold, fontSize = 11.sp)
                    }
                }
            }
        }
    }
}
