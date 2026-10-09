package com.leads.cybersecurity.data.model

enum class SenderType {
    USER,
    AGENT,
    SYSTEM
}

enum class CardType {
    THREAT_VERDICT,
    REMEDIATION_CHECKLIST,
    INFO_NOTICE,
    BREACH_ALERT
}

data class MessageCardData(
    val type: CardType,
    val title: String,
    val subtitle: String? = null,
    val severity: ThreatSeverity = ThreatSeverity.MEDIUM,
    val keyPoints: List<String> = emptyList(),
    val actionLabel: String? = null,
    val actionPayload: String? = null
)

data class ChatMessage(
    val id: String,
    val text: String,
    val sender: SenderType,
    val timestamp: Long = System.currentTimeMillis(),
    val isTyping: Boolean = false,
    val cardData: MessageCardData? = null
)

data class QuickPrompt(
    val id: String,
    val label: String,
    val promptText: String,
    val iconCategory: String = "SHIELD"
)
