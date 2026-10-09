package com.leads.cybersecurity.ui.screens.scanner

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.core.*
import androidx.compose.foundation.background
import androidx.compose.foundation.border
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
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.leads.cybersecurity.data.model.ScanStatus
import com.leads.cybersecurity.data.model.ThreatItem
import com.leads.cybersecurity.data.model.ThreatSeverity
import com.leads.cybersecurity.ui.components.*
import com.leads.cybersecurity.ui.theme.*

@Composable
fun ScannerScreen(
    viewModel: ScannerViewModel
) {
    val scanState by viewModel.scanState.collectAsState()
    val isScanning = scanState.status == ScanStatus.SCANNING
    val isCompleted = scanState.status == ScanStatus.COMPLETED

    Scaffold(
        containerColor = CyberBackground,
        topBar = {
            CyberHeader(
                title = "AI THREAT SCANNER",
                subtitle = "Deep Neural Diagnostic Engine"
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
            // Visualizer & Control Card
            item {
                GlassCard(
                    borderColor = if (isScanning) CyberCyan.copy(alpha = 0.5f) else BorderCyber
                ) {
                    Column(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalAlignment = Alignment.CenterHorizontally
                    ) {
                        ThreatRadarView(
                            threatsCount = scanState.threatsDiscovered.size,
                            isScanning = isScanning,
                            size = 160.dp
                        )

                        Spacer(modifier = Modifier.height(16.dp))

                        Text(
                            text = if (isScanning) scanState.currentStage.title else if (isCompleted) "Scan Completed" else "Diagnostic Ready",
                            style = MaterialTheme.typography.titleMedium.copy(
                                fontWeight = FontWeight.Bold,
                                color = TextPrimary
                            )
                        )

                        Text(
                            text = if (isScanning) scanState.currentStage.description else if (isCompleted) "${scanState.threatsDiscovered.size} vulnerabilities discovered across 184 system vectors." else "Ready to analyze system integrity, SMS payloads & Wi-Fi posture.",
                            style = MaterialTheme.typography.bodySmall.copy(
                                color = TextSecondary
                            ),
                            modifier = Modifier.padding(horizontal = 16.dp),
                            textAlign = androidx.compose.ui.text.style.TextAlign.Center
                        )

                        Spacer(modifier = Modifier.height(16.dp))

                        if (isScanning) {
                            Column(
                                modifier = Modifier.fillMaxWidth(),
                                verticalArrangement = Arrangement.spacedBy(6.dp)
                            ) {
                                Row(
                                    modifier = Modifier.fillMaxWidth(),
                                    horizontalArrangement = Arrangement.SpaceBetween
                                ) {
                                    Text(
                                        text = "Scanning ${scanState.itemsScannedCount} items...",
                                        style = MaterialTheme.typography.bodySmall.copy(color = TextMuted, fontSize = 11.sp)
                                    )
                                    Text(
                                        text = "${(scanState.progress * 100).toInt()}%",
                                        style = MaterialTheme.typography.labelSmall.copy(color = CyberCyan, fontWeight = FontWeight.Bold)
                                    )
                                }
                                LinearProgressIndicator(
                                    progress = { scanState.progress },
                                    modifier = Modifier
                                        .fillMaxWidth()
                                        .height(6.dp)
                                        .clip(RoundedCornerShape(3.dp)),
                                    color = CyberCyan,
                                    trackColor = CyberSurfaceVariant
                                )
                            }
                        } else {
                            Button(
                                onClick = { viewModel.startDeepScan() },
                                colors = ButtonDefaults.buttonColors(
                                    containerColor = CyberCyan,
                                    contentColor = CyberBackground
                                ),
                                shape = RoundedCornerShape(12.dp),
                                modifier = Modifier.fillMaxWidth(0.75f)
                            ) {
                                Icon(imageVector = Icons.Default.PlayArrow, contentDescription = null)
                                Spacer(modifier = Modifier.width(8.dp))
                                Text(
                                    text = if (isCompleted) "Run Full Rescan" else "Start Deep AI Scan",
                                    fontWeight = FontWeight.Bold
                                )
                            }
                        }
                    }
                }
            }

            // Real-Time Diagnostic Terminal Log
            if (scanState.logMessages.isNotEmpty()) {
                item {
                    Surface(
                        modifier = Modifier.fillMaxWidth(),
                        shape = RoundedCornerShape(12.dp),
                        color = Color(0xFF030712),
                        border = androidx.compose.foundation.BorderStroke(1.dp, CyberCyan.copy(alpha = 0.25f))
                    ) {
                        Column(modifier = Modifier.padding(12.dp)) {
                            Row(
                                verticalAlignment = Alignment.CenterVertically,
                                horizontalArrangement = Arrangement.spacedBy(6.dp)
                            ) {
                                Box(
                                    modifier = Modifier
                                        .size(8.dp)
                                        .clip(CircleShape)
                                        .background(if (isScanning) CyberCyan else CyberGreen)
                                )
                                Text(
                                    text = "LEADS TELEMETRY TERMINAL",
                                    style = MaterialTheme.typography.labelSmall.copy(
                                        color = TextMuted,
                                        fontSize = 10.sp,
                                        fontWeight = FontWeight.Bold,
                                        fontFamily = FontFamily.Monospace
                                    )
                                )
                            }
                            Spacer(modifier = Modifier.height(6.dp))
                            scanState.logMessages.forEach { msg ->
                                Text(
                                    text = "> $msg",
                                    style = MaterialTheme.typography.bodySmall.copy(
                                        color = CyberCyan,
                                        fontFamily = FontFamily.Monospace,
                                        fontSize = 11.sp
                                    )
                                )
                            }
                        }
                    }
                }
            }

            // Discovered Threats Section
            item {
                Text(
                    text = "DISCOVERED THREATS & FINDINGS (${scanState.threatsDiscovered.size})",
                    style = MaterialTheme.typography.labelLarge.copy(
                        color = TextMuted,
                        letterSpacing = 1.sp,
                        fontWeight = FontWeight.Bold
                    )
                )
            }

            if (scanState.threatsDiscovered.isEmpty()) {
                item {
                    GlassCard(borderColor = CyberGreen.copy(alpha = 0.25f)) {
                        Row(
                            verticalAlignment = Alignment.CenterVertically,
                            horizontalArrangement = Arrangement.spacedBy(12.dp)
                        ) {
                            Icon(
                                imageVector = Icons.Default.Shield,
                                contentDescription = null,
                                tint = CyberGreen,
                                modifier = Modifier.size(28.dp)
                            )
                            Text(
                                text = "Zero vulnerabilities flagged in active buffer.",
                                style = MaterialTheme.typography.bodyMedium.copy(color = TextSecondary)
                            )
                        }
                    }
                }
            } else {
                items(scanState.threatsDiscovered, key = { it.id }) { threat ->
                    ScannerThreatCard(
                        threat = threat,
                        onNeutralize = { viewModel.mitigateThreat(threat.id) }
                    )
                }
            }
        }
    }
}

@Composable
private fun ScannerThreatCard(
    threat: ThreatItem,
    onNeutralize: () -> Unit
) {
    GlassCard(
        borderColor = if (threat.severity == ThreatSeverity.CRITICAL) CyberRed.copy(alpha = 0.4f) else CyberAmber.copy(alpha = 0.4f)
    ) {
        Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    SeverityBadge(severity = threat.severity)
                    Text(
                        text = threat.category.displayName,
                        style = MaterialTheme.typography.labelSmall.copy(color = TextMuted)
                    )
                }
                Text(
                    text = threat.affectedResource,
                    style = MaterialTheme.typography.bodySmall.copy(color = CyberCyan, fontSize = 11.sp),
                    maxLines = 1
                )
            }

            Text(
                text = threat.title,
                style = MaterialTheme.typography.titleMedium.copy(
                    fontWeight = FontWeight.Bold,
                    color = TextPrimary
                )
            )

            Text(
                text = threat.description,
                style = MaterialTheme.typography.bodySmall.copy(color = TextSecondary)
            )

            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.End
            ) {
                Button(
                    onClick = onNeutralize,
                    colors = ButtonDefaults.buttonColors(
                        containerColor = CyberCyan,
                        contentColor = CyberBackground
                    ),
                    shape = RoundedCornerShape(8.dp),
                    contentPadding = PaddingValues(horizontal = 12.dp, vertical = 6.dp)
                ) {
                    Icon(imageVector = Icons.Default.Check, contentDescription = null, modifier = Modifier.size(14.dp))
                    Spacer(modifier = Modifier.width(6.dp))
                    Text(text = "Neutralize Vector", fontSize = 11.sp, fontWeight = FontWeight.Bold)
                }
            }
        }
    }
}
