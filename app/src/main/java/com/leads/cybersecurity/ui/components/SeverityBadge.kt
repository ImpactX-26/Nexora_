package com.leads.cybersecurity.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.leads.cybersecurity.data.model.ThreatSeverity
import com.leads.cybersecurity.data.model.ThreatSeverityLevel
import com.leads.cybersecurity.ui.theme.*

@Composable
fun SeverityBadge(
    severity: ThreatSeverityLevel,
    modifier: Modifier = Modifier
) {
    val (bgColor, textColor, borderColor) = when (severity) {
        ThreatSeverityLevel.CRITICAL -> Triple(SeverityCritical.copy(alpha = 0.15f), SeverityCritical, SeverityCritical.copy(alpha = 0.4f))
        ThreatSeverityLevel.HIGH -> Triple(SeverityHigh.copy(alpha = 0.15f), SeverityHigh, SeverityHigh.copy(alpha = 0.4f))
        ThreatSeverityLevel.SUSPICIOUS -> Triple(SeveritySuspicious.copy(alpha = 0.15f), SeveritySuspicious, SeveritySuspicious.copy(alpha = 0.4f))
        ThreatSeverityLevel.SAFE -> Triple(SeveritySafe.copy(alpha = 0.15f), SeveritySafe, SeveritySafe.copy(alpha = 0.4f))
    }

    Box(
        modifier = modifier
            .background(bgColor, RoundedCornerShape(6.dp))
            .border(1.dp, borderColor, RoundedCornerShape(6.dp))
            .padding(horizontal = 8.dp, vertical = 3.dp),
        contentAlignment = Alignment.Center
    ) {
        Text(
            text = severity.label,
            color = textColor,
            style = MaterialTheme.typography.labelSmall.copy(
                fontWeight = FontWeight.Bold,
                letterSpacing = 0.8.sp,
                fontSize = 10.sp
            )
        )
    }
}

@Composable
fun SeverityBadge(
    severity: ThreatSeverity,
    modifier: Modifier = Modifier
) {
    val (bgColor, textColor, borderColor) = when (severity) {
        ThreatSeverity.CRITICAL -> Triple(SeverityCritical.copy(alpha = 0.15f), SeverityCritical, SeverityCritical.copy(alpha = 0.4f))
        ThreatSeverity.HIGH -> Triple(SeverityHigh.copy(alpha = 0.15f), SeverityHigh, SeverityHigh.copy(alpha = 0.4f))
        ThreatSeverity.MEDIUM -> Triple(SeveritySuspicious.copy(alpha = 0.15f), SeveritySuspicious, SeveritySuspicious.copy(alpha = 0.4f))
        ThreatSeverity.LOW, ThreatSeverity.SAFE -> Triple(SeveritySafe.copy(alpha = 0.15f), SeveritySafe, SeveritySafe.copy(alpha = 0.4f))
    }

    Box(
        modifier = modifier
            .background(bgColor, RoundedCornerShape(6.dp))
            .border(1.dp, borderColor, RoundedCornerShape(6.dp))
            .padding(horizontal = 8.dp, vertical = 3.dp),
        contentAlignment = Alignment.Center
    ) {
        Text(
            text = severity.label.uppercase(),
            color = textColor,
            style = MaterialTheme.typography.labelSmall.copy(
                fontWeight = FontWeight.Bold,
                letterSpacing = 0.8.sp,
                fontSize = 10.sp
            )
        )
    }
}
