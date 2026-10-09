package com.leads.cybersecurity.ui.screens.investigate

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.leads.cybersecurity.data.model.CoordinatedIncident
import com.leads.cybersecurity.ui.components.*
import com.leads.cybersecurity.ui.theme.*

@Composable
fun AiInvestigationView(
    incident: CoordinatedIncident,
    onNavigateToActions: () -> Unit
) {
    LazyColumn(
        modifier = Modifier.fillMaxSize(),
        contentPadding = PaddingValues(16.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        // Hero Score Card
        item {
            RiskScoreCard(
                riskScore = incident.overallRiskScore,
                severity = incident.severity,
                title = "AI INVESTIGATION COMPLETE",
                subtitle = "Multimodal Correlation Engine v2.4"
            )
        }

        // Section 1: Completed Investigation Stages
        item {
            SectionHeader(title = "Autonomous Investigation Pipeline", trailingText = "7/7 Verified")
            Spacer(modifier = Modifier.height(4.dp))
            GlassCard {
                Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                    incident.investigationStages.forEach { stage ->
                        InvestigationStepView(stage = stage)
                    }
                }
            }
        }

        // Section 2: AI Security Summary
        item {
            SectionHeader(title = "AI Security Summary")
            Spacer(modifier = Modifier.height(4.dp))
            GlassCard(
                borderColor = CyberCyan.copy(alpha = 0.4f)
            ) {
                Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        Icon(
                            imageVector = Icons.Default.SmartToy,
                            contentDescription = null,
                            tint = CyberCyan,
                            modifier = Modifier.size(20.dp)
                        )
                        Text(
                            text = "LEADS Synthesis Report",
                            style = MaterialTheme.typography.titleSmall.copy(
                                fontWeight = FontWeight.Bold,
                                color = TextPrimary
                            )
                        )
                    }

                    Text(
                        text = incident.aiSecuritySummary,
                        style = MaterialTheme.typography.bodyMedium.copy(
                            color = TextPrimary,
                            lineHeight = 20.sp
                        )
                    )
                }
            }
        }

        // Section 3: Threat Intelligence Telemetry
        item {
            SectionHeader(title = "Threat Intelligence Telemetry", trailingText = "Bulletproof Hosting")
            Spacer(modifier = Modifier.height(4.dp))
            GlassCard {
                Column(verticalArrangement = Arrangement.spacedBy(6.dp)) {
                    TelemetryRow("Target Asset", "Wells Fargo Financial Accounts")
                    TelemetryRow("Primary Threat Vector", "Phishing SMS + Android Banking Trojan (Alien/Cerberus)")
                    TelemetryRow("Domain Infrastructure", "wellsfarg0-secure.xyz (IP: 185.220.101.42)")
                    TelemetryRow("Host Location", "Amsterdam, Netherlands (Autonomous System AS206804)")
                    TelemetryRow("Payload Package", "com.bank.auth.helper (wf-verify-auth.apk)")
                    TelemetryRow("Social Engineering Vector", "Voice call spoofing official 1-800 support")
                }
            }
        }

        // Section 4: Forensic Evidence
        item {
            SectionHeader(title = "Forensic Evidence Cards", trailingText = "${incident.evidenceList.size} Indicators")
            Spacer(modifier = Modifier.height(4.dp))
            Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
                incident.evidenceList.forEach { ev ->
                    EvidenceCard(evidence = ev)
                }
            }
        }

        // Section 5: Bottom Protective Call to Action
        item {
            Button(
                onClick = onNavigateToActions,
                colors = ButtonDefaults.buttonColors(
                    containerColor = CyberCyan,
                    contentColor = CyberBackground
                ),
                shape = RoundedCornerShape(12.dp),
                modifier = Modifier.fillMaxWidth()
            ) {
                Icon(imageVector = Icons.Default.Shield, contentDescription = null, modifier = Modifier.size(18.dp))
                Spacer(modifier = Modifier.width(8.dp))
                Text(text = "View Protection Recommendations", fontWeight = FontWeight.Bold)
            }
        }
    }
}

@Composable
private fun TelemetryRow(label: String, value: String) {
    Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.Top
    ) {
        Text(
            text = label,
            style = MaterialTheme.typography.labelSmall.copy(color = TextMuted, fontSize = 11.sp),
            modifier = Modifier.weight(0.4f)
        )
        Text(
            text = value,
            style = MaterialTheme.typography.bodySmall.copy(color = TextPrimary, fontSize = 11.sp),
            modifier = Modifier.weight(0.6f)
        )
    }
}
