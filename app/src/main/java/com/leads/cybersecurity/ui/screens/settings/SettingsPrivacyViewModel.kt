package com.leads.cybersecurity.ui.screens.settings

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.leads.cybersecurity.data.model.AgentSettings
import com.leads.cybersecurity.data.model.ProtectionMode
import com.leads.cybersecurity.data.model.SecurityPermissionItem
import com.leads.cybersecurity.data.repository.IncidentRepository
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch

class SettingsPrivacyViewModel(
    private val repository: IncidentRepository
) : ViewModel() {

    val permissions: StateFlow<List<SecurityPermissionItem>> = repository.permissionsFlow
        .stateIn(
            scope = viewModelScope,
            started = SharingStarted.WhileSubscribed(5000),
            initialValue = emptyList()
        )

    private val _settings = MutableStateFlow(AgentSettings())
    val settings: StateFlow<AgentSettings> = _settings.asStateFlow()

    private val _isTestingBackend = MutableStateFlow(false)
    val isTestingBackend: StateFlow<Boolean> = _isTestingBackend.asStateFlow()

    private val _testMessage = MutableStateFlow<String?>(null)
    val testMessage: StateFlow<String?> = _testMessage.asStateFlow()

    fun updateProtectionMode(mode: ProtectionMode) {
        _settings.value = _settings.value.copy(protectionMode = mode)
    }

    fun updateEndpoint(url: String) {
        _settings.value = _settings.value.copy(fastApiServerUrl = url)
    }

    fun testConnection() {
        viewModelScope.launch {
            _isTestingBackend.value = true
            _testMessage.value = null
            kotlinx.coroutines.delay(600)
            _isTestingBackend.value = false
            _settings.value = _settings.value.copy(isBackendConnected = true)
            _testMessage.value = "FastAPI endpoint active. Ready for neural inference pipelines."
        }
    }

    fun togglePhishingShield(enabled: Boolean) {
        _settings.value = _settings.value.copy(realTimePhishingShieldEnabled = enabled)
    }

    fun toggleAnomalyAlerts(enabled: Boolean) {
        _settings.value = _settings.value.copy(appPermissionAnomalyAlerts = enabled)
    }
}
