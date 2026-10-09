package com.leads.cybersecurity.ui.screens.tools

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.leads.cybersecurity.data.model.BreachRecord
import com.leads.cybersecurity.data.model.BreachStatus
import com.leads.cybersecurity.data.model.MonitoredAccount
import com.leads.cybersecurity.data.model.ThreatSeverity
import com.leads.cybersecurity.ui.components.GlassCard
import com.leads.cybersecurity.ui.components.SeverityBadge
import com.leads.cybersecurity.ui.theme.*

@Composable
fun DarkWebMonitorView(
    viewModel: ToolsViewModel
) {
    val accounts by viewModel.monitoredAccounts.collectAsState()
    var newEmailInput by remember { mutableStateOf("") }
    var showAddDialog by remember { mutableStateOf(false) }

    LazyColumn(
        modifier = Modifier.fillMaxSize(),
        contentPadding = PaddingValues(16.dp),
        verticalArrangement = Arrangement.spacedBy(14.dp)
    ) {
        item {
            GlassCard {
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
                            Icon(
                                imageVector = Icons.Default.Visibility,
                                contentDescription = null,
                                tint = CyberAmber,
                                modifier = Modifier.size(24.dp)
                            )
                            Text(
                                text = "Dark Web Identity Radar",
                                style = MaterialTheme.typography.titleMedium.copy(
                                    fontWeight = FontWeight.Bold,
                                    color = TextPrimary
                                )
                            )
                        }

                        Button(
                            onClick = { showAddDialog = true },
                            colors = ButtonDefaults.buttonColors(
                                containerColor = CyberAmber,
                                contentColor = CyberBackground
                            ),
                            shape = RoundedCornerShape(8.dp),
                            contentPadding = PaddingValues(horizontal = 10.dp, vertical = 4.dp)
                        ) {
                            Icon(imageVector = Icons.Default.Add, contentDescription = null, modifier = Modifier.size(14.dp))
                            Spacer(modifier = Modifier.width(4.dp))
                            Text(text = "Add ID", fontSize = 11.sp, fontWeight = FontWeight.Bold)
                        }
                    }

                    Text(
                        text = "LEADS monitors global credential leak dumps, hacker paste sites, and underground forums for compromised passwords or leaked personal data.",
                        style = MaterialTheme.typography.bodySmall.copy(color = TextSecondary)
                    )
                }
            }
        }

        item {
            Text(
                text = "MONITORED IDENTIFIERS (${accounts.size})",
                style = MaterialTheme.typography.labelLarge.copy(
                    color = TextMuted,
                    letterSpacing = 1.sp,
                    fontWeight = FontWeight.Bold
                )
            )
        }

        items(accounts, key = { it.id }) { account ->
            MonitoredAccountCard(account = account)
        }
    }

    if (showAddDialog) {
        AlertDialog(
            onDismissRequest = { showAddDialog = false },
            containerColor = CyberSurface,
            title = {
                Text(
                    text = "Add Identity to Monitor",
                    style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.Bold, color = TextPrimary)
                )
            },
            text = {
                Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
                    Text(
                        text = "Enter email address or phone number to cross-reference with LEADS breach telemetry.",
                        style = MaterialTheme.typography.bodySmall.copy(color = TextSecondary)
                    )
                    OutlinedTextField(
                        value = newEmailInput,
                        onValueChange = { newEmailInput = it },
                        placeholder = { Text(text = "e.g. yourname@domain.com", color = TextMuted) },
                        shape = RoundedCornerShape(8.dp),
                        colors = OutlinedTextFieldDefaults.colors(
                            focusedBorderColor = CyberAmber,
                            unfocusedBorderColor = BorderCyber,
                            focusedTextColor = TextPrimary,
                            unfocusedTextColor = TextPrimary
                        ),
                        singleLine = true
                    )
                }
            },
            confirmButton = {
                Button(
                    onClick = {
                        if (newEmailInput.isNotBlank()) {
                            viewModel.addMonitoredAccount(newEmailInput)
                            newEmailInput = ""
                            showAddDialog = false
                        }
                    },
                    colors = ButtonDefaults.buttonColors(containerColor = CyberAmber, contentColor = CyberBackground)
                ) {
                    Text(text = "Monitor", fontWeight = FontWeight.Bold)
                }
            },
            dismissButton = {
                TextButton(onClick = { showAddDialog = false }) {
                    Text(text = "Cancel", color = TextMuted)
                }
            }
        )
    }
}

