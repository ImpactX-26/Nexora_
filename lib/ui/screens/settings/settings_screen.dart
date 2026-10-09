import 'package:flutter/material.dart';
import 'package:leads/core/theme/app_colors.dart';
import 'package:leads/core/theme/app_typography.dart';
import 'package:leads/data/models/agent_settings.dart';
import 'package:leads/ui/components/glass_card.dart';
import 'package:leads/ui/components/section_header.dart';
import 'package:leads/ui/screens/settings/settings_view_model.dart';

class SettingsScreen extends StatelessWidget {
  final SettingsViewModel viewModel;

  const SettingsScreen({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final settings = viewModel.settings;

        return Scaffold(
          backgroundColor: AppColors.cyberBackground,
          appBar: AppBar(
            title: Text('DEFENSE CONFIGURATION', style: AppTypography.titleMedium.copyWith(letterSpacing: 0.5)),
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            children: [
              // 1. Autonomous Agent Control Card
              GlassCard(
                borderColor: settings.isAutonomousInterventionEnabled
                    ? AppColors.severitySafe.withAlpha(120)
                    : AppColors.borderCyber,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: settings.isAutonomousInterventionEnabled
                                    ? AppColors.severitySafe.withAlpha(30)
                                    : AppColors.cyberSurfaceVariant,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.smart_toy,
                                color: settings.isAutonomousInterventionEnabled
                                    ? AppColors.severitySafe
                                    : AppColors.textMuted,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Autonomous Threat Agent', style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold)),
                                Text(
                                  settings.isAutonomousInterventionEnabled ? 'Active Interventions Enabled' : 'Passive Telemetry Mode',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: settings.isAutonomousInterventionEnabled ? AppColors.severitySafe : AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Switch(
                          value: settings.isAutonomousInterventionEnabled,
                          activeThumbColor: AppColors.severitySafe,
                          onChanged: (v) => viewModel.toggleAutonomous(v),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'When enabled, LEADS automatically neutralizes high-confidence malicious overlay windows and isolates compromised SMS payloads without waiting for manual confirmation.',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary, height: 1.3),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // 2. Protection Mode Selector
              const SectionHeader(title: 'Defense Posture Level'),
              ...ProtectionLevel.values.map((level) {
                final isSelected = settings.protectionLevel == level;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: GlassCard(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    borderColor: isSelected ? AppColors.cyberCyan : AppColors.borderCyber,
                    backgroundColor: isSelected ? AppColors.cyberCyanDark.withAlpha(80) : null,
                    onTap: () => viewModel.setProtectionLevel(level),
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? AppColors.cyberCyan : AppColors.textMuted,
                              width: 2,
                            ),
                          ),
                          child: isSelected
                              ? Center(
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.cyberCyan,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                level.title,
                                style: AppTypography.titleSmall.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? AppColors.cyberCyan : AppColors.textPrimary,
                                ),
                              ),
                              Text(level.description, style: AppTypography.bodySmall.copyWith(fontSize: 11)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 18),

              // 3. Real-Time Perimeter Guards
              const SectionHeader(title: 'Perimeter Watchdaemons'),
              GlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                child: Column(
                  children: [
                    _buildSwitchRow(
                      'Real-Time SMS & Phishing Heuristics',
                      'Inspects incoming texts for urgent bank tokens and fake links',
                      settings.isRealTimeSmsMonitoringEnabled,
                      (v) => viewModel.toggleSms(v),
                      Icons.sms_outlined,
                    ),
                    const Divider(color: AppColors.borderCyber),
                    _buildSwitchRow(
                      'DNS-over-HTTPS Encryption Shield',
                      'Prevents Wi-Fi captive portals from tampering with domain resolution',
                      settings.isNetworkDnsGuardEnabled,
                      (v) => viewModel.toggleDns(v),
                      Icons.lock_outline,
                    ),
                    const Divider(color: AppColors.borderCyber),
                    _buildSwitchRow(
                      'Sideloaded APK Package Blocker',
                      'Detects untrusted APK signatures and suspicious accessibility permissions',
                      settings.isSideloadAppProtectionEnabled,
                      (v) => viewModel.toggleSideload(v),
                      Icons.download_for_offline_outlined,
                    ),
                    const Divider(color: AppColors.borderCyber),
                    _buildSwitchRow(
                      'Dark Web Breach Telemetry Sync',
                      'Cross-references monitored identifiers against 14.2B breached records',
                      settings.isDarkWebTelemetryEnabled,
                      (v) => viewModel.toggleDarkWeb(v),
                      Icons.travel_explore,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // 4. Privacy & Engine Metadata
              const SectionHeader(title: 'Privacy & Neural Engine'),
              GlassCard(
                child: Column(
                  children: [
                    _buildSwitchRow(
                      'Zero-Knowledge On-Device Processing',
                      'All heuristics execute locally without transmitting telemetry off-device',
                      settings.isLocalAiProcessingOnly,
                      (v) => viewModel.toggleLocalAi(v),
                      Icons.memory,
                    ),
                    const SizedBox(height: 12),
                    const Divider(color: AppColors.borderCyber),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('AI Engine Model:', style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted)),
                        Text(settings.aiModelVersion, style: AppTypography.codeMono.copyWith(fontSize: 11, color: AppColors.cyberCyan)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Signature Database:', style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted)),
                        Text('v2026.10.08-STABLE', style: AppTypography.codeMono.copyWith(fontSize: 11)),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSwitchRow(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.cyberCyan, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.titleSmall.copyWith(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(subtitle, style: AppTypography.bodySmall.copyWith(fontSize: 11, color: AppColors.textMuted)),
              ],
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: AppColors.cyberCyan,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
