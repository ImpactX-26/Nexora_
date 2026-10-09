import '../data/models/security_score.dart';
import '../data/models/threat_models.dart';

class SecurityEngine {
  static SecurityScore computeSecurityScore(List<ThreatItem> threats) {
    final activeThreats = threats.where((t) => t.status == ThreatStatus.active).toList();
    final mitigatedThreats = threats.where((t) => t.status == ThreatStatus.mitigated).toList();

    int penalty = 0;
    for (final threat in activeThreats) {
      penalty += switch (threat.severity) {
        ThreatSeverity.critical => 25,
        ThreatSeverity.high => 15,
        ThreatSeverity.medium => 8,
        ThreatSeverity.low => 3,
        ThreatSeverity.safe => 0,
      };
    }

    final calculatedScore = (100 - penalty).clamp(15, 100);

    final HealthStatus healthStatus;
    if (calculatedScore >= 90) {
      healthStatus = HealthStatus.excellent;
    } else if (calculatedScore >= 75) {
      healthStatus = HealthStatus.good;
    } else if (calculatedScore >= 50) {
      healthStatus = HealthStatus.warning;
    } else {
      healthStatus = HealthStatus.critical;
    }

    final networkScore = activeThreats.any((t) => t.category == ThreatCategory.network) ? 65 : 96;
    final privacyScore = activeThreats.any((t) => t.category == ThreatCategory.privacy) ? 68 : 92;
    final identityScore = activeThreats.any((t) => t.category == ThreatCategory.credentialLeak) ? 58 : 88;
    final systemScore = activeThreats.any((t) => t.category == ThreatCategory.systemIntegrity) ? 60 : 98;

    return SecurityScore(
      overallScore: calculatedScore,
      maxScore: 100,
      healthStatus: healthStatus,
      networkScore: networkScore,
      privacyScore: privacyScore,
      identityScore: identityScore,
      systemScore: systemScore,
      activeThreatsCount: activeThreats.length,
      mitigatedThreatsCount: mitigatedThreats.length,
      lastScanTime: 'Just now',
    );
  }
}
