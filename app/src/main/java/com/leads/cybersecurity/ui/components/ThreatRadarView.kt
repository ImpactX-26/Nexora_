package com.leads.cybersecurity.ui.components

import androidx.compose.animation.core.*
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.size
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import com.leads.cybersecurity.ui.theme.CyberCyan
import com.leads.cybersecurity.ui.theme.CyberRed
import com.leads.cybersecurity.ui.theme.CyberSurfaceVariant
import kotlin.math.cos
import kotlin.math.sin

@Composable
fun ThreatRadarView(
    threatsCount: Int,
    isScanning: Boolean = false,
    modifier: Modifier = Modifier,
    size: Dp = 140.dp
) {
    val infiniteTransition = rememberInfiniteTransition(label = "RadarTransition")

    val rotationAngle by infiniteTransition.animateFloat(
        initialValue = 0f,
        targetValue = 360f,
        animationSpec = infiniteRepeatable(
            animation = tween(durationMillis = if (isScanning) 2000 else 4500, easing = LinearEasing),
            repeatMode = RepeatMode.Restart
        ),
        label = "RadarRotation"
    )

    val pulseRadius by infiniteTransition.animateFloat(
        initialValue = 0.2f,
        targetValue = 1f,
        animationSpec = infiniteRepeatable(
            animation = tween(durationMillis = 1800, easing = FastOutSlowInEasing),
            repeatMode = RepeatMode.Restart
        ),
        label = "RadarPulse"
    )

    Box(
        modifier = modifier.size(size),
        contentAlignment = Alignment.Center
    ) {
        Canvas(modifier = Modifier.size(size)) {
            val center = Offset(size.toPx() / 2f, size.toPx() / 2f)
            val maxRadius = (size.toPx() / 2f) - 6.dp.toPx()

            // Concentric cyber rings
            drawCircle(
                color = CyberSurfaceVariant.copy(alpha = 0.5f),
                radius = maxRadius,
                center = center,
                style = Stroke(width = 1.dp.toPx())
            )
            drawCircle(
                color = CyberSurfaceVariant.copy(alpha = 0.4f),
                radius = maxRadius * 0.66f,
                center = center,
                style = Stroke(width = 1.dp.toPx())
            )
            drawCircle(
                color = CyberSurfaceVariant.copy(alpha = 0.3f),
                radius = maxRadius * 0.33f,
                center = center,
                style = Stroke(width = 1.dp.toPx())
            )

            // Crosshairs
            drawLine(
                color = CyberSurfaceVariant.copy(alpha = 0.3f),
                start = Offset(center.x, center.y - maxRadius),
                end = Offset(center.x, center.y + maxRadius),
                strokeWidth = 1.dp.toPx()
            )
            drawLine(
                color = CyberSurfaceVariant.copy(alpha = 0.3f),
                start = Offset(center.x - maxRadius, center.y),
                end = Offset(center.x + maxRadius, center.y),
                strokeWidth = 1.dp.toPx()
            )

            // Pulse wave
            drawCircle(
                color = CyberCyan.copy(alpha = (1f - pulseRadius) * 0.25f),
                radius = maxRadius * pulseRadius,
                center = center,
                style = Stroke(width = 2.dp.toPx())
            )

            // Sweep Scanner Line
            val sweepRad = Math.toRadians(rotationAngle.toDouble())
            val sweepEnd = Offset(
                (center.x + maxRadius * cos(sweepRad)).toFloat(),
                (center.y + maxRadius * sin(sweepRad)).toFloat()
            )
            drawLine(
                brush = Brush.linearGradient(
                    listOf(CyberCyan.copy(alpha = 0.1f), CyberCyan.copy(alpha = 0.9f)),
                    start = center,
                    end = sweepEnd
                ),
                start = center,
                end = sweepEnd,
                strokeWidth = 2.dp.toPx()
            )

            // Active threat blip dots
            if (threatsCount > 0) {
                val blip1 = Offset(center.x + maxRadius * 0.55f, center.y - maxRadius * 0.35f)
                drawCircle(color = CyberRed, radius = 4.dp.toPx(), center = blip1)
                drawCircle(color = CyberRed.copy(alpha = 0.3f), radius = 8.dp.toPx(), center = blip1)
            }
            if (threatsCount > 1) {
                val blip2 = Offset(center.x - maxRadius * 0.45f, center.y + maxRadius * 0.40f)
                drawCircle(color = CyberRed, radius = 3.5.dp.toPx(), center = blip2)
                drawCircle(color = CyberRed.copy(alpha = 0.3f), radius = 7.dp.toPx(), center = blip2)
            }
            if (threatsCount > 2) {
                val blip3 = Offset(center.x + maxRadius * 0.25f, center.y + maxRadius * 0.55f)
                drawCircle(color = CyberCyan, radius = 3.dp.toPx(), center = blip3)
            }
        }
    }
}
