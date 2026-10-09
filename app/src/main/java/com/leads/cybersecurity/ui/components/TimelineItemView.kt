package com.leads.cybersecurity.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.leads.cybersecurity.data.model.NodeType
import com.leads.cybersecurity.data.model.ThreatSeverityLevel
import com.leads.cybersecurity.data.model.TimelineEvent
import com.leads.cybersecurity.ui.theme.*

@Composable
fun TimelineItemView(
    event: TimelineEvent,
    isLast: Boolean = false,
    modifier: Modifier = Modifier
) {
    val nodeColor = when (event.severity) {
        ThreatSeverityLevel.CRITICAL -> SeverityCritical
        ThreatSeverityLevel.HIGH -> SeverityHigh
        ThreatSeverityLevel.SUSPICIOUS -> SeveritySuspicious
        ThreatSeverityLevel.SAFE -> SeveritySafe
    }

    val icon: ImageVector = when (event.category) {
        NodeType.SMS -> Icons.Default.ChatBubbleOutline
        NodeType.URL -> Icons.Default.Link
        NodeType.DOMAIN -> Icons.Default.Language
        NodeType.APK_DOWNLOAD -> Icons.Default.Download
        NodeType.APPLICATION -> Icons.Default.Apps
        NodeType.CALL_SIGNAL -> Icons.Default.PhoneCallback
        NodeType.INCIDENT -> Icons.Default.Hub
        else -> Icons.Default.Shield
    }

    Row(
        modifier = modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.spacedBy(14.dp),
        verticalAlignment = Alignment.Top
    ) {
        // Left Column: Node Dot + Connecting Line
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            modifier = Modifier.width(32.dp)
        ) {
            Box(
                modifier = Modifier
                    .size(32.dp)
                    .clip(CircleShape)
                    .background(
                        if (event.isCorrelatedByLeads) CyberCyanDark else nodeColor.copy(alpha = 0.15f)
                    )
                    .border(
                        1.5.dp,
                        if (event.isCorrelatedByLeads) CyberCyan else nodeColor,
                        CircleShape
                    ),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    imageVector = icon,
                    contentDescription = null,
                    tint = if (event.isCorrelatedByLeads) CyberCyan else nodeColor,
                    modifier = Modifier.size(16.dp)
                )
            }

            if (!isLast) {
                Box(
                    modifier = Modifier
                        .width(2.dp)
                        .height(100.dp)
                        .background(
                            Brush.verticalGradient(
                                listOf(
                                    if (event.isCorrelatedByLeads) CyberCyan else nodeColor.copy(alpha = 0.6f),
                                    BorderCyber
                                )
                            )
                        )
                )
            }
        }

        // Right Column: Event Content Card
        GlassCard(
            modifier = Modifier
                .weight(1f)
                .padding(bottom = if (isLast) 0.dp else 16.dp),
            borderColor = if (event.isCorrelatedByLeads) CyberCyan.copy(alpha = 0.5f) else BorderCyber.copy(alpha = 0.6f)
        ) {
            Column(verticalArrangement = Arrangement.spacedBy(6.dp)) {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(
                        text = event.time,
                        style = MaterialTheme.typography.labelSmall.copy(
                            color = if (event.isCorrelatedByLeads) CyberCyan else TextMuted,
                            fontWeight = FontWeight.Bold,
                            fontFamily = FontFamily.Monospace,
                            fontSize = 11.sp
                        )
                    )

                    if (event.isCorrelatedByLeads) {
                        Surface(
                            shape = RoundedCornerShape(4.dp),
                            color = CyberCyanDark
                        ) {
                            Text(
                                text = "LEADS CORRELATION",
                                color = CyberCyan,
                                fontSize = 9.sp,
                                fontWeight = FontWeight.Bold,
                                modifier = Modifier.padding(horizontal = 6.dp, vertical = 2.dp)
                            )
                        }
                    } else {
                        SeverityBadge(severity = event.severity)
                    }
                }

                Text(
                    text = event.title,
                    style = MaterialTheme.typography.titleSmall.copy(
                        fontWeight = FontWeight.Bold,
                        color = TextPrimary
                    )
                )

                Text(
                    text = event.description,
                    style = MaterialTheme.typography.bodySmall.copy(
                        color = TextSecondary,
                        fontSize = 12.sp,
                        lineHeight = 17.sp
                    )
                )

                Surface(
                    shape = RoundedCornerShape(6.dp),
                    color = CyberSurfaceVariant.copy(alpha = 0.7f),
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Text(
                        text = event.indicatorText,
                        style = MaterialTheme.typography.bodySmall.copy(
                            color = TextMuted,
                            fontSize = 10.sp,
                            fontFamily = FontFamily.Monospace
                        ),
                        modifier = Modifier.padding(8.dp)
                    )
                }
            }
        }
    }
}
