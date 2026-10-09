package com.leads.cybersecurity.data.model

enum class HealthStatus(val label: String) {
    EXCELLENT("Secure & Protected"),
    GOOD("Guarded with Minor Issues"),
    AT_RISK("Vulnerable - Action Needed"),
    CRITICAL("Severe Threats Detected")
}

data class SecurityScore(
    val overallScore: Int = 84,
    val maxScore: Int = 100,
    val healthStatus: HealthStatus = HealthStatus.GOOD,
    val networkScore: Int = 92,
    val privacyScore: Int = 78,
    val identityScore: Int = 70,
    val systemScore: Int = 95,
    val activeThreatsCount: Int = 3,
    val mitigatedThreatsCount: Int = 14,
    val lastScanTime: String = "15 mins ago"
)
