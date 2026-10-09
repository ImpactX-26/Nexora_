import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:leads/core/theme/app_colors.dart';
import 'package:leads/domain/heuristic_analyzer.dart';
import 'package:leads/domain/url_diagnosis_service.dart';
import 'package:leads/ui/widgets/url_interception_popup.dart';

class UrlDiagnosisScreen extends StatefulWidget {
  final String? targetUrl;
  final bool isExternalIntercept;

  const UrlDiagnosisScreen({
    super.key,
    this.targetUrl,
    this.isExternalIntercept = false,
  });

  @override
  State<UrlDiagnosisScreen> createState() => _UrlDiagnosisScreenState();
}

class _UrlDiagnosisScreenState extends State<UrlDiagnosisScreen>
    with WidgetsBindingObserver {
  late TextEditingController _urlController;
  PhishingAnalysisVerdict? _currentVerdict;
  bool _isAnalyzing = false;
  bool _isAuthenticating = false;
  bool _isDefaultBrowser = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final initial = widget.targetUrl ?? '';
    _urlController = TextEditingController(text: initial);
    if (initial.isNotEmpty) {
      _analyzeUrl(initial);
    }
    _checkDefaultBrowserStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _urlController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkDefaultBrowserStatus();
    }
  }

  Future<void> _checkDefaultBrowserStatus() async {
    final isDef = await UrlDiagnosisService.isDefaultBrowser();
    if (mounted) {
      setState(() => _isDefaultBrowser = isDef);
    }
  }

  Future<void> _enableAutomaticLinkShield() async {
    await UrlDiagnosisService.requestDefaultBrowser();
  }

  void _analyzeUrl(String rawUrl) {
    if (rawUrl.trim().isEmpty) return;
    setState(() {
      _isAnalyzing = true;
    });

    final verdict = UrlDiagnosisService.diagnose(rawUrl.trim());

    setState(() {
      _currentVerdict = verdict;
      _isAnalyzing = false;
    });
  }

  Future<void> _handleProceedWithAuthentication() async {
    final verdict = _currentVerdict;
    if (verdict == null) return;

    setState(() => _isAuthenticating = true);

    // Show Device Biometric / Password Prompt
    final didAuth = await UrlDiagnosisService.authenticateWithDevicePassword(
      reason: 'Verify your device password or biometric to proceed to flagged URL: ${verdict.cleanUrlPreview ?? verdict.inputQuery}',
    );

    setState(() => _isAuthenticating = false);

    if (!mounted) return;

    if (didAuth) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Device verified. Redirecting to external browser...',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
          backgroundColor: const Color(0xFF1E2937),
          duration: const Duration(seconds: 2),
        ),
      );
      await UrlDiagnosisService.launchInExternalBrowser(verdict.inputQuery);
      if (mounted && widget.isExternalIntercept) {
        Navigator.of(context).maybePop();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Authentication cancelled. Redirection safely blocked.',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
          backgroundColor: const Color(0xFFDC2626),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _handleSafeLaunch() async {
    final verdict = _currentVerdict;
    if (verdict == null) return;
    await UrlDiagnosisService.launchInExternalBrowser(verdict.inputQuery);
    if (mounted && widget.isExternalIntercept) {
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1F231E), size: 20),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          title: Text(
            'leads',
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF5A5C61),
              letterSpacing: 1.2,
            ),
          ),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFF16A34A),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'URL Lead Active',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF374151),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            children: [
              // Intercept Notice Banner if opened via external app
              if (widget.isExternalIntercept)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFDE68A)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.security_rounded, color: Color(0xFFB45309), size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Link Intercepted: Leads inspected this URL before opening in your browser.',
                          style: GoogleFonts.inter(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF92400E),
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Title Section
              Text(
                'URL Diagnosis & Link Guard',
                style: GoogleFonts.outfit(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1E201E),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Real-time deep heuristic inspection for incoming redirection links, phishing campaigns, and malware distribution.',
                style: GoogleFonts.inter(
                  fontSize: 13.5,
                  color: const Color(0xFF555A54),
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 16),

              // Automatic WhatsApp / Telegram Interception Setup Card
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E201E),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _isDefaultBrowser ? const Color(0xFF16A34A) : AppColors.leadsLime,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            _isDefaultBrowser ? Icons.verified_user_rounded : Icons.flash_on_rounded,
                            color: _isDefaultBrowser ? Colors.white : const Color(0xFF1E201E),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _isDefaultBrowser ? 'Auto-Intercept Active' : 'Automatic Link Interception',
                                style: GoogleFonts.outfit(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _isDefaultBrowser
                                    ? 'All links clicked in WhatsApp, Telegram & SMS are intercepted & pre-screened automatically.'
                                    : 'Set leads as your Default Link Shield so links clicked in WhatsApp & other apps open here automatically.',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: const Color(0xFFB0B3B8),
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (!_isDefaultBrowser) ...[
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        height: 40,
                        child: ElevatedButton.icon(
                          onPressed: _enableAutomaticLinkShield,
                          icon: const Icon(Icons.shield_rounded, size: 18),
                          label: Text(
                            'Enable Auto-Intercept (Set Default)',
                            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.leadsLime,
                            foregroundColor: const Color(0xFF1E201E),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Input Bar & Action
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFAFAFA),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _urlController,
                      maxLines: 2,
                      minLines: 1,
                      style: GoogleFonts.inter(fontSize: 13.5, color: const Color(0xFF1F2937)),
                      decoration: InputDecoration(
                        hintText: 'Enter or paste link (e.g. https://...)',
                        hintStyle: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF9CA3AF)),
                        prefixIcon: const Icon(Icons.link_rounded, color: Color(0xFF5A5C61), size: 20),
                        suffixIcon: _urlController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 18),
                                onPressed: () {
                                  _urlController.clear();
                                  setState(() => _currentVerdict = null);
                                },
                              )
                            : IconButton(
                                icon: const Icon(Icons.content_paste_rounded, size: 18),
                                tooltip: 'Paste from clipboard',
                                onPressed: () async {
                                  final data = await Clipboard.getData(Clipboard.kTextPlain);
                                  if (data?.text != null) {
                                    _urlController.text = data!.text!;
                                    _analyzeUrl(data.text!);
                                  }
                                },
                              ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                      onSubmitted: _analyzeUrl,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton(
                          onPressed: _isAnalyzing
                              ? null
                              : () => _analyzeUrl(_urlController.text),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.leadsLime,
                            foregroundColor: const Color(0xFF2C302E),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: _isAnalyzing
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color(0xFF2C302E),
                                  ),
                                )
                              : Text(
                                  'Diagnose URL',
                                  style: GoogleFonts.outfit(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Test Preset Shortcuts
              Text(
                'QUICK TEST SCENARIOS',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF7A8077),
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _buildTestScenarioChip(
                      label: '🚨 Fake Bank KYC APK',
                      url: 'http://192.168.1.100/sbi-kyc-update.apk',
                    ),
                    const SizedBox(width: 8),
                    _buildTestScenarioChip(
                      label: '🚨 PayPal Phish',
                      url: 'http://paypa1-security-verify.xyz/login',
                    ),
                    const SizedBox(width: 8),
                    _buildTestScenarioChip(
                      label: '🚨 Account Blocked',
                      url: 'https://account-suspended-verify.top/auth',
                    ),
                    const SizedBox(width: 8),
                    _buildTestScenarioChip(
                      label: '🛡️ Safe Link (Google)',
                      url: 'https://google.com/search',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Simulation button for popup modal
              SizedBox(
                width: double.infinity,
                height: 40,
                child: OutlinedButton.icon(
                  onPressed: () {
                    final target = _urlController.text.isNotEmpty
                        ? _urlController.text
                        : 'http://192.168.1.100/sbi-kyc-update.apk';
                    UrlInterceptionPopup.show(context, target);
                  },
                  icon: const Icon(Icons.picture_in_picture_alt_rounded, size: 16),
                  label: Text(
                    'Preview Interception Popup Modal',
                    style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF1E201E),
                    side: const BorderSide(color: Color(0xFFD1D5DB)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Analysis Results Card
              if (_currentVerdict != null) _buildVerdictCard(_currentVerdict!),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTestScenarioChip({required String label, required String url}) {
    return ActionChip(
      label: Text(label),
      labelStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF374151),
      ),
      backgroundColor: const Color(0xFFF3F4F6),
      side: const BorderSide(color: Color(0xFFE5E7EB)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onPressed: () {
        _urlController.text = url;
        _analyzeUrl(url);
      },
    );
  }

  Widget _buildVerdictCard(PhishingAnalysisVerdict verdict) {
    final isThreat = verdict.isPhishing || verdict.riskScore >= 45;
    final isSuspicious = !isThreat && verdict.riskScore >= 20;

    final Color statusBg = isThreat
        ? const Color(0xFFFEF2F2)
        : isSuspicious
            ? const Color(0xFFFFFBEB)
            : const Color(0xFFF0FDF4);

    final Color statusBorder = isThreat
        ? const Color(0xFFFECACA)
        : isSuspicious
            ? const Color(0xFFFDE68A)
            : const Color(0xFFDCFCE7);

    final Color primaryColor = isThreat
        ? const Color(0xFFDC2626)
        : isSuspicious
            ? const Color(0xFFD97706)
            : const Color(0xFF16A34A);

    final String statusHeader = isThreat
        ? 'MALICIOUS THREAT DETECTED'
        : isSuspicious
            ? 'SUSPICIOUS REDIRECTION DETECTED'
            : 'CLEAN & SAFE URL';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: statusBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: statusBorder, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    isThreat
                        ? Icons.gpp_bad_rounded
                        : isSuspicious
                            ? Icons.warning_amber_rounded
                            : Icons.verified_user_rounded,
                    color: primaryColor,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    statusHeader,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: primaryColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Risk Score: ${verdict.riskScore}/100',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: primaryColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // URL Target Display
          Text(
            'Target Destination:',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 2),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Text(
              verdict.inputQuery,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1F2937),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Detected Threat Vectors
          Text(
            'Detected Vectors & Indicators:',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 6),
          ...verdict.detectedTactics.map((tactic) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      isThreat ? Icons.dangerous_rounded : Icons.check_circle_rounded,
                      size: 14,
                      color: primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        tactic,
                        style: GoogleFonts.inter(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                    ),
                  ],
                ),
              )),

          const SizedBox(height: 12),

          // Security Advice
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: statusBorder),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded, size: 16, color: primaryColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    verdict.aiRecommendation,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF4B5563),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Action Buttons
          if (!isThreat && !isSuspicious)
            // Clean URL: Open in Browser
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.open_in_browser_rounded, size: 18),
                label: Text(
                  'Open in Browser (Safe)',
                  style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w800),
                ),
                onPressed: _handleSafeLaunch,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.leadsLime,
                  foregroundColor: const Color(0xFF2C302E),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            )
          else
            // Threat / Suspicious URL: Block or Override with Device Password
            Column(
              children: [
                // 1. Recommended Action: Block & Abort
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.block_rounded, size: 18),
                    label: Text(
                      'Block & Abort (Recommended)',
                      style: GoogleFonts.outfit(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Redirection blocked. Threat neutralized.',
                            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                          ),
                          backgroundColor: const Color(0xFF16A34A),
                        ),
                      );
                      Navigator.of(context).maybePop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E2937),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // 2. Risk Override: Authenticate via Device Password
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: OutlinedButton.icon(
                    icon: _isAuthenticating
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFDC2626)),
                          )
                        : const Icon(Icons.lock_outline_rounded, size: 16, color: Color(0xFFDC2626)),
                    label: Text(
                      'Proceed with Mobile Password',
                      style: GoogleFonts.outfit(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFDC2626),
                      ),
                    ),
                    onPressed: _isAuthenticating ? null : _handleProceedWithAuthentication,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFFCA5A5), width: 1.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
