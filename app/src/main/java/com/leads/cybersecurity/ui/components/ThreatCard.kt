package com.leads.cybersecurity.ui.components

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowForward
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.leads.cybersecurity.data.model.CoordinatedIncident
import com.leads.cybersecurity.data.model.ThreatSeverityLevel
import com.leads.cybersecurity.ui.theme.*

@Composable
fun ThreatCard(
    incident: CoordinatedIncident,
    onClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    val borderColor = when (incident.severity) {
        ThreatSeverityLevel.CRITICAL -> SeverityCritical.copy(alpha = 0.45f)
        ThreatSeverityLevel.HIGH -> SeverityHigh.copy(alpha = 0.40f)
        ThreatSeverityLevel.SUSPICIOUS -> SeveritySuspicious.copy(alpha = 0.35f)
        ThreatSeverityLevel.SAFE -> BorderCyber
    }

    GlassCard(
        modifier = modifier
            .fillMaxWidth()
            .clickable { onClick() },
        borderColor = borderColor
    ) {
        Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
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
                    SeverityBadge(severity = incident.severity)
                    Text(
                        text = incident.title,
                        style = MaterialTheme.typography.titleMedium.copy(
                            fontWeight = FontWeight.Bold,
                            color = TextPrimary
                        ),
                        maxLines = 1
                    )
                }

                Text(
                    text = "Risk: ${incident.overallRiskScore}/100",
                    style = MaterialTheme.typography.labelMedium.copy(
                        fontWeight = FontWeight.Bold,
                        color = when (incident.severity) {
                            ThreatSeverityLevel.CRITICAL -> SeverityCritical
                            ThreatSeverityLevel.HIGH -> SeverityHigh
                            ThreatSeverityLevel.SUSPICIOUS -> SeveritySuspicious
                            ThreatSeverityLevel.SAFE -> SeveritySafe
                        }
                    )
                )
            }

            Text(
                text = incident.descriptionOrSummary(),
                style = MaterialTheme.typography.bodySmall.copy(
                    color = TextSecondary,
                    lineHeight = 18.sp
                ),
                maxLines = 2
            )

            HorizontalDivider(color = BorderCyber.copy(alpha = 0.4f))

            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = "${incident.detectedTimestamp} • Target: ${incident.targetBrand}",
                    style = MaterialTheme.typography.bodySmall.copy(
                        color = TextMuted,
                        fontSize = 11.sp
                    )
                )

                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(4.dp)
                ) {
                    Text(
                        text = "Inspect Attack Chain",
                        style = MaterialTheme.typography.labelSmall.copy(
                            color = CyberCyan,
                            fontWeight = FontWeight.Bold
                        )
                    )
                    Icon(
                        imageVector = Icons.AutoMirrored.Filled.ArrowForward,
                        contentDescription = null,
                        tint = CyberCyan,
                        modifier = Modifier.size(14.dp)
                    )
                }
            }
        }
    }
}

private fun CoordinatedIncident.descriptionOrSummary(): String {
    return if (summary.isNotBlank()) summary else subtitle
}
