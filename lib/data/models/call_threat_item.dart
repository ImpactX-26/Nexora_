class CallTranscriptSegment {
  final String speaker; // "Caller" or "You"
  final String text;
  final String timeOffset;
  final bool isSuspicious;
  final String? matchedThreat;

  const CallTranscriptSegment({
    required this.speaker,
    required this.text,
    required this.timeOffset,
    this.isSuspicious = false,
    this.matchedThreat,
  });

  Map<String, dynamic> toJson() => {
        'speaker': speaker,
        'text': text,
        'timeOffset': timeOffset,
        'isSuspicious': isSuspicious,
        'matchedThreat': matchedThreat,
      };

  factory CallTranscriptSegment.fromJson(Map<String, dynamic> json) {
    return CallTranscriptSegment(
      speaker: json['speaker'] ?? 'Caller',
      text: json['text'] ?? '',
      timeOffset: json['timeOffset'] ?? '00:00',
      isSuspicious: json['isSuspicious'] ?? false,
      matchedThreat: json['matchedThreat'],
    );
  }
}

class CallThreatVerdict {
  final String callId;
  final String callerNumber;
  final String callerName;
  final DateTime timestamp;
  final int durationSeconds;
  final bool isScam;
  final int riskScore; // 0 to 100
  final String severity; // "Safe", "Low", "Medium", "High", "Critical"
  final String scamCategory;
  final List<String> detectedTactics;
  final List<CallTranscriptSegment> transcript;
  final String aiRecommendation;
  final String stressLevel;

  const CallThreatVerdict({
    required this.callId,
    required this.callerNumber,
    required this.callerName,
    required this.timestamp,
    required this.durationSeconds,
    required this.isScam,
    required this.riskScore,
    required this.severity,
    required this.scamCategory,
    required this.detectedTactics,
    required this.transcript,
    required this.aiRecommendation,
    required this.stressLevel,
  });

  Map<String, dynamic> toJson() => {
        'callId': callId,
        'callerNumber': callerNumber,
        'callerName': callerName,
        'timestamp': timestamp.toIso8601String(),
        'durationSeconds': durationSeconds,
        'isScam': isScam,
        'riskScore': riskScore,
        'severity': severity,
        'scamCategory': scamCategory,
        'detectedTactics': detectedTactics,
        'transcript': transcript.map((e) => e.toJson()).toList(),
        'aiRecommendation': aiRecommendation,
        'stressLevel': stressLevel,
      };

  factory CallThreatVerdict.fromJson(Map<String, dynamic> json) {
    return CallThreatVerdict(
      callId: json['callId'] ?? '',
      callerNumber: json['callerNumber'] ?? 'Unknown',
      callerName: json['callerName'] ?? 'Unknown Caller',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      durationSeconds: json['durationSeconds'] ?? 0,
      isScam: json['isScam'] ?? false,
      riskScore: json['riskScore'] ?? 0,
      severity: json['severity'] ?? 'Safe',
      scamCategory: json['scamCategory'] ?? 'General Call',
      detectedTactics: List<String>.from(json['detectedTactics'] ?? []),
      transcript: (json['transcript'] as List<dynamic>? ?? [])
          .map((e) => CallTranscriptSegment.fromJson(e))
          .toList(),
      aiRecommendation: json['aiRecommendation'] ?? 'No immediate threats found.',
      stressLevel: json['stressLevel'] ?? 'Normal',
    );
  }
}
