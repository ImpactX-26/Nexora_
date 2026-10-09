import 'dart:async';
import '../models/agent_settings.dart';
import '../models/chat_models.dart';
import '../models/scan_models.dart';
import '../models/security_score.dart';
import '../models/threat_models.dart';
import '../models/tools_models.dart';
import '../../domain/heuristic_analyzer.dart';
import '../../domain/security_engine.dart';
import 'security_repository.dart';

class MockSecurityRepository implements SecurityRepository {
  late List<ThreatItem> _threats;
  late SecurityScore _score;
  late List<ChatMessage> _chatMessages;
  late List<AppPrivacyInfo> _appPrivacyList;
  late List<MonitoredAccount> _monitoredAccounts;
  late WifiAuditResult _wifiAudit;
  late AgentSettings _agentSettings;

  final _scoreController = StreamController<SecurityScore>.broadcast();
  final _threatsController = StreamController<List<ThreatItem>>.broadcast();
  final _chatController = StreamController<List<ChatMessage>>.broadcast();
  final _appPrivacyController = StreamController<List<AppPrivacyInfo>>.broadcast();
  final _monitoredAccountsController = StreamController<List<MonitoredAccount>>.broadcast();
  final _wifiAuditController = StreamController<WifiAuditResult>.broadcast();
  final _agentSettingsController = StreamController<AgentSettings>.broadcast();

  MockSecurityRepository() {
    _threats = _initialThreats();
    _score = SecurityEngine.computeSecurityScore(_threats);
    _chatMessages = _initialChatMessages();
    _appPrivacyList = _initialAppPrivacyList();
    _monitoredAccounts = _initialMonitoredAccounts();
    _wifiAudit = _initialWifiAudit();
    _agentSettings = const AgentSettings();
  }

  @override
  Stream<SecurityScore> get securityScoreStream => _scoreController.stream;
  @override
  Stream<List<ThreatItem>> get activeThreatsStream => _threatsController.stream;
  @override
  Stream<List<ChatMessage>> get chatMessagesStream => _chatController.stream;
  @override
  Stream<List<AppPrivacyInfo>> get appPrivacyListStream => _appPrivacyController.stream;
  @override
  Stream<List<MonitoredAccount>> get monitoredAccountsStream => _monitoredAccountsController.stream;
  @override
  Stream<WifiAuditResult> get wifiAuditStream => _wifiAuditController.stream;
  @override
  Stream<AgentSettings> get agentSettingsStream => _agentSettingsController.stream;

  @override
  SecurityScore get currentScore => _score;
  @override
  List<ThreatItem> get currentThreats => List.unmodifiable(_threats);
  @override
  List<ChatMessage> get currentChatMessages => List.unmodifiable(_chatMessages);
  @override
  List<AppPrivacyInfo> get currentAppPrivacyList => List.unmodifiable(_appPrivacyList);
  @override
  List<MonitoredAccount> get currentMonitoredAccounts => List.unmodifiable(_monitoredAccounts);
  @override
  WifiAuditResult get currentWifiAudit => _wifiAudit;
  @override
  AgentSettings get currentAgentSettings => _agentSettings;

  @override
  Future<List<ThreatItem>> runSecurityScan({required void Function(ScanProgressState) onProgressUpdate}) async {
    final stages = [
      (ScanStage.initializing, 'Initializing neural weights & rule signatures...'),
      (ScanStage.appPermissions, 'Auditing 48 installed packages for background camera/mic leaks...'),
      (ScanStage.networkIntegrity, 'Testing DNS integrity and ARP broadcast anomalies...'),
      (ScanStage.smsPhishingHeuristics, 'Scanning SMS inbox for urgent banking deception tokens...'),
      (ScanStage.darkWebIdentity, 'Querying 14.2B records in threat intelligence breach feed...'),
      (ScanStage.systemSecurity, 'Inspecting kernel security posture, patch level & SELinux...'),
      (ScanStage.aiSynthesis, 'Synthesizing mitigation playbooks with LEADS Cyber Agent...'),
    ];

    final currentActive = _threats.where((t) => t.status == ThreatStatus.active).toList();

    for (int i = 0; i < stages.length; i++) {
      final (stage, logMsg) = stages[i];
      final progressVal = (i + 1) / (stages.length + 1);
      final state = ScanProgressState(
        status: ScanStatus.scanning,
        currentStage: stage,
        progress: progressVal,
        itemsScannedCount: (i + 1) * 24,
        threatsDiscovered: currentActive,
        logMessages: [logMsg],
      );
      onProgressUpdate(state);
      await Future.delayed(const Duration(milliseconds: 550));
    }

    final finalState = ScanProgressState(
      status: ScanStatus.completed,
      currentStage: ScanStage.completed,
      progress: 1.0,
      itemsScannedCount: 184,
      threatsDiscovered: currentActive,
      logMessages: ['Scan finished: Diagnostic report ready.'],
    );
    onProgressUpdate(finalState);

    _score = SecurityEngine.computeSecurityScore(_threats);
    _scoreController.add(_score);
    return _threats;
  }

