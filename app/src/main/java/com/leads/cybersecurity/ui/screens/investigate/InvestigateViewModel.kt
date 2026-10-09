package com.leads.cybersecurity.ui.screens.investigate

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.leads.cybersecurity.data.model.CoordinatedIncident
import com.leads.cybersecurity.data.repository.IncidentRepository
import com.leads.cybersecurity.data.repository.MockIncidentRepository
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch

class InvestigateViewModel(
    private val repository: IncidentRepository
) : ViewModel() {

    private val _selectedTab = MutableStateFlow(0)
    val selectedTab: StateFlow<Int> = _selectedTab.asStateFlow()

    val incident: StateFlow<CoordinatedIncident> = repository.currentIncidentFlow
        .stateIn(
            scope = viewModelScope,
            started = SharingStarted.WhileSubscribed(5000),
            initialValue = MockIncidentRepository.createCoordinatedBankingScamIncident()
        )

    fun selectTab(index: Int) {
        _selectedTab.value = index
    }

    fun completeAction(actionId: String) {
        viewModelScope.launch {
            repository.markActionCompleted(actionId)
        }
    }
}
