package com.leads.cybersecurity.ui.screens.threats

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.leads.cybersecurity.data.model.CoordinatedIncident
import com.leads.cybersecurity.data.model.ThreatStatusCategory
import com.leads.cybersecurity.data.repository.IncidentRepository
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.stateIn

class ThreatCenterViewModel(
    private val repository: IncidentRepository
) : ViewModel() {

    private val _selectedTab = MutableStateFlow(0)
    val selectedTab: StateFlow<Int> = _selectedTab.asStateFlow()

    val filteredIncidents: StateFlow<List<CoordinatedIncident>> = combine(
        repository.incidentsListFlow,
        _selectedTab
    ) { list, tabIndex ->
        when (tabIndex) {
            0 -> list.filter { it.category == ThreatStatusCategory.ACTIVE_CAMPAIGN }
            1 -> list.filter { it.category == ThreatStatusCategory.ISOLATED_ANOMALY }
            2 -> list.filter { it.category == ThreatStatusCategory.RESOLVED }
            else -> list
        }
    }.stateIn(
        scope = viewModelScope,
        started = SharingStarted.WhileSubscribed(5000),
        initialValue = emptyList()
    )

    fun selectTab(index: Int) {
        _selectedTab.value = index
    }
}
