import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:leads/core/theme/app_colors.dart';
import 'package:leads/data/models/sms_threat_item.dart';
import 'package:leads/domain/sms_scanner_service.dart';
import 'package:leads/domain/url_diagnosis_service.dart';
import 'package:leads/ui/screens/onboarding/onboarding_screen.dart';
import 'package:leads/ui/screens/url_diagnosis/url_diagnosis_screen.dart';
import 'package:leads/ui/screens/voice_leads/voice_leads_screen.dart';
import 'package:leads/ui/widgets/url_interception_popup.dart';

class LeadsDashboardScreen extends StatefulWidget {
  const LeadsDashboardScreen({super.key});

  @override
  State<LeadsDashboardScreen> createState() => _LeadsDashboardScreenState();
}

class _LeadsDashboardScreenState extends State<LeadsDashboardScreen> {
  int _currentTab = 0;

  // SMS Threat State
  List<SmsThreatItem> _allSms = [];
  List<SmsThreatItem> _riskSms = [];
  bool _isLoadingSms = false;
  bool _filterOnlyRisk = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadDeviceSms();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final pending = UrlDiagnosisService.pendingUrl;
      if (pending != null && mounted) {
        UrlDiagnosisService.clearPendingUrl();
        UrlInterceptionPopup.show(context, pending);
      }
    });
  }

  Future<void> _loadDeviceSms() async {
    setState(() => _isLoadingSms = true);
    try {
      final all = await SmsScannerService.fetchAndAnalyzeSms(onlyRisk: false);
      final risk = all.where((item) => item.isRisk).toList();

      if (mounted) {
        setState(() {
          _allSms = all;
          _riskSms = risk;
          _isLoadingSms = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingSms = false);
    }
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 10000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    } else if (count >= 1000) {
      return NumberFormat('#,###').format(count);
    }
    return '$count';
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'Good Morning';
    } else if (hour >= 12 && hour < 17) {
      return 'Good Afternoon';
    } else if (hour >= 17 && hour < 22) {
      return 'Good Evening';
    } else {
      return 'Good Night';
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
          title: Text(
            'leads',
            style: GoogleFonts.outfit(
              fontSize: 25,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF5A5C61),
              letterSpacing: 1.2,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: Color(0xFF5A5C61), size: 22),
              tooltip: 'Sync SMS & Re-analyze',
              onPressed: _loadDeviceSms,
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: IndexedStack(
          index: _currentTab,
          children: [
            _buildHomeTab(),
            _buildMessagesTab(),
            _buildMoreTab(),
          ],
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: Color(0xFFEEEEEE), width: 1),
            ),
          ),
          child: NavigationBar(
            backgroundColor: Colors.white,
            elevation: 0,
            indicatorColor: AppColors.leadsLime.withValues(alpha: 0.5),
            selectedIndex: _currentTab,
            onDestinationSelected: (index) {
              setState(() {
                _currentTab = index;
              });
            },
            destinations: [
              const NavigationDestination(
                icon: Icon(Icons.home_outlined, size: 22),
                selectedIcon: Icon(Icons.home_rounded, size: 22, color: Color(0xFF2C302E)),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Badge(
                  isLabelVisible: _riskSms.isNotEmpty,
                  label: Text(_riskSms.length > 99 ? '99+' : '${_riskSms.length}'),
                  backgroundColor: const Color(0xFFEF4444),
                  child: const Icon(Icons.chat_bubble_outline_rounded, size: 22),
                ),
                selectedIcon: Badge(
                  isLabelVisible: _riskSms.isNotEmpty,
                  label: Text(_riskSms.length > 99 ? '99+' : '${_riskSms.length}'),
                  backgroundColor: const Color(0xFFEF4444),
                  child: const Icon(Icons.chat_bubble_rounded, size: 22, color: Color(0xFF2C302E)),
                ),
                label: 'Messages',
              ),
              const NavigationDestination(
                icon: Icon(Icons.grid_view_outlined, size: 22),
                selectedIcon: Icon(Icons.grid_view_rounded, size: 22, color: Color(0xFF2C302E)),
                label: 'More',
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // TAB 1: HOME SCREEN
  // ==========================================
  Widget _buildHomeTab() {
    return RefreshIndicator(
      color: const Color(0xFF5A5C61),
      backgroundColor: Colors.white,
      onRefresh: _loadDeviceSms,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        children: [
          // 1. Dynamic Greeting
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getGreeting(),
                    style: GoogleFonts.outfit(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1F221E),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Device Sentinel Active',
                    style: GoogleFonts.inter(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF6B726A),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFDCFCE7)),
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
                      'Shields On',
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF16A34A),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // 2. Risk Overview Hero Card
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: const Color(0xFFFAFCF9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE5ECE2), width: 1.2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'SMS THREAT RADAR',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF7A8077),
                        letterSpacing: 1.5,
                      ),
                    ),
                    if (_riskSms.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFFECACA)),
                        ),
                        child: Text(
                          '${_riskSms.length} RISKS FLAGGED',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFDC2626),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  _riskSms.isEmpty
                      ? 'No Malicious Messages Detected'
                      : '${_riskSms.length} High-Risk SMS Requiring Attention',
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: _riskSms.isEmpty ? const Color(0xFF1F221E) : const Color(0xFFDC2626),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _riskSms.isEmpty
                      ? 'All scanned incoming SMS pass on-device heuristic inspection.'
                      : 'Smishing URLs, fake bank account freezes, and APK links identified.',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: const Color(0xFF6B726A),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _currentTab = 1;
                        _filterOnlyRisk = true;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.leadsLime,
                      foregroundColor: const Color(0xFF2C302E),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'View Flagged Messages (${_riskSms.length})',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2C302E),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 2B. LIVE IN-CALL PANIC SENTINEL CARD
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF1B1D1C),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.leadsLime.withValues(alpha: 0.4)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.leadsLime,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.phone_in_talk_rounded, color: Color(0xFF1E201E), size: 18),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Voice Leads · In-Call Shield',
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF16A34A).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'AI READY',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF4ADE80),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Suspicious call in progress? Tap below to record and run real-time conversational scam analysis.',
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    color: const Color(0xFFD1D5DB),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const VoiceLeadsScreen()),
                      );
                    },
                    icon: const Icon(Icons.mic_rounded, size: 18),
                    label: Text(
                      'Record & Analyse with Voice Leads',
                      style: GoogleFonts.outfit(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.leadsLime,
                      foregroundColor: const Color(0xFF1E201E),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 3. Quick Perimeter Modules Overview
          Text(
            'Active Protections',
            style: GoogleFonts.outfit(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1F221E),
            ),
          ),
          const SizedBox(height: 12),

          _buildHomeModuleRow(
            title: 'SMS Smishing & OTP Defense',
            status: '${_allSms.length} scanned (${_riskSms.length} flagged)',
            isAlert: _riskSms.isNotEmpty,
            onTap: () => setState(() => _currentTab = 1),
          ),
          const Divider(height: 20, color: Color(0xFFEEEEEE)),
          _buildHomeModuleRow(
            title: 'URL Diagnosis (Leads URL Lead)',
            status: 'Monitoring incoming redirects & links',
            isAlert: false,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const UrlDiagnosisScreen()),
              );
            },
          ),
          const Divider(height: 20, color: Color(0xFFEEEEEE)),
          _buildHomeModuleRow(
            title: 'Voice Leads (Live Call Sentinel)',
            status: 'Touch to Record & Analyse in-call scams',
            isAlert: false,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const VoiceLeadsScreen()),
              );
            },
          ),
          const Divider(height: 20, color: Color(0xFFEEEEEE)),
          _buildHomeModuleRow(
            title: 'Deep File & Media Scanner',
            status: 'Download folder guarded',
            isAlert: false,
          ),
        ],
      ),
    );
  }

  Widget _buildHomeModuleRow({
    required String title,
    required String status,
    required bool isAlert,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2C302E),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    status,
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      color: isAlert ? const Color(0xFFDC2626) : const Color(0xFF6B7280),
                      fontWeight: isAlert ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF9CA3AF)),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // TAB 2: LIVE MESSAGES & RISK ANALYSIS
  // ==========================================
  Widget _buildMessagesTab() {
    final displayedList = (_filterOnlyRisk ? _riskSms : _allSms).where((item) {
      if (_searchQuery.isEmpty) return true;
      final query = _searchQuery.toLowerCase();
      return item.sender.toLowerCase().contains(query) ||
          item.body.toLowerCase().contains(query) ||
          item.threatCategory.toLowerCase().contains(query);
    }).toList();

    return Column(
      children: [
        // Filter & Search Controls
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
          ),
          child: Column(
            children: [
              // Search Input
              TextField(
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: InputDecoration(
                  hintText: 'Search sender, keyword or number...',
                  hintStyle: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF9CA3AF)),
                  prefixIcon: const Icon(Icons.search, size: 20, color: Color(0xFF9CA3AF)),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  filled: true,
                  fillColor: const Color(0xFFF9FAFB),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF5A5C61)),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Filter Toggle: Only Risk vs All Messages (Scrollable, zero overflow)
              Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          ChoiceChip(
                            label: Text('Risk Messages (${_formatCount(_riskSms.length)})'),
                            selected: _filterOnlyRisk,
                            onSelected: (selected) {
                              if (selected) setState(() => _filterOnlyRisk = true);
                            },
                            selectedColor: const Color(0xFFFEE2E2),
                            side: BorderSide(
                              color: _filterOnlyRisk ? const Color(0xFFFCA5A5) : const Color(0xFFE5E7EB),
                            ),
                            labelStyle: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _filterOnlyRisk ? const Color(0xFF991B1B) : const Color(0xFF4B5563),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: Text('All Messages (${_formatCount(_allSms.length)})'),
                            selected: !_filterOnlyRisk,
                            onSelected: (selected) {
                              if (selected) setState(() => _filterOnlyRisk = false);
                            },
                            selectedColor: const Color(0xFFF3F4F6),
                            side: BorderSide(
                              color: !_filterOnlyRisk ? const Color(0xFF9CA3AF) : const Color(0xFFE5E7EB),
                            ),
                            labelStyle: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: !_filterOnlyRisk ? const Color(0xFF1F2937) : const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_isLoadingSms)
                    const Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF5A5C61)),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),

        // List of Analyzed SMS Messages
        Expanded(
          child: _isLoadingSms && _allSms.isEmpty
              ? const Center(
                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF5A5C61)),
                )
              : displayedList.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle_outline_rounded, size: 48, color: Color(0xFF16A34A)),
                          const SizedBox(height: 12),
                          Text(
                            _filterOnlyRisk ? 'No Risk Messages Found' : 'No Messages in Inbox',
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1F2937),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Your inbox is clean of flagged smishing threats.',
                            style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF6B726A)),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      color: const Color(0xFF5A5C61),
                      onRefresh: _loadDeviceSms,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        itemCount: displayedList.length,
                        separatorBuilder: (context, index) => const Divider(height: 24, color: Color(0xFFEEEEEE)),
                        itemBuilder: (context, index) {
                          final item = displayedList[index];
                          return _buildSmsTile(item);
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildSmsTile(SmsThreatItem item) {
    final timeStr = DateFormat('dd MMM, hh:mm a').format(item.timestamp);

    return InkWell(
      onTap: () => _showThreatDetailsModal(item),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Sender & Risk Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          item.sender,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1E201E),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (item.isRisk)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            item.threatCategory.toUpperCase(),
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF991B1B),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  timeStr,
                  style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF9CA3AF)),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Message Body
            Text(
              item.body,
              style: GoogleFonts.inter(
                fontSize: 13.5,
                color: item.isRisk ? const Color(0xFF2C302E) : const Color(0xFF555A54),
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),

            // Tactics Pill Tags
            if (item.detectedTactics.isNotEmpty)
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: item.detectedTactics.take(2).map((tactic) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: item.isRisk ? const Color(0xFFFFF1F2) : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: item.isRisk ? const Color(0xFFFECDD3) : const Color(0xFFE5E7EB),
                      ),
                    ),
                    child: Text(
                      tactic,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: item.isRisk ? const Color(0xFFBE123C) : const Color(0xFF4B5563),
                      ),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  void _showThreatDetailsModal(SmsThreatItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.92,
          expand: false,
          builder: (context, scrollController) {
            return ListView(
              controller: scrollController,
              padding: const EdgeInsets.all(24),
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Threat Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.sender,
                          style: GoogleFonts.outfit(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                        Text(
                          DateFormat('EEEE, dd MMMM yyyy • hh:mm a').format(item.timestamp),
                          style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF6B7280)),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: item.isRisk ? const Color(0xFFFEE2E2) : const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.isRisk ? 'THREAT SCORE: ${item.riskScore}' : 'SAFE',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: item.isRisk ? const Color(0xFFDC2626) : const Color(0xFF16A34A),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Full Message Container
                Text(
                  'Message Content',
                  style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF374151)),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: SelectableText(
                    item.body,
                    style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF1F2937), height: 1.45),
                  ),
                ),

                const SizedBox(height: 18),

                // Detected Tactics
                if (item.detectedTactics.isNotEmpty) ...[
                  Text(
                    'Heuristic Indicators Flagged',
                    style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF374151)),
                  ),
                  const SizedBox(height: 8),
                  ...item.detectedTactics.map((t) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.warning_amber_rounded, size: 16, color: Color(0xFFDC2626)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                t,
                                style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF4B5563)),
                              ),
                            ),
                          ],
                        ),
                      )),
                  const SizedBox(height: 14),
                ],

                // AI Recommendation
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: item.isRisk ? const Color(0xFFFFFBEB) : const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: item.isRisk ? const Color(0xFFFDE68A) : const Color(0xFFBBF7D0),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        item.isRisk ? Icons.shield_outlined : Icons.check_circle_outline,
                        size: 20,
                        color: item.isRisk ? const Color(0xFFD97706) : const Color(0xFF16A34A),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Leads Recommendation',
                              style: GoogleFonts.outfit(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: item.isRisk ? const Color(0xFF92400E) : const Color(0xFF14532D),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.aiRecommendation,
                              style: GoogleFonts.inter(
                                fontSize: 12.5,
                                color: item.isRisk ? const Color(0xFFB45309) : const Color(0xFF15803D),
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                if (item.extractedUrls.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.link_rounded, size: 18),
                      label: Text(
                        'Diagnose Extracted Link (${item.extractedUrls.first})',
                        style: GoogleFonts.outfit(fontSize: 13.5, fontWeight: FontWeight.w700),
                        overflow: TextOverflow.ellipsis,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => UrlDiagnosisScreen(targetUrl: item.extractedUrls.first),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.leadsLime,
                        foregroundColor: const Color(0xFF2C302E),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 14),

                // Dismiss Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF3F4F6),
                      foregroundColor: const Color(0xFF1F2937),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Close'),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ==========================================
  // TAB 3: MORE & SETTINGS
  // ==========================================
  Widget _buildMoreTab() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      children: [
        Text(
          'More Options',
          style: GoogleFonts.outfit(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1E201E),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Manage device permissions and protection engines.',
          style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF6B726A)),
        ),
        const SizedBox(height: 24),

        _buildMoreTile(
          title: 'URL & QR Diagnosis (Leads URL Lead)',
          subtitle: 'Intercept incoming links, test domains and verify safety',
          icon: Icons.link_rounded,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const UrlDiagnosisScreen()),
            );
          },
        ),

        const Divider(height: 24, color: Color(0xFFEEEEEE)),

        _buildMoreTile(
          title: 'Voice Leads (Live Call Scam Sentinel)',
          subtitle: 'Record and analyze live calls with acoustic AI for scam cues',
          icon: Icons.mic_rounded,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const VoiceLeadsScreen()),
            );
          },
        ),

        const Divider(height: 24, color: Color(0xFFEEEEEE)),

        _buildMoreTile(
          title: 'Device Permissions',
          subtitle: 'Manage SMS, Camera, Microphone & Storage access',
          icon: Icons.security_rounded,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const OnboardingScreen()),
            );
          },
        ),

        const Divider(height: 24, color: Color(0xFFEEEEEE)),

        _buildMoreTile(
          title: 'Re-sync Live SMS',
          subtitle: 'Pull latest incoming messages and run neural analysis',
          icon: Icons.sync_rounded,
          onTap: () {
            _loadDeviceSms();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('SMS inbox refreshed and analyzed.')),
            );
          },
        ),

        const Divider(height: 24, color: Color(0xFFEEEEEE)),

        _buildMoreTile(
          title: 'About Leads Sentinel',
          subtitle: 'Version 2.4.0 • On-Device Neural Shield',
          icon: Icons.info_outline_rounded,
        ),
      ],
    );
  }

  Widget _buildMoreTile({
    required String title,
    required String subtitle,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: const Color(0xFF374151)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF6B7280)),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF9CA3AF)),
          ],
        ),
      ),
    );
  }
}
