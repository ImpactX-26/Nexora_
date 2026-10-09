package com.leads.cybersecurity.data.repository

import com.leads.cybersecurity.data.model.*
import com.leads.cybersecurity.domain.HeuristicAnalyzer
import com.leads.cybersecurity.domain.PhishingAnalysisVerdict
import com.leads.cybersecurity.domain.SecurityEngine
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow
import java.util.UUID

class MockSecurityRepository : SecurityRepository {

    private val _threats = MutableStateFlow(initialThreats())
    private val _score = MutableStateFlow(SecurityEngine.computeSecurityScore(_threats.value))
    private val _chatMessages = MutableStateFlow(initialChatMessages())
    private val _appPrivacyList = MutableStateFlow(initialAppPrivacyList())
    private val _monitoredAccounts = MutableStateFlow(initialMonitoredAccounts())
    private val _wifiAudit = MutableStateFlow(initialWifiAudit())
    private val _agentSettings = MutableStateFlow(AgentSettings())

    private val fastApiBackend = FastApiBackendService()

    override val securityScoreFlow: Flow<SecurityScore> = _score.asStateFlow()
    override val activeThreatsFlow: Flow<List<ThreatItem>> = _threats.asStateFlow()
    override val chatMessagesFlow: Flow<List<ChatMessage>> = _chatMessages.asStateFlow()
    override val appPrivacyListFlow: Flow<List<AppPrivacyInfo>> = _appPrivacyList.asStateFlow()
    override val monitoredAccountsFlow: Flow<List<MonitoredAccount>> = _monitoredAccounts.asStateFlow()
    override val wifiAuditFlow: Flow<WifiAuditResult> = _wifiAudit.asStateFlow()
    override val agentSettingsFlow: Flow<AgentSettings> = _agentSettings.asStateFlow()

    override suspend fun runSecurityScan(onProgressUpdate: (ScanProgressState) -> Unit): List<ThreatItem> {
        val stages = listOf(
            ScanStage.INITIALIZING to "Initializing neural weights & rule signatures...",
            ScanStage.APP_PERMISSIONS to "Auditing 48 installed packages for background camera/mic leaks...",
            ScanStage.NETWORK_INTEGRITY to "Testing DNS integrity and ARP broadcast anomalies...",
            ScanStage.SMS_PHISHING_HEURISTICS to "Scanning SMS inbox for urgent banking deception tokens...",
            ScanStage.DARK_WEB_IDENTITY to "Querying 14.2B records in threat intelligence breach feed...",
            ScanStage.SYSTEM_SECURITY to "Inspecting kernel security posture, patch level & SELinux...",
            ScanStage.AI_SYNTHESIS to "Synthesizing mitigation playbooks with LEADS Cyber Agent..."
        )

        val total = stages.size
        var currentThreats = _threats.value.filter { it.status == ThreatStatus.ACTIVE }.toMutableList()

        for ((index, stagePair) in stages.withIndex()) {
            val (stage, logMsg) = stagePair
            val progressVal = (index + 1).toFloat() / (total + 1)
            onProgressUpdate(
                ScanProgressState(
                    status = ScanStatus.SCANNING,
                    currentStage = stage,
                    progress = progressVal,
                    itemsScannedCount = (index + 1) * 24,
                    threatsDiscovered = currentThreats,
                    logMessages = listOf(logMsg)
                )
            )
            delay(650)
        }

        // Final completion stage
        onProgressUpdate(
            ScanProgressState(
                status = ScanStatus.COMPLETED,
                currentStage = ScanStage.COMPLETED,
                progress = 1.0f,
                itemsScannedCount = 184,
                threatsDiscovered = currentThreats,
                logMessages = listOf("Scan finished: Diagnostic report ready.")
            )
        )

        _score.value = SecurityEngine.computeSecurityScore(_threats.value)
        return _threats.value
    }

    override suspend fun mitigateThreat(threatId: String) {
        val updated = _threats.value.map { item ->
            if (item.id == threatId) item.copy(status = ThreatStatus.MITIGATED) else item
        }
        _threats.value = updated
        _score.value = SecurityEngine.computeSecurityScore(updated)
    }

    override suspend fun ignoreThreat(threatId: String) {
        val updated = _threats.value.map { item ->
            if (item.id == threatId) item.copy(status = ThreatStatus.IGNORED) else item
        }
        _threats.value = updated
        _score.value = SecurityEngine.computeSecurityScore(updated)
    }

    override suspend fun sendChatMessage(userText: String): ChatMessage {
        val userMsg = ChatMessage(
            id = UUID.randomUUID().toString(),
            text = userText,
            sender = SenderType.USER
        )
        _chatMessages.value = _chatMessages.value + userMsg

        // Simulate agent reasoning delay
        delay(800)

        val responseMsg = generateAgentResponse(userText)
        _chatMessages.value = _chatMessages.value + responseMsg
        return responseMsg
    }

