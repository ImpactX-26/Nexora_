import 'package:leads/data/models/threat_models.dart';
import 'package:leads/domain/heuristic_analyzer.dart';

class SmsThreatItem {
  final String id;
  final String sender;
  final String body;
  final DateTime timestamp;
  final bool isRisk;
  final ThreatSeverity severity;
  final int riskScore;
  final String threatCategory;
  final List<String> detectedTactics;
  final List<String> extractedUrls;
  final String aiRecommendation;

  const SmsThreatItem({
    required this.id,
    required this.sender,
    required this.body,
    required this.timestamp,
    required this.isRisk,
    required this.severity,
    required this.riskScore,
    required this.threatCategory,
    required this.detectedTactics,
    required this.extractedUrls,
    required this.aiRecommendation,
  });

  factory SmsThreatItem.fromRaw({
    required String id,
    required String sender,
    required String body,
    required DateTime timestamp,
  }) {
    final verdict = HeuristicAnalyzer.analyzeTextOrUrl(body);

    // Additional SMS specific heuristic evaluation
    final lower = body.toLowerCase();
    final lowerSender = sender.toLowerCase();
    final extracted = <String>[];
    final urlRegex = RegExp(r'https?://[^\s]+|(?:www\.)[^\s]+|[a-zA-Z0-9-]+\.(?:xyz|top|icu|buzz|work|apk|ru)[^\s]*');
    for (final match in urlRegex.allMatches(body)) {
      extracted.add(match.group(0) ?? '');
    }

    int score = verdict.riskScore;
    final tactics = List<String>.from(verdict.detectedTactics);

    // SMS fraud checks
    if (lowerSender.contains('alert') || lowerSender.contains('verify') || lowerSender.contains('service')) {
      if (score > 20) score += 10;
    }
    if (lower.contains('electricity') && (lower.contains('power will be disconnected') || lower.contains('bill update'))) {
      score += 40;
      tactics.add('Fake Electricity Bill Disconnection Scam');
    }
    if (lower.contains('part time job') || lower.contains('earn 5000 daily') || lower.contains('telegram task')) {
      score += 35;
      tactics.add('Part-Time Telegram Job Scam');
    }
    if (lower.contains('pan card') && (lower.contains('blocked') || lower.contains('link now'))) {
      score += 45;
      tactics.add('Urgent PAN / Bank Account Freezing Scam');
    }
    if (lower.contains('lottery') || lower.contains('kbc') || lower.contains('won 25,00,000')) {
      score += 50;
      tactics.add('Lottery & Prize Impersonation Fraud');
    }
    if (lower.contains('apk') || lower.contains('.apk')) {
      score += 45;
      tactics.add('Dangerous Android APK Dropper');
    }

    score = score.clamp(0, 100);
    final isThreat = score >= 40;

    final ThreatSeverity finalSeverity;
    if (score >= 70) {
      finalSeverity = ThreatSeverity.critical;
    } else if (score >= 45) {
      finalSeverity = ThreatSeverity.high;
    } else if (score >= 25) {
      finalSeverity = ThreatSeverity.medium;
    } else {
      finalSeverity = ThreatSeverity.safe;
    }

    String category = 'Safe Message';
    if (score >= 40) {
      if (tactics.any((t) => t.contains('Electricity'))) {
        category = 'Utility Bill Fraud';
      } else if (tactics.any((t) => t.contains('PAN') || t.contains('Bank') || t.contains('KYC'))) {
        category = 'Banking Smishing';
      } else if (tactics.any((t) => t.contains('Job'))) {
        category = 'Employment Scam';
      } else if (tactics.any((t) => t.contains('APK'))) {
        category = 'Malware APK Dropper';
      } else {
        category = 'Phishing Link / Social Engineering';
      }
    }

    return SmsThreatItem(
      id: id,
      sender: sender,
      body: body,
      timestamp: timestamp,
      isRisk: isThreat,
      severity: finalSeverity,
      riskScore: score,
      threatCategory: category,
      detectedTactics: tactics,
      extractedUrls: extracted,
      aiRecommendation: isThreat
          ? 'DO NOT open links or reply to this sender. Block and delete this message immediately.'
          : 'Standard legitimate message. No threat indicators found.',
    );
  }
}
