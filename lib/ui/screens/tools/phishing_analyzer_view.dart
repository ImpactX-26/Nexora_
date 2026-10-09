import 'package:flutter/material.dart';
import 'package:leads/core/theme/app_colors.dart';
import 'package:leads/core/theme/app_typography.dart';
import 'package:leads/ui/components/glass_card.dart';
import 'package:leads/ui/components/severity_badge.dart';
import 'package:leads/ui/screens/tools/tools_view_model.dart';

class PhishingAnalyzerView extends StatefulWidget {
  final ToolsViewModel viewModel;

  const PhishingAnalyzerView({super.key, required this.viewModel});

  @override
  State<PhishingAnalyzerView> createState() => _PhishingAnalyzerViewState();
}

class _PhishingAnalyzerViewState extends State<PhishingAnalyzerView> {
  final TextEditingController _inputController = TextEditingController();

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _analyze([String? preset]) {
    final query = preset ?? _inputController.text;
    if (query.trim().isEmpty) return;
    if (preset != null) _inputController.text = preset;
    widget.viewModel.analyzePhishingQuery(query);
  }

  @override
  Widget build(BuildContext context) {
    final verdict = widget.viewModel.phishingVerdict;
    final isAnalyzing = widget.viewModel.isAnalyzingPhishing;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.cyberCyan.withAlpha(30),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.link_off, color: AppColors.cyberCyan, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Phishing & Deceptive URL Analyzer', style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                        Text('Real-time regex & heuristic decomposition of URLs & SMS text', style: AppTypography.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _inputController,
                maxLines: 3,
                minLines: 2,
                style: AppTypography.codeMono.copyWith(fontSize: 12),
                decoration: InputDecoration(
                  hintText: 'Paste suspicious link, SMS message, or domain name...',
                  hintStyle: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                  filled: true,
                  fillColor: AppColors.cyberSurfaceVariant,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.borderCyber),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.cyberCyan),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _buildExampleChip('https://wellsfarg0-secure.xyz/login'),
                  _buildExampleChip('Your PayPal is suspended: paypa1-verify.xyz'),
                  _buildExampleChip('https://google.com'),
                ],
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isAnalyzing ? null : () => _analyze(),
                  icon: Icon(isAnalyzing ? Icons.hourglass_empty : Icons.radar),
                  label: Text(isAnalyzing ? 'Decomposing Heuristics...' : 'Analyze Threat Heuristics'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.cyberCyan,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        if (verdict != null) ...[
          GlassCard(
            borderColor: verdict.isPhishing
                ? AppColors.severityCritical.withAlpha(120)
                : AppColors.severitySafe.withAlpha(120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SeverityBadge.fromSeverity(severity: verdict.riskSeverity),
                        const SizedBox(width: 8),
                        Text(
                          verdict.isPhishing ? 'MALICIOUS THREAT FLAGGED' : 'LOW RISK / SAFE',
                          style: AppTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: verdict.isPhishing ? AppColors.severityCritical : AppColors.severitySafe,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Risk: ${verdict.riskScore}/100',
                      style: AppTypography.labelLarge.copyWith(
                        color: verdict.riskScore > 50 ? AppColors.severityCritical : AppColors.severitySafe,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text('AI Recommendation:', style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted)),
                const SizedBox(height: 2),
                Text(
                  verdict.aiRecommendation,
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary, height: 1.35),
                ),
                const SizedBox(height: 12),
                const Divider(color: AppColors.borderCyber),
                const SizedBox(height: 8),
                Text('Detected Attack Tactics:', style: AppTypography.labelSmall.copyWith(color: AppColors.cyberCyan)),
                const SizedBox(height: 6),
                ...verdict.detectedTactics.map((tactic) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, size: 14, color: AppColors.severitySuspicious),
                        const SizedBox(width: 6),
                        Expanded(child: Text(tactic, style: AppTypography.bodySmall)),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 8),
                Text('Deceptive Indicators & Heuristic Flaws:', style: AppTypography.labelSmall.copyWith(color: AppColors.severityCritical)),
                const SizedBox(height: 6),
                ...verdict.deceptiveIndicators.map((ind) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ', style: TextStyle(color: AppColors.severityCritical, fontWeight: FontWeight.bold)),
                        Expanded(child: Text(ind, style: AppTypography.bodySmall)),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildExampleChip(String sample) {
    return InkWell(
      onTap: () => _analyze(sample),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.cyberSurfaceVariant,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.borderCyber),
        ),
        child: Text(
          sample,
          style: AppTypography.codeMono.copyWith(fontSize: 10, color: AppColors.textSecondary),
        ),
      ),
    );
  }
}
