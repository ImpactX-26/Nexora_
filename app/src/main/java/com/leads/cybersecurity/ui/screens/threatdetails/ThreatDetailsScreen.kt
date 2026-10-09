package com.leads.cybersecurity.ui.screens.threatdetails

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.automirrored.filled.ArrowForward
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
import com.leads.cybersecurity.data.model.ThreatSeverityLevel
import com.leads.cybersecurity.ui.components.*
import com.leads.cybersecurity.ui.theme.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ThreatDetailsScreen(
    viewModel: ThreatDetailsViewModel,
    onNavigateBack: () -> Unit,
    onInvestigateFurther: () -> Unit
) {
    val incident by viewModel.incident.collectAsState()

    Scaffold(
        containerColor = CyberBackground,
        topBar = {
            TopAppBar(
                title = {
                    Text(
                        text = "Threat Investigation",
                        style = MaterialTheme.typography.titleMedium.copy(
                            fontWeight = FontWeight.Bold,
                            color = TextPrimary
                        )
                    )
                },
                navigationIcon = {
                    IconButton(onClick = onNavigateBack) {
                        Icon(
                            imageVector = Icons.AutoMirrored.Filled.ArrowBack,
                            contentDescription = "Back",
                            tint = TextPrimary
                        )
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = CyberBackground,
                    titleContentColor = TextPrimary
                )
            )
        },
        bottomBar = {
            Surface(
                color = CyberSurface,
                border = androidx.compose.foundation.BorderStroke(1.dp, BorderCyber.copy(alpha = 0.5f)),
                modifier = Modifier.fillMaxWidth()
            ) {
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(16.dp),
                    horizontalArrangement = Arrangement.spacedBy(12.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Button(
                        onClick = onInvestigateFurther,
                        colors = ButtonDefaults.buttonColors(
                            containerColor = CyberCyan,
                            contentColor = CyberBackground
                        ),
                        shape = RoundedCornerShape(12.dp),
                        modifier = Modifier.fillMaxWidth()
                    ) {
                        Icon(
                            imageVector = Icons.Default.Hub,
                            contentDescription = null,
                            modifier = Modifier.size(18.dp)
                        )
                        Spacer(modifier = Modifier.width(8.dp))
                        Text(
                            text = "Investigate Further (ScamGraph & AI)",
                            fontWeight = FontWeight.Bold,
                            fontSize = 13.sp
                        )
                    }
                }
            }
        }
    ) { innerPadding ->
        LazyColumn(
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding),
            contentPadding = PaddingValues(16.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            // Header Card
            item {
                RiskScoreCard(
                    riskScore = incident.overallRiskScore,
                    severity = incident.severity,
                    title = incident.title,
                    subtitle = incident.subtitle
                )
            }

            // Section 1: WHY THIS IS RISKY
            item {
                SectionHeader(title = "Why This is Risky")
                Spacer(modifier = Modifier.height(6.dp))
                GlassCard {
                    Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                        RiskyPointRow("Bank Impersonation", "Directly clones Wells Fargo identity tokens to manipulate customer trust.")
                        RiskyPointRow("Suspicious Sender", "Message originated from an unverified VoIP trunk with high spam abuse scoring.")
                        RiskyPointRow("Phishing URL", "Deceptive path designed to capture customer online banking usernames & passwords.")
                        RiskyPointRow("Suspicious Domain", "Domain registered 48 hours ago in Russia on bulletproof proxy IP 185.220.101.42.")
                        RiskyPointRow("Malicious APK Indicators", "Sideloaded package holds dangerous SMS reading capabilities to intercept 2FA codes.")
                        RiskyPointRow("Related Infrastructure", "Incoming spoofed voice calls and SMS links share identical backend servers.")
                    }
                }
            }

            // Section 2: ATTACK CHAIN
            item {
                SectionHeader(title = "Correlated Attack Chain")
                Spacer(modifier = Modifier.height(6.dp))
                AttackChainVisualizer()
            }

            // Section 3: EVIDENCE CARDS
            item {
                SectionHeader(title = "Forensic Evidence & Telemetry", trailingText = "${incident.evidenceList.size} Signals")
                Spacer(modifier = Modifier.height(6.dp))
                Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
                    incident.evidenceList.forEach { evidence ->
                        EvidenceCard(evidence = evidence)
                    }
                }
            }

            // Section 4: RECOMMENDED ACTIONS
            item {
                SectionHeader(title = "Recommended Protection Playbook")
                Spacer(modifier = Modifier.height(6.dp))
                Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
                    incident.recommendedActions.forEach { action ->
                        RecommendationCard(
                            action = action,
                            onActionClick = { viewModel.completeAction(action.id) }
                        )
                    }
                }
            }
        }
    }
}

@Composable
private fun RiskyPointRow(title: String, explanation: String) {
    Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.spacedBy(8.dp),
        verticalAlignment = Alignment.Top
    ) {
        Box(
            modifier = Modifier
                .padding(top = 4.dp)
                .size(6.dp)
                .clip(CircleShape)
                .background(SeverityCritical)
        )
        Column {
            Text(
                text = title,
                style = MaterialTheme.typography.titleSmall.copy(
                    fontWeight = FontWeight.Bold,
                    color = TextPrimary,
                    fontSize = 12.sp
                )
            )
            Text(
                text = explanation,
                style = MaterialTheme.typography.bodySmall.copy(
                    color = TextSecondary,
                    fontSize = 11.sp
                )
            )
        }
    }
}

@Composable
private fun AttackChainVisualizer() {
    val chainSteps = listOf(
        "SMS" to "Urgent Fraud Alert",
        "URL" to "Phishing Landing",
        "DOMAIN" to "wellsfarg0-secure.xyz",
        "APK" to "wf-verify-auth.apk",
        "APPLICATION" to "Bank Auth Helper",
        "CALL SIGNAL" to "Spoofed Support Voice"
    )

    GlassCard(borderColor = CyberCyan.copy(alpha = 0.35f)) {
        Column(verticalArrangement = Arrangement.spacedBy(6.dp)) {
            chainSteps.forEachIndexed { index, pair ->
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.SpaceBetween
                ) {
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        Surface(
                            shape = RoundedCornerShape(4.dp),
                            color = CyberCyanDark
                        ) {
                            Text(
                                text = pair.first,
                                color = CyberCyan,
                                style = MaterialTheme.typography.labelSmall.copy(
                                    fontWeight = FontWeight.Bold,
                                    fontSize = 10.sp
                                ),
                                modifier = Modifier.padding(horizontal = 6.dp, vertical = 2.dp)
                            )
                        }

                        Text(
                            text = pair.second,
                            style = MaterialTheme.typography.bodySmall.copy(
                                color = TextPrimary,
                                fontWeight = FontWeight.Medium,
                                fontSize = 12.sp
                            )
                        )
                    }

                    if (index < chainSteps.size - 1) {
                        Icon(
                            imageVector = Icons.Default.ArrowDownward,
                            contentDescription = null,
                            tint = CyberCyan,
                            modifier = Modifier.size(14.dp)
                        )
                    } else {
                        Surface(shape = RoundedCornerShape(4.dp), color = SeverityCritical.copy(alpha = 0.2f)) {
                            Text(
                                text = "CRITICAL TARGET",
                                color = SeverityCritical,
                                fontSize = 9.sp,
                                fontWeight = FontWeight.Bold,
                                modifier = Modifier.padding(horizontal = 6.dp, vertical = 2.dp)
                            )
                        }
                    }
                }
            }
        }
    }
}
