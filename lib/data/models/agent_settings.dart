enum ProtectionLevel {
  standard('Standard Guardian', 'Balanced real-time heuristics and passive monitoring.'),
  aggressive('Aggressive Isolation', 'Immediate killswitch for untrusted APKs and deceptive domains.'),
  paranoid('Zero-Trust Paranoia', 'Continuous neural inspection, strict sandbox mode, all unknown packets blocked.');

  final String title;
  final String description;
  const ProtectionLevel(this.title, this.description);
}

class AgentSettings {
  final bool isAutonomousInterventionEnabled;
  final ProtectionLevel protectionLevel;
  final bool isRealTimeSmsMonitoringEnabled;
  final bool isNetworkDnsGuardEnabled;
  final bool isSideloadAppProtectionEnabled;
  final bool isDarkWebTelemetryEnabled;
  final bool isLocalAiProcessingOnly;
  final String aiModelVersion;

  const AgentSettings({
    this.isAutonomousInterventionEnabled = true,
    this.protectionLevel = ProtectionLevel.aggressive,
    this.isRealTimeSmsMonitoringEnabled = true,
    this.isNetworkDnsGuardEnabled = true,
    this.isSideloadAppProtectionEnabled = true,
    this.isDarkWebTelemetryEnabled = true,
    this.isLocalAiProcessingOnly = false,
    this.aiModelVersion = 'LEADS-Neural-v4.8-Edge',
  });

  AgentSettings copyWith({
    bool? isAutonomousInterventionEnabled,
    ProtectionLevel? protectionLevel,
    bool? isRealTimeSmsMonitoringEnabled,
    bool? isNetworkDnsGuardEnabled,
    bool? isSideloadAppProtectionEnabled,
    bool? isDarkWebTelemetryEnabled,
    bool? isLocalAiProcessingOnly,
    String? aiModelVersion,
  }) {
    return AgentSettings(
      isAutonomousInterventionEnabled:
          isAutonomousInterventionEnabled ?? this.isAutonomousInterventionEnabled,
      protectionLevel: protectionLevel ?? this.protectionLevel,
      isRealTimeSmsMonitoringEnabled:
          isRealTimeSmsMonitoringEnabled ?? this.isRealTimeSmsMonitoringEnabled,
      isNetworkDnsGuardEnabled:
          isNetworkDnsGuardEnabled ?? this.isNetworkDnsGuardEnabled,
      isSideloadAppProtectionEnabled:
          isSideloadAppProtectionEnabled ?? this.isSideloadAppProtectionEnabled,
      isDarkWebTelemetryEnabled:
          isDarkWebTelemetryEnabled ?? this.isDarkWebTelemetryEnabled,
      isLocalAiProcessingOnly:
          isLocalAiProcessingOnly ?? this.isLocalAiProcessingOnly,
      aiModelVersion: aiModelVersion ?? this.aiModelVersion,
    );
  }
}

class SecurityPermissionItem {
  final String id;
  final String name;
  final String whyNeeded;
  final bool isGranted;

  const SecurityPermissionItem({
    required this.id,
    required this.name,
    required this.whyNeeded,
    this.isGranted = true,
  });

  SecurityPermissionItem copyWith({
    String? id,
    String? name,
    String? whyNeeded,
    bool? isGranted,
  }) {
    return SecurityPermissionItem(
      id: id ?? this.id,
      name: name ?? this.name,
      whyNeeded: whyNeeded ?? this.whyNeeded,
      isGranted: isGranted ?? this.isGranted,
    );
  }
}
