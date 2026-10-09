package com.leads.cybersecurity.data.model

enum class BreachStatus {
    SAFE,
    COMPROMISED,
    ACTION_REQUIRED
}

data class BreachRecord(
    val id: String,
    val sourceName: String,
    val breachDate: String,
    val exposedData: List<String>,
    val passwordExposed: Boolean,
    val severity: ThreatSeverity,
    val description: String,
    val recommendedFix: String
)

data class MonitoredAccount(
    val id: String,
    val identifier: String, // email or phone
    val status: BreachStatus,
    val totalBreachesFound: Int,
    val breaches: List<BreachRecord>,
    val lastAuditedDate: String
)
