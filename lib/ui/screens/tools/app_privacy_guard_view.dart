import 'package:flutter/material.dart';
import 'package:leads/core/theme/app_colors.dart';
import 'package:leads/core/theme/app_typography.dart';
import 'package:leads/ui/components/glass_card.dart';
import 'package:leads/ui/components/severity_badge.dart';
import 'package:leads/ui/screens/tools/tools_view_model.dart';

class AppPrivacyGuardView extends StatelessWidget {
  final ToolsViewModel viewModel;

  const AppPrivacyGuardView({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final list = viewModel.appPrivacyList;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        GlassCard(
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.severityCritical.withAlpha(30),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.security, color: AppColors.severityCritical, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('App Privacy & Permission Guard', style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                    Text('Auditing background camera, mic, overlay & SMS access across packages', style: AppTypography.bodySmall),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        ...list.map((app) {
          final isHighRisk = app.riskScore >= 70;
          return GlassCard(
            borderColor: isHighRisk ? AppColors.severityCritical.withAlpha(100) : AppColors.borderCyber,
            margin: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            app.appName,
                            style: AppTypography.titleMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isHighRisk ? AppColors.severityCritical : AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            '${app.category} • ${app.packageName}',
                            style: AppTypography.codeMono.copyWith(fontSize: 10, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                    SeverityBadge.fromSeverity(severity: app.riskSeverity),
                  ],
                ),
                const SizedBox(height: 8),
                Text('AI Assessment: ${app.aiRiskAnalysis}', style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
                if (app.dangerousPermissions.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  const Divider(color: AppColors.borderCyber),
                  const SizedBox(height: 6),
                  Text('Active Permissions:', style: AppTypography.labelSmall.copyWith(color: AppColors.cyberCyan)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: app.dangerousPermissions.map((perm) {
                      return InputChip(
                        label: Text(perm),
                        labelStyle: AppTypography.labelSmall.copyWith(fontSize: 10, color: AppColors.severityCritical),
                        backgroundColor: AppColors.cyberSurfaceVariant,
                        deleteIcon: const Icon(Icons.close, size: 14, color: AppColors.severityCritical),
                        onDeleted: () {
                          viewModel.revokePermission(app.packageName, perm);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Revoked $perm from ${app.appName}')),
                          );
                        },
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          );
        }),
      ],
    );
  }
}
