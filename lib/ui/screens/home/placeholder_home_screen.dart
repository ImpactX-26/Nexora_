import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class PlaceholderHomeScreen extends StatelessWidget {
  final Map<String, bool> grantedPermissions;

  const PlaceholderHomeScreen({
    super.key,
    this.grantedPermissions = const {
      'sms': true,
      'qr_url': true,
      'call': true,
      'files': true,
    },
  });

  @override
  Widget build(BuildContext context) {
    final activeCount = grantedPermissions.values.where((v) => v).length;

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
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF5A5C61),
              letterSpacing: 1.2,
            ),
          ),
          centerTitle: false,
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$activeCount of 4 Active',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF374151),
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            children: [
              const SizedBox(height: 12),
              Text(
                'Security Dashboard',
                style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1E201E),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'All enabled protection agents are running on-device.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFF555A54),
                ),
              ),
              const SizedBox(height: 24),

              _buildServiceRow(
                title: 'SMS Reading and Analysis',
                detail: 'Incoming message link and smishing inspection',
                isActive: grantedPermissions['sms'] ?? false,
              ),

              const Divider(height: 28, color: Color(0xFFEEEEEE)),

              _buildServiceRow(
                title: 'URL Diagnosis (QR Agent)',
                detail: 'Pre-browser QR and hyperlink validation',
                isActive: grantedPermissions['qr_url'] ?? false,
              ),

              const Divider(height: 28, color: Color(0xFFEEEEEE)),

              _buildServiceRow(
                title: 'Call Analysis & Recording',
                detail: 'Conversational audio vishing sentinel',
                isActive: grantedPermissions['call'] ?? false,
              ),

              const Divider(height: 28, color: Color(0xFFEEEEEE)),

              _buildServiceRow(
                title: 'File & Media Analysis',
                detail: 'Pre-inspection for APKs, documents, and media',
                isActive: grantedPermissions['files'] ?? false,
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceRow({
    required String title,
    required String detail,
    required bool isActive,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1F231E),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                detail,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFF0FDF4) : const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isActive ? const Color(0xFFDCFCE7) : const Color(0xFFE5E7EB),
            ),
          ),
          child: Text(
            isActive ? 'Active' : 'Disabled',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isActive ? const Color(0xFF16A34A) : const Color(0xFF9CA3AF),
            ),
          ),
        ),
      ],
    );
  }
}
