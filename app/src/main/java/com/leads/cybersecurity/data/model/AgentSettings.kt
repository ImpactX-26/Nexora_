package com.leads.cybersecurity.data.model

enum class ProtectionMode(val displayName: String, val description: String) {
    AUTONOMOUS("Autonomous Defense", "LEADS automatically isolates threats, blocks deceptive links, and hardens DNS in real time."),
    BALANCED("Balanced Guard", "Prompts the user with one-tap mitigation recommendations for medium and high threats."),
    HIGH_PARANOIA("Maximum Paranoia", "Strictest heuristics: flags all untrusted Wi-Fi, aggressive domain entropy checks, and background app scrutiny."),
    MONITOR_ONLY("Passive Sentinel", "Logs security telemetry without active alerts or system suggestions.")
}

data class AgentSettings(
    val protectionMode: ProtectionMode = ProtectionMode.AUTONOMOUS,
    val fastApiServerUrl: String = "http://10.0.2.2:8000", // standard android emulator localhost
    val isBackendConnected: Boolean = false,
    val autoScanIntervalHours: Int = 12,
    val realTimePhishingShieldEnabled: Boolean = true,
    val darkWebWatchEnabled: Boolean = true,
    val rogueWifiDetectionEnabled: Boolean = true,
    val appPermissionAnomalyAlerts: Boolean = true,
    val biometricUnlockRequired: Boolean = false
)
