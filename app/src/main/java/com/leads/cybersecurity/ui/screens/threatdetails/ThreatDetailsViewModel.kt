package com.leads.cybersecurity.ui.screens.threatdetails

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.leads.cybersecurity.data.model.CoordinatedIncident
import com.leads.cybersecurity.data.repository.IncidentRepository
import com.leads.cybersecurity.data.repository.MockIncidentRepository
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

class ThreatDetailsViewModel(
    private val repository: IncidentRepository,
    private val incidentId: String
) : ViewModel() {

    private val _incident = MutableStateFlow(MockIncidentRepository.createCoordinatedBankingScamIncident())
    val incident: StateFlow<CoordinatedIncident> = _incident.asStateFlow()

    init {
        viewModelScope.launch {
            val found = repository.getIncidentById(incidentId)
            if (found != null) {
                _incident.value = found
            }
        }
    }

    fun completeAction(actionId: String) {
        viewModelScope.launch {
            repository.markActionCompleted(actionId)
            val updated = repository.getIncidentById(incidentId)
            if (updated != null) {
                _incident.value = updated
            }
        }
    }
}
