enum ThreatSeverity {
  critical('Critical', 4),
  high('High', 3),
  medium('Medium', 2),
  low('Low', 1),
  safe('Safe', 0);

  final String label;
  final int level;
  const ThreatSeverity(this.label, this.level);
}

enum ThreatCategory {
  phishing('Phishing & Scams'),
  malware('Malware & Spyware'),
  network('Wi-Fi & Network'),
  privacy('Privacy & Permissions'),
  credentialLeak('Dark Web Breach'),
  systemIntegrity('System Vulnerability');

  final String displayName;
  const ThreatCategory(this.displayName);
}

enum ThreatStatus {
  active,
  mitigated,
  quarantined,
  ignored;
}

class ThreatItem {
  final String id;
  final String title;
  final String description;
  final ThreatCategory category;
  final ThreatSeverity severity;
  final ThreatStatus status;
  final String timestamp;
  final String affectedResource;
  final List<String> remediationSteps;
  final String aiExplanation;

  const ThreatItem({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.severity,
    this.status = ThreatStatus.active,
    required this.timestamp,
    required this.affectedResource,
    required this.remediationSteps,
    required this.aiExplanation,
  });

  ThreatItem copyWith({
    String? id,
    String? title,
    String? description,
    ThreatCategory? category,
    ThreatSeverity? severity,
    ThreatStatus? status,
    String? timestamp,
    String? affectedResource,
    List<String>? remediationSteps,
    String? aiExplanation,
  }) {
    return ThreatItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      severity: severity ?? this.severity,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      affectedResource: affectedResource ?? this.affectedResource,
      remediationSteps: remediationSteps ?? this.remediationSteps,
      aiExplanation: aiExplanation ?? this.aiExplanation,
    );
  }
}