    override suspend fun analyzeUrlOrSms(query: String): PhishingAnalysisVerdict {
        delay(500)
        return HeuristicAnalyzer.analyzeTextOrUrl(query)
    }

    override suspend fun revokeAppPermission(packageName: String, permission: String) {
        val updated = _appPrivacyList.value.map { app ->
            if (app.packageName == packageName) {
                val remaining = app.dangerousPermissions.filter { it != permission }
                val newScore = (app.riskScore - 25).coerceAtLeast(10)
                app.copy(
                    dangerousPermissions = remaining,
                    riskScore = newScore,
                    riskSeverity = if (newScore < 30) ThreatSeverity.LOW else ThreatSeverity.MEDIUM
                )
            } else app
        }
        _appPrivacyList.value = updated
    }

    override suspend fun addMonitoredAccount(emailOrPhone: String) {
        val newAccount = MonitoredAccount(
            id = UUID.randomUUID().toString(),
            identifier = emailOrPhone,
            status = BreachStatus.SAFE,
            totalBreachesFound = 0,
            breaches = emptyList(),
            lastAuditedDate = "Just now"
        )
        _monitoredAccounts.value = _monitoredAccounts.value + newAccount
    }

    override suspend fun auditCurrentWifi(): WifiAuditResult {
        delay(700)
        return _wifiAudit.value
    }

    override suspend fun updateSettings(settings: AgentSettings) {
        _agentSettings.value = settings
    }

    override suspend fun testBackendConnection(endpoint: String): Boolean {
        val isUp = fastApiBackend.pingBackend(endpoint)
        _agentSettings.value = _agentSettings.value.copy(
            fastApiServerUrl = endpoint,
            isBackendConnected = isUp
        )
        return isUp
    }

    private fun generateAgentResponse(input: String): ChatMessage {
        val lower = input.lowercase()
        val verdict = HeuristicAnalyzer.analyzeTextOrUrl(input)

        val isCheckingPhishing = lower.contains("http") || lower.contains("phish") || lower.contains("sms") || lower.contains("link") || lower.contains("verify") || lower.contains("bank")
        val isCheckingWifi = lower.contains("wifi") || lower.contains("wi-fi") || lower.contains("hotel") || lower.contains("coffee") || lower.contains("network")
        val isCheckingPermissions = lower.contains("permission") || lower.contains("camera") || lower.contains("microphone") || lower.contains("privacy") || lower.contains("app")
        val isCheckingScore = lower.contains("score") || lower.contains("health") || lower.contains("status") || lower.contains("threat")

        return when {
            isCheckingPhishing && verdict.isPhishing -> {
                ChatMessage(
                    id = UUID.randomUUID().toString(),
                    text = "🚨 **Malicious Phishing Detected!**\nI examined this content using our neural heuristic engine. The message exhibits high-urgency psychological manipulation and attempts deceptive credential harvesting.",
                    sender = SenderType.AGENT,
                    cardData = MessageCardData(
                        type = CardType.THREAT_VERDICT,
                        title = "Phishing Verdict: Block Recommended",
                        subtitle = "Risk Score: ${verdict.riskScore}/100",
                        severity = verdict.riskSeverity,
                        keyPoints = verdict.detectedTactics + verdict.deceptiveIndicators,
                        actionLabel = "One-Tap Block Sender"
                    )
                )
            }
            isCheckingWifi -> {
                ChatMessage(
                    id = UUID.randomUUID().toString(),
                    text = "🛡️ **Network Security Assessment:**\nPublic and unencrypted Wi-Fi networks allow attackers to perform Man-In-The-Middle (MITM) attacks and DNS spoofing.",
                    sender = SenderType.AGENT,
                    cardData = MessageCardData(
                        type = CardType.REMEDIATION_CHECKLIST,
                        title = "Public Wi-Fi Safety Guide",
                        subtitle = "Target Network: StarCoffee-Guest (Open)",
                        severity = ThreatSeverity.HIGH,
                        keyPoints = listOf(
                            "Avoid accessing banking apps on open networks",
                            "Enable DNS-over-HTTPS (DoH) in LEADS settings",
                            "Turn off automatic Wi-Fi reconnect",
                            "Verify HTTPS padlock in all browsers"
                        ),
                        actionLabel = "Activate DNS Armor"
                    )
                )
            }
            isCheckingPermissions -> {
                ChatMessage(
                    id = UUID.randomUUID().toString(),
                    text = "🔍 **App Privacy Audit:**\nI discovered 2 background applications requesting sensitive device capabilities (SMS read & Background Microphone) without clear functional justification.",
                    sender = SenderType.AGENT,
                    cardData = MessageCardData(
                        type = CardType.REMEDIATION_CHECKLIST,
                        title = "High-Risk App Permissions",
                        subtitle = "Flagged: FastClean Master Pro & FlashTool",
                        severity = ThreatSeverity.MEDIUM,
                        keyPoints = listOf(
                            "Revoke 'READ_SMS' from FlashTool",
                            "Deny background location to FastClean",
                            "Enable Android scoped storage isolation"
                        ),
                        actionLabel = "Review Permissions"
                    )
                )
            }
            isCheckingScore -> {
                val scoreVal = _score.value.overallScore
                ChatMessage(
                    id = UUID.randomUUID().toString(),
                    text = "📊 **Current Security Posture:**\nYour device cyber health is currently rated at **$scoreVal/100** (${_score.value.healthStatus.label}).\n\nThere are ${_score.value.activeThreatsCount} active vulnerabilities requiring your attention.",
                    sender = SenderType.AGENT,
                    cardData = MessageCardData(
                        type = CardType.INFO_NOTICE,
                        title = "Health Summary",
                        subtitle = "Last scanned: ${_score.value.lastScanTime}",
                        severity = if (scoreVal < 70) ThreatSeverity.HIGH else ThreatSeverity.LOW,
                        keyPoints = listOf(
                            "Network Shield: ${_score.value.networkScore}%",
                            "Privacy Shield: ${_score.value.privacyScore}%",
                            "Dark Web Identity: ${_score.value.identityScore}%",
                            "System Integrity: ${_score.value.systemScore}%"
                        ),
                        actionLabel = "Start Deep Scan"
                    )
                )
            }
            else -> {
                ChatMessage(
                    id = UUID.randomUUID().toString(),
                    text = "I am **LEADS Cyber Agent**, your autonomous security co-pilot. I actively monitor phishing attacks, analyze suspicious URLs/SMS, audit app privacy leaks, and verify network integrity.\n\nHow can I protect you right now?",
                    sender = SenderType.AGENT
                )
            }
        }
    }

