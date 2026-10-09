import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:leads/core/theme/app_colors.dart';
import 'package:leads/data/models/call_threat_item.dart';
import 'package:leads/domain/voice_leads_service.dart';

class VoiceLeadsScreen extends StatefulWidget {
  const VoiceLeadsScreen({super.key});

  @override
  State<VoiceLeadsScreen> createState() => _VoiceLeadsScreenState();
}

class _VoiceLeadsScreenState extends State<VoiceLeadsScreen>
    with SingleTickerProviderStateMixin {
  VoiceLeadsState _voiceState = VoiceLeadsState.idle;
  int _seconds = 0;
  List<double> _amplitudes = List.filled(24, 0.2);
  CallThreatVerdict? _latestVerdict;
  String _selectedScenario = 'digital_arrest';
  final TextEditingController _customTextController = TextEditingController();
  final TextEditingController _callerNumberController =
      TextEditingController(text: '+91 22 2652 9000');

  StreamSubscription? _stateSub;
  StreamSubscription? _durationSub;
  StreamSubscription? _amplitudeSub;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    VoiceLeadsService.initialize();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _stateSub = VoiceLeadsService.onStateChanged.listen((state) {
      if (mounted) setState(() => _voiceState = state);
    });

    _durationSub = VoiceLeadsService.onDurationTick.listen((sec) {
      if (mounted) setState(() => _seconds = sec);
    });

    _amplitudeSub = VoiceLeadsService.onAmplitudeUpdate.listen((amps) {
      if (mounted) setState(() => _amplitudes = amps);
    });
  }

  @override
  void dispose() {
    _stateSub?.cancel();
    _durationSub?.cancel();
    _amplitudeSub?.cancel();
    _pulseController.dispose();
    _customTextController.dispose();
    _callerNumberController.dispose();
    super.dispose();
  }

  void _startLiveCallMonitoring() {
    VoiceLeadsService.startRecording(
      callerNumber: _callerNumberController.text.trim(),
    );
  }

  Future<void> _stopAndRunVoiceAnalysis() async {
    final verdict = await VoiceLeadsService.stopAndAnalyze(
      callerNumber: _callerNumberController.text.trim(),
      scenarioType: _selectedScenario,
      customTranscript: _customTextController.text.isNotEmpty
          ? _customTextController.text.trim()
          : null,
    );

    if (mounted) {
      setState(() {
        _latestVerdict = verdict;
      });
      _showVerdictBottomSheet(verdict);
    }
  }

  String _formatDuration(int totalSeconds) {
    final m = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final isRecording = _voiceState == VoiceLeadsState.recording;
    final isAnalyzing = _voiceState == VoiceLeadsState.analyzing;

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
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Color(0xFF1F231E), size: 20),
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
                color: isRecording
                    ? const Color(0xFFFEE2E2)
                    : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isRecording
                      ? const Color(0xFFFECDD3)
                      : const Color(0xFFE5E7EB),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: isRecording
                          ? const Color(0xFFDC2626)
                          : const Color(0xFF16A34A),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isRecording ? 'LIVE CALL ACTIVE' : 'VOICE SENTINEL',
                    style: GoogleFonts.inter(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: isRecording
                          ? const Color(0xFF991B1B)
                          : const Color(0xFF374151),
                      letterSpacing: 0.5,
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
              // Title Header
              Text(
                'Voice Leads · Call Threat Sentinel',
                style: GoogleFonts.outfit(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1E201E),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Real-time acoustic & conversational AI analysis to protect you against Digital Arrest, Fake CBI, and Banking Vishing scams during live calls.',
                style: GoogleFonts.inter(
                  fontSize: 13.5,
                  color: const Color(0xFF555A54),
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 20),

              // MAIN LIVE IN-CALL CONSOLE
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B1D1C),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isRecording
                        ? const Color(0xFFDC2626).withValues(alpha: 0.8)
                        : isAnalyzing
                            ? AppColors.leadsLime
                            : const Color(0xFF333835),
                    width: isRecording ? 2 : 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Status Badge & Duration Timer
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              AnimatedBuilder(
                                animation: _pulseController,
                                builder: (context, child) {
                                  return Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: isRecording
                                          ? const Color(0xFFEF4444)
                                          : isAnalyzing
                                              ? AppColors.leadsLime
                                              : const Color(0xFF9CA3AF),
                                      shape: BoxShape.circle,
                                      boxShadow: isRecording
                                          ? [
                                              BoxShadow(
                                                color: const Color(0xFFEF4444)
                                                    .withValues(
                                                        alpha: 0.3 +
                                                            (_pulseController
                                                                    .value *
                                                                0.5)),
                                                blurRadius: 10,
                                                spreadRadius: 2,
                                              )
                                            ]
                                          : null,
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  isRecording
                                      ? 'RECORDING IN-CALL AUDIO'
                                      : isAnalyzing
                                          ? 'AI DEEP ACOUSTIC SCAN'
                                          : 'STANDBY · READY TO MONITOR',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: isRecording
                                        ? const Color(0xFFFCA5A5)
                                        : isAnalyzing
                                            ? AppColors.leadsLime
                                            : const Color(0xFF9CA3AF),
                                    letterSpacing: 0.6,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatDuration(_seconds),
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: isRecording
                                ? Colors.white
                                : const Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Dynamic Audio Waveform Visualizer
                    SizedBox(
                      height: 56,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: List.generate(_amplitudes.length, (index) {
                          final height = isRecording
                              ? (10 + (_amplitudes[index] * 46)).clamp(6.0, 56.0)
                              : 8.0;

                          return Container(
                            width: 5,
                            height: height,
                            margin: const EdgeInsets.symmetric(horizontal: 2.5),
                            decoration: BoxDecoration(
                              color: isRecording
                                  ? (index % 2 == 0
                                      ? AppColors.leadsLime
                                      : const Color(0xFF22C55E))
                                  : const Color(0xFF4B5563),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          );
                        }),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Caller Info Box
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.phone_in_talk_rounded,
                              color: AppColors.leadsLime, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _callerNumberController,
                              enabled: !isRecording && !isAnalyzing,
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                              decoration: InputDecoration(
                                isDense: true,
                                border: InputBorder.none,
                                hintText: 'Enter Caller Number',
                                hintStyle: GoogleFonts.jetBrainsMono(
                                  fontSize: 13,
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // MAIN PANIC / ACTION BUTTON
                    if (isAnalyzing) ...[
                      SizedBox(
                        height: 52,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: AppColors.leadsLime,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Analyzing Conversational Intent...',
                              style: GoogleFonts.outfit(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.leadsLime,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else if (!isRecording) ...[
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: _startLiveCallMonitoring,
                          icon: const Icon(Icons.mic_rounded, size: 22),
                          label: Text(
                            'Record & Analyse with Voice Leads',
                            style: GoogleFonts.outfit(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.leadsLime,
                            foregroundColor: const Color(0xFF1E201E),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ] else ...[
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: _stopAndRunVoiceAnalysis,
                          icon: const Icon(Icons.stop_circle_rounded,
                              size: 22, color: Colors.white),
                          label: Text(
                            'Stop & Finalize Scam Analysis',
                            style: GoogleFonts.outfit(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFDC2626),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              if (_latestVerdict != null) ...[
                const SizedBox(height: 20),
                Text(
                  'LATEST CALL SECURITY ASSESSMENT',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF7A8077),
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                _buildHistoryCallCard(_latestVerdict!),
              ],

              const SizedBox(height: 24),

              // SCENARIO SANDBOX SELECTOR
              Text(
                'LIVE CALL SCENARIO SANDBOX',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF7A8077),
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 10),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _buildScenarioChoiceChip(
                      id: 'digital_arrest',
                      label: '🚨 Digital Arrest CBI Call',
                      number: '+91 22 2652 9000',
                    ),
                    const SizedBox(width: 8),
                    _buildScenarioChoiceChip(
                      id: 'bank_kyc',
                      label: '🚨 Bank OTP & KYC Block',
                      number: '+91 98402 11234',
                    ),
                    const SizedBox(width: 8),
                    _buildScenarioChoiceChip(
                      id: 'lottery_scam',
                      label: '🚨 KBC 25 Lakh Lottery',
                      number: '+91 97120 44556',
                    ),
                    const SizedBox(width: 8),
                    _buildScenarioChoiceChip(
                      id: 'safe_call',
                      label: '🟢 Safe Broadband Call',
                      number: '+91 94440 55667',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // CALL AUDIT & RECENT THREAT LOGS
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'RECENT CALL ANALYTICS',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF7A8077),
                      letterSpacing: 1.2,
                    ),
                  ),
                  Text(
                    '${VoiceLeadsService.cachedHistory.length} Scans',
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (VoiceLeadsService.cachedHistory.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Center(
                    child: Text(
                      'No calls recorded yet. Tap "Record & Analyse with Voice Leads" above to inspect incoming calls.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                          fontSize: 13, color: const Color(0xFF6B7280)),
                    ),
                  ),
                )
              else
                ...VoiceLeadsService.cachedHistory.map((item) {
                  return _buildHistoryCallCard(item);
                }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScenarioChoiceChip({
    required String id,
    required String label,
    required String number,
  }) {
    final isSelected = _selectedScenario == id;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) {
        if (val) {
          setState(() {
            _selectedScenario = id;
            _callerNumberController.text = number;
          });
        }
      },
      selectedColor: AppColors.leadsLime,
      backgroundColor: const Color(0xFFF3F4F6),
      labelStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        color: isSelected ? const Color(0xFF1E201E) : const Color(0xFF374151),
      ),
      side: BorderSide(
        color: isSelected ? AppColors.leadsLime : const Color(0xFFE5E7EB),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  Widget _buildHistoryCallCard(CallThreatVerdict item) {
    final timeStr = DateFormat('dd MMM • hh:mm a').format(item.timestamp);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: item.isScam ? const Color(0xFFFEF2F2) : const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: item.isScam
              ? const Color(0xFFFECDD3)
              : const Color(0xFFBBF7D0),
        ),
      ),
      child: InkWell(
        onTap: () => _showVerdictBottomSheet(item),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      item.isScam
                          ? Icons.warning_amber_rounded
                          : Icons.verified_user_rounded,
                      color: item.isScam
                          ? const Color(0xFFDC2626)
                          : const Color(0xFF16A34A),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      item.callerName,
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E201E),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: item.isScam
                        ? const Color(0xFFDC2626)
                        : const Color(0xFF16A34A),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    item.isScam ? 'RISK ${item.riskScore}%' : 'SAFE',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${item.callerNumber} · ${item.durationSeconds}s duration · $timeStr',
              style: GoogleFonts.inter(
                fontSize: 11.5,
                color: const Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item.aiRecommendation,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 12.5,
                color: item.isScam
                    ? const Color(0xFF991B1B)
                    : const Color(0xFF14532D),
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showVerdictBottomSheet(CallThreatVerdict verdict) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: const Color(0xFF1B1D1C),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: verdict.isScam
                  ? const Color(0xFFDC2626).withValues(alpha: 0.8)
                  : const Color(0xFF16A34A).withValues(alpha: 0.8),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: verdict.isScam
                              ? const Color(0xFFDC2626)
                              : const Color(0xFF16A34A),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          verdict.isScam
                              ? Icons.gavel_rounded
                              : Icons.check_circle_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            verdict.isScam
                                ? 'SCAM DETECTED'
                                : 'SAFE CALL VERIFIED',
                            style: GoogleFonts.outfit(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: verdict.isScam
                                  ? const Color(0xFFF87171)
                                  : const Color(0xFF4ADE80),
                            ),
                          ),
                          Text(
                            'Risk Score: ${verdict.riskScore}/100 · ${verdict.scamCategory}',
                            style: GoogleFonts.inter(
                              fontSize: 11.5,
                              color: const Color(0xFF9CA3AF),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded,
                        color: Color(0xFF9CA3AF)),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // AI Recommendation Box
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: verdict.isScam
                      ? const Color(0xFF7F1D1D).withValues(alpha: 0.35)
                      : const Color(0xFF14532D).withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: verdict.isScam
                        ? const Color(0xFFDC2626).withValues(alpha: 0.6)
                        : const Color(0xFF16A34A).withValues(alpha: 0.6),
                  ),
                ),
                child: Text(
                  verdict.aiRecommendation,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.white,
                    height: 1.4,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Identified Scam Tactics
              if (verdict.detectedTactics.isNotEmpty) ...[
                Text(
                  'DETECTED COERCION & SCAM TACTICS',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF9CA3AF),
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: verdict.detectedTactics.map((tactic) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF374151),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        tactic,
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          color: const Color(0xFFFCA5A5),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
              ],

              // Transcript Preview
              Text(
                'LIVE CONVERSATION TRANSCRIPT',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF9CA3AF),
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 8),

              Container(
                constraints: const BoxConstraints(maxHeight: 180),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.08)),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(12),
                  itemCount: verdict.transcript.length,
                  separatorBuilder: (c, i) => const SizedBox(height: 8),
                  itemBuilder: (c, i) {
                    final seg = verdict.transcript[i];
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${seg.timeOffset} [${seg.speaker}]: ',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: seg.isSuspicious
                                ? const Color(0xFFF87171)
                                : AppColors.leadsLime,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            seg.text,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: seg.isSuspicious
                                  ? const Color(0xFFFCA5A5)
                                  : const Color(0xFFE5E7EB),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(height: 18),

              // Action Buttons: Block vs Dismiss
              if (verdict.isScam)
                SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Caller ${verdict.callerNumber} flagged and blocked in system.',
                            style:
                                GoogleFonts.inter(fontWeight: FontWeight.w600),
                          ),
                          backgroundColor: const Color(0xFFDC2626),
                        ),
                      );
                    },
                    icon: const Icon(Icons.block_rounded, size: 18),
                    label: Text(
                      'Hang Up & Block Scammer',
                      style: GoogleFonts.outfit(
                          fontSize: 14.5, fontWeight: FontWeight.w800),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDC2626),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                )
              else
                SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.of(ctx).pop(),
                    icon: const Icon(Icons.check_circle_outline, size: 18),
                    label: Text(
                      'Done',
                      style: GoogleFonts.outfit(
                          fontSize: 14.5, fontWeight: FontWeight.w800),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF16A34A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
