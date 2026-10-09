package com.leads.cybersecurity.ui.screens.assistant

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.leads.cybersecurity.data.model.ChatMessage
import com.leads.cybersecurity.data.model.QuickPrompt
import com.leads.cybersecurity.data.repository.IncidentRepository
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch

class AiAssistantViewModel(
    private val repository: IncidentRepository
) : ViewModel() {

    val messages: StateFlow<List<ChatMessage>> = repository.chatMessagesFlow
        .stateIn(
            scope = viewModelScope,
            started = SharingStarted.WhileSubscribed(5000),
            initialValue = emptyList()
        )

    val quickPrompts: List<QuickPrompt> = listOf(
        QuickPrompt(
            id = "qp_1",
            label = "Why is this dangerous?",
            promptText = "Why is this dangerous?"
        ),
        QuickPrompt(
            id = "qp_2",
            label = "Why is the risk 94?",
            promptText = "Why is the risk 94?"
        ),
        QuickPrompt(
            id = "qp_3",
            label = "What happened?",
            promptText = "What happened in this attack chain?"
        ),
        QuickPrompt(
            id = "qp_4",
            label = "What should I do?",
            promptText = "What should I do right now to protect my accounts?"
        )
    )

    fun sendPrompt(text: String) {
        if (text.isBlank()) return
        viewModelScope.launch {
            repository.sendAssistantQuery(text.trim())
        }
    }
}
