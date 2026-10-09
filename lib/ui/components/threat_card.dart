import 'package:flutter/material.dart';
import 'package:leads/core/theme/app_colors.dart';
import 'package:leads/core/theme/app_typography.dart';
import 'package:leads/data/models/threat_models.dart';
import 'package:leads/ui/components/glass_card.dart';
import 'package:leads/ui/components/severity_badge.dart';

class ThreatCard extends StatelessWidget {
  final ThreatItem threat;
  final VoidCallback? onTap;
  final VoidCallback? onMitigate;
  final VoidCallback? onIgnore;

  const ThreatCard({
    super.key,
    required this.threat,
    this.onTap,
    this.onMitigate,
    this.onIgnore,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = switch (threat.severity) {
      ThreatSeverity.critical => AppColors.severityCritical.withAlpha(110),
      ThreatSeverity.high => AppColors.severityHigh.withAlpha(90),
      ThreatSeverity.medium => AppColors.severitySuspicious.withAlpha(80),
      ThreatSeverity.low || ThreatSeverity.safe => AppColors.borderCyber,
    };

    return GlassCard(
      borderColor: borderColor,
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    SeverityBadge.fromSeverity(severity: threat.severity),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        threat.title,
                        style: AppTypography.titleSmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                threat.timestamp,
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textMuted,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            threat.description,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.link, size: 14, color: AppColors.cyberCyan),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  threat.affectedResource,
                  style: AppTypography.codeMono.copyWith(
                    fontSize: 11,
                    color: AppColors.cyberCyan,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (threat.status == ThreatStatus.active && (onMitigate != null || onIgnore != null)) ...[
            const SizedBox(height: 12),
            const Divider(height: 1, color: AppColors.borderCyber),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (onIgnore != null)
                  TextButton(
                    onPressed: onIgnore,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.textMuted,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    ),
                    child: const Text('Dismiss'),
                  ),
                if (onMitigate != null)
                  ElevatedButton.icon(
                    onPressed: onMitigate,
                    icon: const Icon(Icons.shield_outlined, size: 14),
                    label: const Text('Mitigate'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.cyberCyanDark,
                      foregroundColor: AppColors.cyberCyan,
                      side: const BorderSide(color: AppColors.cyberCyan, width: 1),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
