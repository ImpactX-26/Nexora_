package com.leads.cybersecurity.data.repository

import com.leads.cybersecurity.data.model.*
import com.leads.cybersecurity.domain.PhishingAnalysisVerdict
import kotlinx.coroutines.flow.Flow

interface SecurityRepository {
    val securityScoreFlow: Flow<SecurityScore>
    val activeThreatsFlow: Flow<List<ThreatItem>>
    val chatMessagesFlow: Flow<List<ChatMessage>>
    val appPrivacyListFlow: Flow<List<AppPrivacyInfo>>
    val monitoredAccountsFlow: Flow<List<MonitoredAccount>>
    val wifiAuditFlow: Flow<WifiAuditResult>
    val agentSettingsFlow: Flow<AgentSettings>

    suspend fun runSecurityScan(onProgressUpdate: (ScanProgressState) -> Unit): List<ThreatItem>
    suspend fun mitigateThreat(threatId: String)
    suspend fun ignoreThreat(threatId: String)
    suspend fun sendChatMessage(userText: String): ChatMessage
    suspend fun analyzeUrlOrSms(query: String): PhishingAnalysisVerdict
    suspend fun revokeAppPermission(packageName: String, permission: String)
    suspend fun addMonitoredAccount(emailOrPhone: String)
    suspend fun auditCurrentWifi(): WifiAuditResult
    suspend fun updateSettings(settings: AgentSettings)
    suspend fun testBackendConnection(endpoint: String): Boolean
}
