package com.leads.cybersecurity.ui.screens.dashboard

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.leads.cybersecurity.data.model.SecurityScore
import com.leads.cybersecurity.data.model.ThreatItem
import com.leads.cybersecurity.data.model.ThreatStatus
import com.leads.cybersecurity.data.repository.SecurityRepository
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch

data class DashboardUiState(
    val score: SecurityScore = SecurityScore(),
    val activeThreats: List<ThreatItem> = emptyList(),
    val isAutonomousGuardEnabled: Boolean = true,
    val selectedThreatForDetail: ThreatItem? = null
)

class DashboardViewModel(
    private val repository: SecurityRepository
) : ViewModel() {

    val uiState: StateFlow<DashboardUiState> = repository.securityScoreFlow
        .map { score ->
            DashboardUiState(
                score = score,
                activeThreats = emptyList() // populated via combined flows below
            )
        }
        .stateIn(
            scope = viewModelScope,
            started = SharingStarted.WhileSubscribed(5000),
            initialValue = DashboardUiState()
        )

    val activeThreatsState: StateFlow<List<ThreatItem>> = repository.activeThreatsFlow
        .map { list -> list.filter { it.status == ThreatStatus.ACTIVE } }
        .stateIn(
            scope = viewModelScope,
            started = SharingStarted.WhileSubscribed(5000),
            initialValue = emptyList()
        )

    val securityScoreState: StateFlow<SecurityScore> = repository.securityScoreFlow
        .stateIn(
            scope = viewModelScope,
            started = SharingStarted.WhileSubscribed(5000),
            initialValue = SecurityScore()
        )

    fun mitigateThreat(threatId: String) {
        viewModelScope.launch {
            repository.mitigateThreat(threatId)
        }
    }

    fun ignoreThreat(threatId: String) {
        viewModelScope.launch {
            repository.ignoreThreat(threatId)
        }
    }
}
