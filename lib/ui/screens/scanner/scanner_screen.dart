import 'package:flutter/material.dart';
import 'package:leads/core/theme/app_colors.dart';
import 'package:leads/core/theme/app_typography.dart';
import 'package:leads/data/models/scan_models.dart';
import 'package:leads/ui/components/glass_card.dart';
import 'package:leads/ui/components/section_header.dart';
import 'package:leads/ui/components/threat_card.dart';
import 'package:leads/ui/components/threat_radar_view.dart';
import 'package:leads/ui/screens/scanner/scanner_view_model.dart';

class ScannerScreen extends StatelessWidget {
  final ScannerViewModel viewModel;

  const ScannerScreen({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final state = viewModel.scanState;
        final isScanning = viewModel.isScanning;
        final isCompleted = state.status == ScanStatus.completed;

        return Scaffold(
          backgroundColor: AppColors.cyberBackground,
          appBar: AppBar(
            title: Text('AI NEURAL SCANNER', style: AppTypography.titleMedium.copyWith(letterSpacing: 0.5)),
            actions: [
              if (!isScanning)
                IconButton(
                  icon: const Icon(Icons.refresh, color: AppColors.cyberCyan),
                  onPressed: () => viewModel.startDeepScan(),
                ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            children: [
              // 1. Radar & Scan Visualizer
              GlassCard(
                child: Column(
                  children: [
                    Center(
                      child: ThreatRadarView(
                        size: 160,
                        activeThreatsCount: state.threatsDiscovered.length,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.currentStage.description,
                      style: AppTypography.titleSmall.copyWith(
                        color: AppColors.cyberCyan,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: state.progress,
                        backgroundColor: AppColors.cyberSurfaceLight,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.cyberCyan),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'STAGE: ${state.currentStage.code}',
                          style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted),
                        ),
                        Text(
                          '${(state.progress * 100).toInt()}% (${state.itemsScannedCount} items audited)',
                          style: AppTypography.labelSmall.copyWith(color: AppColors.cyberCyan),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: isScanning ? null : () => viewModel.startDeepScan(),
                        icon: Icon(isScanning ? Icons.hourglass_top : Icons.play_arrow),
                        label: Text(
                          isScanning
                              ? 'Scanning Defense Perimeters...'
                              : (isCompleted ? 'Re-Run Deep Diagnostic Scan' : 'Start Neural Deep Scan'),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isScanning ? AppColors.cyberSurfaceVariant : AppColors.cyberCyan,
                          foregroundColor: isScanning ? AppColors.textMuted : Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // 2. Real-Time Telemetry Log Console
              SectionHeader(
                title: 'Diagnostic Kernel Logs',
                badgeText: isScanning ? 'STREAMING' : 'IDLE',
                badgeColor: isScanning ? AppColors.severitySafe : AppColors.textMuted,
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.cyberSurface.withAlpha(220),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.borderCyber),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.terminal, size: 14, color: AppColors.cyberCyan),
                        const SizedBox(width: 6),
                        Text('LEADS_HEURISTIC_DAEMON', style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (state.logMessages.isEmpty)
                      Text(
                        'Ready to initiate security heuristics. Tap "Start Neural Deep Scan" above.',
                        style: AppTypography.codeMono.copyWith(fontSize: 11, color: AppColors.textMuted),
                      )
                    else
                      ...state.logMessages.map((msg) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text(
                            '❯ $msg',
                            style: AppTypography.codeMono.copyWith(fontSize: 11, color: AppColors.cyberCyan),
                          ),
                        );
                      }),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // 3. Scan Results
              if (isCompleted || state.threatsDiscovered.isNotEmpty) ...[
                SectionHeader(
                  title: 'Discovered Vulnerabilities & Anomalies',
                  badgeText: '${state.threatsDiscovered.length} FLAGGED',
                  badgeColor: state.threatsDiscovered.isEmpty ? AppColors.severitySafe : AppColors.severityCritical,
                ),
                if (state.threatsDiscovered.isEmpty)
                  GlassCard(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: Text(
                          'No anomalies discovered! All perimeter gates verified clean.',
                          style: AppTypography.bodySmall.copyWith(color: AppColors.severitySafe),
                        ),
                      ),
                    ),
                  )
                else
                  ...state.threatsDiscovered.map((threat) {
                    return ThreatCard(
                      threat: threat,
                      onMitigate: () => viewModel.mitigate(threat.id),
                    );
                  }),
              ],

              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}
