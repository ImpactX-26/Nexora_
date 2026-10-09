package com.leads.cybersecurity.data.model

enum class ThreatSeverity(val label: String, val level: Int) {
    CRITICAL("Critical", 4),
    HIGH("High", 3),
    MEDIUM("Medium", 2),
    LOW("Low", 1),
    SAFE("Safe", 0)
}

enum class ThreatCategory(val displayName: String) {
    PHISHING("Phishing & Scams"),
    MALWARE("Malware & Spyware"),
    NETWORK("Wi-Fi & Network"),
    PRIVACY("Privacy & Permissions"),
    CREDENTIAL_LEAK("Dark Web Breach"),
    SYSTEM_INTEGRITY("System Vulnerability")
}

enum class ThreatStatus {
    ACTIVE,
    MITIGATED,
    QUARANTINED,
    IGNORED
}

data class ThreatItem(
    val id: String,
    val title: String,
    val description: String,
    val category: ThreatCategory,
    val severity: ThreatSeverity,
    val status: ThreatStatus = ThreatStatus.ACTIVE,
    val timestamp: String,
    val affectedResource: String,
    val remediationSteps: List<String>,
    val aiExplanation: String
)
