package com.leads.cybersecurity.ui.screens.settings

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowForward
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.leads.cybersecurity.data.model.ProtectionMode
import com.leads.cybersecurity.ui.components.CyberHeader
import com.leads.cybersecurity.ui.components.GlassCard
import com.leads.cybersecurity.ui.components.SectionHeader
import com.leads.cybersecurity.ui.theme.*

@Composable
fun SettingsPrivacyScreen(
    viewModel: SettingsPrivacyViewModel,
    onNavigateToPermissions: () -> Unit
) {
    val permissions by viewModel.permissions.collectAsState()
    val settings by viewModel.settings.collectAsState()
    val isTesting by viewModel.isTestingBackend.collectAsState()
    val testMessage by viewModel.testMessage.collectAsState()

    var endpointInput by remember(settings.fastApiServerUrl) { mutableStateOf(settings.fastApiServerUrl) }

    val grantedCount = permissions.count { it.isGranted }

    Scaffold(
        containerColor = CyberBackground,
        topBar = {
            CyberHeader(
                title = "SETTINGS & PRIVACY",
                subtitle = "Security Posture & Control"
            )
        }
    ) { innerPadding ->
        LazyColumn(
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding),
            contentPadding = PaddingValues(16.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            // Section 1: Security Permissions Summary Card
            item {
                SectionHeader(title = "Security Permissions")
                Spacer(modifier = Modifier.height(4.dp))
                GlassCard(
                    borderColor = CyberCyan.copy(alpha = 0.35f),
                    modifier = Modifier.clickable { onNavigateToPermissions() }
                ) {
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Column(modifier = Modifier.weight(1f)) {
                            Row(
                                verticalAlignment = Alignment.CenterVertically,
                                horizontalArrangement = Arrangement.spacedBy(8.dp)
                            ) {
                                Icon(
                                    imageVector = Icons.Default.Security,
                                    contentDescription = null,
                                    tint = CyberCyan,
                                    modifier = Modifier.size(20.dp)
                                )
                                Text(
                                    text = "Android Security Permissions",
                                    style = MaterialTheme.typography.titleMedium.copy(
                                        fontWeight = FontWeight.Bold,
                                        color = TextPrimary
                                    )
                                )
                            }
                            Spacer(modifier = Modifier.height(2.dp))
                            Text(
                                text = "$grantedCount of ${permissions.size} security layers granted.",
                                style = MaterialTheme.typography.bodySmall.copy(color = TextSecondary, fontSize = 11.sp)
                            )
                        }

                        Row(
                            verticalAlignment = Alignment.CenterVertically,
                            horizontalArrangement = Arrangement.spacedBy(4.dp)
                        ) {
                            Text(
                                text = "Configure",
                                style = MaterialTheme.typography.labelSmall.copy(
                                    color = CyberCyan,
                                    fontWeight = FontWeight.Bold
                                )
                            )
                            Icon(
                                imageVector = Icons.AutoMirrored.Filled.ArrowForward,
                                contentDescription = null,
                                tint = CyberCyan,
                                modifier = Modifier.size(16.dp)
                            )
                        }
                    }
                }
            }

            // Section 2: Protection Mode
            item {
                SectionHeader(title = "Protection Mode")
                Spacer(modifier = Modifier.height(4.dp))
                GlassCard {
                    Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                        ProtectionMode.values().forEach { mode ->
                            val isSelected = settings.protectionMode == mode
                            Surface(
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .clickable { viewModel.updateProtectionMode(mode) },
                                shape = RoundedCornerShape(8.dp),
                                color = if (isSelected) CyberCyanDark.copy(alpha = 0.45f) else CyberSurfaceVariant.copy(alpha = 0.4f),
                                border = androidx.compose.foundation.BorderStroke(
                                    1.dp,
                                    if (isSelected) CyberCyan else BorderCyber.copy(alpha = 0.4f)
                                )
                            ) {
                                Row(
                                    modifier = Modifier.padding(10.dp),
                                    verticalAlignment = Alignment.Top,
                                    horizontalArrangement = Arrangement.spacedBy(10.dp)
                                ) {
                                    RadioButton(
                                        selected = isSelected,
                                        onClick = { viewModel.updateProtectionMode(mode) },
                                        colors = RadioButtonDefaults.colors(selectedColor = CyberCyan, unselectedColor = TextMuted)
                                    )
                                    Column {
                                        Text(
                                            text = mode.displayName,
                                            style = MaterialTheme.typography.titleSmall.copy(
                                                fontWeight = FontWeight.Bold,
                                                color = TextPrimary,
                                                fontSize = 12.sp
                                            )
                                        )
                                        Text(
                                            text = mode.description,
                                            style = MaterialTheme.typography.bodySmall.copy(
                                                color = TextSecondary,
                                                fontSize = 10.sp
                                            )
                                        )
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // Section 3: Privacy Controls
            item {
                SectionHeader(title = "Privacy Principles & Telemetry")
                Spacer(modifier = Modifier.height(4.dp))
                GlassCard(borderColor = SeveritySafe.copy(alpha = 0.35f)) {
                    Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                        Text(
                            text = "\"Your security, your control.\"",
                            style = MaterialTheme.typography.titleSmall.copy(
                                color = SeveritySafe,
                                fontWeight = FontWeight.Bold,
                                fontSize = 13.sp
                            )
                        )
                        HorizontalDivider(color = BorderCyber.copy(alpha = 0.4f))
                        PrivacyPrincipleRow("User-Controlled Permissions", "Telemetry is only inspected when explicitly authorized by you.")
                        PrivacyPrincipleRow("Minimal Data Sharing", "No personal contacts, raw SMS databases, or photos leave your device.")
                        PrivacyPrincipleRow("Local Analysis Where Possible", "Regex and heuristic entropy checks execute on-device in real-time.")
                        PrivacyPrincipleRow("Protected Security Evidence", "All ScamGraph nodes and hash signatures are encrypted in sandbox storage.")
                    }
                }
            }

            // Section 4: Backend Configuration (FastAPI)
            item {
                SectionHeader(title = "FastAPI Backend Configuration")
                Spacer(modifier = Modifier.height(4.dp))
                GlassCard(borderColor = CyberPurple.copy(alpha = 0.35f)) {
                    Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
                        Text(
                            text = "Connects LEADS mobile agent to the Python/FastAPI backend neural engine.",
                            style = MaterialTheme.typography.bodySmall.copy(color = TextSecondary, fontSize = 11.sp)
                        )

                        OutlinedTextField(
                            value = endpointInput,
                            onValueChange = {
                                endpointInput = it
                                viewModel.updateEndpoint(it)
                            },
                            label = { Text("Server URL", color = TextMuted) },
                            modifier = Modifier.fillMaxWidth(),
                            shape = RoundedCornerShape(8.dp),
                            colors = OutlinedTextFieldDefaults.colors(
                                focusedBorderColor = CyberPurple,
                                unfocusedBorderColor = BorderCyber,
                                focusedTextColor = TextPrimary,
                                unfocusedTextColor = TextPrimary
                            ),
                            singleLine = true
                        )

                        Button(
                            onClick = { viewModel.testConnection() },
                            colors = ButtonDefaults.buttonColors(
                                containerColor = CyberPurple,
                                contentColor = CyberBackground
                            ),
                            shape = RoundedCornerShape(8.dp),
                            modifier = Modifier.fillMaxWidth()
                        ) {
                            if (isTesting) {
                                CircularProgressIndicator(modifier = Modifier.size(16.dp), color = CyberBackground, strokeWidth = 2.dp)
                                Spacer(modifier = Modifier.width(8.dp))
                                Text(text = "Testing Connection...", fontWeight = FontWeight.Bold)
                            } else {
                                Text(text = "Test Backend Connection", fontWeight = FontWeight.Bold, fontSize = 12.sp)
                            }
                        }

                        testMessage?.let { msg ->
                            Surface(
                                modifier = Modifier.fillMaxWidth(),
                                shape = RoundedCornerShape(6.dp),
                                color = CyberSurfaceVariant
                            ) {
                                Text(
                                    text = msg,
                                    color = SeveritySafe,
                                    style = MaterialTheme.typography.bodySmall.copy(fontSize = 11.sp),
                                    modifier = Modifier.padding(8.dp)
                                )
                            }
                        }
                    }
                }
            }

            // Section 5: About LEADS
            item {
                Surface(
                    modifier = Modifier.fillMaxWidth(),
                    shape = RoundedCornerShape(12.dp),
                    color = CyberSurfaceVariant.copy(alpha = 0.3f),
                    border = androidx.compose.foundation.BorderStroke(1.dp, BorderCyber.copy(alpha = 0.3f))
                ) {
                    Column(
                        modifier = Modifier.padding(14.dp),
                        horizontalAlignment = Alignment.CenterHorizontally,
                        verticalArrangement = Arrangement.spacedBy(2.dp)
                    ) {
                        Text(
                            text = "LEADS Mobile Agent v1.0.0",
                            style = MaterialTheme.typography.labelMedium.copy(color = TextPrimary, fontWeight = FontWeight.Bold)
                        )
                        Text(
                            text = "AI-Powered Personal Cybersecurity Agent • Hackathon Edition",
                            style = MaterialTheme.typography.bodySmall.copy(color = TextMuted, fontSize = 10.sp)
                        )
                    }
                }
            }
        }
    }
}

@Composable
private fun PrivacyPrincipleRow(title: String, desc: String) {
    Column(verticalArrangement = Arrangement.spacedBy(1.dp)) {
        Text(
            text = "• $title",
            style = MaterialTheme.typography.titleSmall.copy(
                fontWeight = FontWeight.Bold,
                color = TextPrimary,
                fontSize = 11.sp
            )
        )
        Text(
            text = desc,
            style = MaterialTheme.typography.bodySmall.copy(
                color = TextSecondary,
                fontSize = 10.sp
            ),
            modifier = Modifier.padding(start = 12.dp)
        )
    }
}