    private fun initialThreats(): List<ThreatItem> = listOf(
        ThreatItem(
            id = "threat-01",
            title = "Deceptive Bank Smishing Campaign",
            description = "SMS received containing urgent spoofed URL masquerading as official Wells Fargo verification portal.",
            category = ThreatCategory.PHISHING,
            severity = ThreatSeverity.CRITICAL,
            timestamp = "12 mins ago",
            affectedResource = "SMS: +1 (844) 923-0192",
            remediationSteps = listOf(
                "Block and report sender number",
                "Do not click or open URL 'wellsfarg0-secure.xyz'",
                "Enable LEADS SMS proactive interception filter"
            ),
            aiExplanation = "Attacker utilized zero-width Unicode characters and high-frequency urgency tokens to bypass standard spam filters."
        ),
        ThreatItem(
            id = "threat-02",
            title = "Unencrypted Open Wi-Fi Network",
            description = "Connected to 'StarCoffee_Guest' with no WPA2/WPA3 encryption, allowing cleartext packet interception.",
            category = ThreatCategory.NETWORK,
            severity = ThreatSeverity.HIGH,
            timestamp = "45 mins ago",
            affectedResource = "SSID: StarCoffee_Guest",
            remediationSteps = listOf(
                "Disconnect from open Wi-Fi or turn on encrypted tunnel",
                "Disable automatic network rejoin in Android Settings",
                "Enforce Secure DNS (DoH/DoT)"
            ),
            aiExplanation = "Open wireless access points are vulnerable to Evil Twin hotspots and ARP cache poisoning attacks."
        ),
        ThreatItem(
            id = "threat-03",
            title = "Over-privileged Sideloaded Utility",
            description = "App 'Flashlight Plus' holds active READ_SMS and READ_CONTACTS background permissions.",
            category = ThreatCategory.PRIVACY,
            severity = ThreatSeverity.MEDIUM,
            timestamp = "2 hours ago",
            affectedResource = "com.utility.brightflashlight",
            remediationSteps = listOf(
                "Revoke SMS & Contact permissions via App Privacy Guard",
                "Uninstall unverified APK"
            ),
            aiExplanation = "A flashlight utility has zero legitimate technical requirement to read customer address books or incoming SMS OTPs."
        )
    )

