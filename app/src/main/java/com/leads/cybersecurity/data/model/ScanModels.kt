package com.leads.cybersecurity.data.model

enum class ScanStage(val title: String, val description: String) {
    INITIALIZING("Initializing Agent", "Calibrating neural security models..."),
    APP_PERMISSIONS("Auditing Applications", "Scanning for sideloaded apps & permission leaks..."),
    NETWORK_INTEGRITY("Network Diagnostics", "Verifying Wi-Fi encryption, DNS & ARP integrity..."),
    SMS_PHISHING_HEURISTICS("Phishing & Smishing Engine", "Analyzing deceptive links & SMS patterns..."),
    DARK_WEB_IDENTITY("Dark Web Breach Index", "Querying leaked credentials and exposed PII..."),
    SYSTEM_SECURITY("Kernel & Device Posture", "Validating SELinux, boot integrity & patch level..."),
    AI_SYNTHESIS("AI Threat Synthesis", "Compiling actionable mitigation strategies..."),
    COMPLETED("Scan Finished", "All diagnostic layers completed successfully.")
}

enum class ScanStatus {
    IDLE,
    SCANNING,
    COMPLETED,
    FAILED
}

data class ScanProgressState(
    val status: ScanStatus = ScanStatus.IDLE,
    val currentStage: ScanStage = ScanStage.INITIALIZING,
    val progress: Float = 0f, // 0.0 to 1.0
    val itemsScannedCount: Int = 0,
    val threatsDiscovered: List<ThreatItem> = emptyList(),
    val logMessages: List<String> = emptyList()
)