  @override
  Future<void> mitigateThreat(String threatId) async {
    _threats = _threats.map((item) {
      if (item.id == threatId) return item.copyWith(status: ThreatStatus.mitigated);
      return item;
    }).toList();
    _score = SecurityEngine.computeSecurityScore(_threats);
    _threatsController.add(List.unmodifiable(_threats));
    _scoreController.add(_score);
  }

  @override
  Future<void> ignoreThreat(String threatId) async {
    _threats = _threats.map((item) {
      if (item.id == threatId) return item.copyWith(status: ThreatStatus.ignored);
      return item;
    }).toList();
    _score = SecurityEngine.computeSecurityScore(_threats);
    _threatsController.add(List.unmodifiable(_threats));
    _scoreController.add(_score);
  }

  @override
  Future<ChatMessage> sendChatMessage(String userText) async {
    final userMsg = ChatMessage(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      text: userText,
      sender: SenderType.user,
    );
    _chatMessages = [..._chatMessages, userMsg];
    _chatController.add(List.unmodifiable(_chatMessages));

    await Future.delayed(const Duration(milliseconds: 700));

    final responseMsg = _generateAgentResponse(userText);
    _chatMessages = [..._chatMessages, responseMsg];
    _chatController.add(List.unmodifiable(_chatMessages));
    return responseMsg;
  }

