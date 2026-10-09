import 'package:flutter/material.dart';
import 'package:leads/core/theme/app_colors.dart';
import 'package:leads/core/theme/app_typography.dart';
import 'package:leads/data/models/coordinated_incident.dart';
import 'package:leads/data/models/threat_models.dart';

class SeverityBadge extends StatelessWidget {
  final String label;
  final Color color;
  final EdgeInsetsGeometry padding;

  const SeverityBadge._({
    required this.label,
    required this.color,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
  });

  factory SeverityBadge.fromLevel({
    required ThreatSeverityLevel severity,
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
  }) {
    final (label, color) = switch (severity) {
      ThreatSeverityLevel.critical => ('CRITICAL', AppColors.severityCritical),
      ThreatSeverityLevel.high => ('HIGH', AppColors.severityHigh),
      ThreatSeverityLevel.suspicious => ('SUSPICIOUS', AppColors.severitySuspicious),
      ThreatSeverityLevel.safe => ('SAFE', AppColors.severitySafe),
    };
    return SeverityBadge._(label: label, color: color, padding: padding);
  }

  factory SeverityBadge.fromSeverity({
    required ThreatSeverity severity,
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
  }) {
    final (label, color) = switch (severity) {
      ThreatSeverity.critical => ('CRITICAL', AppColors.severityCritical),
      ThreatSeverity.high => ('HIGH', AppColors.severityHigh),
      ThreatSeverity.medium => ('MEDIUM', AppColors.severitySuspicious),
      ThreatSeverity.low => ('LOW', AppColors.severitySafe),
      ThreatSeverity.safe => ('SAFE', AppColors.severitySafe),
    };
    return SeverityBadge._(label: label, color: color, padding: padding);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color.withAlpha(35),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withAlpha(90), width: 1),
      ),
      child: Text(
        label,
        style: AppTypography.labelSmall.copyWith(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
