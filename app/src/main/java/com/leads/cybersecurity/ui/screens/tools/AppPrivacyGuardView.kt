package com.leads.cybersecurity.ui.screens.tools

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.leads.cybersecurity.data.model.AppPrivacyInfo
import com.leads.cybersecurity.data.model.ThreatSeverity
import com.leads.cybersecurity.ui.components.GlassCard
import com.leads.cybersecurity.ui.components.SeverityBadge
import com.leads.cybersecurity.ui.theme.*

@Composable
fun AppPrivacyGuardView(
    viewModel: ToolsViewModel
) {
    val appList by viewModel.appPrivacyList.collectAsState()

    LazyColumn(
        modifier = Modifier.fillMaxSize(),
        contentPadding = PaddingValues(16.dp),
        verticalArrangement = Arrangement.spacedBy(14.dp)
    ) {
        item {
            GlassCard {
                Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        Icon(
                            imageVector = Icons.Default.PrivacyTip,
                            contentDescription = null,
                            tint = CyberPurple,
                            modifier = Modifier.size(24.dp)
                        )
                        Text(
                            text = "App Permissions & Privacy Guardian",
                            style = MaterialTheme.typography.titleMedium.copy(
                                fontWeight = FontWeight.Bold,
                                color = TextPrimary
                            )
                        )
                    }
                    Text(
                        text = "LEADS continuously inspects installed applications for privilege escalation, background audio/camera polling, and unverified analytics trackers.",
                        style = MaterialTheme.typography.bodySmall.copy(color = TextSecondary)
                    )
                }
            }
        }

        item {
            Text(
                text = "INSTALLED PACKAGES AUDIT (${appList.size})",
                style = MaterialTheme.typography.labelLarge.copy(
                    color = TextMuted,
                    letterSpacing = 1.sp,
                    fontWeight = FontWeight.Bold
                )
            )
        }

        items(appList, key = { it.packageName }) { app ->
            AppPrivacyCard(
                app = app,
                onRevokePermission = { perm -> viewModel.revokePermission(app.packageName, perm) }
            )
        }
    }
}

@Composable
private fun AppPrivacyCard(
    app: AppPrivacyInfo,
    onRevokePermission: (String) -> Unit
) {
    val borderColor = when (app.riskSeverity) {
        ThreatSeverity.CRITICAL -> CyberRed.copy(alpha = 0.4f)
        ThreatSeverity.HIGH -> CyberRed.copy(alpha = 0.3f)
        ThreatSeverity.MEDIUM -> CyberAmber.copy(alpha = 0.3f)
        else -> BorderCyber
    }

    GlassCard(borderColor = borderColor) {
        Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(10.dp)
                ) {
                    Box(
                        modifier = Modifier
                            .size(36.dp)
                            .clip(RoundedCornerShape(8.dp))
                            .background(CyberSurfaceVariant),
                        contentAlignment = Alignment.Center
                    ) {
                        Icon(
                            imageVector = if (app.isFlaggedSuspicious) Icons.Default.Warning else Icons.Default.Android,
                            contentDescription = null,
                            tint = if (app.isFlaggedSuspicious) CyberRed else CyberCyan,
                            modifier = Modifier.size(20.dp)
                        )
                    }

                    Column {
                        Text(
                            text = app.appName,
                            style = MaterialTheme.typography.titleSmall.copy(
                                fontWeight = FontWeight.Bold,
                                color = TextPrimary
                            )
                        )
                        Text(
                            text = "${app.category} • ${app.packageName}",
                            style = MaterialTheme.typography.bodySmall.copy(
                                color = TextMuted,
                                fontSize = 10.sp
                            )
                        )
                    }
                }

                SeverityBadge(severity = app.riskSeverity)
            }

            Text(
                text = "AI Assessment: ${app.aiRiskAnalysis}",
                style = MaterialTheme.typography.bodySmall.copy(
                    color = TextSecondary,
                    fontSize = 12.sp
                )
            )

            if (app.dangerousPermissions.isNotEmpty()) {
                Text(
                    text = "Dangerous Permissions Held:",
                    style = MaterialTheme.typography.labelSmall.copy(color = TextMuted)
                )

                Column(verticalArrangement = Arrangement.spacedBy(6.dp)) {
                    app.dangerousPermissions.forEach { perm ->
                        Row(
                            modifier = Modifier
                                .fillMaxWidth()
                                .background(CyberSurfaceVariant.copy(alpha = 0.6f), RoundedCornerShape(8.dp))
                                .padding(horizontal = 10.dp, vertical = 6.dp),
                            horizontalArrangement = Arrangement.SpaceBetween,
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Text(
                                text = perm,
                                style = MaterialTheme.typography.bodySmall.copy(
                                    color = TextPrimary,
                                    fontSize = 11.sp,
                                    fontWeight = FontWeight.Medium
                                )
                            )

                            Button(
                                onClick = { onRevokePermission(perm) },
                                colors = ButtonDefaults.buttonColors(
                                    containerColor = CyberRedDark,
                                    contentColor = CyberRed
                                ),
                                shape = RoundedCornerShape(6.dp),
                                contentPadding = PaddingValues(horizontal = 8.dp, vertical = 2.dp)
                            ) {
                                Text(text = "Revoke", fontSize = 10.sp, fontWeight = FontWeight.Bold)
                            }
                        }
                    }
                }
            } else {
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(6.dp)
                ) {
                    Icon(
                        imageVector = Icons.Default.Check,
                        contentDescription = null,
                        tint = CyberGreen,
                        modifier = Modifier.size(14.dp)
                    )
                    Text(
                        text = "No active high-risk permissions detected",
                        style = MaterialTheme.typography.bodySmall.copy(color = CyberGreen, fontSize = 11.sp)
                    )
                }
            }
        }
    }
}
