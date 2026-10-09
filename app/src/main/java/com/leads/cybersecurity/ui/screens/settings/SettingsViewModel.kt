package com.leads.cybersecurity.ui.screens.settings

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.leads.cybersecurity.data.model.AgentSettings
import com.leads.cybersecurity.data.model.ProtectionMode
import com.leads.cybersecurity.data.repository.SecurityRepository
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch

class SettingsViewModel(
    private val repository: SecurityRepository
) : ViewModel() {

    val settings: StateFlow<AgentSettings> = repository.agentSettingsFlow
        .stateIn(
            scope = viewModelScope,
            started = SharingStarted.WhileSubscribed(5000),
            initialValue = AgentSettings()
        )

    private val _isTestingConnection = MutableStateFlow(false)
    val isTestingConnection: StateFlow<Boolean> = _isTestingConnection.asStateFlow()

    private val _connectionResult = MutableStateFlow<String?>(null)
    val connectionResult: StateFlow<String?> = _connectionResult.asStateFlow()

    fun updateProtectionMode(mode: ProtectionMode) {
        viewModelScope.launch {
            val current = settings.value
            repository.updateSettings(current.copy(protectionMode = mode))
        }
    }

    fun updateEndpoint(url: String) {
        viewModelScope.launch {
            val current = settings.value
            repository.updateSettings(current.copy(fastApiServerUrl = url))
        }
    }

    fun testBackendConnection(endpoint: String) {
        viewModelScope.launch {
            _isTestingConnection.value = true
            _connectionResult.value = null
            val isSuccess = repository.testBackendConnection(endpoint)
            _isTestingConnection.value = false
            _connectionResult.value = if (isSuccess) "Connected to FastAPI Agent Server (200 OK)" else "Server unreachable. Mock data fallback active."
        }
    }

    fun toggleRealTimePhishing(enabled: Boolean) {
        viewModelScope.launch {
            val current = settings.value
            repository.updateSettings(current.copy(realTimePhishingShieldEnabled = enabled))
        }
    }

    fun toggleDarkWeb(enabled: Boolean) {
        viewModelScope.launch {
            val current = settings.value
            repository.updateSettings(current.copy(darkWebWatchEnabled = enabled))
        }
    }

    fun toggleRogueWifi(enabled: Boolean) {
        viewModelScope.launch {
            val current = settings.value
            repository.updateSettings(current.copy(rogueWifiDetectionEnabled = enabled))
        }
    }

    fun toggleAppAnomaly(enabled: Boolean) {
        viewModelScope.launch {
            val current = settings.value
            repository.updateSettings(current.copy(appPermissionAnomalyAlerts = enabled))
        }
    }
}
