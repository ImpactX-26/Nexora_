package com.leads.cybersecurity.data.model

data class AppPrivacyInfo(
    val packageName: String,
    val appName: String,
    val category: String,
    val riskScore: Int, // 0 to 100
    val riskSeverity: ThreatSeverity,
    val dangerousPermissions: List<String>,
    val trackerCount: Int,
    val backgroundAccess: Boolean,
    val isFlaggedSuspicious: Boolean,
    val aiRiskAnalysis: String
)
