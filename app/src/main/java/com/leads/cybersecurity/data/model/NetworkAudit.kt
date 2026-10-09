package com.leads.cybersecurity.data.model

data class WifiAuditResult(
    val ssid: String,
    val securityProtocol: String, // e.g. WPA3, WPA2, Open
    val isPublicUnencrypted: Boolean,
    val isDnsTamperingDetected: Boolean,
    val isArpPoisoningDetected: Boolean,
    val isCaptivePortalDeception: Boolean,
    val overallSafety: ThreatSeverity,
    val gatewayIp: String,
    val dnsServer: String,
    val aiNetworkAnalysis: String
)
