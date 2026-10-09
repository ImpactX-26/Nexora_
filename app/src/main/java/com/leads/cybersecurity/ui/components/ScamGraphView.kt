package com.leads.cybersecurity.ui.components

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.core.*
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Info
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.drawscope.DrawScope
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.text.*
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.leads.cybersecurity.data.model.GraphEdge
import com.leads.cybersecurity.data.model.GraphNode
import com.leads.cybersecurity.data.model.ThreatSeverityLevel
import com.leads.cybersecurity.ui.theme.*
import kotlin.math.atan2
import kotlin.math.cos
import kotlin.math.sin
import kotlin.math.sqrt

@Composable
fun ScamGraphView(
    nodes: List<GraphNode>,
    edges: List<GraphEdge>,
    modifier: Modifier = Modifier
) {
    var selectedNodeId by remember { mutableStateOf<String?>("node_url") }
    val textMeasurer = rememberTextMeasurer()

    val selectedNode = nodes.find { it.id == selectedNodeId }
    val connectedNodeIds = remember(selectedNodeId) {
        if (selectedNodeId == null) emptySet()
        else {
            val from = edges.filter { it.fromNodeId == selectedNodeId }.map { it.toNodeId }
            val to = edges.filter { it.toNodeId == selectedNodeId }.map { it.fromNodeId }
            (from + to + selectedNodeId!!).toSet()
        }
    }

    val infiniteTransition = rememberInfiniteTransition(label = "GraphPulse")
    val pulseScale by infiniteTransition.animateFloat(
        initialValue = 1f,
        targetValue = 1.15f,
        animationSpec = infiniteRepeatable(
            animation = tween(1200, easing = FastOutSlowInEasing),
            repeatMode = RepeatMode.Reverse
        ),
        label = "PulseScale"
    )

    Column(
        modifier = modifier.fillMaxWidth(),
        verticalArrangement = Arrangement.spacedBy(10.dp)
    ) {
        // Graph Canvas Container
        Surface(
            modifier = Modifier
                .fillMaxWidth()
                .height(340.dp),
            shape = RoundedCornerShape(16.dp),
            color = CyberSurface.copy(alpha = 0.9f),
            border = androidx.compose.foundation.BorderStroke(1.dp, BorderCyber.copy(alpha = 0.6f))
        ) {
            Box(modifier = Modifier.fillMaxSize()) {
                Canvas(
                    modifier = Modifier
                        .fillMaxSize()
                        .pointerInput(nodes) {
                            detectTapGestures { tapOffset ->
                                val width = size.width
                                val height = size.height
                                var tappedNode: GraphNode? = null
                                for (node in nodes) {
                                    val nx = node.xRatio * width
                                    val ny = node.yRatio * height
                                    val dx = tapOffset.x - nx
                                    val dy = tapOffset.y - ny
                                    if (sqrt((dx * dx + dy * dy).toDouble()) <= 28.dp.toPx()) {
                                        tappedNode = node
                                        break
                                    }
                                }
                                selectedNodeId = if (tappedNode != null) {
                                    if (selectedNodeId == tappedNode.id) null else tappedNode.id
                                } else null
                            }
                        }
                ) {
                    val w = size.width
                    val h = size.height

                    // 1. Draw subtle background cyber grid dots
                    val step = 28.dp.toPx()
                    var gx = 14.dp.toPx()
                    while (gx < w) {
                        var gy = 14.dp.toPx()
                        while (gy < h) {
                            drawCircle(
                                color = BorderCyber.copy(alpha = 0.25f),
                                radius = 1.dp.toPx(),
                                center = Offset(gx, gy)
                            )
                            gy += step
                        }
                        gx += step
                    }

                    // 2. Draw Edges with relationship lines and arrows
                    for (edge in edges) {
                        val from = nodes.find { it.id == edge.fromNodeId } ?: continue
                        val to = nodes.find { it.id == edge.toNodeId } ?: continue

                        val p1 = Offset(from.xRatio * w, from.yRatio * h)
                        val p2 = Offset(to.xRatio * w, to.yRatio * h)

                        val isEdgeHighlighted = selectedNodeId != null &&
                                (edge.fromNodeId == selectedNodeId || edge.toNodeId == selectedNodeId)

                        val lineColor = if (isEdgeHighlighted) CyberCyan else BorderCyber.copy(alpha = 0.6f)
                        val lineWidth = if (isEdgeHighlighted) 2.5.dp.toPx() else 1.2.dp.toPx()

                        // Draw line
                        drawLine(
                            color = lineColor,
                            start = p1,
                            end = p2,
                            strokeWidth = lineWidth
                        )

                        // Draw Arrow in middle
                        drawArrowHead(p1, p2, lineColor)

                        // Draw relationship text badge
                        val midX = (p1.x + p2.x) / 2
                        val midY = (p1.y + p2.y) / 2
                        val relText = edge.relationship.label
                        val textResult = textMeasurer.measure(
                            text = relText,
                            style = TextStyle(
                                color = if (isEdgeHighlighted) CyberCyan else TextMuted,
                                fontSize = 8.sp,
                                fontWeight = FontWeight.Bold
                            )
                        )
                        drawText(
                            textLayoutResult = textResult,
                            topLeft = Offset(midX - textResult.size.width / 2, midY - textResult.size.height / 2 - 4.dp.toPx())
                        )
                    }

                    // 3. Draw Nodes
                    for (node in nodes) {
                        val center = Offset(node.xRatio * w, node.yRatio * h)
                        val isSelected = node.id == selectedNodeId
                        val isConnected = connectedNodeIds.contains(node.id)

                        val nodeColor = when (node.severity) {
                            ThreatSeverityLevel.CRITICAL -> SeverityCritical
                            ThreatSeverityLevel.HIGH -> SeverityHigh
                            ThreatSeverityLevel.SUSPICIOUS -> SeveritySuspicious
                            ThreatSeverityLevel.SAFE -> SeveritySafe
                        }

                        val radius = if (isSelected) 18.dp.toPx() * pulseScale else 14.dp.toPx()

                        // Glow behind node if selected or critical
                        if (isSelected || node.severity == ThreatSeverityLevel.CRITICAL) {
                            drawCircle(
                                color = if (isSelected) CyberCyan.copy(alpha = 0.35f) else nodeColor.copy(alpha = 0.2f),
                                radius = radius + 8.dp.toPx(),
                                center = center
                            )
                        }

                        // Outer border circle
                        drawCircle(
                            color = if (isSelected) CyberCyan else if (isConnected) nodeColor else nodeColor.copy(alpha = 0.6f),
                            radius = radius,
                            center = center,
                            style = Stroke(width = if (isSelected) 2.5.dp.toPx() else 1.5.dp.toPx())
                        )

                        // Center filled circle
                        drawCircle(
                            color = if (isSelected) CyberCyanDark else CyberSurfaceVariant,
                            radius = radius - 2.dp.toPx(),
                            center = center
                        )

                        // Inner dot
                        drawCircle(
                            color = nodeColor,
                            radius = 4.dp.toPx(),
                            center = center
                        )

                        // Node Label below
                        val labelResult = textMeasurer.measure(
                            text = node.label,
                            style = TextStyle(
                                color = if (isSelected) CyberCyan else TextPrimary,
                                fontSize = 9.sp,
                                fontWeight = if (isSelected) FontWeight.Bold else FontWeight.Medium
                            )
                        )
                        drawText(
                            textLayoutResult = labelResult,
                            topLeft = Offset(center.x - labelResult.size.width / 2, center.y + radius + 3.dp.toPx())
                        )
                    }
                }

                // Legend / Helper in top corner
                Surface(
                    modifier = Modifier
                        .align(Alignment.TopStart)
                        .padding(8.dp),
                    shape = RoundedCornerShape(6.dp),
                    color = CyberSurfaceVariant.copy(alpha = 0.85f),
                    border = androidx.compose.foundation.BorderStroke(1.dp, BorderCyber.copy(alpha = 0.4f))
                ) {
                    Text(
                        text = "Tap any node to inspect links",
                        style = MaterialTheme.typography.labelSmall.copy(
                            color = TextMuted,
                            fontSize = 9.sp
                        ),
                        modifier = Modifier.padding(horizontal = 6.dp, vertical = 3.dp)
                    )
                }
            }
        }

        // Selected Node Inspection Card
        selectedNode?.let { node ->
            GlassCard(
                borderColor = CyberCyan.copy(alpha = 0.45f),
                modifier = Modifier.fillMaxWidth()
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
                            SeverityBadge(severity = node.severity)
                            Text(
                                text = node.label,
                                style = MaterialTheme.typography.titleMedium.copy(
                                    fontWeight = FontWeight.Bold,
                                    color = TextPrimary
                                )
                            )
                        }

                        Text(
                            text = "Risk: +${node.riskContribution}",
                            style = MaterialTheme.typography.labelSmall.copy(
                                color = SeverityCritical,
                                fontWeight = FontWeight.Bold
                            )
                        )
                    }

                    Text(
                        text = "Entity Type: ${node.type.displayName} • ${node.subtitle}",
                        style = MaterialTheme.typography.bodySmall.copy(color = CyberCyan, fontSize = 11.sp)
                    )

                    if (node.attributes.isNotEmpty()) {
                        HorizontalDivider(color = BorderCyber.copy(alpha = 0.4f))
                        Column(verticalArrangement = Arrangement.spacedBy(3.dp)) {
                            node.attributes.forEach { (k, v) ->
                                Row(
                                    modifier = Modifier.fillMaxWidth(),
                                    horizontalArrangement = Arrangement.SpaceBetween
                                ) {
                                    Text(text = k, style = MaterialTheme.typography.labelSmall.copy(color = TextMuted, fontSize = 10.sp))
                                    Text(text = v, style = MaterialTheme.typography.bodySmall.copy(color = TextPrimary, fontSize = 11.sp))
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

private fun DrawScope.drawArrowHead(p1: Offset, p2: Offset, color: Color) {
    val mid = Offset((p1.x + p2.x) / 2, (p1.y + p2.y) / 2)
    val angle = atan2((p2.y - p1.y).toDouble(), (p2.x - p1.x).toDouble())
    val arrowLen = 8.dp.toPx()
    val arrowAngle = Math.toRadians(25.0)

    val x1 = mid.x - arrowLen * cos(angle - arrowAngle)
    val y1 = mid.y - arrowLen * sin(angle - arrowAngle)

    val x2 = mid.x - arrowLen * cos(angle + arrowAngle)
    val y2 = mid.y - arrowLen * sin(angle + arrowAngle)

    val path = Path().apply {
        moveTo(mid.x, mid.y)
        lineTo(x1.toFloat(), y1.toFloat())
        lineTo(x2.toFloat(), y2.toFloat())
        close()
    }
    drawPath(path, color)
}
