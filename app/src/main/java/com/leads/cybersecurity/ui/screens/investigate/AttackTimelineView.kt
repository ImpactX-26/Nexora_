package com.leads.cybersecurity.ui.screens.investigate

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.leads.cybersecurity.data.model.CoordinatedIncident
import com.leads.cybersecurity.ui.components.GlassCard
import com.leads.cybersecurity.ui.components.SectionHeader
import com.leads.cybersecurity.ui.components.TimelineItemView
import com.leads.cybersecurity.ui.theme.BorderCyber
import com.leads.cybersecurity.ui.theme.TextSecondary

@Composable
fun AttackTimelineView(
    incident: CoordinatedIncident
) {
    LazyColumn(
        modifier = Modifier.fillMaxSize(),
        contentPadding = PaddingValues(16.dp),
        verticalArrangement = Arrangement.spacedBy(14.dp)
    ) {
        item {
            GlassCard(borderColor = BorderCyber.copy(alpha = 0.5f)) {
                Column(verticalArrangement = Arrangement.spacedBy(6.dp)) {
                    Text(
                        text = "Attack Progression Timeline",
                        style = MaterialTheme.typography.titleMedium.copy(
                            color = com.leads.cybersecurity.ui.theme.TextPrimary,
                            fontWeight = androidx.compose.ui.text.font.FontWeight.Bold
                        )
                    )
                    Text(
                        text = "Visualizing how separate isolated events from 10:42 AM to 10:55 AM became one unified attack campaign.",
                        style = MaterialTheme.typography.bodySmall.copy(color = TextSecondary)
                    )
                }
            }
        }

        item {
            SectionHeader(title = "Chronological Attack Sequence", trailingText = "${incident.timeline.size} Events")
        }

        itemsIndexed(incident.timeline, key = { _, item -> item.id }) { index, event ->
            TimelineItemView(
                event = event,
                isLast = index == incident.timeline.size - 1
            )
        }
    }
}
