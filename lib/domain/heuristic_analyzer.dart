import '../data/models/threat_models.dart';

class PhishingAnalysisVerdict {
  final String inputQuery;
  final bool isPhishing;
  final ThreatSeverity riskSeverity;
  final int riskScore; // 0 to 100
  final List<String> detectedTactics;
  final List<String> deceptiveIndicators;
  final String aiRecommendation;
  final String? cleanUrlPreview;

  const PhishingAnalysisVerdict({
    required this.inputQuery,
    required this.isPhishing,
    required this.riskSeverity,
    required this.riskScore,
    required this.detectedTactics,
    required this.deceptiveIndicators,
    required this.aiRecommendation,
    this.cleanUrlPreview,
  });

  int get score => riskScore;
  String get category => isPhishing ? 'Phishing / Malware' : 'Safe';
  List<String> get detectedFlags => detectedTactics;
}

class HeuristicAnalyzer {
  PhishingAnalysisVerdict analyze(String rawInput) => analyzeTextOrUrl(rawInput);

  static const Set<String> _suspiciousTlds = {
    '.xyz',
    '.top',
    '.buzz',
    '.icu',
    '.work',
    '.cfd',
    '.gq',
    '.ml',
    '.tk',
    '.ga',
  };

  static const List<String> _highRiskKeywords = [
    'verify your identity',
    'account suspended',
    'account is suspended',
    'immediate action required',
    'unauthorized transaction',
    'click here to claim',
    'urgent notice',
    'urgent',
    'password expired',
    'lottery winner',
    'refund available',
    'update your kyc',
    'update kyc',
    'crypto giveaway',
    'unusual sign-in activity',
    'login now to prevent closure',
  ];

  static const Map<String, String> _knownBrandImpersonations = {
    'paypa1': 'PayPal',
    'paypai': 'PayPal',
    'netflix-update': 'Netflix',
    'amzn-': 'Amazon',
    'amazn': 'Amazon',
    'appleid-verify': 'Apple',
    'wellsfarg0': 'Wells Fargo',
    'chase-security': 'Chase Bank',
    'google-security-alert': 'Google',
  };

  static PhishingAnalysisVerdict analyzeTextOrUrl(String rawInput) {
    final input = rawInput.trim();
    final lower = input.toLowerCase();
    final tactics = <String>[];
    final indicators = <String>[];
    int score = 5; // baseline safe

    final isUrl = lower.startsWith('http://') ||
        lower.startsWith('https://') ||
        lower.contains('.com') ||
        lower.contains('.org') ||
        lower.contains('.net') ||
        lower.contains('.xyz');

    if (lower.startsWith('http://')) {
      tactics.add('Insecure Protocol (HTTP)');
      indicators.add('Unencrypted HTTP communication exposes credentials in transit.');
      score += 25;
    }

    // Check suspicious TLDs
    for (final tld in _suspiciousTlds) {
      if (lower.contains(tld)) {
        tactics.add('High-Risk Domain TLD ($tld)');
        indicators.add('Domain uses a top-level extension frequently abused for automated fraud.');
        score += 30;
        break;
      }
    }

    // Check IP address in hostname
    final ipRegex = RegExp(r'https?://\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}');
    if (ipRegex.hasMatch(lower)) {
      tactics.add('Raw IP Address in URL');
      indicators.add('Direct IP address used instead of legitimate registered domain name.');
      score += 35;
    }

    // Check Brand Impersonation
    for (final entry in _knownBrandImpersonations.entries) {
      if (lower.contains(entry.key)) {
        tactics.add('Brand Typosquatting (${entry.value} Impersonation)');
        indicators.add('Look-alike domain crafted to deceive users into believing this is official ${entry.value}.');
        score += 45;
        break;
      }
    }

    // Check Urgency / Social Engineering Keywords
    for (final keyword in _highRiskKeywords) {
      if (lower.contains(keyword)) {
        tactics.add('Urgency & Fear Tactics: "$keyword"');
        indicators.add('Attacker creates false urgency to provoke impulsive credential entry.');
        score += 20;
      }
    }

    // Subdomain stuffing check
    if (isUrl && '.'.allMatches(lower).length > 3) {
      tactics.add('Subdomain Masking / Stuffing');
      indicators.add('Multiple nested subdomains frequently conceal malicious hosts.');
      score += 15;
    }

    // APK payload check
    if (lower.contains('.apk')) {
      tactics.add('Untrusted APK Payload Link');
      indicators.add('Direct link prompts sideloading an executable Android package.');
      score += 40;
    }

    score = score.clamp(0, 100);

    final ThreatSeverity severity;
    final bool isPhishing;
    final String recommendation;

    if (score >= 70) {
      severity = ThreatSeverity.critical;
      isPhishing = true;
      recommendation = 'DO NOT open this link or input credentials. LEADS classified this as an active phishing / credential theft vector.';
    } else if (score >= 45) {
      severity = ThreatSeverity.high;
      isPhishing = true;
      recommendation = 'High degree of suspicious indicators detected. Exercise caution and verify directly via official institution channels.';
    } else if (score >= 20) {
      severity = ThreatSeverity.medium;
      isPhishing = false;
      recommendation = 'Some low-confidence signals noted. Check domain spelling carefully before logging in.';
    } else {
      severity = ThreatSeverity.safe;
      isPhishing = false;
      recommendation = 'No malicious indicators or spoofing patterns flagged by LEADS heuristic analysis.';
    }

    String? preview;
    if (isUrl) {
      preview = input.replaceAll(RegExp(r'https?://'), '').split('/')[0];
    }

    return PhishingAnalysisVerdict(
      inputQuery: input,
      isPhishing: isPhishing,
      riskSeverity: severity,
      riskScore: score,
      detectedTactics: tactics.isEmpty ? ['Standard Content'] : tactics,
      deceptiveIndicators: indicators.isEmpty ? ['No deceptive markers detected.'] : indicators,
      aiRecommendation: recommendation,
      cleanUrlPreview: preview,
    );
  }
}
