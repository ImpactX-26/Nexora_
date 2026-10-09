import 'dart:async';
import '../models/agent_settings.dart';
import '../models/chat_models.dart';
import '../models/coordinated_incident.dart';
import '../models/scan_models.dart';
import '../models/security_score.dart';
import 'incident_repository.dart';

class MockIncidentRepository implements IncidentRepository {
  late CoordinatedIncident _primaryIncident;
  late final List<CoordinatedIncident> _allIncidents;
  late final List<SecurityPermissionItem> _allPermissions;
  late final List<ChatMessage> _allChatMessages;
  ScanProgressState _currentScanState = const ScanProgressState();
  late SecurityScore _currentScore;

  final _incidentController = StreamController<CoordinatedIncident>.broadcast();
  final _incidentsListController = StreamController<List<CoordinatedIncident>>.broadcast();
  final _permissionsController = StreamController<List<SecurityPermissionItem>>.broadcast();
  final _chatController = StreamController<List<ChatMessage>>.broadcast();
  final _scanStateController = StreamController<ScanProgressState>.broadcast();
  final _scoreController = StreamController<SecurityScore>.broadcast();

  MockIncidentRepository() {
    _primaryIncident = createCoordinatedBankingScamIncident();
    _allIncidents = [
      _primaryIncident,
      createSecondaryIsolatedAnomaly(),
      createTertiaryResolvedIncident(),
    ];
    _allPermissions = [
      const SecurityPermissionItem(
        id: 'perm_sms',
        name: 'Messages (SMS)',
        whyNeeded: 'Analyzes incoming SMS for urgent phishing patterns and deceptive banking links.',
        isGranted: true,
      ),
      const SecurityPermissionItem(
        id: 'perm_notif',
        name: 'Notifications',
        whyNeeded: 'Delivers instantaneous threat intervention alerts when high-risk links or APKs are detected.',
        isGranted: true,
      ),
      const SecurityPermissionItem(
        id: 'perm_files',
        name: 'Files & Downloads',
        whyNeeded: 'Inspects downloaded APK file signatures and hashes against known threat intelligence feeds.',
        isGranted: false,
      ),
      const SecurityPermissionItem(
        id: 'perm_apps',
        name: 'Installed Apps',
        whyNeeded: 'Detects sideloaded applications holding excessive background permissions or banking overlay traps.',
        isGranted: true,
      ),
      const SecurityPermissionItem(
        id: 'perm_calls',
        name: 'Calls & Vishing Signals',
        whyNeeded: 'Flags incoming numbers correlated with active telecom spoofing and social engineering campaigns.',
        isGranted: false,
      ),
    ];
    _allChatMessages = [
      ChatMessage(
        id: 'msg_init_01',
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
    _currentScore = const SecurityScore(
      overallScore: 92,
      maxScore: 100,
      healthStatus: HealthStatus.good,
      networkScore: 96,
      privacyScore: 84,
      identityScore: 90,
      systemScore: 98,
      activeThreatsCount: 1,
      mitigatedThreatsCount: 8,
      lastScanTime: '12 mins ago',
    );
  }

  @override
  Stream<CoordinatedIncident> get currentIncidentStream => _incidentController.stream;
  @override
  Stream<List<CoordinatedIncident>> get incidentsListStream => _incidentsListController.stream;
  @override
  Stream<List<SecurityPermissionItem>> get permissionsStream => _permissionsController.stream;
  @override
  Stream<List<ChatMessage>> get chatMessagesStream => _chatController.stream;
  @override
  Stream<ScanProgressState> get manualScanStateStream => _scanStateController.stream;
  @override
  Stream<SecurityScore> get securityScoreStream => _scoreController.stream;

  @override
  CoordinatedIncident get currentIncident => _primaryIncident;
  @override
  List<CoordinatedIncident> get incidentsList => List.unmodifiable(_allIncidents);
  @override
  List<SecurityPermissionItem> get permissions => List.unmodifiable(_allPermissions);
  @override
  List<ChatMessage> get chatMessages => List.unmodifiable(_allChatMessages);
  @override
  ScanProgressState get manualScanState => _currentScanState;
  @override
  SecurityScore get securityScore => _currentScore;

  @override
  Future<CoordinatedIncident?> getIncidentById(String id) async {
    return _allIncidents.firstWhere((i) => i.id == id, orElse: () => _primaryIncident);
  }

  @override
  Future<void> togglePermission(String permissionId, bool isGranted) async {
    final index = _allPermissions.indexWhere((p) => p.id == permissionId);
    if (index != -1) {
      _allPermissions[index] = _allPermissions[index].copyWith(isGranted: isGranted);
      _permissionsController.add(List.unmodifiable(_allPermissions));
    }
  }

  @override
  Future<void> markActionCompleted(String actionId) async {
    final updatedActions = _primaryIncident.recommendedActions.map((action) {
      if (action.id == actionId) {
        return action.copyWith(isCompleted: true);
      }
      return action;
    }).toList();

    _primaryIncident = _primaryIncident.copyWith(recommendedActions: updatedActions);
    _incidentController.add(_primaryIncident);
  }

  @override
  Future<void> resetAllActions() async {
    final updatedActions = _primaryIncident.recommendedActions.map((action) {
      return action.copyWith(isCompleted: false);
    }).toList();

    _primaryIncident = _primaryIncident.copyWith(recommendedActions: updatedActions);
    _incidentController.add(_primaryIncident);
  }

  @override
  Future<ChatMessage> askAiAssistant(String userPrompt) async {
    final userMsg = ChatMessage(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      text: userPrompt,
      sender: SenderType.user,
    );
    _allChatMessages.add(userMsg);
    _chatController.add(List.unmodifiable(_allChatMessages));

    await Future.delayed(const Duration(milliseconds: 650));

    final reply = _generateResponse(userPrompt);
    final agentMsg = ChatMessage(
      id: 'agent_${DateTime.now().millisecondsSinceEpoch}',
      text: reply,
      sender: SenderType.agent,
      suggestedReplies: [
        'How do I uninstall the APK?',
        'Verify my phone permissions',
        'Show attack timeline',
      ],
    );
    _allChatMessages.add(agentMsg);
    _chatController.add(List.unmodifiable(_allChatMessages));
    return agentMsg;
  }

  String _generateResponse(String query) {
    final lower = query.toLowerCase();
    if (lower.contains('why') || lower.contains('dangerous') || lower.contains('risk')) {
      return '⚠️ **Why This Attack is Extremely High Risk (94/100):**\n\n'
          '1. **Multi-Vector Correlation**: The attackers aren\'t relying on SMS alone. They synchronized a phishing link with a **sideloaded APK** and a spoofed incoming call.\n'
          '2. **Banking Overlay Capture**: The payload `wf-verify-auth.apk` requests accessibility permissions to draw invisible overlay screens over your real banking app.\n'
          '3. **High Automation**: The domain was registered just 48 hours ago on bulletproof hosting in the Netherlands.';
    } else if (lower.contains('happen') || lower.contains('timeline') || lower.contains('what')) {
      return '🔍 **Attack Sequence Summary:**\n\n'
          '• **10:42 AM**: You received an urgent SMS claiming card suspension.\n'
          '• **10:44 AM**: Link redirected to `wellsfarg0-secure.xyz`.\n'
          '• **10:47 AM**: Site prompted download of `wf-verify-auth.apk`.\n'
          '• **10:49 AM**: Malicious package installed as \'Bank Auth Helper\'.\n'
          '• **10:53 AM**: Follow-up spoofed call arrived seeking OTP confirmation.\n'
          '• **10:55 AM**: LEADS correlated all vectors into a single coordinated campaign.';
    } else if (lower.contains('do') || lower.contains('action') || lower.contains('protect')) {
      return '🛡️ **Immediate Protection Steps:**\n\n'
          '1. **Do NOT open** `wellsfarg0-secure.xyz` or click SMS links.\n'
          '2. **Uninstall \'Bank Auth Helper\'** immediately via Android App Settings.\n'
          '3. **Never share OTPs** or 2FA codes with anyone on incoming calls.\n'
          '4. **Call Wells Fargo directly** using the official phone number printed on the back of your physical card.\n'
          '5. **Forward the SMS** to 7726 (SPAM).';
    } else {
      return 'I am actively monitoring the **Coordinated Banking Scam** (Risk: 94/100 CRITICAL). I can explain the attack chain, breakdown why the domain and APK are malicious, or guide you through safe remediation.';
    }
  }

  @override
  Future<void> startManualScan({required void Function(ScanProgressState) onProgress}) async {
    final stages = [
      (ScanStage.initializing, 'Initializing neural weights & rule signatures...'),
      (ScanStage.appPermissions, 'Auditing installed packages for background camera/mic leaks...'),
      (ScanStage.networkIntegrity, 'Testing DNS integrity and ARP broadcast anomalies...'),
      (ScanStage.smsPhishingHeuristics, 'Scanning SMS inbox for urgent banking deception tokens...'),
      (ScanStage.darkWebIdentity, 'Querying 14.2B records in threat intelligence breach feed...'),
      (ScanStage.systemSecurity, 'Inspecting kernel security posture, patch level & SELinux...'),
      (ScanStage.aiSynthesis, 'Synthesizing mitigation playbooks with LEADS Cyber Agent...'),
    ];

    for (int i = 0; i < stages.length; i++) {
      final (stage, log) = stages[i];
      _currentScanState = ScanProgressState(
        status: ScanStatus.scanning,
        currentStage: stage,
        progress: (i + 1) / (stages.length + 1),
        itemsScannedCount: (i + 1) * 26,
        logMessages: [log],
      );
      onProgress(_currentScanState);
      _scanStateController.add(_currentScanState);
      await Future.delayed(const Duration(milliseconds: 550));
    }

    _currentScanState = const ScanProgressState(
      status: ScanStatus.completed,
      currentStage: ScanStage.completed,
      progress: 1.0,
      itemsScannedCount: 182,
      logMessages: ['Scan complete: Diagnostic telemetry synchronized.'],
    );
    onProgress(_currentScanState);
    _scanStateController.add(_currentScanState);
  }

  static CoordinatedIncident createCoordinatedBankingScamIncident() {
    const nodes = [
      GraphNode(
        id: 'node_sms',
        type: NodeType.sms,
        label: 'Urgent Bank SMS',
        subtitle: '+1 (844) 923-0192',
        severity: ThreatSeverityLevel.critical,
        riskContribution: 15,
        xRatio: 0.20,
        yRatio: 0.18,
        attributes: {
          'Sender': '+1 (844) 923-0192',
          'Content': 'Urgent: Card blocked. Verify now.',
          'Urgency': 'High',
        },
      ),
      GraphNode(
        id: 'node_phone',
        type: NodeType.phoneNumber,
        label: '+1 (844) 923-0192',
        subtitle: 'VoIP Spoofed Gateway',
        severity: ThreatSeverityLevel.high,
        riskContribution: 10,
        xRatio: 0.08,
        yRatio: 0.38,
        attributes: {
          'Carrier': 'Bandwidth VoIP',
          'Reputation': 'Known Robocaller',
        },
      ),
      GraphNode(
        id: 'node_url',
        type: NodeType.url,
        label: 'Phishing URL',
        subtitle: 'wellsfarg0-secure.xyz/login',
        severity: ThreatSeverityLevel.critical,
        riskContribution: 25,
        xRatio: 0.48,
        yRatio: 0.22,
        attributes: {
          'Protocol': 'HTTP/HTTPS',
          'Path': '/auth/verify-token',
        },
      ),
      GraphNode(
        id: 'node_domain',
        type: NodeType.domain,
        label: 'wellsfarg0-secure.xyz',
        subtitle: 'Registered 48h ago',
        severity: ThreatSeverityLevel.critical,
        riskContribution: 20,
        xRatio: 0.78,
        yRatio: 0.16,
        attributes: {
          'Registrar': 'NameCheap Inc',
          'Creation Date': '2 days ago',
          'Typosquat': 'Wells Fargo',
        },
      ),
      GraphNode(
        id: 'node_ip',
        type: NodeType.ipAddress,
        label: '185.220.101.42',
        subtitle: 'Bulletproof Host (NL)',
        severity: ThreatSeverityLevel.high,
        riskContribution: 10,
        xRatio: 0.90,
        yRatio: 0.42,
        attributes: {
          'ASN': 'AS206804',
          'Country': 'Netherlands',
          'Abuse Score': '98%',
        },
      ),
      GraphNode(
        id: 'node_apk',
        type: NodeType.apkDownload,
        label: 'wf-verify-auth.apk',
        subtitle: 'Trojan Payload (Sideloaded)',
        severity: ThreatSeverityLevel.critical,
        riskContribution: 25,
        xRatio: 0.42,
        yRatio: 0.60,
        attributes: {
          'Hash': 'e83b8a109f...',
          'Signature': 'Untrusted Self-Signed',
        },
      ),
      GraphNode(
        id: 'node_app',
        type: NodeType.application,
        label: 'Bank Auth Helper',
        subtitle: 'Holding Overlay Permission',
        severity: ThreatSeverityLevel.critical,
        riskContribution: 20,
        xRatio: 0.70,
        yRatio: 0.68,
        attributes: {
          'Package': 'com.auth.bankhelper.sec',
          'Permissions': 'SYSTEM_ALERT_WINDOW, READ_SMS',
        },
      ),
      GraphNode(
        id: 'node_target',
        type: NodeType.targetBank,
        label: 'Wells Fargo Client',
        subtitle: 'Target Financial Account',
        severity: ThreatSeverityLevel.suspicious,
        riskContribution: 5,
        xRatio: 0.50,
        yRatio: 0.88,
        attributes: {
          'Institution': 'Wells Fargo Bank',
          'Objective': 'Credential & OTP Exfiltration',
        },
      ),
    ];

    const edges = [
      GraphEdge(fromNodeId: 'node_phone', toNodeId: 'node_sms', relationship: EdgeRelationship.contains, label: 'originated'),
      GraphEdge(fromNodeId: 'node_sms', toNodeId: 'node_url', relationship: EdgeRelationship.contains, label: 'contains link'),
      GraphEdge(fromNodeId: 'node_url', toNodeId: 'node_domain', relationship: EdgeRelationship.resolvesTo, label: 'hosts on'),
      GraphEdge(fromNodeId: 'node_domain', toNodeId: 'node_ip', relationship: EdgeRelationship.resolvesTo, label: 'resolves to IP'),
      GraphEdge(fromNodeId: 'node_url', toNodeId: 'node_apk', relationship: EdgeRelationship.redirectsTo, label: 'prompts APK download'),
      GraphEdge(fromNodeId: 'node_apk', toNodeId: 'node_app', relationship: EdgeRelationship.installs, label: 'sideloads'),
      GraphEdge(fromNodeId: 'node_app', toNodeId: 'node_target', relationship: EdgeRelationship.targets, label: 'injects overlay on'),
    ];

    const timeline = [
      TimelineEventItem(
        id: 'evt_1',
        time: '10:42 AM',
        title: 'Deceptive SMS Received',
        description: 'Received SMS from +1 (844) 923-0192 stating: "Wells Fargo Alert: Card locked due to unusual activity. Unlock: wellsfarg0-secure.xyz"',
        severity: ThreatSeverityLevel.critical,
        type: NodeType.sms,
      ),
      TimelineEventItem(
        id: 'evt_2',
        time: '10:44 AM',
        title: 'Typosquat Domain Contacted',
        description: 'Browser navigated to wellsfarg0-secure.xyz (registered 48 hours ago in Netherlands).',
        severity: ThreatSeverityLevel.critical,
        type: NodeType.domain,
      ),
      TimelineEventItem(
        id: 'evt_3',
        time: '10:47 AM',
        title: 'Untrusted APK Download Triggered',
        description: 'Web page forced download of wf-verify-auth.apk posing as official bank verification tool.',
        severity: ThreatSeverityLevel.critical,
        type: NodeType.apkDownload,
      ),
      TimelineEventItem(
        id: 'evt_4',
        time: '10:49 AM',
        title: 'Overlay Trojan Installed',
        description: 'User initiated installation of package com.auth.bankhelper.sec holding dangerous overlay permissions.',
        severity: ThreatSeverityLevel.critical,
        type: NodeType.application,
      ),
      TimelineEventItem(
        id: 'evt_5',
        time: '10:53 AM',
        title: 'Follow-Up Vishing Call Attempt',
        description: 'Incoming call from same VoIP gateway +1 (844) 923-0192 attempting OTP social engineering.',
        severity: ThreatSeverityLevel.high,
        type: NodeType.callSignal,
      ),
    ];

    const evidenceList = [
      EvidenceArtifact(
        id: 'ev_1',
        label: 'SMS Text Payload',
        value: 'Wells Fargo: Account suspended. Resolve immediately at https://wellsfarg0-secure.xyz/auth/verify',
        source: 'Android SMS Gateway',
        timestamp: '10:42 AM',
        severity: ThreatSeverityLevel.critical,
      ),
      EvidenceArtifact(
        id: 'ev_2',
        label: 'Typosquat Hostname',
        value: 'wellsfarg0-secure.xyz (IP: 185.220.101.42)',
        source: 'DNS Telemetry & WHOIS',
        timestamp: '10:44 AM',
        severity: ThreatSeverityLevel.critical,
      ),
      EvidenceArtifact(
        id: 'ev_3',
        label: 'APK SHA-256 Hash',
        value: 'e83b8a109f02c918374a2b10938f61203948572a19b8c746201f928374a1029c',
        source: 'File Download Watcher',
        timestamp: '10:47 AM',
        severity: ThreatSeverityLevel.critical,
      ),
      EvidenceArtifact(
        id: 'ev_4',
        label: 'Dangerous Permission Request',
        value: 'SYSTEM_ALERT_WINDOW (Draw over other apps)',
        source: 'Package Manager Audit',
        timestamp: '10:49 AM',
        severity: ThreatSeverityLevel.critical,
      ),
    ];

    const recommendedActions = [
      RecommendedActionItem(
        id: 'act_1',
        title: 'Uninstall "Bank Auth Helper"',
        description: 'Remove malicious sideloaded APK containing screen overlay keylogger.',
        urgency: ThreatSeverityLevel.critical,
        buttonLabel: 'Uninstall App',
        targetComponent: 'AppManager',
      ),
      RecommendedActionItem(
        id: 'act_2',
        title: 'Block Sender & Report SMS',
        description: 'Block +1 (844) 923-0192 and report spam text to cellular carrier (7726).',
        urgency: ThreatSeverityLevel.high,
        buttonLabel: 'Block Number',
        targetComponent: 'SmsBlocker',
      ),
      RecommendedActionItem(
        id: 'act_3',
        title: 'Reset Banking Password',
        description: 'Change credentials from a known secure device if typed into phishing portal.',
        urgency: ThreatSeverityLevel.high,
        buttonLabel: 'Open Official Bank Site',
        targetComponent: 'Browser',
      ),
      RecommendedActionItem(
        id: 'act_4',
        title: 'Verify 2FA Authenticator',
        description: 'Ensure hardware or app-based 2FA is active rather than SMS OTP.',
        urgency: ThreatSeverityLevel.suspicious,
        buttonLabel: 'Configure 2FA',
        targetComponent: 'SecuritySettings',
      ),
    ];

    const investigationSteps = [
      InvestigationStep(
        stepNumber: 1,
        title: 'Multi-Signal Correlation Engine',
        analysis: 'LEADS matched the SMS sender phone number directly with the caller ID of a VoIP robo-dialer.',
        findings: 'Confirmed synchronized social engineering campaign targeting Wells Fargo customer credentials.',
      ),
      InvestigationStep(
        stepNumber: 2,
        title: 'Threat Intelligence Domain Heuristics',
        analysis: 'Analyzed WHOIS records, SSL cert issuer, and reverse DNS on wellsfarg0-secure.xyz.',
        findings: 'Domain is 48 hours old, hosted on known bulletproof server cluster in Amsterdam (AS206804).',
      ),
      InvestigationStep(
        stepNumber: 3,
        title: 'Static APK Disassembly & Permission Extraction',
        analysis: 'Extracted AndroidManifest.xml from wf-verify-auth.apk.',
        findings: 'Discovered covert overlay injection payload targeting `com.wf.wellsfargomobile` window focus.',
      ),
    ];

    return const CoordinatedIncident(
      id: 'inc_bank_001',
      title: 'Coordinated Banking Phishing & Overlay Attack',
      summary: 'Correlated SMS phishing lure, typosquatted domain, malicious sideloaded APK, and follow-up spoofed VoIP call actively attempting banking credential theft.',
      overallRiskScore: 94,
      severity: ThreatSeverityLevel.critical,
      status: ThreatStatusCategory.activeCampaign,
      detectedTimestamp: 'Detected 12m ago',
      nodes: nodes,
      edges: edges,
      timeline: timeline,
      evidenceList: evidenceList,
      recommendedActions: recommendedActions,
      investigationSteps: investigationSteps,
      attackVector: 'SMS -> Typosquat Web -> Sideloaded Overlay APK',
      confidenceScore: '99.4% (Neural Correlation Engine)',
    );
  }

  static CoordinatedIncident createSecondaryIsolatedAnomaly() {
    return const CoordinatedIncident(
      id: 'inc_net_002',
      title: 'Rogue Public Wi-Fi DNS Hijack',
      summary: 'Connected network "Starbucks_Free_Guest" injected altered DNS entries routing payment gateways through a local MITM proxy.',
      overallRiskScore: 68,
      severity: ThreatSeverityLevel.high,
      status: ThreatStatusCategory.isolatedAnomaly,
      detectedTimestamp: 'Detected 2h ago',
      nodes: [],
      edges: [],
      timeline: [],
      evidenceList: [],
      recommendedActions: [],
      investigationSteps: [],
      attackVector: 'Unencrypted 802.11 ARP / DNS Spoofing',
      confidenceScore: '94.2%',
    );
  }

  static CoordinatedIncident createTertiaryResolvedIncident() {
    return const CoordinatedIncident(
      id: 'inc_old_003',
      title: 'Dark Web Credential Spill Alert',
      summary: 'Primary email matched in 2026 data leak containing hashed passwords and phone numbers.',
      overallRiskScore: 42,
      severity: ThreatSeverityLevel.suspicious,
      status: ThreatStatusCategory.resolved,
      detectedTimestamp: 'Resolved 3 days ago',
      nodes: [],
      edges: [],
      timeline: [],
      evidenceList: [],
      recommendedActions: [],
      investigationSteps: [],
      attackVector: 'Third-Party Database Breach',
      confidenceScore: '100%',
    );
  }
}
