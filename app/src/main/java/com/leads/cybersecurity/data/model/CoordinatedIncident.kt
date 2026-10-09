package com.leads.cybersecurity.data.model

import androidx.compose.ui.graphics.Color
import com.leads.cybersecurity.ui.theme.SeverityCritical
import com.leads.cybersecurity.ui.theme.SeverityHigh
import com.leads.cybersecurity.ui.theme.SeveritySafe
import com.leads.cybersecurity.ui.theme.SeveritySuspicious

enum class ThreatSeverityLevel(val label: String, val scoreWeight: Int) {
    SAFE("SAFE", 0),
    SUSPICIOUS("SUSPICIOUS", 45),
    HIGH("HIGH", 75),
    CRITICAL("CRITICAL", 94)
}

enum class ThreatStatusCategory {
    ACTIVE_CAMPAIGN,
    ISOLATED_ANOMALY,
    RESOLVED
}

enum class NodeType(val displayName: String) {
    SMS("SMS Message"),
    PHONE_NUMBER("Phone Number"),
    URL("Phishing URL"),
    DOMAIN("Suspicious Domain"),
    IP_ADDRESS("Host IP"),
    APK_DOWNLOAD("Malicious APK"),
    APPLICATION("Installed App"),
    CALL_SIGNAL("Social Eng Call"),
    INCIDENT("Coordinated Scam"),
    TARGET_BANK("Target Institution")
}

enum class EdgeRelationship(val label: String) {
    CONTAINS("CONTAINS"),
    REDIRECTS_TO("REDIRECTS_TO"),
    RESOLVES_TO("RESOLVES_TO"),
    INSTALLS("INSTALLS"),
    RELATED_TO("RELATED_TO"),
    PART_OF("PART_OF"),
    TARGETS("TARGETS")
}

data class GraphNode(
    val id: String,
    val type: NodeType,
    val label: String,
    val subtitle: String,
    val severity: ThreatSeverityLevel,
    val riskContribution: Int,
    val xRatio: Float, // 0.0 to 1.0 position in Canvas
    val yRatio: Float,
    val attributes: Map<String, String> = emptyMap()
)

data class GraphEdge(
    val fromNodeId: String,
    val toNodeId: String,
    val relationship: EdgeRelationship,
    val isPrimaryAttackVector: Boolean = true
)

data class TimelineEvent(
    val id: String,
    val time: String,
    val title: String,
    val description: String,
    val category: NodeType,
    val severity: ThreatSeverityLevel,
    val indicatorText: String,
    val isCorrelatedByLeads: Boolean = false
)

data class EvidenceItem(
    val id: String,
    val title: String,
    val detail: String,
    val source: String,
    val confidenceScore: Int,
    val severity: ThreatSeverityLevel,
    val technicalTags: List<String>
)

data class RiskFactor(
    val name: String,
    val points: Int,
    val rationale: String,
    val severity: ThreatSeverityLevel
)

data class ProtectionAction(
    val id: String,
    val stepNumber: Int,
    val title: String,
    val description: String,
    val isSupportedPlatformAction: Boolean,
    val actionButtonText: String? = null,
    val isCompleted: Boolean = false
)

data class CoordinatedIncident(
    val id: String,
    val title: String,
    val subtitle: String,
    val category: ThreatStatusCategory,
    val severity: ThreatSeverityLevel,
    val overallRiskScore: Int,
    val summary: String,
    val aiSecuritySummary: String,
    val targetBrand: String,
    val detectedTimestamp: String,
    val nodes: List<GraphNode>,
    val edges: List<GraphEdge>,
    val timeline: List<TimelineEvent>,
    val evidenceList: List<EvidenceItem>,
    val riskFactors: List<RiskFactor>,
    val recommendedActions: List<ProtectionAction>,
    val investigationStages: List<InvestigationStage>
)

data class InvestigationStage(
    val id: String,
    val title: String,
    val detail: String,
    val isCompleted: Boolean = true,
    val timestamp: String = "Complete"
)

data class SecurityPermissionItem(
    val id: String,
    val name: String,
    val whyNeeded: String,
    val isGranted: Boolean,
    val isCritical: Boolean = true
)
