package com.leads.cybersecurity.ui.screens.settings

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.leads.cybersecurity.data.model.ProtectionMode
import com.leads.cybersecurity.ui.components.CyberHeader
import com.leads.cybersecurity.ui.components.GlassCard
import com.leads.cybersecurity.ui.theme.*

@Composable
fun SettingsScreen(
    viewModel: SettingsViewModel
) {
    val settings by viewModel.settings.collectAsState()
    val isTesting by viewModel.isTestingConnection.collectAsState()
    val connectionResult by viewModel.connectionResult.collectAsState()
    var endpointInput by remember(settings.fastApiServerUrl) { mutableStateOf(settings.fastApiServerUrl) }

    Scaffold(
        containerColor = CyberBackground,
        topBar = {
            CyberHeader(
                title = "SETTINGS & AGENT",
                subtitle = "Configuration & FastAPI Endpoint"
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
            // Section 1: Agent Protection Mode
            item {
                Text(
                    text = "AGENT DEFENSE POSTURE",
                    style = MaterialTheme.typography.labelLarge.copy(
                        color = TextMuted,
                        letterSpacing = 1.sp,
                        fontWeight = FontWeight.Bold
                    )
                )
                Spacer(modifier = Modifier.height(8.dp))

                GlassCard {
                    Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
                        ProtectionMode.values().forEach { mode ->
                            val isSelected = settings.protectionMode == mode
                            Surface(
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .clickable { viewModel.updateProtectionMode(mode) },
                                shape = RoundedCornerShape(10.dp),
                                color = if (isSelected) CyberCyanDark.copy(alpha = 0.5f) else CyberSurfaceVariant.copy(alpha = 0.4f),
                                border = androidx.compose.foundation.BorderStroke(
                                    1.dp,
                                    if (isSelected) CyberCyan else BorderCyber.copy(alpha = 0.5f)
                                )
                            ) {
                                Row(
                                    modifier = Modifier.padding(12.dp),
                                    verticalAlignment = Alignment.Top,
                                    horizontalArrangement = Arrangement.spacedBy(10.dp)
                                ) {
                                    RadioButton(
                                        selected = isSelected,
                                        onClick = { viewModel.updateProtectionMode(mode) },
                                        colors = RadioButtonDefaults.colors(
                                            selectedColor = CyberCyan,
                                            unselectedColor = TextMuted
                                        )
                                    )
                                    Column {
                                        Text(
                                            text = mode.displayName,
                                            style = MaterialTheme.typography.titleSmall.copy(
                                                fontWeight = FontWeight.Bold,
                                                color = TextPrimary
                                            )
                                        )
                                        Spacer(modifier = Modifier.height(2.dp))
                                        Text(
                                            text = mode.description,
                                            style = MaterialTheme.typography.bodySmall.copy(
                                                color = TextSecondary,
                                                fontSize = 11.sp
                                            )
                                        )
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // Section 2: FastAPI Backend Integration Gateway
            item {
                Text(
                    text = "FASTAPI / PYTHON BACKEND INTEGRATION",
                    style = MaterialTheme.typography.labelLarge.copy(
                        color = TextMuted,
                        letterSpacing = 1.sp,
                        fontWeight = FontWeight.Bold
                    )
                )
                Spacer(modifier = Modifier.height(8.dp))

                GlassCard(borderColor = CyberPurple.copy(alpha = 0.3f)) {
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
                                    imageVector = Icons.Default.CloudQueue,
                                    contentDescription = null,
                                    tint = CyberPurple,
                                    modifier = Modifier.size(20.dp)
                                )
                                Text(
                                    text = "Agent API Gateway",
                                    style = MaterialTheme.typography.titleMedium.copy(
                                        fontWeight = FontWeight.Bold,
                                        color = TextPrimary
                                    )
                                )
                            }

                            Surface(
                                shape = RoundedCornerShape(6.dp),
                                color = if (settings.isBackendConnected) CyberGreenDark else CyberSurfaceVariant
                            ) {
                                Text(
                                    text = if (settings.isBackendConnected) "CONNECTED" else "MOCK MODE",
                                    color = if (settings.isBackendConnected) CyberGreen else TextMuted,
                                    style = MaterialTheme.typography.labelSmall.copy(
                                        fontSize = 10.sp,
                                        fontWeight = FontWeight.Bold
                                    ),
                                    modifier = Modifier.padding(horizontal = 8.dp, vertical = 3.dp)
                                )
                            }
                        }

                        Text(
                            text = "Connects the mobile UI to our Python FastAPI server running neural inference pipelines.",
                            style = MaterialTheme.typography.bodySmall.copy(color = TextSecondary)
                        )

                        OutlinedTextField(
                            value = endpointInput,
                            onValueChange = {
                                endpointInput = it
                                viewModel.updateEndpoint(it)
                            },
                            modifier = Modifier.fillMaxWidth(),
                            placeholder = { Text(text = "http://10.0.2.2:8000", color = TextMuted) },
                            label = { Text(text = "FastAPI Server URL", color = TextMuted) },
                            shape = RoundedCornerShape(10.dp),
                            colors = OutlinedTextFieldDefaults.colors(
                                focusedBorderColor = CyberPurple,
                                unfocusedBorderColor = BorderCyber,
                                focusedTextColor = TextPrimary,
                                unfocusedTextColor = TextPrimary
                            ),
                            singleLine = true
                        )

                        Button(
                            onClick = { viewModel.testBackendConnection(endpointInput) },
                            colors = ButtonDefaults.buttonColors(
                                containerColor = CyberPurple,
                                contentColor = CyberBackground
                            ),
                            shape = RoundedCornerShape(10.dp),
                            modifier = Modifier.fillMaxWidth()
                        ) {
                            if (isTesting) {
                                CircularProgressIndicator(modifier = Modifier.size(16.dp), color = CyberBackground, strokeWidth = 2.dp)
                                Spacer(modifier = Modifier.width(8.dp))
                                Text(text = "Pinging Server...", fontWeight = FontWeight.Bold)
                            } else {
                                Icon(imageVector = Icons.Default.Sensors, contentDescription = null, modifier = Modifier.size(16.dp))
                                Spacer(modifier = Modifier.width(8.dp))
                                Text(text = "Test Connection", fontWeight = FontWeight.Bold)
                            }
                        }

                        connectionResult?.let { msg ->
                            Surface(
                                modifier = Modifier.fillMaxWidth(),
                                shape = RoundedCornerShape(8.dp),
                                color = CyberSurfaceVariant
                            ) {
                                Text(
                                    text = msg,
                                    color = if (msg.contains("200")) CyberGreen else CyberAmber,
                                    style = MaterialTheme.typography.bodySmall.copy(fontSize = 11.sp),
                                    modifier = Modifier.padding(8.dp)
                                )
                            }
                        }
                    }
                }
            }

            // Section 3: Telemetry & Active Shields Toggles
            item {
                Text(
                    text = "ACTIVE PERIMETER DEFENSES",
                    style = MaterialTheme.typography.labelLarge.copy(
                        color = TextMuted,
                        letterSpacing = 1.sp,
                        fontWeight = FontWeight.Bold
                    )
                )
                Spacer(modifier = Modifier.height(8.dp))

                GlassCard {
                    Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                        ToggleRow(
                            title = "Real-Time Phishing Shield",
                            subtitle = "Intercepts deceptive SMS & URL intents",
                            checked = settings.realTimePhishingShieldEnabled,
                            onCheckedChange = { viewModel.toggleRealTimePhishing(it) }
                        )
                        HorizontalDivider(color = BorderCyber.copy(alpha = 0.5f))
                        ToggleRow(
                            title = "Dark Web Breach Watch",
                            subtitle = "Background monitoring of credential exposures",
                            checked = settings.darkWebWatchEnabled,
                            onCheckedChange = { viewModel.toggleDarkWeb(it) }
                        )
                        HorizontalDivider(color = BorderCyber.copy(alpha = 0.5f))
                        ToggleRow(
                            title = "Rogue Wi-Fi & ARP Guard",
                            subtitle = "Warns immediately on unencrypted hotspots",
                            checked = settings.rogueWifiDetectionEnabled,
                            onCheckedChange = { viewModel.toggleRogueWifi(it) }
                        )
                        HorizontalDivider(color = BorderCyber.copy(alpha = 0.5f))
                        ToggleRow(
                            title = "App Permission Anomaly Alerts",
                            subtitle = "Flags unexpected camera/mic background polling",
                            checked = settings.appPermissionAnomalyAlerts,
                            onCheckedChange = { viewModel.toggleAppAnomaly(it) }
                        )
                    }
                }
            }

            // About Hackathon / Build Info
            item {
                Surface(
                    modifier = Modifier.fillMaxWidth(),
                    shape = RoundedCornerShape(12.dp),
                    color = CyberSurfaceVariant.copy(alpha = 0.3f),
                    border = androidx.compose.foundation.BorderStroke(1.dp, BorderCyber.copy(alpha = 0.4f))
                ) {
                    Column(
                        modifier = Modifier.padding(14.dp),
                        horizontalAlignment = Alignment.CenterHorizontally,
                        verticalArrangement = Arrangement.spacedBy(4.dp)
                    ) {
                        Text(
                            text = "LEADS Mobile Agent v1.0.0",
                            style = MaterialTheme.typography.labelMedium.copy(color = TextPrimary, fontWeight = FontWeight.Bold)
                        )
                        Text(
                            text = "Built for Personal Cybersecurity Hackathon • Kotlin + Jetpack Compose",
                            style = MaterialTheme.typography.bodySmall.copy(color = TextMuted, fontSize = 10.sp)
                        )
                    }
                }
            }
        }
    }
}

@Composable
private fun ToggleRow(
    title: String,
    subtitle: String,
    checked: Boolean,
    onCheckedChange: (Boolean) -> Unit
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 4.dp),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically
    ) {
        Column(modifier = Modifier.weight(1f)) {
            Text(
                text = title,
                style = MaterialTheme.typography.titleSmall.copy(
                    fontWeight = FontWeight.SemiBold,
                    color = TextPrimary
                )
            )
            Text(
                text = subtitle,
                style = MaterialTheme.typography.bodySmall.copy(
                    color = TextMuted,
                    fontSize = 11.sp
                )
            )
        }

        Switch(
            checked = checked,
            onCheckedChange = onCheckedChange,
            colors = SwitchDefaults.colors(
                checkedThumbColor = CyberCyan,
                checkedTrackColor = CyberCyanDark,
                uncheckedThumbColor = TextMuted,
                uncheckedTrackColor = CyberSurfaceVariant
            )
        )
    }
}
