import 'threat_models.dart';

enum ScanStage {
  idle('IDLE', 'Scanner ready'),
  initializing('INITIALIZING', 'Initializing neural weights & rule signatures...'),
  appPermissions('APP_PERMISSIONS', 'Auditing installed packages for background camera/mic leaks...'),
  networkIntegrity('NETWORK_INTEGRITY', 'Testing DNS integrity and ARP broadcast anomalies...'),
  smsPhishingHeuristics('SMS_PHISHING', 'Scanning SMS inbox for urgent banking deception tokens...'),
  darkWebIdentity('DARK_WEB', 'Querying 14.2B records in threat intelligence breach feed...'),
  systemSecurity('SYSTEM_SECURITY', 'Inspecting kernel security posture, patch level & SELinux...'),
  aiSynthesis('AI_SYNTHESIS', 'Synthesizing mitigation playbooks with LEADS Cyber Agent...'),
  completed('COMPLETED', 'Scan Complete: All perimeters analyzed.');

  final String code;
  final String description;
  const ScanStage(this.code, this.description);
}

enum ScanStatus {
  idle,
  scanning,
  completed,
  failed;
}

class ScanProgressState {
  final ScanStatus status;
  final ScanStage currentStage;
  final double progress; // 0.0 to 1.0
  final int itemsScannedCount;
  final List<ThreatItem> threatsDiscovered;
  final List<String> logMessages;

  const ScanProgressState({
    this.status = ScanStatus.idle,
    this.currentStage = ScanStage.idle,
    this.progress = 0.0,
    this.itemsScannedCount = 0,
    this.threatsDiscovered = const [],
    this.logMessages = const [],
  });

  ScanProgressState copyWith({
    ScanStatus? status,
    ScanStage? currentStage,
    double? progress,
    int? itemsScannedCount,
    List<ThreatItem>? threatsDiscovered,
    List<String>? logMessages,
  }) {
    return ScanProgressState(
      status: status ?? this.status,
      currentStage: currentStage ?? this.currentStage,
      progress: progress ?? this.progress,
      itemsScannedCount: itemsScannedCount ?? this.itemsScannedCount,
      threatsDiscovered: threatsDiscovered ?? this.threatsDiscovered,
      logMessages: logMessages ?? this.logMessages,
    );
  }
}
