import 'package:flutter/material.dart';
import 'package:leads/core/theme/app_colors.dart';
import 'package:leads/core/theme/app_typography.dart';
import 'package:leads/data/models/coordinated_incident.dart';
import 'package:leads/ui/components/severity_badge.dart';

class RecommendationCard extends StatelessWidget {
  final RecommendedActionItem action;
  final VoidCallback onToggle;

  const RecommendationCard({
    super.key,
    required this.action,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: action.isCompleted
            ? AppColors.cyberSurfaceVariant.withAlpha(60)
            : AppColors.cyberSurfaceVariant.withAlpha(150),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: action.isCompleted
              ? AppColors.severitySafe.withAlpha(80)
              : AppColors.borderCyber,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SeverityBadge.fromLevel(severity: action.urgency),
                  const SizedBox(width: 8),
                  if (action.isCompleted)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.severitySafe.withAlpha(30),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'RESOLVED',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.severitySafe,
                          fontSize: 9,
                        ),
                      ),
                    ),
                ],
              ),
              IconButton(
                icon: Icon(
                  action.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: action.isCompleted ? AppColors.severitySafe : AppColors.textMuted,
                  size: 22,
                ),
                onPressed: onToggle,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            action.title,
            style: AppTypography.titleSmall.copyWith(
              fontWeight: FontWeight.bold,
              color: action.isCompleted ? AppColors.textMuted : AppColors.textPrimary,
              decoration: action.isCompleted ? TextDecoration.lineThrough : null,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            action.description,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: onToggle,
              icon: Icon(
                action.isCompleted ? Icons.undo : Icons.bolt,
                size: 14,
              ),
              label: Text(action.isCompleted ? 'Mark Pending' : action.buttonLabel),
              style: OutlinedButton.styleFrom(
                foregroundColor: action.isCompleted ? AppColors.textMuted : AppColors.cyberCyan,
                side: BorderSide(
                  color: action.isCompleted ? AppColors.borderCyber : AppColors.cyberCyan,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