  @override
  Future<PhishingAnalysisVerdict> analyzeUrlOrSms(String query) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return HeuristicAnalyzer.analyzeTextOrUrl(query);
  }

  @override
  Future<void> revokeAppPermission(String packageName, String permission) async {
    _appPrivacyList = _appPrivacyList.map((app) {
      if (app.packageName == packageName) {
        final remaining = app.dangerousPermissions.where((p) => p != permission).toList();
        final newScore = (app.riskScore - 25).clamp(10, 100);
        final newSeverity = newScore > 60 ? ThreatSeverity.high : (newScore > 30 ? ThreatSeverity.medium : ThreatSeverity.safe);
        return app.copyWith(
          dangerousPermissions: remaining,
          riskScore: newScore,
          riskSeverity: newSeverity,
          aiRiskAnalysis: remaining.isEmpty ? 'All invasive permissions revoked. Application sandboxed.' : app.aiRiskAnalysis,
        );
      }
      return app;
    }).toList();
    _appPrivacyController.add(List.unmodifiable(_appPrivacyList));
  }

  @override
  Future<void> addMonitoredAccount(String emailOrPhone) async {
    final isEmail = emailOrPhone.contains('@');
    final newAccount = MonitoredAccount(
      emailOrPhone: emailOrPhone,
      totalBreachesFound: 1,
      breaches: [
        BreachRecord(
          sourceName: 'Global Intelligence Sync 2026',
          breachDate: 'Jan 2026',
          exposedData: isEmail ? ['Email Address', 'Password Hash', 'IP History'] : ['Phone Number', 'Device IMEI', 'Carrier Metadata'],
          passwordExposed: isEmail,
          recommendedFix: 'Change master password & activate 2FA token generator.',
        ),
      ],
      lastChecked: 'Just now',
    );
    _monitoredAccounts = [newAccount, ..._monitoredAccounts];
    _monitoredAccountsController.add(List.unmodifiable(_monitoredAccounts));
  }

  @override
  Future<void> updateAgentSettings(AgentSettings newSettings) async {
    _agentSettings = newSettings;
    _agentSettingsController.add(_agentSettings);
  }

  ChatMessage _generateAgentResponse(String userText) {
    final lower = userText.toLowerCase();

    if (lower.contains('phish') || lower.contains('sms') || lower.contains('bank')) {
      return ChatMessage(
        id: 'agent_${DateTime.now().millisecondsSinceEpoch}',
        text: 'I detected an active **Coordinated Banking Scam** on your device.\n\nAttack vector breakdown:\n• Spoofed VoIP SMS from `+1 (844) 923-0192`\n• Phishing destination: `wellsfarg0-secure.xyz`\n• Trojan dropper: `wf-verify-auth.apk`\n\nI recommend immediate isolation.',
        sender: SenderType.agent,
        cardData: const ChatCardData(
          type: ChatCardType.threatAlert,
          title: 'Wells Fargo Phishing Campaign',
          subtitle: 'Active credential interception attack',
          severity: ThreatSeverity.critical,
          keyPoints: [
            'Do NOT enter PINs or passwords.',
            'Uninstall \'Bank Auth Helper\' payload.',
            'Report SMS to 7726 carrier spam filter.',
          ],
          actionLabel: 'Isolate Device Now',
          actionPayload: 'isolate_threat',
        ),
        suggestedReplies: [
          'How do I remove the APK?',
          'Scan my device again',
          'Is my password stolen?',
        ],
      );
    } else if (lower.contains('wifi') || lower.contains('network')) {
      return ChatMessage(
        id: 'agent_${DateTime.now().millisecondsSinceEpoch}',
        text: 'Your current network audit for **"Starbucks_Guest_Open"** flagged **Unencrypted 802.11 Traffic**.\n\nWithout WPA3 or VPN encapsulation, neighboring devices on the subnet can sniff unencrypted HTTP requests and DNS lookups.',
        sender: SenderType.agent,
        cardData: const ChatCardData(
          type: ChatCardType.quickFix,
          title: 'Network Encryption Missing',
          subtitle: 'Open Wi-Fi Hotspot',
          severity: ThreatSeverity.medium,
          keyPoints: [
            'Enable LEADS WireGuard VPN tunnel.',
            'Turn off auto-connect for open networks.',
            'Verify HTTPS indicator in browser.',
          ],
          actionLabel: 'Activate DNS Shield',
          actionPayload: 'dns_shield',
        ),
        suggestedReplies: [
          'Audit Wi-Fi Now',
          'Check VPN status',
          'Explain DNS tampering',
        ],
      );
    } else {
      return ChatMessage(
        id: 'agent_${DateTime.now().millisecondsSinceEpoch}',
        text: 'I am **LEADS AI** — your autonomous personal cybersecurity agent. I analyze multi-vector attack chains, inspect suspicious URLs & SMS tokens, audit permissions, and monitor dark web leaks in real-time.\n\nHow can I protect your digital perimeter today?',
        sender: SenderType.agent,
        suggestedReplies: [
          'Analyze a suspicious link',
          'Run full system scan',
          'Check my email for leaks',
          'Audit installed apps',
        ],
      );
    }
  }

  static List<ThreatItem> _initialThreats() {
    return [
      const ThreatItem(
        id: 'threat_01',
        title: 'Banking Phishing Lure via SMS',
        description: 'Received SMS from +1 (844) 923-0192 containing deceptive card-block alert pointing to wellsfarg0-secure.xyz.',
        category: ThreatCategory.phishing,
        severity: ThreatSeverity.critical,
        timestamp: '12 mins ago',
        affectedResource: 'Messages (SMS) • Carrier Gateway',
        remediationSteps: [
          'Do NOT click the SMS link.',
          'Block sender number +1 (844) 923-0192.',
          'Forward text to 7726 (SPAM).',
        ],
        aiExplanation: 'Domain registered 48h ago on bulletproof hosting in Amsterdam. Typosquats Wells Fargo brand.',
      ),
      const ThreatItem(
        id: 'threat_02',
        title: 'Sideloaded Overlay App ("Bank Auth Helper")',
        description: 'App holds SYSTEM_ALERT_WINDOW and accessibility services, capable of drawing credential-stealing screens.',
        category: ThreatCategory.malware,
        severity: ThreatSeverity.critical,
        timestamp: '8 mins ago',
        affectedResource: 'com.auth.bankhelper.sec',
        remediationSteps: [
          'Immediately uninstall application via Settings.',
          'Revoke accessibility permissions.',
          'Inspect bank accounts for unauthorized logins.',
        ],
        aiExplanation: 'Disassembly revealed window-focus listeners specifically targeting banking applications.',
      ),
      const ThreatItem(
        id: 'threat_03',
        title: 'Unencrypted Public Wi-Fi Connection',
        description: 'Connected to Starbucks_Guest_Open with zero encryption, exposing DNS queries to local ARP snooping.',
        category: ThreatCategory.network,
        severity: ThreatSeverity.medium,
        timestamp: '1 hour ago',
        affectedResource: 'Wi-Fi Interface (wlan0)',
        remediationSteps: [
          'Enable LEADS Secure DNS Over HTTPS.',
          'Connect to a trusted VPN before transacting.',
        ],
        aiExplanation: 'Captive portal detected with plain HTTP redirection before login.',
      ),
      const ThreatItem(
        id: 'threat_04',
        title: 'Dark Web Master Credential Spill',
        description: 'Email address matched in 2026 combo list with plaintext password hash exposure.',
        category: ThreatCategory.credentialLeak,
        severity: ThreatSeverity.high,
        timestamp: '2 days ago',
        affectedResource: 'user.personal@gmail.com',
        remediationSteps: [
          'Change password on primary email account.',
          'Enable hardware security key or Authenticator 2FA.',
        ],
        aiExplanation: 'Exposed credentials include full name, birth year, and SHA-1 password hashes.',
      ),
    ];
  }

  static List<ChatMessage> _initialChatMessages() {
    return [
      ChatMessage(
        id: 'msg_welcome',
        text: 'Hello! I am **LEADS AI** — your autonomous personal cybersecurity agent.\n\nI have correlated an active **Coordinated Banking Scam** on your device. You can ask me why it\'s dangerous, what happened in the attack chain, or how to protect yourself.',
        sender: SenderType.agent,
        timestamp: DateTime.now().millisecondsSinceEpoch - 600000,
        suggestedReplies: [
          'What happened?',
          'Why is it dangerous?',
          'How do I protect myself?',
          'Explain APK payload',
        ],
      ),
    ];
  }

  static List<AppPrivacyInfo> _initialAppPrivacyList() {
    return [
      const AppPrivacyInfo(
        appName: 'Bank Auth Helper',
        packageName: 'com.auth.bankhelper.sec',
        category: 'Untrusted Utility (Sideloaded)',
        riskScore: 95,
        riskSeverity: ThreatSeverity.critical,
        dangerousPermissions: [
          'SYSTEM_ALERT_WINDOW (Draw Over Apps)',
          'RECEIVE_SMS (Read 2FA OTPs)',
          'BIND_ACCESSIBILITY_SERVICE',
        ],
        aiRiskAnalysis: 'High malicious probability. Actively attempts to draw fake login overlays on top of banking apps.',
      ),
      const AppPrivacyInfo(
        appName: 'Flashlight Ultra HD',
        packageName: 'com.bright.torch.free',
        category: 'Utility',
        riskScore: 75,
        riskSeverity: ThreatSeverity.high,
        dangerousPermissions: [
          'ACCESS_FINE_LOCATION (Background)',
          'READ_CONTACTS',
          'RECORD_AUDIO',
        ],
        aiRiskAnalysis: 'Excessive permissions requested for a basic torch app. High privacy risk.',
      ),
      const AppPrivacyInfo(
        appName: 'Photo Effects Pro',
        packageName: 'com.image.fxpro.edit',
        category: 'Photography',
        riskScore: 45,
        riskSeverity: ThreatSeverity.medium,
        dangerousPermissions: [
          'READ_MEDIA_IMAGES',
          'ACCESS_NETWORK_STATE',
        ],
        aiRiskAnalysis: 'Standard photo editing app permissions. Moderate background analytics traffic.',
      ),
      const AppPrivacyInfo(
        appName: 'Pro Signal Messenger',
        packageName: 'org.thoughtcrime.securesms',
        category: 'Communication',
        riskScore: 10,
        riskSeverity: ThreatSeverity.safe,
        dangerousPermissions: [
          'CAMERA',
          'RECORD_AUDIO',
        ],
        aiRiskAnalysis: 'Verified end-to-end encrypted messaging. Strict zero-knowledge architecture.',
      ),
    ];
  }

  static List<MonitoredAccount> _initialMonitoredAccounts() {
    return [
      const MonitoredAccount(
        emailOrPhone: 'user.personal@gmail.com',
        totalBreachesFound: 2,
        lastChecked: '12 mins ago',
        breaches: [
          BreachRecord(
            sourceName: 'Global Travel Booking Portal Spill',
            breachDate: 'Nov 2025',
            exposedData: ['Email', 'Password Hash', 'Full Name', 'Phone Number'],
            passwordExposed: true,
            recommendedFix: 'Change password on all sites reusing this credential.',
          ),
          BreachRecord(
            sourceName: 'Retail Rewards DB Leak',
            breachDate: 'May 2024',
            exposedData: ['Email', 'Billing ZIP Code', 'Order History'],
            passwordExposed: false,
            recommendedFix: 'Monitor credit card alerts for unexpected micro-transactions.',
          ),
        ],
      ),
      const MonitoredAccount(
        emailOrPhone: '+1 (555) 349-2049',
        totalBreachesFound: 1,
        lastChecked: '1 hour ago',
        breaches: [
          BreachRecord(
            sourceName: 'Telecom Marketing Directory',
            breachDate: 'Aug 2025',
            exposedData: ['Phone Number', 'Carrier Details', 'City'],
            passwordExposed: false,
            recommendedFix: 'Enable strict vishing / robocall spam filters.',
          ),
        ],
      ),
    ];
  }

  static WifiAuditResult _initialWifiAudit() {
    return const WifiAuditResult(
      ssid: 'Starbucks_Guest_Open',
      bssid: '8C:3B:AD:12:4F:90',
      encryptionType: 'None (Open 802.11b/g/n)',
      signalStrength: 82,
      isCaptivePortal: true,
      isDnsTamperingDetected: false,
      isArpSpoofingDetected: false,
      overallSafety: ThreatSeverity.medium,
      advice: 'Open network without WPA3 encryption. Never log into financial portals without LEADS VPN Shield active.',
    );
  }
}
