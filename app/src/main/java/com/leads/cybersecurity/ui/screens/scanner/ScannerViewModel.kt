package com.leads.cybersecurity.ui.screens.scanner

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.leads.cybersecurity.data.model.ScanProgressState
import com.leads.cybersecurity.data.model.ScanStatus
import com.leads.cybersecurity.data.repository.SecurityRepository
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

class ScannerViewModel(
    private val repository: SecurityRepository
) : ViewModel() {

    private val _scanState = MutableStateFlow(ScanProgressState())
    val scanState: StateFlow<ScanProgressState> = _scanState.asStateFlow()

    fun startDeepScan() {
        if (_scanState.value.status == ScanStatus.SCANNING) return

        viewModelScope.launch {
            repository.runSecurityScan { state ->
                _scanState.value = state
            }
        }
    }

    fun mitigateThreat(threatId: String) {
        viewModelScope.launch {
            repository.mitigateThreat(threatId)
            val updatedThreats = _scanState.value.threatsDiscovered.filter { it.id != threatId }
            _scanState.value = _scanState.value.copy(threatsDiscovered = updatedThreats)
        }
    }

    fun resetScanner() {
        _scanState.value = ScanProgressState()
    }
}
