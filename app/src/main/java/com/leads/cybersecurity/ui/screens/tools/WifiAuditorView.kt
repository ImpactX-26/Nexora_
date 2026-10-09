package com.leads.cybersecurity.ui.screens.tools

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.leads.cybersecurity.data.model.ThreatSeverity
import com.leads.cybersecurity.data.model.WifiAuditResult
import com.leads.cybersecurity.ui.components.GlassCard
import com.leads.cybersecurity.ui.components.SeverityBadge
import com.leads.cybersecurity.ui.theme.*

@Composable
fun WifiAuditorView(
    viewModel: ToolsViewModel
) {
    val audit by viewModel.wifiAudit.collectAsState()
    val isAuditing by viewModel.isAuditingWifi.collectAsState()

    LazyColumn(
        modifier = Modifier.fillMaxSize(),
        contentPadding = PaddingValues(16.dp),
        verticalArrangement = Arrangement.spacedBy(14.dp)
    ) {
        item {
            GlassCard(
                borderColor = if (audit.overallSafety == ThreatSeverity.HIGH || audit.overallSafety == ThreatSeverity.CRITICAL)
                    CyberRed.copy(alpha = 0.4f)
                else
                    CyberGreen.copy(alpha = 0.4f)
            ) {
                Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Row(
                            verticalAlignment = Alignment.CenterVertically,
                            horizontalArrangement = Arrangement.spacedBy(8.dp)
                        ) {
                            Icon(
                                imageVector = Icons.Default.Wifi,
                                contentDescription = null,
                                tint = CyberCyan,
                                modifier = Modifier.size(24.dp)
                            )
                            Column {
                                Text(
                                    text = audit.ssid,
                                    style = MaterialTheme.typography.titleMedium.copy(
                                        fontWeight = FontWeight.Bold,
                                        color = TextPrimary
                                    )
                                )
                                Text(
                                    text = "Encryption: ${audit.securityProtocol}",
                                    style = MaterialTheme.typography.bodySmall.copy(
                                        color = TextMuted,
                                        fontSize = 11.sp
                                    )
                                )
                            }
                        }

                        SeverityBadge(severity = audit.overallSafety)
                    }

                    HorizontalDivider(color = BorderCyber.copy(alpha = 0.5f))

                    // Integrity check rows
                    NetworkCheckItem(
                        title = "DNS Encryption & Hijacking Check",
                        isPassed = !audit.isDnsTamperingDetected,
                        statusText = if (audit.isDnsTamperingDetected) "Tampering Detected" else "Verified Secure (DoH Active)"
                    )
                    NetworkCheckItem(
                        title = "ARP Spoofing & MITM Watch",
                        isPassed = !audit.isArpPoisoningDetected,
                        statusText = if (audit.isArpPoisoningDetected) "Broadcast Anomaly (High Risk)" else "No MITM Probes"
                    )
                    NetworkCheckItem(
                        title = "Captive Portal Trap Check",
                        isPassed = !audit.isCaptivePortalDeception,
                        statusText = if (audit.isCaptivePortalDeception) "Deceptive Portal" else "Standard Gateway"
                    )

                    Surface(
                        modifier = Modifier.fillMaxWidth(),
                        shape = RoundedCornerShape(8.dp),
                        color = CyberSurfaceVariant.copy(alpha = 0.8f),
                        border = androidx.compose.foundation.BorderStroke(1.dp, BorderCyber)
                    ) {
                        Column(
                            modifier = Modifier.padding(10.dp),
                            verticalArrangement = Arrangement.spacedBy(4.dp)
                        ) {
                            Text(
                                text = "Gateway: ${audit.gatewayIp} • DNS: ${audit.dnsServer}",
                                style = MaterialTheme.typography.labelSmall.copy(color = TextMuted)
                            )
                            Text(
                                text = "AI Network Diagnosis: ${audit.aiNetworkAnalysis}",
                                style = MaterialTheme.typography.bodySmall.copy(color = TextPrimary, lineHeight = 16.sp)
                            )
                        }
                    }

                    Button(
                        onClick = { viewModel.refreshWifiAudit() },
                        colors = ButtonDefaults.buttonColors(
                            containerColor = CyberCyan,
                            contentColor = CyberBackground
                        ),
                        shape = RoundedCornerShape(10.dp),
                        modifier = Modifier.fillMaxWidth()
                    ) {
                        if (isAuditing) {
                            CircularProgressIndicator(modifier = Modifier.size(16.dp), color = CyberBackground, strokeWidth = 2.dp)
                            Spacer(modifier = Modifier.width(8.dp))
                            Text(text = "Auditing Packets...", fontWeight = FontWeight.Bold)
                        } else {
                            Icon(imageVector = Icons.Default.Refresh, contentDescription = null, modifier = Modifier.size(16.dp))
                            Spacer(modifier = Modifier.width(8.dp))
                            Text(text = "Re-Audit Wi-Fi Perimeter", fontWeight = FontWeight.Bold)
                        }
                    }
                }
            }
        }
    }
}

@Composable
private fun NetworkCheckItem(title: String, isPassed: Boolean, statusText: String) {
    Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically
    ) {
        Row(
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(6.dp)
        ) {
            Icon(
                imageVector = if (isPassed) Icons.Default.CheckCircle else Icons.Default.Cancel,
                contentDescription = null,
                tint = if (isPassed) CyberGreen else CyberRed,
                modifier = Modifier.size(16.dp)
            )
            Text(
                text = title,
                style = MaterialTheme.typography.bodySmall.copy(color = TextPrimary, fontSize = 12.sp)
            )
        }

        Text(
            text = statusText,
            style = MaterialTheme.typography.labelSmall.copy(
                color = if (isPassed) CyberGreen else CyberRed,
                fontWeight = FontWeight.SemiBold,
                fontSize = 11.sp
            )
        )
    }
}