@Composable
private fun MonitoredAccountCard(account: MonitoredAccount) {
    val isCompromised = account.status == BreachStatus.COMPROMISED

    GlassCard(
        borderColor = if (isCompromised) CyberRed.copy(alpha = 0.4f) else CyberGreen.copy(alpha = 0.4f)
    ) {
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
                    Icon(
                        imageVector = if (isCompromised) Icons.Default.Warning else Icons.Default.CheckCircle,
                        contentDescription = null,
                        tint = if (isCompromised) CyberRed else CyberGreen,
                        modifier = Modifier.size(20.dp)
                    )
                    Text(
                        text = account.identifier,
                        style = MaterialTheme.typography.titleSmall.copy(
                            fontWeight = FontWeight.Bold,
                            color = TextPrimary
                        )
                    )
                }

                Surface(
                    shape = RoundedCornerShape(6.dp),
                    color = if (isCompromised) CyberRedDark else CyberGreenDark
                ) {
                    Text(
                        text = if (isCompromised) "${account.totalBreachesFound} BREACHES FOUND" else "CLEAN & SECURE",
                        color = if (isCompromised) CyberRed else CyberGreen,
                        style = MaterialTheme.typography.labelSmall.copy(
                            fontSize = 10.sp,
                            fontWeight = FontWeight.Bold
                        ),
                        modifier = Modifier.padding(horizontal = 8.dp, vertical = 3.dp)
                    )
                }
            }

            if (account.breaches.isNotEmpty()) {
                HorizontalDivider(color = BorderCyber.copy(alpha = 0.5f))
                Text(
                    text = "Breach Incidents on Record:",
                    style = MaterialTheme.typography.labelSmall.copy(color = TextMuted)
                )

                account.breaches.forEach { breach ->
                    BreachItemRow(breach = breach)
                }
            }
        }
    }
}

@Composable
private fun BreachItemRow(breach: BreachRecord) {
    Surface(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(10.dp),
        color = CyberSurfaceVariant.copy(alpha = 0.6f),
        border = androidx.compose.foundation.BorderStroke(1.dp, BorderCyber.copy(alpha = 0.4f))
    ) {
        Column(
            modifier = Modifier.padding(10.dp),
            verticalArrangement = Arrangement.spacedBy(4.dp)
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = "${breach.sourceName} (${breach.breachDate})",
                    style = MaterialTheme.typography.titleSmall.copy(
                        fontWeight = FontWeight.Bold,
                        color = TextPrimary,
                        fontSize = 12.sp
                    )
                )
                if (breach.passwordExposed) {
                    Surface(shape = RoundedCornerShape(4.dp), color = CyberRedDark) {
                        Text(
                            text = "PASSWORD EXPOSED",
                            color = CyberRed,
                            fontSize = 9.sp,
                            fontWeight = FontWeight.Bold,
                            modifier = Modifier.padding(horizontal = 6.dp, vertical = 2.dp)
                        )
                    }
                }
            }

            Text(
                text = "Exposed Data: ${breach.exposedData.joinToString(", ")}",
                style = MaterialTheme.typography.bodySmall.copy(color = CyberAmber, fontSize = 11.sp)
            )

            Text(
                text = "Remedy: ${breach.recommendedFix}",
                style = MaterialTheme.typography.bodySmall.copy(color = TextSecondary, fontSize = 11.sp)
            )
        }
    }
}