    private fun initialChatMessages(): List<ChatMessage> = listOf(
        ChatMessage(
            id = "welcome-01",
            text = "👋 Welcome! I am **LEADS AI** — your autonomous personal cybersecurity agent.\n\nI am continuously monitoring your device posture. Paste any suspicious link or text message, or ask me for a security audit anytime.",
            sender = SenderType.AGENT,
            timestamp = System.currentTimeMillis() - 600000
        )
    )

    private fun initialAppPrivacyList(): List<AppPrivacyInfo> = listOf(
        AppPrivacyInfo(
            packageName = "com.utility.brightflashlight",
            appName = "Flashlight Plus Pro",
            category = "Tools",
            riskScore = 88,
            riskSeverity = ThreatSeverity.CRITICAL,
            dangerousPermissions = listOf("READ_SMS", "READ_CONTACTS", "ACCESS_FINE_LOCATION"),
            trackerCount = 5,
            backgroundAccess = true,
            isFlaggedSuspicious = true,
            aiRiskAnalysis = "Dangerous permission mismatch. Unverified analytics trackers transmitting location metadata in background."
        ),
        AppPrivacyInfo(
            packageName = "com.cleaner.speedbooster",
            appName = "Turbo Memory Cleaner",
            category = "Utilities",
            riskScore = 72,
            riskSeverity = ThreatSeverity.HIGH,
            dangerousPermissions = listOf("SYSTEM_ALERT_WINDOW", "QUERY_ALL_PACKAGES"),
            trackerCount = 3,
            backgroundAccess = true,
            isFlaggedSuspicious = true,
            aiRiskAnalysis = "Draws over other applications and queries installed banking software."
        ),
        AppPrivacyInfo(
            packageName = "com.social.chatpulse",
            appName = "ChatPulse Messenger",
            category = "Communication",
            riskScore = 32,
            riskSeverity = ThreatSeverity.LOW,
            dangerousPermissions = listOf("CAMERA", "RECORD_AUDIO", "READ_CONTACTS"),
            trackerCount = 1,
            backgroundAccess = false,
            isFlaggedSuspicious = false,
            aiRiskAnalysis = "Permissions align with standard messaging app capabilities."
        ),
        AppPrivacyInfo(
            packageName = "com.finance.securebank",
            appName = "First Horizon Mobile",
            category = "Finance",
            riskScore = 12,
            riskSeverity = ThreatSeverity.SAFE,
            dangerousPermissions = listOf("USE_BIOMETRIC"),
            trackerCount = 0,
            backgroundAccess = false,
            isFlaggedSuspicious = false,
            aiRiskAnalysis = "Hardened banking application adhering to standard security best practices."
        )
    )

    private fun initialMonitoredAccounts(): List<MonitoredAccount> = listOf(
        MonitoredAccount(
            id = "acc-01",
            identifier = "user.cyber@leads-defense.io",
            status = BreachStatus.COMPROMISED,
            totalBreachesFound = 2,
            breaches = listOf(
                BreachRecord(
                    id = "br-01",
                    sourceName = "Canva Data Leak",
                    breachDate = "May 2024",
                    exposedData = listOf("Email Address", "Bcrypt Password Hashes", "Username"),
                    passwordExposed = true,
                    severity = ThreatSeverity.HIGH,
                    description = "137 million customer records exposed containing salted bcrypt hashes.",
                    recommendedFix = "Rotate password immediately and activate 2-factor authentication."
                ),
                BreachRecord(
                    id = "br-02",
                    sourceName = "FitnessApp Cloud Storage",
                    breachDate = "Nov 2024",
                    exposedData = listOf("Email", "GPS Workout Tracks"),
                    passwordExposed = false,
                    severity = ThreatSeverity.MEDIUM,
                    description = "Misconfigured S3 bucket exposed telemetry coordinates.",
                    recommendedFix = "Review active connected third-party integrations."
                )
            ),
            lastAuditedDate = "Today, 14:30"
        ),
        MonitoredAccount(
            id = "acc-02",
            identifier = "+1 (555) 382-9011",
            status = BreachStatus.SAFE,
            totalBreachesFound = 0,
            breaches = emptyList(),
            lastAuditedDate = "Today, 14:30"
        )
    )

    private fun initialWifiAudit(): WifiAuditResult = WifiAuditResult(
        ssid = "StarCoffee_Guest",
        securityProtocol = "Open (None / Unencrypted)",
        isPublicUnencrypted = true,
        isDnsTamperingDetected = false,
        isArpPoisoningDetected = true,
        isCaptivePortalDeception = false,
        overallSafety = ThreatSeverity.HIGH,
        gatewayIp = "192.168.4.1",
        dnsServer = "8.8.8.8 (Google Public)",
        aiNetworkAnalysis = "ARP broadcast flooding observed from IP 192.168.4.28. High risk of local session sniffing and credential interception."
    )
}
