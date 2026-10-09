import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:leads/core/theme/app_colors.dart';
import 'package:leads/core/theme/app_typography.dart';
import 'package:leads/data/models/coordinated_incident.dart';
import 'package:leads/ui/components/severity_badge.dart';

class EvidenceCard extends StatelessWidget {
  final EvidenceArtifact artifact;

  const EvidenceCard({super.key, required this.artifact});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cyberSurfaceVariant.withAlpha(120),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderCyber),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                artifact.label.toUpperCase(),
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.cyberCyan,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
              SeverityBadge.fromLevel(severity: artifact.severity),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.cyberBackground,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.borderCyber.withAlpha(60)),
            ),
            child: SelectableText(
              artifact.value,
              style: AppTypography.codeMono.copyWith(fontSize: 11),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Source: ${artifact.source} • ${artifact.timestamp}',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textMuted,
                  fontSize: 10,
                ),
              ),
              InkWell(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: artifact.value));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Artifact copied to clipboard'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                child: Row(
                  children: [
                    const Icon(Icons.copy, size: 12, color: AppColors.cyberCyan),
                    const SizedBox(width: 4),
                    Text(
                      'Copy',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.cyberCyan,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
