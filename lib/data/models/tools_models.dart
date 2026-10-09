import 'threat_models.dart';

class AppPrivacyInfo {
  final String appName;
  final String packageName;
  final String category;
  final int riskScore;
  final ThreatSeverity riskSeverity;
  final List<String> dangerousPermissions;
  final String aiRiskAnalysis;

  const AppPrivacyInfo({
    required this.appName,
    required this.packageName,
    required this.category,
    required this.riskScore,
    required this.riskSeverity,
    required this.dangerousPermissions,
    required this.aiRiskAnalysis,
  });

  AppPrivacyInfo copyWith({
    String? appName,
    String? packageName,
    String? category,
    int? riskScore,
    ThreatSeverity? riskSeverity,
    List<String>? dangerousPermissions,
    String? aiRiskAnalysis,
  }) {
    return AppPrivacyInfo(
      appName: appName ?? this.appName,
      packageName: packageName ?? this.packageName,
      category: category ?? this.category,
      riskScore: riskScore ?? this.riskScore,
      riskSeverity: riskSeverity ?? this.riskSeverity,
      dangerousPermissions: dangerousPermissions ?? this.dangerousPermissions,
      aiRiskAnalysis: aiRiskAnalysis ?? this.aiRiskAnalysis,
    );
  }
}

class BreachRecord {
  final String sourceName;
  final String breachDate;
  final List<String> exposedData;
  final bool passwordExposed;
  final String recommendedFix;

  const BreachRecord({
    required this.sourceName,
    required this.breachDate,
    required this.exposedData,
    required this.passwordExposed,
    required this.recommendedFix,
  });
}

class MonitoredAccount {
  final String emailOrPhone;
  final int totalBreachesFound;
  final List<BreachRecord> breaches;
  final String lastChecked;

  const MonitoredAccount({
    required this.emailOrPhone,
    required this.totalBreachesFound,
    required this.breaches,
    required this.lastChecked,
  });

  MonitoredAccount copyWith({
    String? emailOrPhone,
    int? totalBreachesFound,
    List<BreachRecord>? breaches,
    String? lastChecked,
  }) {
    return MonitoredAccount(
      emailOrPhone: emailOrPhone ?? this.emailOrPhone,
      totalBreachesFound: totalBreachesFound ?? this.totalBreachesFound,
      breaches: breaches ?? this.breaches,
      lastChecked: lastChecked ?? this.lastChecked,
    );
  }
}

class WifiAuditResult {
  final String ssid;
  final String bssid;
  final String encryptionType;
  final int signalStrength;
  final bool isCaptivePortal;
  final bool isDnsTamperingDetected;
  final bool isArpSpoofingDetected;
  final ThreatSeverity overallSafety;
  final String advice;

  const WifiAuditResult({
    required this.ssid,
    required this.bssid,
    required this.encryptionType,
    required this.signalStrength,
    required this.isCaptivePortal,
    required this.isDnsTamperingDetected,
    required this.isArpSpoofingDetected,
    required this.overallSafety,
    required this.advice,
  });
}
