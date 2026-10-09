package com.leads.cybersecurity.ui.screens.home

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.leads.cybersecurity.data.model.CoordinatedIncident
import com.leads.cybersecurity.data.model.SecurityScore
import com.leads.cybersecurity.data.repository.IncidentRepository
import com.leads.cybersecurity.data.repository.MockIncidentRepository
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.stateIn

class HomeDashboardViewModel(
    private val repository: IncidentRepository
) : ViewModel() {

    val incident: StateFlow<CoordinatedIncident> = repository.currentIncidentFlow
        .stateIn(
            scope = viewModelScope,
            started = SharingStarted.WhileSubscribed(5000),
            initialValue = MockIncidentRepository.createCoordinatedBankingScamIncident()
        )

    val securityScore: StateFlow<SecurityScore> = repository.securityScoreFlow
        .stateIn(
            scope = viewModelScope,
            started = SharingStarted.WhileSubscribed(5000),
            initialValue = SecurityScore(overallScore = 92)
        )
}
