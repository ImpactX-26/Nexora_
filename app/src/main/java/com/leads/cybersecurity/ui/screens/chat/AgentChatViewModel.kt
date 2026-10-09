package com.leads.cybersecurity.ui.screens.chat

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.leads.cybersecurity.data.model.ChatMessage
import com.leads.cybersecurity.data.model.QuickPrompt
import com.leads.cybersecurity.data.repository.SecurityRepository
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch

class AgentChatViewModel(
    private val repository: SecurityRepository
) : ViewModel() {

    val messages: StateFlow<List<ChatMessage>> = repository.chatMessagesFlow
        .stateIn(
            scope = viewModelScope,
            started = SharingStarted.WhileSubscribed(5000),
            initialValue = emptyList()
        )

    val quickPrompts: List<QuickPrompt> = listOf(
        QuickPrompt(
            id = "qp-1",
            label = "Check Suspicious SMS",
            promptText = "Analyze this suspicious SMS: \"Wells Fargo: Unusual login detected. Verify your identity now at wellsfarg0-secure.xyz to avoid account lock.\""
        ),
        QuickPrompt(
            id = "qp-2",
            label = "Is Cafe Wi-Fi Safe?",
            promptText = "I am connected to an open public cafe Wi-Fi network. What are the security risks and how can LEADS protect me?"
        ),
        QuickPrompt(
            id = "qp-3",
            label = "Audit App Permissions",
            promptText = "Audit my device for background app privacy leaks and suspicious camera/microphone access."
        ),
        QuickPrompt(
            id = "qp-4",
            label = "Device Security Posture",
            promptText = "Give me a breakdown of my current cybersecurity health score and top recommended actions."
        )
    )

    fun sendMessage(text: String) {
        if (text.isBlank()) return
        viewModelScope.launch {
            repository.sendChatMessage(text.trim())
        }
    }
}
