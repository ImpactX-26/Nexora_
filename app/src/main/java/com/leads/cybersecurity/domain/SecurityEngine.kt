package com.leads.cybersecurity.domain

import com.leads.cybersecurity.data.model.HealthStatus
import com.leads.cybersecurity.data.model.SecurityScore
import com.leads.cybersecurity.data.model.ThreatItem
import com.leads.cybersecurity.data.model.ThreatSeverity
import com.leads.cybersecurity.data.model.ThreatStatus

object SecurityEngine {

    fun computeSecurityScore(threats: List<ThreatItem>): SecurityScore {
        val activeThreats = threats.filter { it.status == ThreatStatus.ACTIVE }
        val mitigatedThreats = threats.filter { it.status == ThreatStatus.MITIGATED }

        var penalty = 0
        for (threat in activeThreats) {
            penalty += when (threat.severity) {
                ThreatSeverity.CRITICAL -> 25
                ThreatSeverity.HIGH -> 15
                ThreatSeverity.MEDIUM -> 8
                ThreatSeverity.LOW -> 3
                ThreatSeverity.SAFE -> 0
            }
        }

        val calculatedScore = (100 - penalty).coerceIn(15, 100)

        val healthStatus = when {
            calculatedScore >= 90 -> HealthStatus.EXCELLENT
            calculatedScore >= 75 -> HealthStatus.GOOD
            calculatedScore >= 50 -> HealthStatus.AT_RISK
            else -> HealthStatus.CRITICAL
        }

        // Subcategory scores
        val networkScore = if (activeThreats.any { it.category == com.leads.cybersecurity.data.model.ThreatCategory.NETWORK }) 65 else 96
        val privacyScore = if (activeThreats.any { it.category == com.leads.cybersecurity.data.model.ThreatCategory.PRIVACY }) 68 else 92
        val identityScore = if (activeThreats.any { it.category == com.leads.cybersecurity.data.model.ThreatCategory.CREDENTIAL_LEAK }) 58 else 88
        val systemScore = if (activeThreats.any { it.category == com.leads.cybersecurity.data.model.ThreatCategory.SYSTEM_INTEGRITY }) 60 else 98

        return SecurityScore(
            overallScore = calculatedScore,
            maxScore = 100,
            healthStatus = healthStatus,
            networkScore = networkScore,
            privacyScore = privacyScore,
            identityScore = identityScore,
            systemScore = systemScore,
            activeThreatsCount = activeThreats.size,
            mitigatedThreatsCount = mitigatedThreats.size,
            lastScanTime = "Just now"
        )
    }
}
