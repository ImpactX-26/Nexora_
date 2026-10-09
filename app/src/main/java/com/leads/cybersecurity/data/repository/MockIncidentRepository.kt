package com.leads.cybersecurity.data.repository

import com.leads.cybersecurity.data.model.*
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow
import java.util.UUID

class MockIncidentRepository : IncidentRepository {

    private val primaryIncident = createCoordinatedBankingScamIncident()

    private val _currentIncident = MutableStateFlow(primaryIncident)
    private val _incidentsList = MutableStateFlow(listOf(
        primaryIncident,
        createSecondaryIsolatedAnomaly(),
        createTertiaryResolvedIncident()
    ))

    private val _permissions = MutableStateFlow(listOf(
        SecurityPermissionItem(
            id = "perm_sms",
            name = "Messages (SMS)",
            whyNeeded = "Analyzes incoming SMS for urgent phishing patterns and deceptive banking links.",
            isGranted = true
        ),
        SecurityPermissionItem(
            id = "perm_notif",
            name = "Notifications",
            whyNeeded = "Delivers instantaneous threat intervention alerts when high-risk links or APKs are detected.",
            isGranted = true
        ),
        SecurityPermissionItem(
            id = "perm_files",
            name = "Files & Downloads",
            whyNeeded = "Inspects downloaded APK file signatures and hashes against known threat intelligence feeds.",
            isGranted = false
        ),
        SecurityPermissionItem(
            id = "perm_apps",
            name = "Installed Apps",
            whyNeeded = "Detects sideloaded applications holding excessive background permissions or banking overlay traps.",
            isGranted = true
        ),
        SecurityPermissionItem(
            id = "perm_calls",
            name = "Calls & Vishing Signals",
            whyNeeded = "Flags incoming numbers correlated with active telecom spoofing and social engineering campaigns.",
            isGranted = false
        )
    ))

    private val _chatMessages = MutableStateFlow(listOf(
        ChatMessage(
            id = "msg_init_01",
            text = "Hello! I am **LEADS AI** — your autonomous personal cybersecurity agent.\n\nI have correlated an active **Coordinated Banking Scam** on your device. You can ask me why it's dangerous, what happened in the attack chain, or how to protect yourself.",
            sender = SenderType.AGENT,
            timestamp = System.currentTimeMillis() - 600000
        )
    ))

    private val _manualScanState = MutableStateFlow(ScanProgressState())
    private val _securityScore = MutableStateFlow(
        SecurityScore(
            overallScore = 92,
            maxScore = 100,
            healthStatus = HealthStatus.GOOD,
            networkScore = 96,
            privacyScore = 84,
            identityScore = 90,
            systemScore = 98,
            activeThreatsCount = 1,
            mitigatedThreatsCount = 8,
            lastScanTime = "12 mins ago"
        )
    )

    override val currentIncidentFlow: Flow<CoordinatedIncident> = _currentIncident.asStateFlow()
    override val incidentsListFlow: Flow<List<CoordinatedIncident>> = _incidentsList.asStateFlow()
    override val permissionsFlow: Flow<List<SecurityPermissionItem>> = _permissions.asStateFlow()
    override val chatMessagesFlow: Flow<List<ChatMessage>> = _chatMessages.asStateFlow()
    override val manualScanStateFlow: Flow<ScanProgressState> = _manualScanState.asStateFlow()
    override val securityScoreFlow: Flow<SecurityScore> = _securityScore.asStateFlow()

    override suspend fun getIncidentById(id: String): CoordinatedIncident? {
        return _incidentsList.value.find { it.id == id } ?: _currentIncident.value
    }

    override suspend fun togglePermission(permissionId: String, isGranted: Boolean) {
        val updated = _permissions.value.map { item ->
            if (item.id == permissionId) item.copy(isGranted = isGranted) else item
        }
        _permissions.value = updated
    }

    override suspend fun markActionCompleted(actionId: String) {
        val current = _currentIncident.value
        val updatedActions = current.recommendedActions.map { action ->
            if (action.id == actionId) action.copy(isCompleted = true) else action
        }
        _currentIncident.value = current.copy(recommendedActions = updatedActions)
    }

