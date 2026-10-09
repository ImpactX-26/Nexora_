enum HealthStatus {
  excellent('EXCELLENT'),
  good('GOOD'),
  warning('WARNING'),
  critical('CRITICAL');

  final String label;
  const HealthStatus(this.label);
}

class SecurityScore {
  final int overallScore;
  final int maxScore;
  final HealthStatus healthStatus;
  final int networkScore;
  final int privacyScore;
  final int identityScore;
  final int systemScore;
  final int activeThreatsCount;
  final int mitigatedThreatsCount;
  final String lastScanTime;

  const SecurityScore({
    required this.overallScore,
    this.maxScore = 100,
    this.healthStatus = HealthStatus.good,
    this.networkScore = 95,
    this.privacyScore = 88,
    this.identityScore = 90,
    this.systemScore = 98,
    this.activeThreatsCount = 1,
    this.mitigatedThreatsCount = 8,
    this.lastScanTime = "Just now",
  });
}
