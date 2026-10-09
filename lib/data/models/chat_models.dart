import 'threat_models.dart';

enum SenderType {
  user,
  agent,
  system;
}

enum ChatCardType {
  threatAlert,
  recommendation,
  quickFix,
  investigationInsight;
}

class ChatCardData {
  final ChatCardType type;
  final String title;
  final String? subtitle;
  final ThreatSeverity severity;
  final List<String> keyPoints;
  final String? actionLabel;
  final String? actionPayload;

  const ChatCardData({
    required this.type,
    required this.title,
    this.subtitle,
    this.severity = ThreatSeverity.high,
    this.keyPoints = const [],
    this.actionLabel,
    this.actionPayload,
  });
}

class ChatMessage {
  final String id;
  final String text;
  final SenderType sender;
  final int timestamp;
  final ChatCardData? cardData;
  final List<String> suggestedReplies;

  ChatMessage({
    required this.id,
    required this.text,
    required this.sender,
    int? timestamp,
    this.cardData,
    this.suggestedReplies = const [],
  }) : timestamp = timestamp ?? DateTime.now().millisecondsSinceEpoch;
}
