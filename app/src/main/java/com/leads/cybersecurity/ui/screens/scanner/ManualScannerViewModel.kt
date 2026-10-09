package com.leads.cybersecurity.ui.screens.scanner

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.leads.cybersecurity.data.model.ScanProgressState
import com.leads.cybersecurity.data.model.ScanStatus
import com.leads.cybersecurity.data.repository.IncidentRepository
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch

class ManualScannerViewModel(
    private val repository: IncidentRepository
) : ViewModel() {

    private val _inputTarget = MutableStateFlow("")
    val inputTarget: StateFlow<String> = _inputTarget.asStateFlow()

    val scanState: StateFlow<ScanProgressState> = repository.manualScanStateFlow
        .stateIn(
            scope = viewModelScope,
            started = SharingStarted.WhileSubscribed(5000),
            initialValue = ScanProgressState()
        )

    fun updateTarget(input: String) {
        _inputTarget.value = input
    }

    fun startScan(scanType: String = "ALL") {
        viewModelScope.launch {
            repository.runManualScan(scanType) {}
        }
    }
}
