enum ThreatSeverityLevel {
  safe('SAFE', 0),
  suspicious('SUSPICIOUS', 45),
  high('HIGH', 75),
  critical('CRITICAL', 94);

  final String label;
  final int scoreWeight;
  const ThreatSeverityLevel(this.label, this.scoreWeight);
}

enum ThreatStatusCategory {
  activeCampaign,
  isolatedAnomaly,
  resolved;
}

enum NodeType {
  sms('SMS Message'),
  phoneNumber('Phone Number'),
  url('Phishing URL'),
  domain('Suspicious Domain'),
  ipAddress('Host IP'),
  apkDownload('Malicious APK'),
  application('Installed App'),
  callSignal('Social Eng Call'),
  incident('Coordinated Scam'),
  targetBank('Target Institution');

  final String displayName;
  const NodeType(this.displayName);
}

enum EdgeRelationship {
  contains('CONTAINS'),
  redirectsTo('REDIRECTS_TO'),
  resolvesTo('RESOLVES_TO'),
  installs('INSTALLS'),
  relatedTo('RELATED_TO'),
  partOf('PART_OF'),
  targets('TARGETS');

  final String label;
  const EdgeRelationship(this.label);
}

class GraphNode {
  final String id;
  final NodeType type;
  final String label;
  final String subtitle;
  final ThreatSeverityLevel severity;
  final int riskContribution;
  final double xRatio; // 0.0 to 1.0 position in Canvas
  final double yRatio;
  final Map<String, String> attributes;

  const GraphNode({
    required this.id,
    required this.type,
    required this.label,
    required this.subtitle,
    required this.severity,
    required this.riskContribution,
    required this.xRatio,
    required this.yRatio,
    this.attributes = const {},
  });
}

class GraphEdge {
  final String fromNodeId;
  final String toNodeId;
  final EdgeRelationship relationship;
  final String? label;

  const GraphEdge({
    required this.fromNodeId,
    required this.toNodeId,
    required this.relationship,
    this.label,
  });
}

class RecommendedActionItem {
  final String id;
  final String title;
  final String description;
  final ThreatSeverityLevel urgency;
  final String buttonLabel;
  final bool isCompleted;
  final String targetComponent;

  const RecommendedActionItem({
    required this.id,
    required this.title,
    required this.description,
    required this.urgency,
    required this.buttonLabel,
    this.isCompleted = false,
    required this.targetComponent,
  });

  RecommendedActionItem copyWith({
    String? id,
    String? title,
    String? description,
    ThreatSeverityLevel? urgency,
    String? buttonLabel,
    bool? isCompleted,
    String? targetComponent,
  }) {
    return RecommendedActionItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      urgency: urgency ?? this.urgency,
      buttonLabel: buttonLabel ?? this.buttonLabel,
      isCompleted: isCompleted ?? this.isCompleted,
      targetComponent: targetComponent ?? this.targetComponent,
    );
  }
}

class InvestigationStep {
  final int stepNumber;
  final String title;
  final String analysis;
  final String findings;
  final bool isCompleted;

  const InvestigationStep({
    required this.stepNumber,
    required this.title,
    required this.analysis,
    required this.findings,
    this.isCompleted = true,
  });
}

class EvidenceArtifact {
  final String id;
  final String label;
  final String value;
  final String source;
  final String timestamp;
  final ThreatSeverityLevel severity;

  const EvidenceArtifact({
    required this.id,
    required this.label,
    required this.value,
    required this.source,
    required this.timestamp,
    required this.severity,
  });
}

class TimelineEventItem {
  final String id;
  final String time;
  final String title;
  final String description;
  final ThreatSeverityLevel severity;
  final NodeType type;

  const TimelineEventItem({
    required this.id,
    required this.time,
    required this.title,
    required this.description,
    required this.severity,
    required this.type,
  });
}

class CoordinatedIncident {
  final String id;
  final String title;
  final String summary;
  final int overallRiskScore;
  final ThreatSeverityLevel severity;
  final ThreatStatusCategory status;
  final String detectedTimestamp;
  final List<GraphNode> nodes;
  final List<GraphEdge> edges;
  final List<TimelineEventItem> timeline;
  final List<EvidenceArtifact> evidenceList;
  final List<RecommendedActionItem> recommendedActions;
  final List<InvestigationStep> investigationSteps;
  final String attackVector;
  final String confidenceScore;

  const CoordinatedIncident({
    required this.id,
    required this.title,
    required this.summary,
    required this.overallRiskScore,
    required this.severity,
    required this.status,
    required this.detectedTimestamp,
    required this.nodes,
    required this.edges,
    required this.timeline,
    required this.evidenceList,
    required this.recommendedActions,
    required this.investigationSteps,
    required this.attackVector,
    required this.confidenceScore,
  });

  CoordinatedIncident copyWith({
    String? id,
    String? title,
    String? summary,
    int? overallRiskScore,
    ThreatSeverityLevel? severity,
    ThreatStatusCategory? status,
    String? detectedTimestamp,
    List<GraphNode>? nodes,
    List<GraphEdge>? edges,
    List<TimelineEventItem>? timeline,
    List<EvidenceArtifact>? evidenceList,
    List<RecommendedActionItem>? recommendedActions,
    List<InvestigationStep>? investigationSteps,
    String? attackVector,
    String? confidenceScore,
  }) {
    return CoordinatedIncident(
      id: id ?? this.id,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      overallRiskScore: overallRiskScore ?? this.overallRiskScore,
      severity: severity ?? this.severity,
      status: status ?? this.status,
      detectedTimestamp: detectedTimestamp ?? this.detectedTimestamp,
      nodes: nodes ?? this.nodes,
      edges: edges ?? this.edges,
      timeline: timeline ?? this.timeline,
      evidenceList: evidenceList ?? this.evidenceList,
      recommendedActions: recommendedActions ?? this.recommendedActions,
      investigationSteps: investigationSteps ?? this.investigationSteps,
      attackVector: attackVector ?? this.attackVector,
      confidenceScore: confidenceScore ?? this.confidenceScore,
    );
  }
}
