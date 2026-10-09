import 'package:flutter/material.dart';
import 'package:leads/core/theme/app_colors.dart';
import 'package:leads/core/theme/app_typography.dart';
import 'package:leads/ui/components/glass_card.dart';
import 'package:leads/ui/components/severity_badge.dart';
import 'package:leads/ui/screens/tools/tools_view_model.dart';

class WifiAuditorView extends StatelessWidget {
  final ToolsViewModel viewModel;

  const WifiAuditorView({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final audit = viewModel.wifiAudit;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        GlassCard(
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.severitySuspicious.withAlpha(30),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.wifi_find, color: AppColors.severitySuspicious, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Wi-Fi & Network Auditor', style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                    Text('DNS Hijacking, ARP Spoofing, & Rogue AP checks', style: AppTypography.bodySmall),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        if (audit != null) ...[
          GlassCard(
            borderColor: AppColors.severitySuspicious.withAlpha(100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.wifi, color: AppColors.severitySuspicious, size: 24),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(audit.ssid, style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                            Text('BSSID: ${audit.bssid} • ${audit.encryptionType}', style: AppTypography.codeMono.copyWith(fontSize: 10)),
                          ],
                        ),
                      ],
                    ),
                    SeverityBadge.fromSeverity(severity: audit.overallSafety),
                  ],
                ),
                const SizedBox(height: 14),
                const Divider(color: AppColors.borderCyber),
                const SizedBox(height: 8),
                _buildAuditRow('DNS Tampering & Hijacking Check', !audit.isDnsTamperingDetected, audit.isDnsTamperingDetected ? 'Tampered' : 'Verified Secure (DoH Active)'),
                _buildAuditRow('ARP Spoofing & MITM Proxy Watch', !audit.isArpSpoofingDetected, audit.isArpSpoofingDetected ? 'Gateway Inconsistency' : 'Clean (No ARP Poisoning)'),
                _buildAuditRow('Captive Portal SSL Interception', !audit.isCaptivePortal, audit.isCaptivePortal ? 'Open Captive Portal Detected' : 'Direct Gateway Access'),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.cyberSurfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.borderCyber),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: AppColors.cyberCyan, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          audit.advice,
                          style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary, height: 1.3),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAuditRow(String title, bool isClean, String detail) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.titleSmall.copyWith(fontSize: 12)),
                Text(detail, style: AppTypography.bodySmall.copyWith(fontSize: 11, color: isClean ? AppColors.severitySafe : AppColors.severityCritical)),
              ],
            ),
          ),
          Icon(
            isClean ? Icons.check_circle : Icons.warning_amber_rounded,
            color: isClean ? AppColors.severitySafe : AppColors.severityCritical,
            size: 18,
          ),
        ],
      ),
    );
  }
}
