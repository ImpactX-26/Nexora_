package com.leads.cybersecurity.ui.screens.investigate

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Warning
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.leads.cybersecurity.data.model.CoordinatedIncident
import com.leads.cybersecurity.data.model.RiskFactor
import com.leads.cybersecurity.data.model.ThreatSeverityLevel
import com.leads.cybersecurity.ui.components.GlassCard
import com.leads.cybersecurity.ui.components.RiskScoreCard
import com.leads.cybersecurity.ui.components.SectionHeader
import com.leads.cybersecurity.ui.components.SeverityBadge
import com.leads.cybersecurity.ui.theme.*

@Composable
fun RiskAssessmentView(
    incident: CoordinatedIncident,
    onNavigateToActions: () -> Unit
) {
    LazyColumn(
        modifier = Modifier.fillMaxSize(),
        contentPadding = PaddingValues(16.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        // Overall Risk Score Hero
        item {
            RiskScoreCard(
                riskScore = incident.overallRiskScore,
                severity = incident.severity,
                title = "COMPREHENSIVE RISK ASSESSMENT",
                subtitle = "Algorithmic multi-vector risk synthesis"
            )
        }

        // Summary Callout
        item {
            GlassCard(
                borderColor = SeverityCritical.copy(alpha = 0.4f)
            ) {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(10.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Icon(
                        imageVector = Icons.Default.Warning,
                        contentDescription = null,
                        tint = SeverityCritical,
                        modifier = Modifier.size(24.dp)
                    )
                    Text(
                        text = "Multiple independent indicators are connected to the same attack campaign.",
                        style = MaterialTheme.typography.bodyMedium.copy(
                            color = TextPrimary,
                            fontWeight = FontWeight.SemiBold,
                            lineHeight = 20.sp
                        )
                    )
                }
            }
        }

        // Section: Risk Breakdown by Category
        item {
            SectionHeader(title = "Risk Points Attribution Breakdown", trailingText = "Score: ${incident.overallRiskScore} / 100")
            Spacer(modifier = Modifier.height(4.dp))
            Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
                incident.riskFactors.forEach { factor ->
                    RiskFactorCard(factor = factor)
                }
            }
        }

        // Action Button
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
                Text(text = "Review Protection Actions", fontWeight = FontWeight.Bold)
            }
        }
    }
}

@Composable
private fun RiskFactorCard(factor: RiskFactor) {
    val factorColor = when (factor.severity) {
        ThreatSeverityLevel.CRITICAL -> SeverityCritical
        ThreatSeverityLevel.HIGH -> SeverityHigh
        ThreatSeverityLevel.SUSPICIOUS -> SeveritySuspicious
        ThreatSeverityLevel.SAFE -> SeveritySafe
    }

    GlassCard(
        borderColor = factorColor.copy(alpha = 0.35f),
        modifier = Modifier.fillMaxWidth()
    ) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Column(
                modifier = Modifier.weight(1f),
                verticalArrangement = Arrangement.spacedBy(4.dp)
            ) {
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    Text(
                        text = factor.name,
                        style = MaterialTheme.typography.titleSmall.copy(
                            fontWeight = FontWeight.Bold,
                            color = TextPrimary
                        )
                    )
                    SeverityBadge(severity = factor.severity)
                }

                Text(
                    text = factor.rationale,
                    style = MaterialTheme.typography.bodySmall.copy(
                        color = TextSecondary,
                        fontSize = 11.sp
                    )
                )
            }

            Surface(
                shape = RoundedCornerShape(8.dp),
                color = factorColor.copy(alpha = 0.15f),
                border = androidx.compose.foundation.BorderStroke(1.dp, factorColor.copy(alpha = 0.4f)),
                modifier = Modifier.padding(start = 8.dp)
            ) {
                Text(
                    text = "+${factor.points}",
                    color = factorColor,
                    style = MaterialTheme.typography.titleMedium.copy(
                        fontWeight = FontWeight.Black,
                        fontSize = 16.sp
                    ),
                    modifier = Modifier.padding(horizontal = 10.dp, vertical = 6.dp)
                )
            }
        }
    }
}