    override suspend fun sendAssistantQuery(userPrompt: String): ChatMessage {
        val userMsg = ChatMessage(
            id = UUID.randomUUID().toString(),
            text = userPrompt,
            sender = SenderType.USER
        )
        _chatMessages.value = _chatMessages.value + userMsg

        delay(700)

        val responseText = generateContextualAssistantReply(userPrompt)
        val agentMsg = ChatMessage(
            id = UUID.randomUUID().toString(),
            text = responseText,
            sender = SenderType.AGENT
        )
        _chatMessages.value = _chatMessages.value + agentMsg
        return agentMsg
    }

    override suspend fun runManualScan(scanType: String, onProgress: (ScanProgressState) -> Unit): CoordinatedIncident {
        val stages = listOf(
            ScanStage.INITIALIZING to "Initializing heuristics & signature caches...",
            ScanStage.SMS_PHISHING_HEURISTICS to "Inspecting SMS vectors for urgent spoofing tokens...",
            ScanStage.NETWORK_INTEGRITY to "Cross-referencing domain infrastructure & bulletproof IPs...",
            ScanStage.APP_PERMISSIONS to "Auditing sideloaded APK payload hash 'wf-verify-auth.apk'...",
            ScanStage.AI_SYNTHESIS to "Synthesizing ScamGraph correlations across 6 entities..."
        )

        for ((index, stage) in stages.withIndex()) {
            val progress = (index + 1).toFloat() / (stages.size + 1)
            val state = ScanProgressState(
                status = ScanStatus.SCANNING,
                currentStage = stage.first,
                progress = progress,
                itemsScannedCount = (index + 1) * 36,
                threatsDiscovered = emptyList(),
                logMessages = listOf(stage.second)
            )
            _manualScanState.value = state
            onProgress(state)
            delay(500)
        }

        val completedState = ScanProgressState(
            status = ScanStatus.COMPLETED,
            currentStage = ScanStage.COMPLETED,
            progress = 1.0f,
            itemsScannedCount = 184,
            threatsDiscovered = emptyList(),
            logMessages = listOf("Scan complete: Coordinated Banking Scam correlation updated.")
        )
        _manualScanState.value = completedState
        onProgress(completedState)
        return _currentIncident.value
    }

    private fun generateContextualAssistantReply(input: String): String {
        val lower = input.lowercase()
        return when {
            lower.contains("why") && (lower.contains("danger") || lower.contains("risk")) -> {
                "⚠️ **Why This Attack is Extremely Dangerous:**\n\n1. **Multi-Vector Coordination**: This isn't just spam. The attacker combined an SMS alert, a typosquatted domain (`wellsfarg0-secure.xyz`), a malicious APK token generator, and an incoming voice call.\n2. **Credential & OTP Interception**: The installed APK requests background SMS permissions specifically to siphon real-time bank OTPs while the scam caller keeps you distracted.\n3. **Financial Compromise**: The end objective is unauthorized takeover of your Wells Fargo accounts."
            }
            lower.contains("score") || lower.contains("94") -> {
                "📊 **Risk Score Breakdown (94 / 100 — CRITICAL):**\n\n• **Suspicious URL**: +25 (Unregistered path requesting authentication)\n• **Malicious APK Payload**: +25 (Trojan banker signature match)\n• **Domain Age & Reputation**: +20 (Registered 2 days ago on bulletproof host)\n• **Sender Impersonation**: +15 (Spoofed Wells Fargo security alert)\n• **ScamGraph Multi-Entity Linkage**: +9 (6 independent signals converge on one target)\n\nTotal Risk: **94/100**."
            }
            lower.contains("happen") || lower.contains("timeline") || lower.contains("what") -> {
                "🔍 **Attack Sequence Summary:**\n\n• **10:42 AM**: You received an urgent SMS claiming card suspension.\n• **10:44 AM**: Link redirected to `wellsfarg0-secure.xyz`.\n• **10:47 AM**: Site prompted download of `wf-verify-auth.apk`.\n• **10:49 AM**: Malicious package installed as 'Bank Auth Helper'.\n• **10:53 AM**: Follow-up spoofed call arrived seeking OTP confirmation.\n• **10:55 AM**: LEADS correlated all vectors into a single coordinated campaign."
            }
            lower.contains("do") || lower.contains("action") || lower.contains("protect") -> {
                "🛡️ **Immediate Protection Steps:**\n\n1. **Do NOT open** `wellsfarg0-secure.xyz` or click SMS links.\n2. **Uninstall 'Bank Auth Helper'** immediately via Android App Settings.\n3. **Never share OTPs** or 2FA codes with anyone on incoming calls.\n4. **Call Wells Fargo directly** using the official phone number printed on the back of your physical card.\n5. **Forward the SMS** to 7726 (SPAM)."
            }
            else -> {
                "I am monitoring the active **Coordinated Banking Scam** (Risk: 94/100 CRITICAL). I can explain the attack chain, breakdown why the domain and APK are malicious, or guide you through safe remediation."
            }
        }
    }

