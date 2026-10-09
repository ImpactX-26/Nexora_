import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:leads/core/theme/app_colors.dart';
import 'package:leads/domain/heuristic_analyzer.dart';
import 'package:leads/domain/url_diagnosis_service.dart';

class UrlInterceptionPopup extends StatefulWidget {
  final String rawUrl;
  final VoidCallback? onDismiss;

  const UrlInterceptionPopup({
    super.key,
    required this.rawUrl,
    this.onDismiss,
  });

  static Future<void> show(BuildContext context, String url) async {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: false,
      isDismissible: false,
      builder: (ctx) => UrlInterceptionPopup(rawUrl: url),
    );
  }

  @override
  State<UrlInterceptionPopup> createState() => _UrlInterceptionPopupState();
}

class _UrlInterceptionPopupState extends State<UrlInterceptionPopup>
    with SingleTickerProviderStateMixin {
  bool _isAnalyzing = true;
  PhishingAnalysisVerdict? _verdict;
  Timer? _autoRedirectTimer;
  int _redirectCountdown = 2;
  bool _isAuthenticating = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _runAnalysis();
  }

  @override
  void dispose() {
    _autoRedirectTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _runAnalysis() async {
    setState(() => _isAnalyzing = true);

    // Provide authentic security inspection animation pause (900ms)
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    final verdict = UrlDiagnosisService.diagnose(widget.rawUrl);

    setState(() {
      _verdict = verdict;
      _isAnalyzing = false;
    });

    // If Safe (Score < 30), automatically redirect
    if (verdict.riskScore < 30) {
      _startAutoRedirect(verdict.inputQuery);
    }
  }

  void _startAutoRedirect(String targetUrl) {
    _autoRedirectTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_redirectCountdown <= 1) {
        timer.cancel();
        await _executeBrowserLaunch(targetUrl);
      } else {
        setState(() {
          _redirectCountdown--;
        });
      }
    });
  }

  Future<void> _executeBrowserLaunch(String targetUrl) async {
    await UrlDiagnosisService.launchInExternalBrowser(targetUrl);
    if (mounted) {
      Navigator.of(context).maybePop();
      widget.onDismiss?.call();
    }
  }

  Future<void> _handleProceedWithPassword() async {
    final verdict = _verdict;
    if (verdict == null) return;

    setState(() => _isAuthenticating = true);

    final bool didAuth = await UrlDiagnosisService.authenticateWithDevicePassword(
      reason: 'Enter your Mobile Password or PIN to proceed to suspicious URL',
    );

    setState(() => _isAuthenticating = false);

    if (!mounted) return;

    if (didAuth) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Device verified. Redirecting to browser...',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
          backgroundColor: const Color(0xFF1E2937),
          duration: const Duration(seconds: 2),
        ),
      );
      await _executeBrowserLaunch(verdict.inputQuery);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Authentication failed/cancelled. Link safely blocked.',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
          backgroundColor: const Color(0xFFDC2626),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSafe = _verdict != null && _verdict!.riskScore < 30;
    final isThreat = _verdict != null && _verdict!.riskScore >= 30;

    return PopScope(
      canPop: !_isAnalyzing,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: const Color(0xFF1B1D1C),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _isAnalyzing
                ? AppColors.leadsLime.withValues(alpha: 0.5)
                : isSafe
                    ? const Color(0xFF16A34A).withValues(alpha: 0.8)
                    : const Color(0xFFDC2626).withValues(alpha: 0.8),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.6),
              blurRadius: 25,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Header: App Name & Security Status Tag
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: _isAnalyzing
                            ? AppColors.leadsLime
                            : isSafe
                                ? const Color(0xFF22C55E)
                                : const Color(0xFFEF4444),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'leads · URL Lead',
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _isAnalyzing
                        ? 'ANALYZING'
                        : isSafe
                            ? 'SAFE VERDICT'
                            : 'THREAT WARNING',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _isAnalyzing
                          ? AppColors.leadsLime
                          : isSafe
                              ? const Color(0xFF4ADE80)
                              : const Color(0xFFF87171),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // Target URL Box
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.link_rounded, color: Color(0xFF9CA3AF), size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.rawUrl,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFE5E7EB),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Main Body: Scanning vs Safe vs Threat
            if (_isAnalyzing) ...[
              Center(
                child: Column(
                  children: [
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.leadsLime.withValues(
                              alpha: 0.1 + (_pulseController.value * 0.15),
                            ),
                            border: Border.all(
                              color: AppColors.leadsLime.withValues(
                                alpha: 0.4 + (_pulseController.value * 0.5),
                              ),
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.radar_rounded,
                            size: 38,
                            color: AppColors.leadsLime,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Deep Link Inspection in Progress...',
                      style: GoogleFonts.outfit(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Analyzing brand integrity, raw IP, malware payloads & typosquatting',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFF9CA3AF),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (isSafe) ...[
              // 🟢 SAFE VERDICT VIEW
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF14532D).withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF16A34A).withValues(alpha: 0.5)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Color(0xFF16A34A),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check_rounded, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Link is Safe & Verified',
                            style: GoogleFonts.outfit(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF4ADE80),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'No malicious vectors or deception detected.\nAuto-opening in browser in $_redirectCountdown s...',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: const Color(0xFFD1D5DB),
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 46,
                child: ElevatedButton.icon(
                  onPressed: () => _executeBrowserLaunch(widget.rawUrl),
                  icon: const Icon(Icons.open_in_browser_rounded, size: 18),
                  label: Text(
                    'Open in Browser Now',
                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16A34A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ] else if (isThreat) ...[
              // 🔴 THREAT VERDICT VIEW
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF7F1D1D).withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFDC2626).withValues(alpha: 0.6)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: Color(0xFFDC2626),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Suspicious Link Detected!',
                                style: GoogleFonts.outfit(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFFF87171),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Risk Score: ${_verdict?.riskScore ?? 85}/100 (${_verdict?.riskSeverity.name.toUpperCase() ?? "CRITICAL"})',
                                style: GoogleFonts.inter(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFFFCA5A5),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _verdict?.aiRecommendation ??
                          'This URL exhibits severe phishing traits, unencrypted raw IP host, or dangerous download payloads.',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFFE5E7EB),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Action Buttons: Safe Block (Default) vs Mobile Password Override
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 46,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).maybePop();
                          widget.onDismiss?.call();
                        },
                        icon: const Icon(Icons.shield_rounded, size: 18),
                        label: Text(
                          'Block & Abort',
                          style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w700),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.leadsLime,
                          foregroundColor: const Color(0xFF1E201E),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 46,
                      child: OutlinedButton.icon(
                        onPressed: _isAuthenticating ? null : _handleProceedWithPassword,
                        icon: _isAuthenticating
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.lock_open_rounded, size: 18),
                        label: Text(
                          'Proceed (Password)',
                          style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w600),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFF87171),
                          side: const BorderSide(color: Color(0xFFDC2626)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
