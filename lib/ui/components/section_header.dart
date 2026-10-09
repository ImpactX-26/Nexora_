import 'package:flutter/material.dart';
import 'package:leads/core/theme/app_colors.dart';
import 'package:leads/core/theme/app_typography.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? badgeText;
  final Color? badgeColor;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.badgeText,
    this.badgeColor,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                title.toUpperCase(),
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textMuted,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
              if (badgeText != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: (badgeColor ?? AppColors.cyberCyan).withAlpha(30),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: (badgeColor ?? AppColors.cyberCyan).withAlpha(100),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    badgeText!,
                    style: AppTypography.labelSmall.copyWith(
                      color: badgeColor ?? AppColors.cyberCyan,
                      fontSize: 9,
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (actionLabel != null && onAction != null)
            GestureDetector(
              onTap: onAction,
              child: Text(
                actionLabel!,
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.cyberCyan,
                  fontSize: 11,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
