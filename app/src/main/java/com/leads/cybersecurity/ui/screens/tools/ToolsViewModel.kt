package com.leads.cybersecurity.ui.screens.tools

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.leads.cybersecurity.data.model.AppPrivacyInfo
import com.leads.cybersecurity.data.model.MonitoredAccount
import com.leads.cybersecurity.data.model.WifiAuditResult
import com.leads.cybersecurity.data.repository.SecurityRepository
import com.leads.cybersecurity.domain.PhishingAnalysisVerdict
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch

class ToolsViewModel(
    private val repository: SecurityRepository
) : ViewModel() {

    // Tab 0: Phishing Analyzer
    private val _phishingInput = MutableStateFlow("")
    val phishingInput: StateFlow<String> = _phishingInput.asStateFlow()

    private val _phishingVerdict = MutableStateFlow<PhishingAnalysisVerdict?>(null)
    val phishingVerdict: StateFlow<PhishingAnalysisVerdict?> = _phishingVerdict.asStateFlow()

    private val _isAnalyzingPhishing = MutableStateFlow(false)
    val isAnalyzingPhishing: StateFlow<Boolean> = _isAnalyzingPhishing.asStateFlow()

    // Tab 1: App Privacy
    val appPrivacyList: StateFlow<List<AppPrivacyInfo>> = repository.appPrivacyListFlow
        .stateIn(
            scope = viewModelScope,
            started = SharingStarted.WhileSubscribed(5000),
            initialValue = emptyList()
        )

    // Tab 2: Dark Web Monitor
    val monitoredAccounts: StateFlow<List<MonitoredAccount>> = repository.monitoredAccountsFlow
        .stateIn(
            scope = viewModelScope,
            started = SharingStarted.WhileSubscribed(5000),
            initialValue = emptyList()
        )

    // Tab 3: Wi-Fi Auditor
    val wifiAudit: StateFlow<WifiAuditResult> = repository.wifiAuditFlow
        .stateIn(
            scope = viewModelScope,
            started = SharingStarted.WhileSubscribed(5000),
            initialValue = WifiAuditResult(
                ssid = "Scanning...",
                securityProtocol = "Unknown",
                isPublicUnencrypted = false,
                isDnsTamperingDetected = false,
                isArpPoisoningDetected = false,
                isCaptivePortalDeception = false,
                overallSafety = com.leads.cybersecurity.data.model.ThreatSeverity.SAFE,
                gatewayIp = "0.0.0.0",
                dnsServer = "0.0.0.0",
                aiNetworkAnalysis = "Initiating network integrity scan..."
            )
        )

    private val _isAuditingWifi = MutableStateFlow(false)
    val isAuditingWifi: StateFlow<Boolean> = _isAuditingWifi.asStateFlow()

    fun updatePhishingInput(text: String) {
        _phishingInput.value = text
    }

    fun analyzePhishing(input: String? = null) {
        val query = input ?: _phishingInput.value
        if (query.isBlank()) return

        viewModelScope.launch {
            _isAnalyzingPhishing.value = true
            val verdict = repository.analyzeUrlOrSms(query)
            _phishingVerdict.value = verdict
            _isAnalyzingPhishing.value = false
        }
    }

    fun revokePermission(packageName: String, permission: String) {
        viewModelScope.launch {
            repository.revokeAppPermission(packageName, permission)
        }
    }

    fun addMonitoredAccount(identifier: String) {
        if (identifier.isBlank()) return
        viewModelScope.launch {
            repository.addMonitoredAccount(identifier.trim())
        }
    }

    fun refreshWifiAudit() {
        viewModelScope.launch {
            _isAuditingWifi.value = true
            repository.auditCurrentWifi()
            _isAuditingWifi.value = false
        }
    }
}
