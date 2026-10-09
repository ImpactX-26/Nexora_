package com.leads.cybersecurity.ui.screens.tools

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.leads.cybersecurity.domain.PhishingAnalysisVerdict
import com.leads.cybersecurity.ui.components.GlassCard
import com.leads.cybersecurity.ui.components.SeverityBadge
import com.leads.cybersecurity.ui.theme.*

@Composable
fun PhishingAnalyzerView(
    viewModel: ToolsViewModel
) {
    val input by viewModel.phishingInput.collectAsState()
    val verdict by viewModel.phishingVerdict.collectAsState()
    val isAnalyzing by viewModel.isAnalyzingPhishing.collectAsState()

    val samplePayloads = listOf(
        "Urgent Wells Fargo SMS: Unusual sign-in. Verify at http://wellsfarg0-secure.xyz/login",
        "PayPal Notice: Account suspended. Immediate action required: http://paypa1-update.cfd",
        "Netflix: We couldn't process your payment. Update your KYC here: https://netflix-update.icu",
        "https://github.com/google/jetpack-compose"
    )

    LazyColumn(
        modifier = Modifier.fillMaxSize(),
        contentPadding = PaddingValues(16.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        item {
            GlassCard {
                Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
                    Text(
                        text = "SMS & URL Heuristic Inspector",
                        style = MaterialTheme.typography.titleMedium.copy(
                            fontWeight = FontWeight.Bold,
                            color = TextPrimary
                        )
                    )
                    Text(
                        text = "Paste any incoming SMS text, deceptive link, or email body. LEADS runs deep neural entropy checks, typosquatting discovery, and social engineering risk scoring.",
                        style = MaterialTheme.typography.bodySmall.copy(color = TextSecondary)
                    )

                    OutlinedTextField(
                        value = input,
                        onValueChange = { viewModel.updatePhishingInput(it) },
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(100.dp),
                        placeholder = {
                            Text(
                                text = "Paste suspicious URL or message text here...",
                                color = TextMuted,
                                fontSize = 13.sp
                            )
                        },
                        shape = RoundedCornerShape(12.dp),
                        colors = OutlinedTextFieldDefaults.colors(
                            focusedBorderColor = CyberCyan,
                            unfocusedBorderColor = BorderCyber,
                            focusedContainerColor = CyberSurface,
                            unfocusedContainerColor = CyberSurface,
                            focusedTextColor = TextPrimary,
                            unfocusedTextColor = TextPrimary
                        )
                    )

                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        TextButton(onClick = { viewModel.updatePhishingInput("") }) {
                            Text(text = "Clear", color = TextMuted)
                        }

                        Button(
                            onClick = { viewModel.analyzePhishing() },
                            enabled = input.isNotBlank() && !isAnalyzing,
                            colors = ButtonDefaults.buttonColors(
                                containerColor = CyberCyan,
                                contentColor = CyberBackground
                            ),
                            shape = RoundedCornerShape(10.dp)
                        ) {
                            if (isAnalyzing) {
                                CircularProgressIndicator(
                                    modifier = Modifier.size(16.dp),
                                    color = CyberBackground,
                                    strokeWidth = 2.dp
                                )
                                Spacer(modifier = Modifier.width(6.dp))
                                Text(text = "Analyzing...", fontWeight = FontWeight.Bold)
                            } else {
                                Icon(imageVector = Icons.Default.Search, contentDescription = null, modifier = Modifier.size(16.dp))
                                Spacer(modifier = Modifier.width(6.dp))
                                Text(text = "Analyze Content", fontWeight = FontWeight.Bold)
                            }
                        }
                    }
                }
            }
        }

        // Preset Test Samples
        item {
            Column(verticalArrangement = Arrangement.spacedBy(6.dp)) {
                Text(
                    text = "TRY PRESET THREAT SAMPLES",
                    style = MaterialTheme.typography.labelMedium.copy(
                        color = TextMuted,
                        letterSpacing = 0.5.sp,
                        fontWeight = FontWeight.Bold
                    )
                )

                LazyRow(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                    items(samplePayloads) { sample ->
                        Surface(
                            modifier = Modifier.clickable {
                                viewModel.updatePhishingInput(sample)
                                viewModel.analyzePhishing(sample)
                            },
                            shape = RoundedCornerShape(10.dp),
                            color = CyberSurfaceVariant.copy(alpha = 0.8f),
                            border = androidx.compose.foundation.BorderStroke(1.dp, BorderCyber)
                        ) {
                            Text(
                                text = sample.take(34) + "...",
                                color = CyberCyan,
                                fontSize = 11.sp,
                                modifier = Modifier.padding(horizontal = 10.dp, vertical = 6.dp)
                            )
                        }
                    }
                }
            }
        }

        // Verdict Display
        verdict?.let { result ->
            item {
                VerdictCard(verdict = result)
            }
        }
    }
}

