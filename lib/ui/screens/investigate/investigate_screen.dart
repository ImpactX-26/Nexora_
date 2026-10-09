import 'package:flutter/material.dart';
import 'package:leads/core/theme/app_colors.dart';
import 'package:leads/core/theme/app_typography.dart';
import 'package:leads/data/models/coordinated_incident.dart';
import 'package:leads/ui/components/evidence_card.dart';
import 'package:leads/ui/components/glass_card.dart';
import 'package:leads/ui/components/recommendation_card.dart';
import 'package:leads/ui/components/risk_score_card.dart';
import 'package:leads/ui/components/scam_graph_view.dart';
import 'package:leads/ui/components/severity_badge.dart';
import 'package:leads/ui/components/timeline_item_view.dart';
import 'package:leads/ui/screens/investigate/investigate_view_model.dart';

class InvestigateScreen extends StatelessWidget {
  final InvestigateViewModel viewModel;

  const InvestigateScreen({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final incident = viewModel.incident;
        final selectedTab = viewModel.selectedTabIndex;

        return Scaffold(
          backgroundColor: AppColors.cyberBackground,
          appBar: AppBar(
            title: Text('INCIDENT INVESTIGATION', style: AppTypography.titleMedium.copyWith(letterSpacing: 0.5)),
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            children: [
              // 1. Incident Overview Header
              RiskScoreCard(
                riskScore: incident.overallRiskScore,
                severity: incident.severity,
                title: incident.title,
                subtitle: incident.summary,
              ),

              const SizedBox(height: 14),

              // Telemetry Info Bar
              GlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.bolt, color: AppColors.severityCritical, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'Vector: ${incident.attackVector}',
                          style: AppTypography.codeMono.copyWith(fontSize: 10, color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                    SeverityBadge.fromLevel(severity: incident.severity),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 2. Tab Navigation
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildTabButton('Attack Graph', 0, Icons.hub_outlined),
                    _buildTabButton('Timeline (${incident.timeline.length})', 1, Icons.timeline),
                    _buildTabButton('Forensic Evidence (${incident.evidenceList.length})', 2, Icons.fact_check_outlined),
                    _buildTabButton('Remediation (${incident.recommendedActions.length})', 3, Icons.checklist),
                    _buildTabButton('AI Triage (${incident.investigationSteps.length})', 4, Icons.auto_awesome),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 3. Tab Content
              if (selectedTab == 0) ...[
                ScamGraphView(
                  incident: incident,
                  height: 380,
                  onNodeSelected: (node) => viewModel.selectNode(node),
                ),
              ] else if (selectedTab == 1) ...[
                ...incident.timeline.asMap().entries.map((entry) {
                  return TimelineItemView(
                    event: entry.value,
                    isLast: entry.key == incident.timeline.length - 1,
                  );
                }),
              ] else if (selectedTab == 2) ...[
                ...incident.evidenceList.map((artifact) {
                  return EvidenceCard(artifact: artifact);
                }),
              ] else if (selectedTab == 3) ...[
                ...incident.recommendedActions.map((action) {
                  return RecommendationCard(
                    action: action,
                    onToggle: () => viewModel.toggleAction(action.id),
                  );
                }),
              ] else if (selectedTab == 4) ...[
                ...incident.investigationSteps.map((step) {
                  return _buildInvestigationStepCard(step);
                }),
              ],

              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabButton(String label, int index, IconData icon) {
    final isSelected = viewModel.selectedTabIndex == index;
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        showCheckmark: false,
        avatar: Icon(
          icon,
          size: 16,
          color: isSelected ? AppColors.cyberCyan : AppColors.textMuted,
        ),
        label: Text(label),
        labelStyle: AppTypography.labelSmall.copyWith(
          color: isSelected ? AppColors.cyberCyan : AppColors.textSecondary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        backgroundColor: AppColors.cyberSurface,
        selectedColor: AppColors.cyberCyanDark.withAlpha(160),
        side: BorderSide(
          color: isSelected ? AppColors.cyberCyan : AppColors.borderCyber,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        onSelected: (_) => viewModel.selectTab(index),
      ),
    );
  }

  Widget _buildInvestigationStepCard(InvestigationStep step) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cyberSurfaceVariant.withAlpha(140),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderCyber),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: AppColors.cyberCyan,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${step.stepNumber}',
                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  step.title,
                  style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
              ),
              const Icon(Icons.check_circle, size: 18, color: AppColors.severitySafe),
            ],
          ),
          const SizedBox(height: 8),
          Text('Analysis:', style: AppTypography.labelSmall.copyWith(color: AppColors.cyberCyan)),
          Text(step.analysis, style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary, height: 1.3)),
          const SizedBox(height: 6),
          Text('Findings:', style: AppTypography.labelSmall.copyWith(color: AppColors.severitySuspicious)),
          Text(step.findings, style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary, height: 1.3)),
        ],
      ),
    );
  }
}
