import 'package:flutter/material.dart';
import 'package:leads/core/theme/app_colors.dart';
import 'package:leads/core/theme/app_typography.dart';
import 'package:leads/data/models/tools_models.dart';
import 'package:leads/ui/components/glass_card.dart';
import 'package:leads/ui/screens/tools/tools_view_model.dart';

class DarkWebMonitorView extends StatefulWidget {
  final ToolsViewModel viewModel;

  const DarkWebMonitorView({super.key, required this.viewModel});

  @override
  State<DarkWebMonitorView> createState() => _DarkWebMonitorViewState();
}

class _DarkWebMonitorViewState extends State<DarkWebMonitorView> {
  final TextEditingController _inputController = TextEditingController();

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.cyberSurface,
          title: Text('Add Identity to Monitor', style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Enter email address or phone number to cross-reference with LEADS breach telemetry.', style: AppTypography.bodySmall),
              const SizedBox(height: 12),
              TextField(
                controller: _inputController,
                style: AppTypography.bodyMedium,
                decoration: InputDecoration(
                  hintText: 'e.g. yourname@domain.com',
                  hintStyle: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                  filled: true,
                  fillColor: AppColors.cyberSurfaceVariant,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_inputController.text.trim().isNotEmpty) {
                  widget.viewModel.addAccountToMonitor(_inputController.text.trim());
                  _inputController.clear();
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.cyberCyan, foregroundColor: Colors.black),
              child: const Text('Add Account'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final accounts = widget.viewModel.monitoredAccounts;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        GlassCard(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.cyberPurple.withAlpha(30),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.travel_explore, color: AppColors.cyberPurple, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Dark Web & Breach Monitor', style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                        Text('14.2B records indexed in telemetry feeds', style: AppTypography.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.add_circle, color: AppColors.cyberCyan),
                onPressed: _showAddDialog,
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        ...accounts.map((account) {
          final isCompromised = account.totalBreachesFound > 0;
          return GlassCard(
            borderColor: isCompromised ? AppColors.severityCritical.withAlpha(100) : AppColors.severitySafe.withAlpha(100),
            margin: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(account.emailOrPhone, style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                        Text('Last checked: ${account.lastChecked}', style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isCompromised ? AppColors.severityCritical.withAlpha(30) : AppColors.severitySafe.withAlpha(30),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isCompromised ? AppColors.severityCritical.withAlpha(100) : AppColors.severitySafe.withAlpha(100),
                        ),
                      ),
                      child: Text(
                        isCompromised ? '${account.totalBreachesFound} BREACHES' : 'CLEAN',
                        style: AppTypography.labelSmall.copyWith(
                          color: isCompromised ? AppColors.severityCritical : AppColors.severitySafe,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                if (account.breaches.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Divider(color: AppColors.borderCyber),
                  const SizedBox(height: 6),
                  Text('Breach Incidents on Record:', style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted)),
                  const SizedBox(height: 6),
                  ...account.breaches.map((b) => _buildBreachItem(b)),
                ],
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildBreachItem(BreachRecord breach) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.cyberSurfaceVariant.withAlpha(140),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderCyber.withAlpha(80)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${breach.sourceName} (${breach.breachDate})', style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold, fontSize: 12)),
              if (breach.passwordExposed)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.severityCritical.withAlpha(30),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text('PASSWORD EXPOSED', style: AppTypography.labelSmall.copyWith(color: AppColors.severityCritical, fontSize: 9)),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text('Exposed: ${breach.exposedData.joinToString(", ")}', style: AppTypography.codeMono.copyWith(fontSize: 10, color: AppColors.cyberAmber)),
          const SizedBox(height: 2),
          Text('Fix: ${breach.recommendedFix}', style: AppTypography.bodySmall.copyWith(fontSize: 11)),
        ],
      ),
    );
  }
}

extension on List<String> {
  String joinToString(String separator) => join(separator);
}