@Composable
private fun VerdictCard(verdict: PhishingAnalysisVerdict) {
    val borderColor = if (verdict.isPhishing) CyberRed.copy(alpha = 0.5f) else CyberGreen.copy(alpha = 0.5f)

    GlassCard(borderColor = borderColor) {
        Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    SeverityBadge(severity = verdict.riskSeverity)
                    Text(
                        text = if (verdict.isPhishing) "MALICIOUS THREAT FLAGGED" else "LOW RISK / SAFE",
                        style = MaterialTheme.typography.titleMedium.copy(
                            fontWeight = FontWeight.Bold,
                            color = if (verdict.isPhishing) CyberRed else CyberGreen
                        )
                    )
                }

                Text(
                    text = "Risk: ${verdict.riskScore}/100",
                    style = MaterialTheme.typography.labelLarge.copy(
                        fontWeight = FontWeight.Bold,
                        color = if (verdict.riskScore > 50) CyberRed else CyberGreen
                    )
                )
            }

            HorizontalDivider(color = BorderCyber.copy(alpha = 0.5f))

            Text(
                text = "Identified Attack Vectors & Tactics:",
                style = MaterialTheme.typography.labelMedium.copy(color = TextMuted)
            )

            verdict.detectedTactics.forEach { tactic ->
                Row(
                    horizontalArrangement = Arrangement.spacedBy(6.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Icon(
                        imageVector = if (verdict.isPhishing) Icons.Default.Warning else Icons.Default.Check,
                        contentDescription = null,
                        tint = if (verdict.isPhishing) CyberAmber else CyberGreen,
                        modifier = Modifier.size(14.dp)
                    )
                    Text(
                        text = tactic,
                        style = MaterialTheme.typography.bodySmall.copy(color = TextPrimary)
                    )
                }
            }

            Text(
                text = "Deceptive Indicators Breakdown:",
                style = MaterialTheme.typography.labelMedium.copy(color = TextMuted)
            )

            verdict.deceptiveIndicators.forEach { indicator ->
                Text(
                    text = "• $indicator",
                    style = MaterialTheme.typography.bodySmall.copy(color = TextSecondary)
                )
            }

            Surface(
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(8.dp),
                color = if (verdict.isPhishing) CyberRedDark.copy(alpha = 0.4f) else CyberGreenDark.copy(alpha = 0.4f),
                border = androidx.compose.foundation.BorderStroke(
                    1.dp,
                    if (verdict.isPhishing) CyberRed.copy(alpha = 0.4f) else CyberGreen.copy(alpha = 0.4f)
                )
            ) {
                Text(
                    text = "AI Recommendation: ${verdict.aiRecommendation}",
                    color = TextPrimary,
                    style = MaterialTheme.typography.bodySmall.copy(lineHeight = 18.sp),
                    modifier = Modifier.padding(10.dp)
                )
            }
        }
    }
}
