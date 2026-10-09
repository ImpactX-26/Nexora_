import 'package:flutter/material.dart';
import 'package:leads/core/theme/app_colors.dart';
import 'package:leads/core/theme/app_typography.dart';
import 'package:leads/data/models/coordinated_incident.dart';
import 'package:leads/ui/components/glass_card.dart';
import 'package:leads/ui/components/severity_badge.dart';

class RiskScoreCard extends StatelessWidget {
  final int riskScore;
  final ThreatSeverityLevel severity;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const RiskScoreCard({
    super.key,
    required this.riskScore,
    required this.severity,
    this.title = 'OVERALL THREAT RISK',
    this.subtitle = 'Calculated across correlated attack signals',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = switch (severity) {
      ThreatSeverityLevel.critical => AppColors.severityCritical,
      ThreatSeverityLevel.high => AppColors.severityHigh,
      ThreatSeverityLevel.suspicious => AppColors.severitySuspicious,
      ThreatSeverityLevel.safe => AppColors.severitySafe,
    };

    return GlassCard(
      borderColor: accentColor.withAlpha(100),
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textMuted,
                    letterSpacing: 1.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    SeverityBadge.fromLevel(severity: severity),
                    const SizedBox(width: 8),
                    Text(
                      '${severity.label} RISK',
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w900,
                        color: accentColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: accentColor.withAlpha(30),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: accentColor.withAlpha(90), width: 1),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$riskScore',
                  style: AppTypography.headlineLarge.copyWith(
                    fontWeight: FontWeight.w900,
                    color: accentColor,
                    fontSize: 32,
                    height: 1.0,
                  ),
                ),
                Text(
                  '/ 100',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textMuted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
