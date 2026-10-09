package com.leads.cybersecurity.ui.screens.onboarding

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.leads.cybersecurity.ui.components.GlassCard
import com.leads.cybersecurity.ui.theme.*

@Composable
fun OnboardingScreen(
    onFinishOnboarding: () -> Unit,
    onOpenPermissions: () -> Unit
) {
    var currentPage by remember { mutableIntStateOf(0) }

    val pages = listOf(
        OnboardingPageData(
            title = "Your Personal Security Layer",
            subtitle = "Autonomous Personal Cybersecurity Agent",
            description = "LEADS monitors your device posture to protect you from deceptive social engineering, phishing campaigns, and malicious apps using user-granted permissions and supported Android security APIs.",
            icon = Icons.Default.Shield,
            tag = "USER CONTROL & PRIVACY"
        ),
        OnboardingPageData(
            title = "Understand the Attack",
            subtitle = "Connected Threat Intelligence",
            description = "Unlike isolated anti-virus utilities that treat threats as separate alerts, LEADS correlates SMS tokens, deceptive URLs, sideloaded APKs, and spoofed calls into one complete attack story.",
            icon = Icons.Default.Hub,
            tag = "SCAMGRAPH CORRELATION"
        ),
        OnboardingPageData(
            title = "Detect. Investigate. Protect.",
            subtitle = "Actionable Defensive Intervention",
            description = "Experience real-time ScamGraph visualizer, step-by-step AI investigation reasoning, and one-tap verified countermeasures designed to keep your banking and digital identity secure.",
            icon = Icons.Default.VerifiedUser,
            tag = "AUTONOMOUS DEFENSE"
        )
    )

    val currentData = pages[currentPage]

    Scaffold(
        containerColor = CyberBackground,
        bottomBar = {
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(24.dp),
                verticalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                // Page Indicator Dots
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.Center,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    pages.indices.forEach { index ->
                        Box(
                            modifier = Modifier
                                .padding(horizontal = 4.dp)
                                .size(if (currentPage == index) 20.dp else 8.dp, 8.dp)
                                .clip(RoundedCornerShape(4.dp))
                                .background(if (currentPage == index) CyberCyan else BorderCyber)
                        )
                    }
                }

                Spacer(modifier = Modifier.height(8.dp))

                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    TextButton(onClick = onFinishOnboarding) {
                        Text(text = "Skip", color = TextMuted, fontWeight = FontWeight.SemiBold)
                    }

                    Button(
                        onClick = {
                            if (currentPage < pages.size - 1) {
                                currentPage++
                            } else {
                                onOpenPermissions()
                            }
                        },
                        colors = ButtonDefaults.buttonColors(
                            containerColor = CyberCyan,
                            contentColor = CyberBackground
                        ),
                        shape = RoundedCornerShape(12.dp),
                        contentPadding = PaddingValues(horizontal = 24.dp, vertical = 12.dp)
                    ) {
                        Text(
                            text = if (currentPage == pages.size - 1) "Set Up Permissions" else "Next",
                            fontWeight = FontWeight.Bold,
                            fontSize = 14.sp
                        )
                    }
                }
            }
        }
    ) { innerPadding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding)
                .padding(24.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center
        ) {
            Surface(
                shape = RoundedCornerShape(24.dp),
                color = CyberCyanDark.copy(alpha = 0.4f),
                border = androidx.compose.foundation.BorderStroke(1.dp, CyberCyan.copy(alpha = 0.5f)),
                modifier = Modifier.size(96.dp)
            ) {
                Box(contentAlignment = Alignment.Center) {
                    Icon(
                        imageVector = currentData.icon,
                        contentDescription = null,
                        tint = CyberCyan,
                        modifier = Modifier.size(48.dp)
                    )
                }
            }

            Spacer(modifier = Modifier.height(24.dp))

            Surface(
                shape = RoundedCornerShape(6.dp),
                color = CyberSurfaceVariant
            ) {
                Text(
                    text = currentData.tag,
                    color = CyberCyan,
                    style = MaterialTheme.typography.labelSmall.copy(
                        fontSize = 10.sp,
                        fontWeight = FontWeight.Bold,
                        letterSpacing = 1.sp
                    ),
                    modifier = Modifier.padding(horizontal = 10.dp, vertical = 4.dp)
                )
            }

            Spacer(modifier = Modifier.height(14.dp))

            Text(
                text = currentData.title,
                style = MaterialTheme.typography.headlineMedium.copy(
                    fontWeight = FontWeight.Bold,
                    color = TextPrimary,
                    fontSize = 24.sp
                ),
                textAlign = TextAlign.Center
            )

            Spacer(modifier = Modifier.height(6.dp))

            Text(
                text = currentData.subtitle,
                style = MaterialTheme.typography.titleSmall.copy(
                    color = CyberCyan,
                    fontWeight = FontWeight.SemiBold
                ),
                textAlign = TextAlign.Center
            )

            Spacer(modifier = Modifier.height(16.dp))

            GlassCard(
                borderColor = BorderCyber.copy(alpha = 0.5f),
                modifier = Modifier.fillMaxWidth()
            ) {
                Text(
                    text = currentData.description,
                    style = MaterialTheme.typography.bodyMedium.copy(
                        color = TextSecondary,
                        lineHeight = 22.sp
                    ),
                    textAlign = TextAlign.Center
                )
            }
        }
    }
}

private data class OnboardingPageData(
    val title: String,
    val subtitle: String,
    val description: String,
    val icon: ImageVector,
    val tag: String
)