    companion object {
        fun createCoordinatedBankingScamIncident(): CoordinatedIncident {
            val nodes = listOf(
                GraphNode(
                    id = "node_sms",
                    type = NodeType.SMS,
                    label = "Urgent Bank SMS",
                    subtitle = "+1 (844) 923-0192",
                    severity = ThreatSeverityLevel.CRITICAL,
                    riskContribution = 15,
                    xRatio = 0.20f,
                    yRatio = 0.18f,
                    attributes = mapOf("Sender" to "+1 (844) 923-0192", "Content" to "Urgent: Card blocked. Verify now.", "Urgency" to "High")
                ),
                GraphNode(
                    id = "node_phone",
                    type = NodeType.PHONE_NUMBER,
                    label = "+1 (844) 923-0192",
                    subtitle = "VoIP Spoofed Gateway",
                    severity = ThreatSeverityLevel.HIGH,
                    riskContribution = 10,
                    xRatio = 0.08f,
                    yRatio = 0.35f,
                    attributes = mapOf("Carrier" to "Bandwidth VoIP", "Reputation" to "Known Robocaller")
                ),
                GraphNode(
                    id = "node_url",
                    type = NodeType.URL,
                    label = "Phishing URL",
                    subtitle = "wellsfarg0-secure.xyz/login",
                    severity = ThreatSeverityLevel.CRITICAL,
                    riskContribution = 25,
                    xRatio = 0.45f,
                    yRatio = 0.25f,
                    attributes = mapOf("Protocol" to "HTTP/HTTPS", "Path" to "/auth/verify-token")
                ),
                GraphNode(
                    id = "node_domain",
                    type = NodeType.DOMAIN,
                    label = "wellsfarg0-secure.xyz",
                    subtitle = "Registered 48h ago",
                    severity = ThreatSeverityLevel.CRITICAL,
                    riskContribution = 20,
                    xRatio = 0.72f,
                    yRatio = 0.18f,
                    attributes = mapOf("Registrar" to "NameCheap Inc", "Creation Date" to "2 days ago", "Typosquat" to "Wells Fargo")
                ),
                GraphNode(
                    id = "node_ip",
                    type = NodeType.IP_ADDRESS,
                    label = "185.220.101.42",
                    subtitle = "Bulletproof Host (NL)",
                    severity = ThreatSeverityLevel.HIGH,
                    riskContribution = 10,
                    xRatio = 0.90f,
                    yRatio = 0.38f,
                    attributes = mapOf("ASN" to "AS206804", "Country" to "Netherlands", "Abuse Score" to "98%")
                ),
                GraphNode(
                    id = "node_apk",
                    type = NodeType.APK_DOWNLOAD,
                    label = "wf-verify-auth.apk",
                    subtitle = "Trojan Payload (Sideloaded)",
                    severity = ThreatSeverityLevel.CRITICAL,
                    riskContribution = 25,
                    xRatio = 0.40f,
                    yRatio = 0.58f,
                    attributes = mapOf("Hash" to "e83b8a109f...", "Signature" to "Untrusted Self-Signed")
                ),
                GraphNode(
                    id = "node_app",
                    type = NodeType.APPLICATION,
                    label = "Bank Auth Helper",
                    subtitle = "com.bank.auth.helper",
                    severity = ThreatSeverityLevel.CRITICAL,
                    riskContribution = 20,
                    xRatio = 0.65f,
                    yRatio = 0.68f,
                    attributes = mapOf("Permissions" to "READ_SMS, RECEIVE_BOOT_COMPLETED", "Status" to "Background Active")
                ),
                GraphNode(
                    id = "node_call",
                    type = NodeType.CALL_SIGNAL,
                    label = "Spoofed Vishing Call",
                    subtitle = "+1 (800) 869-3557 (Fake)",
                    severity = ThreatSeverityLevel.HIGH,
                    riskContribution = 15,
                    xRatio = 0.15f,
                    yRatio = 0.72f,
                    attributes = mapOf("Caller ID" to "Wells Fargo Fraud", "Tactic" to "OTP Harvesting Pressure")
                ),
                GraphNode(
                    id = "node_bank",
                    type = NodeType.TARGET_BANK,
                    label = "Wells Fargo Accounts",
                    subtitle = "Target Asset",
                    severity = ThreatSeverityLevel.CRITICAL,
                    riskContribution = 0,
                    xRatio = 0.50f,
                    yRatio = 0.90f,
                    attributes = mapOf("Entity" to "Financial Institution", "Protected" to "LEADS Guard Active")
                )
            )

            val edges = listOf(
                GraphEdge("node_phone", "node_sms", EdgeRelationship.PART_OF),
                GraphEdge("node_sms", "node_url", EdgeRelationship.CONTAINS),
                GraphEdge("node_url", "node_domain", EdgeRelationship.REDIRECTS_TO),
                GraphEdge("node_domain", "node_ip", EdgeRelationship.RESOLVES_TO),
                GraphEdge("node_url", "node_apk", EdgeRelationship.INSTALLS),
                GraphEdge("node_apk", "node_app", EdgeRelationship.RELATED_TO),
                GraphEdge("node_call", "node_sms", EdgeRelationship.RELATED_TO),
                GraphEdge("node_app", "node_bank", EdgeRelationship.TARGETS),
                GraphEdge("node_call", "node_bank", EdgeRelationship.TARGETS)
            )

            val timeline = listOf(
                TimelineEvent(
                    id = "tl_1",
                    time = "10:42 AM",
                    title = "Suspicious SMS received",
                    description = "Incoming message from unverified VoIP sender +1 (844) 923-0192 posing as Wells Fargo Fraud Prevention.",
                    category = NodeType.SMS,
                    severity = ThreatSeverityLevel.CRITICAL,
                    indicatorText = "SMS text: \"Wells Fargo Alert: Card blocked due to suspicious charge. Verify identity immediately: http://wellsfarg0-secure.xyz\""
                ),
                TimelineEvent(
                    id = "tl_2",
                    time = "10:44 AM",
                    title = "Suspicious URL detected",
                    description = "Browser requested destination link 'wellsfarg0-secure.xyz'. LEADS flagged deceptive typosquatting.",
                    category = NodeType.URL,
                    severity = ThreatSeverityLevel.CRITICAL,
                    indicatorText = "Domain registered 48 hours ago in Russia; hosted on bulletproof proxy IP 185.220.101.42."
                ),
                TimelineEvent(
                    id = "tl_3",
                    time = "10:47 AM",
                    title = "APK downloaded",
                    description = "Phishing landing page prompted user to download fake 'security update' package wf-verify-auth.apk.",
                    category = NodeType.APK_DOWNLOAD,
                    severity = ThreatSeverityLevel.CRITICAL,
                    indicatorText = "File hash matched known Cerberus/Alien banking trojan signature database."
                ),
                TimelineEvent(
                    id = "tl_4",
                    time = "10:49 AM",
                    title = "APK installed",
                    description = "Sideloaded application 'Bank Auth Helper' (com.bank.auth.helper) requested broad SMS reading capabilities.",
                    category = NodeType.APPLICATION,
                    severity = ThreatSeverityLevel.CRITICAL,
                    indicatorText = "App holds READ_SMS & SYSTEM_ALERT_WINDOW to intercept banking 2FA codes."
                ),
                TimelineEvent(
                    id = "tl_5",
                    time = "10:53 AM",
                    title = "Suspicious call / social engineering signal",
                    description = "Incoming voice call spoofing the official Wells Fargo customer helpline (+1-800-869-3557).",
                    category = NodeType.CALL_SIGNAL,
                    severity = ThreatSeverityLevel.HIGH,
                    indicatorText = "Attacker pressured victim to read back the incoming SMS verification token."
                ),
                TimelineEvent(
                    id = "tl_6",
                    time = "10:54 AM",
                    title = "LEADS correlated activity",
                    description = "LEADS neural correlation engine linked SMS, domain infrastructure, APK payload, and spoofed call into a single unified graph.",
                    category = NodeType.INCIDENT,
                    severity = ThreatSeverityLevel.HIGH,
                    indicatorText = "ScamGraph identified 6 linked entities targeting the same banking credentials.",
                    isCorrelatedByLeads = true
                ),
                TimelineEvent(
                    id = "tl_7",
                    time = "10:55 AM",
                    title = "Coordinated banking scam identified",
                    description = "Automated defense posture elevated to CRITICAL (94/100). Protective countermeasures and mitigation playbook generated.",
                    category = NodeType.INCIDENT,
                    severity = ThreatSeverityLevel.CRITICAL,
                    indicatorText = "Active multi-vector attack confirmed. Recommended actions ready for user review.",
                    isCorrelatedByLeads = true
                )
            )

            val evidence = listOf(
                EvidenceItem(
                    id = "ev_1",
                    title = "Bank Brand Impersonation",
                    detail = "SMS headers, message text, and web styling directly clone Wells Fargo brand identity without authorization.",
                    source = "SMS Header & Landing DOM Analysis",
                    confidenceScore = 99,
                    severity = ThreatSeverityLevel.CRITICAL,
                    technicalTags = listOf("Impersonation", "Zero-Width Spaces", "Urgency Cues")
                ),
                EvidenceItem(
                    id = "ev_2",
                    title = "Typosquatted Domain (wellsfarg0-secure.xyz)",
                    detail = "Replaces letter 'o' with number '0'. Domain registered 2 days ago via anonymous Russian registrar on bulletproof host 185.220.101.42.",
                    source = "WHOIS & Passive DNS Intelligence",
                    confidenceScore = 96,
                    severity = ThreatSeverityLevel.CRITICAL,
                    technicalTags = listOf("Typosquatting", "Bulletproof IP", "New Domain")
                ),
                EvidenceItem(
                    id = "ev_3",
                    title = "Banking Trojan APK Signature",
                    detail = "Package 'com.bank.auth.helper' requests READ_SMS and RECEIVE_BOOT_COMPLETED to intercept incoming SMS OTP codes.",
                    source = "Static Manifest & Hash Analysis",
                    confidenceScore = 95,
                    severity = ThreatSeverityLevel.CRITICAL,
                    technicalTags = listOf("Trojan:Android/BankBot", "Privilege Abuse", "Overlay Trap")
                ),
                EvidenceItem(
                    id = "ev_4",
                    title = "Telecom Spoofing & Vishing Signal",
                    detail = "Incoming caller ID matches official Wells Fargo support (+1-800-869-3557) but originates from an unverified VoIP trunk.",
                    source = "Call Signal Telemetry",
                    confidenceScore = 88,
                    severity = ThreatSeverityLevel.HIGH,
                    technicalTags = listOf("Caller ID Spoofing", "Social Engineering", "Vishing")
                )
            )

            val riskFactors = listOf(
                RiskFactor("Suspicious URL", 25, "Deceptive login path designed for credential harvesting", ThreatSeverityLevel.CRITICAL),
                RiskFactor("APK Indicators", 25, "Known banking trojan permissions to read 2FA OTP codes", ThreatSeverityLevel.CRITICAL),
                RiskFactor("Domain Reputation", 20, "Brand-new domain hosted on bulletproof anonymous infrastructure", ThreatSeverityLevel.HIGH),
                RiskFactor("Sender Impersonation", 15, "VoIP spoofing mimicking official Wells Fargo fraud department", ThreatSeverityLevel.HIGH),
                RiskFactor("Graph Correlation", 9, "6 independent attack vectors mathematically linked to single campaign", ThreatSeverityLevel.CRITICAL)
            )

            val actions = listOf(
                ProtectionAction(
                    id = "act_1",
                    stepNumber = 1,
                    title = "Do not open the suspicious URL",
                    description = "Avoid accessing 'wellsfarg0-secure.xyz' or entering passwords. LEADS has blocked domain access.",
                    isSupportedPlatformAction = true,
                    actionButtonText = "Block Domain"
                ),
                ProtectionAction(
                    id = "act_2",
                    stepNumber = 2,
                    title = "Remove the suspicious APK",
                    description = "Uninstall 'Bank Auth Helper' (com.bank.auth.helper) immediately to stop background SMS reads.",
                    isSupportedPlatformAction = true,
                    actionButtonText = "Open App Settings"
                ),
                ProtectionAction(
                    id = "act_3",
                    stepNumber = 3,
                    title = "Do not share OTP or credentials",
                    description = "Never provide verification codes or card PINs to incoming callers, even if they claim to be from the fraud department.",
                    isSupportedPlatformAction = false,
                    actionButtonText = null
                ),
                ProtectionAction(
                    id = "act_4",
                    stepNumber = 4,
                    title = "Contact your bank through official channel",
                    description = "Call Wells Fargo directly using the telephone number printed on the back of your physical debit/credit card.",
                    isSupportedPlatformAction = true,
                    actionButtonText = "Call Official Number"
                ),
                ProtectionAction(
                    id = "act_5",
                    stepNumber = 5,
                    title = "Report the suspicious message",
                    description = "Forward the fraudulent SMS to 7726 (SPAM) to aid global carrier blocking efforts.",
                    isSupportedPlatformAction = true,
                    actionButtonText = "Forward to 7726"
                )
            )

            val stages = listOf(
                InvestigationStage("stg_1", "Message analyzed", "SMS tokens examined; urgent credential harvest cue identified."),
                InvestigationStage("stg_2", "URL investigated", "Deceptive destination link 'wellsfarg0-secure.xyz' unmasked."),
                InvestigationStage("stg_3", "Domain analyzed", "WHOIS & DNS telemetry resolved to bulletproof server 185.220.101.42."),
                InvestigationStage("stg_4", "APK analyzed", "Static analysis matched trojan signatures and excessive SMS read capabilities."),
                InvestigationStage("stg_5", "Related entities correlated", "ScamGraph mapped connection between SMS, URL, APK, and spoofed call."),
                InvestigationStage("stg_6", "Campaign identified", "Confirmed coordinated banking scam targeting Wells Fargo customers."),
                InvestigationStage("stg_7", "Risk calculated", "Computed comprehensive risk rating of 94/100 (CRITICAL).")
            )

            return CoordinatedIncident(
                id = "inc_banking_01",
                title = "Coordinated Banking Scam",
                subtitle = "SMS, phishing URL and APK appear to be related",
                category = ThreatStatusCategory.ACTIVE_CAMPAIGN,
                severity = ThreatSeverityLevel.CRITICAL,
                overallRiskScore = 94,
                summary = "SMS, phishing URL, and sideloaded APK appear to be related. The attacker orchestrated an SMS alert, a deceptive typosquatted domain, a banking trojan APK, and a spoofed incoming call to compromise Wells Fargo credentials.",
                aiSecuritySummary = "LEADS identified multiple related indicators suggesting that the SMS, URL, and APK are part of the same coordinated banking scam. Rather than isolated events, the attacker built an end-to-end credential and OTP interception pipeline.",
                targetBrand = "Wells Fargo",
                detectedTimestamp = "Today, 10:55 AM",
                nodes = nodes,
                edges = edges,
                timeline = timeline,
                evidenceList = evidence,
                riskFactors = riskFactors,
                recommendedActions = actions,
                investigationStages = stages
            )
        }

        private fun createSecondaryIsolatedAnomaly(): CoordinatedIncident {
            return CoordinatedIncident(
                id = "inc_anomaly_02",
                title = "Untrusted Wi-Fi Captive Portal",
                subtitle = "Unencrypted public hotspot anomaly",
                category = ThreatStatusCategory.ISOLATED_ANOMALY,
                severity = ThreatSeverityLevel.SUSPICIOUS,
                overallRiskScore = 48,
                summary = "Connected to open network 'CoffeeShop_Guest' with no WPA encryption and anomalous gateway DNS.",
                aiSecuritySummary = "Isolated network anomaly. No related APK or phishing SMS signals detected in association with this network.",
                targetBrand = "Public Network",
                detectedTimestamp = "Yesterday, 4:15 PM",
                nodes = emptyList(),
                edges = emptyList(),
                timeline = emptyList(),
                evidenceList = emptyList(),
                riskFactors = emptyList(),
                recommendedActions = emptyList(),
                investigationStages = emptyList()
            )
        }

        private fun createTertiaryResolvedIncident(): CoordinatedIncident {
            return CoordinatedIncident(
                id = "inc_resolved_03",
                title = "Fake Delivery Tracking Phish",
                subtitle = "Resolved delivery smishing link",
                category = ThreatStatusCategory.RESOLVED,
                severity = ThreatSeverityLevel.SAFE,
                overallRiskScore = 12,
                summary = "SMS claiming missed USPS parcel was blocked and sender blacklisted.",
                aiSecuritySummary = "Phishing domain blocked and neutralized. Zero persistence on device.",
                targetBrand = "USPS",
                detectedTimestamp = "Oct 3, 2026",
                nodes = emptyList(),
                edges = emptyList(),
                timeline = emptyList(),
                evidenceList = emptyList(),
                riskFactors = emptyList(),
                recommendedActions = emptyList(),
                investigationStages = emptyList()
            )
        }
    }
}
