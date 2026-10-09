import 'package:flutter/material.dart';
import 'package:leads/core/theme/app_colors.dart';
import 'package:leads/core/theme/app_typography.dart';
import 'package:leads/ui/components/cyber_gauge.dart';
import 'package:leads/ui/components/glass_card.dart';
import 'package:leads/ui/components/risk_score_card.dart';
import 'package:leads/ui/components/scam_graph_view.dart';
import 'package:leads/ui/components/section_header.dart';
import 'package:leads/ui/components/threat_card.dart';
import 'package:leads/ui/screens/dashboard/dashboard_view_model.dart';

class DashboardScreen extends StatelessWidget {
  final DashboardViewModel viewModel;
  final VoidCallback onNavigateToScanner;
  final VoidCallback onNavigateToChat;
  final Function(int) onNavigateToTools;
  final VoidCallback onNavigateToInvestigate;

  const DashboardScreen({
    super.key,
    required this.viewModel,
    required this.onNavigateToScanner,
    required this.onNavigateToChat,
    required this.onNavigateToTools,
    required this.onNavigateToInvestigate,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final score = viewModel.score;
        final activeThreats = viewModel.activeThreats;
        final incident = viewModel.primaryIncident;

        return Scaffold(
          backgroundColor: AppColors.cyberBackground,
          appBar: AppBar(
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.cyberCyan.withAlpha(30),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.cyberCyan, width: 1.5),
                  ),
                  child: const Icon(Icons.shield, color: AppColors.cyberCyan, size: 18),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('LEADS GUARDIAN', style: AppTypography.titleMedium.copyWith(letterSpacing: 0.5)),
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppColors.severitySafe,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'NEURAL SHIELD ACTIVE',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.severitySafe,
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.smart_toy_outlined, color: AppColors.cyberCyan),
                tooltip: 'AI Cybersecurity Agent',
                onPressed: onNavigateToChat,
              ),
              IconButton(
                icon: const Icon(Icons.radar, color: AppColors.cyberCyan),
                tooltip: 'Launch Deep Scan',
                onPressed: onNavigateToScanner,
              ),
            ],
          ),
          body: RefreshIndicator(
            color: AppColors.cyberCyan,
            backgroundColor: AppColors.cyberSurface,
            onRefresh: () async => onNavigateToScanner(),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                // 1. Live Threat Score & Gauge Section
                GlassCard(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'REAL-TIME POSTURE',
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.textMuted,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                activeThreats.isEmpty ? 'All Perimeters Secure' : '${activeThreats.length} High-Risk Threat Vectors',
                                style: AppTypography.titleSmall.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: activeThreats.isEmpty ? AppColors.severitySafe : AppColors.severityCritical,
                                ),
                              ),
                            ],
                          ),
                          OutlinedButton.icon(
                            onPressed: onNavigateToScanner,
                            icon: const Icon(Icons.refresh, size: 14),
                            label: const Text('Scan Now'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.cyberCyan,
                              side: const BorderSide(color: AppColors.cyberCyan),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: CyberGauge(
                          score: score.overallScore,
                          status: score.healthStatus,
                          size: 190,
                          onTap: onNavigateToScanner,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Sub-score Pillars
                      Row(
                        children: [
                          _buildSubScorePillar('Network', score.networkScore, Icons.wifi),
                          _buildSubScorePillar('Privacy', score.privacyScore, Icons.lock_outline),
                          _buildSubScorePillar('Identity', score.identityScore, Icons.person_search_outlined),
                          _buildSubScorePillar('System', score.systemScore, Icons.memory),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // 2. Correlated Incident Attack Graph Card
                if (incident != null) ...[
                  SectionHeader(
                    title: 'Active Correlated Campaign',
                    badgeText: '${incident.overallRiskScore}/100 CRITICAL',
                    badgeColor: AppColors.severityCritical,
                    actionLabel: 'Full Investigation →',
                    onAction: onNavigateToInvestigate,
                  ),
                  RiskScoreCard(
                    riskScore: incident.overallRiskScore,
                    severity: incident.severity,
                    title: incident.title,
                    subtitle: incident.summary,
                    onTap: onNavigateToInvestigate,
                  ),
                  const SizedBox(height: 12),
                  ScamGraphView(
                    incident: incident,
                    height: 280,
                    onNodeSelected: (node) {},
                  ),
                  const SizedBox(height: 18),
                ],

                // 3. Quick Defense Hub Launchers
                SectionHeader(
                  title: 'Defense Tools',
                  actionLabel: 'All Tools →',
                  onAction: () => onNavigateToTools(0),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildToolQuickCard(
                        title: 'Phishing\nAnalyzer',
                        icon: Icons.link_off,
                        color: AppColors.cyberCyan,
                        onTap: () => onNavigateToTools(0),
                      ),
                      _buildToolQuickCard(
                        title: 'App Privacy\nGuard',
                        icon: Icons.security,
                        color: AppColors.severityCritical,
                        onTap: () => onNavigateToTools(1),
                      ),
                      _buildToolQuickCard(
                        title: 'Wi-Fi\nAuditor',
                        icon: Icons.wifi_find,
                        color: AppColors.severitySuspicious,
                        onTap: () => onNavigateToTools(2),
                      ),
                      _buildToolQuickCard(
                        title: 'Dark Web\nMonitor',
                        icon: Icons.travel_explore,
                        color: AppColors.cyberPurple,
                        onTap: () => onNavigateToTools(3),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // 4. Active Threats Feed
                SectionHeader(
                  title: 'Detected Signals & Threat Feed',
                  badgeText: '${activeThreats.length} ACTIVE',
                  badgeColor: activeThreats.isEmpty ? AppColors.severitySafe : AppColors.severityHigh,
                ),
                if (activeThreats.isEmpty)
                  GlassCard(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Column(
                        children: [
                          const Icon(Icons.verified_user_outlined, size: 44, color: AppColors.severitySafe),
                          const SizedBox(height: 10),
                          Text(
                            'No active threats detected',
                            style: AppTypography.titleMedium.copyWith(color: AppColors.severitySafe),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Continuous neural telemetry is guarding SMS, installed apps, and Wi-Fi packets.',
                            style: AppTypography.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...activeThreats.map((threat) {
                    return ThreatCard(
                      threat: threat,
                      onMitigate: () => viewModel.mitigateThreat(threat.id),
                      onIgnore: () => viewModel.ignoreThreat(threat.id),
                    );
                  }),

                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSubScorePillar(String title, int scoreVal, IconData icon) {
    final color = scoreVal >= 80
        ? AppColors.severitySafe
        : (scoreVal >= 60 ? AppColors.severitySuspicious : AppColors.severityCritical);

    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.cyberSurfaceVariant.withAlpha(100),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.borderCyber.withAlpha(80)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(height: 4),
            Text('$scoreVal', style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold, color: color)),
            Text(title, style: AppTypography.labelSmall.copyWith(fontSize: 9, color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }

  Widget _buildToolQuickCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 110,
      margin: const EdgeInsets.only(right: 10),
      child: GlassCard(
        padding: const EdgeInsets.all(12),
        onTap: onTap,
        borderColor: color.withAlpha(80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withAlpha(30),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textPrimary,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
