package com.leads.cybersecurity.ui.screens.recommendations

import android.content.Intent
import android.net.Uri
import android.provider.Settings
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.Shield
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.leads.cybersecurity.data.model.CoordinatedIncident
import com.leads.cybersecurity.data.repository.IncidentRepository
import com.leads.cybersecurity.ui.components.GlassCard
import com.leads.cybersecurity.ui.components.RecommendationCard
import com.leads.cybersecurity.ui.components.SectionHeader
import com.leads.cybersecurity.ui.theme.*
import kotlinx.coroutines.launch

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun RecommendedActionsScreen(
    repository: IncidentRepository,
    onNavigateBack: () -> Unit
) {
    val incident by repository.currentIncidentFlow.collectAsState(initial = com.leads.cybersecurity.data.repository.MockIncidentRepository.createCoordinatedBankingScamIncident())
    val context = LocalContext.current
    val coroutineScope = rememberCoroutineScope()

    var feedbackMessage by remember { mutableStateOf<String?>(null) }

    Scaffold(
        containerColor = CyberBackground,
        topBar = {
            TopAppBar(
                title = {
                    Text(
                        text = "Protect Yourself",
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
        }
    ) { innerPadding ->
        LazyColumn(
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding),
            contentPadding = PaddingValues(16.dp),
            verticalArrangement = Arrangement.spacedBy(14.dp)
        ) {
            item {
                GlassCard(borderColor = SeveritySafe.copy(alpha = 0.4f)) {
                    Column(verticalArrangement = Arrangement.spacedBy(6.dp)) {
                        Row(
                            verticalAlignment = Alignment.CenterVertically,
                            horizontalArrangement = Arrangement.spacedBy(8.dp)
                        ) {
                            Icon(
                                imageVector = Icons.Default.Shield,
                                contentDescription = null,
                                tint = SeveritySafe,
                                modifier = Modifier.size(24.dp)
                            )
                            Text(
                                text = "Automated & Guided Playbook",
                                style = MaterialTheme.typography.titleMedium.copy(
                                    fontWeight = FontWeight.Bold,
                                    color = TextPrimary
                                )
                            )
                        }
                        Text(
                            text = "Follow these priority actions to neutralize the active banking scam and prevent credential compromise.",
                            style = MaterialTheme.typography.bodySmall.copy(
                                color = TextSecondary,
                                lineHeight = 17.sp
                            )
                        )
                    }
                }
            }

            feedbackMessage?.let { msg ->
                item {
                    Surface(
                        modifier = Modifier.fillMaxWidth(),
                        shape = androidx.compose.foundation.shape.RoundedCornerShape(8.dp),
                        color = CyberSurfaceVariant
                    ) {
                        Text(
                            text = msg,
                            color = CyberCyan,
                            style = MaterialTheme.typography.bodySmall.copy(fontWeight = FontWeight.Medium),
                            modifier = Modifier.padding(10.dp)
                        )
                    }
                }
            }

            item {
                SectionHeader(title = "Immediate Action Steps", trailingText = "${incident.recommendedActions.size} Steps")
            }

            items(incident.recommendedActions, key = { it.id }) { action ->
                RecommendationCard(
                    action = action,
                    onActionClick = {
                        coroutineScope.launch {
                            repository.markActionCompleted(action.id)
                        }
                        when (action.stepNumber) {
                            1 -> {
                                feedbackMessage = "Domain 'wellsfarg0-secure.xyz' added to local firewall blocklist."
                            }
                            2 -> {
                                try {
                                    val intent = Intent(Settings.ACTION_MANAGE_APPLICATIONS_SETTINGS)
                                    context.startActivity(intent)
                                } catch (e: Exception) {
                                    feedbackMessage = "Opening Android Application Settings to remove package."
                                }
                            }
                            4 -> {
                                feedbackMessage = "Official Wells Fargo fraud line: 1-800-869-3557 (Dial directly from phone app)."
                            }
                            5 -> {
                                feedbackMessage = "Fraudulent SMS forwarded to 7726 (SPAM registry)."
                            }
                            else -> {
                                feedbackMessage = "Action recorded."
                            }
                        }
                    }
                )
            }
        }
    }
}
