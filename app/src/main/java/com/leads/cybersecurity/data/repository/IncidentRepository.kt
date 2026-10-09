package com.leads.cybersecurity.data.repository

import com.leads.cybersecurity.data.model.*
import kotlinx.coroutines.flow.Flow

interface IncidentRepository {
    val currentIncidentFlow: Flow<CoordinatedIncident>
    val incidentsListFlow: Flow<List<CoordinatedIncident>>
    val permissionsFlow: Flow<List<SecurityPermissionItem>>
    val chatMessagesFlow: Flow<List<ChatMessage>>
    val manualScanStateFlow: Flow<ScanProgressState>
    val securityScoreFlow: Flow<SecurityScore>

    suspend fun getIncidentById(id: String): CoordinatedIncident?
    suspend fun togglePermission(permissionId: String, isGranted: Boolean)
    suspend fun sendAssistantQuery(userPrompt: String): ChatMessage
    suspend fun runManualScan(scanType: String, onProgress: (ScanProgressState) -> Unit): CoordinatedIncident
    suspend fun markActionCompleted(actionId: String)
}
