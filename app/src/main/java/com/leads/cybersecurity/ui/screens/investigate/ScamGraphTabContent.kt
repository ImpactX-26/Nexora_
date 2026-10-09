package com.leads.cybersecurity.ui.screens.investigate

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.leads.cybersecurity.data.model.CoordinatedIncident
import com.leads.cybersecurity.ui.components.GlassCard
import com.leads.cybersecurity.ui.components.ScamGraphView
import com.leads.cybersecurity.ui.components.SectionHeader
import com.leads.cybersecurity.ui.theme.BorderCyber
import com.leads.cybersecurity.ui.theme.CyberCyan
import com.leads.cybersecurity.ui.theme.TextPrimary
import com.leads.cybersecurity.ui.theme.TextSecondary

@Composable
fun ScamGraphTabContent(
    incident: CoordinatedIncident
) {
    LazyColumn(
        modifier = Modifier.fillMaxSize(),
        contentPadding = PaddingValues(16.dp),
        verticalArrangement = Arrangement.spacedBy(14.dp)
    ) {
        item {
            GlassCard(borderColor = CyberCyan.copy(alpha = 0.35f)) {
                Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
                    Text(
                        text = "ScamGraph",
                        style = MaterialTheme.typography.titleMedium.copy(
                            fontWeight = FontWeight.Bold,
                            color = TextPrimary
                        )
                    )
                    Text(
                        text = "Connected threat intelligence",
                        style = MaterialTheme.typography.titleSmall.copy(
                            color = CyberCyan,
                            fontWeight = FontWeight.SemiBold,
                            fontSize = 12.sp
                        )
                    )
                    Spacer(modifier = Modifier.height(2.dp))
                    Text(
                        text = "ScamGraph correlates 6 disparate entities across telecom, domain registry, malware hash feeds, and voice signals to reveal the full attack topography.",
                        style = MaterialTheme.typography.bodySmall.copy(
                            color = TextSecondary,
                            fontSize = 11.sp,
                            lineHeight = 16.sp
                        )
                    )
                }
            }
        }

        item {
            SectionHeader(title = "Interactive Threat Topography", trailingText = "${incident.nodes.size} Nodes • ${incident.edges.size} Links")
            Spacer(modifier = Modifier.height(4.dp))
            ScamGraphView(
                nodes = incident.nodes,
                edges = incident.edges
            )
        }
    }
}
