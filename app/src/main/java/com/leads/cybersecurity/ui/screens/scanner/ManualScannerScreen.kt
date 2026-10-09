package com.leads.cybersecurity.ui.screens.scanner

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.leads.cybersecurity.data.model.ScanStatus
import com.leads.cybersecurity.ui.components.CyberHeader
import com.leads.cybersecurity.ui.components.GlassCard
import com.leads.cybersecurity.ui.components.SectionHeader
import com.leads.cybersecurity.ui.components.ThreatRadarView
import com.leads.cybersecurity.ui.theme.*

@Composable
fun ManualScannerScreen(
    viewModel: ManualScannerViewModel,
    onViewInvestigation: () -> Unit
) {
    val scanState by viewModel.scanState.collectAsState()
    val targetInput by viewModel.inputTarget.collectAsState()
    val isScanning = scanState.status == ScanStatus.SCANNING
    val isCompleted = scanState.status == ScanStatus.COMPLETED

    Scaffold(
        containerColor = CyberBackground,
        topBar = {
            CyberHeader(
                title = "MANUAL SCANNER",
                subtitle = "On-Demand Diagnostic Probe"
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
            // Scanner Radar Visualizer & Trigger Card
            item {
                GlassCard(
                    borderColor = if (isScanning) CyberCyan.copy(alpha = 0.5f) else BorderCyber
                ) {
                    Column(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalAlignment = Alignment.CenterHorizontally
                    ) {
                        ThreatRadarView(
                            threatsCount = 1,
                            isScanning = isScanning,
                            size = 140.dp
                        )

                        Spacer(modifier = Modifier.height(14.dp))

                        Text(
                            text = if (isScanning) scanState.currentStage.title else if (isCompleted) "Probe Completed" else "System Diagnostic Ready",
                            style = MaterialTheme.typography.titleMedium.copy(
                                fontWeight = FontWeight.Bold,
                                color = TextPrimary
                            )
                        )

                        Text(
                            text = if (isScanning) scanState.currentStage.description else if (isCompleted) "ScamGraph correlated all discovered artifacts into Coordinated Banking Scam." else "Inspect individual URLs, APK packages, or perform comprehensive full-device heuristic scan.",
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
                                        text = "Scanning vectors...",
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
                            Row(
                                modifier = Modifier.fillMaxWidth(),
                                horizontalArrangement = Arrangement.spacedBy(8.dp)
                            ) {
                                Button(
                                    onClick = { viewModel.startScan("ALL") },
                                    colors = ButtonDefaults.buttonColors(
                                        containerColor = CyberCyan,
                                        contentColor = CyberBackground
                                    ),
                                    shape = RoundedCornerShape(10.dp),
                                    modifier = Modifier.weight(1f)
                                ) {
                                    Icon(imageVector = Icons.Default.PlayArrow, contentDescription = null, modifier = Modifier.size(16.dp))
                                    Spacer(modifier = Modifier.width(6.dp))
                                    Text(text = if (isCompleted) "Run Rescan" else "Run Deep Scan", fontWeight = FontWeight.Bold)
                                }

                                if (isCompleted) {
                                    Button(
                                        onClick = onViewInvestigation,
                                        colors = ButtonDefaults.buttonColors(
                                            containerColor = CyberPurple,
                                            contentColor = CyberBackground
                                        ),
                                        shape = RoundedCornerShape(10.dp),
                                        modifier = Modifier.weight(1f)
                                    ) {
                                        Text(text = "View ScamGraph", fontWeight = FontWeight.Bold)
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // Input Target Inspector (URL / Package / Hash)
            item {
                SectionHeader(title = "Inspect Specific Target")
                Spacer(modifier = Modifier.height(4.dp))
                GlassCard {
                    Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
                        OutlinedTextField(
                            value = targetInput,
                            onValueChange = { viewModel.updateTarget(it) },
                            modifier = Modifier.fillMaxWidth(),
                            placeholder = { Text(text = "Paste URL, phone number, or package name...", color = TextMuted) },
                            shape = RoundedCornerShape(10.dp),
                            colors = OutlinedTextFieldDefaults.colors(
                                focusedBorderColor = CyberCyan,
                                unfocusedBorderColor = BorderCyber,
                                focusedTextColor = TextPrimary,
                                unfocusedTextColor = TextPrimary
                            ),
                            singleLine = true
                        )

                        Button(
                            onClick = {
                                if (targetInput.isNotBlank()) {
                                    viewModel.startScan("TARGET")
                                }
                            },
                            enabled = targetInput.isNotBlank() && !isScanning,
                            colors = ButtonDefaults.buttonColors(
                                containerColor = CyberCyanDark,
                                contentColor = CyberCyan
                            ),
                            shape = RoundedCornerShape(8.dp),
                            modifier = Modifier.align(Alignment.End)
                        ) {
                            Text(text = "Inspect Target", fontWeight = FontWeight.Bold, fontSize = 12.sp)
                        }
                    }
                }
            }

            // Real-Time Log Messages Terminal
            if (scanState.logMessages.isNotEmpty()) {
                item {
                    Surface(
                        modifier = Modifier.fillMaxWidth(),
                        shape = RoundedCornerShape(12.dp),
                        color = androidx.compose.ui.graphics.Color(0xFF030712),
                        border = androidx.compose.foundation.BorderStroke(1.dp, CyberCyan.copy(alpha = 0.25f))
                    ) {
                        Column(modifier = Modifier.padding(12.dp)) {
                            Text(
                                text = "> LEADS DIAGNOSTIC LOG",
                                color = TextMuted,
                                fontFamily = FontFamily.Monospace,
                                fontSize = 10.sp,
                                fontWeight = FontWeight.Bold
                            )
                            Spacer(modifier = Modifier.height(4.dp))
                            scanState.logMessages.forEach { msg ->
                                Text(
                                    text = "> $msg",
                                    color = CyberCyan,
                                    fontFamily = FontFamily.Monospace,
                                    fontSize = 11.sp
                                )
                            }
                        }
                    }
                }
            }
        }
    }
}
