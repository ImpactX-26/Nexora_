import 'package:flutter/material.dart';
import 'package:leads/core/theme/app_colors.dart';
import 'package:leads/core/theme/app_typography.dart';
import 'package:leads/ui/components/recommendation_card.dart';
import 'package:leads/ui/components/section_header.dart';
import 'package:leads/ui/screens/investigate/investigate_view_model.dart';

class RecommendationsScreen extends StatelessWidget {
  final InvestigateViewModel viewModel;

  const RecommendationsScreen({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final actions = viewModel.incident.recommendedActions;
        final completedCount = actions.where((a) => a.isCompleted).length;

        return Scaffold(
          backgroundColor: AppColors.cyberBackground,
          appBar: AppBar(
            title: Text('REMEDIATION ACTIONS', style: AppTypography.titleMedium.copyWith(letterSpacing: 0.5)),
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            children: [
              SectionHeader(
                title: 'Remediation Checklist',
                badgeText: '$completedCount / ${actions.length} RESOLVED',
                badgeColor: completedCount == actions.length ? AppColors.severitySafe : AppColors.severityHigh,
              ),
              const SizedBox(height: 8),
              ...actions.map((action) {
                return RecommendationCard(
                  action: action,
                  onToggle: () => viewModel.toggleAction(action.id),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
