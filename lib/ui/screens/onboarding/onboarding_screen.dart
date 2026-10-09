import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:leads/core/theme/app_colors.dart';
import 'package:leads/domain/url_diagnosis_service.dart';
import 'package:leads/ui/screens/dashboard/leads_dashboard_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with WidgetsBindingObserver {
  // Real System Permission Tracking
  PermissionStatus _smsStatus = PermissionStatus.denied;
  PermissionStatus _cameraStatus = PermissionStatus.denied;
  PermissionStatus _callStatus = PermissionStatus.denied;
  PermissionStatus _storageStatus = PermissionStatus.denied;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkAllPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkAllPermissions();
    }
  }

  int get _grantedCount {
    int count = 0;
    if (_smsStatus.isGranted) count++;
    if (_cameraStatus.isGranted) count++;
    if (_callStatus.isGranted) count++;
    if (_storageStatus.isGranted) count++;
    return count;
  }

  bool get _allPermissionsGranted => _grantedCount == 4;

  Future<void> _checkAllPermissions() async {
    setState(() => _isLoading = true);

    try {
      if (kIsWeb) {
        setState(() => _isLoading = false);
        return;
      }

      final sms = await Permission.sms.status;
      final camera = await Permission.camera.status;
      final mic = await Permission.microphone.status;

      // Check modern Android 13+ (API 33+) media permissions & storage fallback
      final photos = await Permission.photos.status;
      final videos = await Permission.videos.status;
      final audio = await Permission.audio.status;
      final storage = await Permission.storage.status;
      final manage = await Permission.manageExternalStorage.status;

      final isMediaGranted = photos.isGranted ||
          videos.isGranted ||
          audio.isGranted ||
          storage.isGranted ||
          manage.isGranted;

      final isMediaPermanentlyDenied = !isMediaGranted &&
          (photos.isPermanentlyDenied || storage.isPermanentlyDenied);

      final mediaStatus = isMediaGranted
          ? PermissionStatus.granted
          : isMediaPermanentlyDenied
              ? PermissionStatus.permanentlyDenied
              : PermissionStatus.denied;

      if (mounted) {
        setState(() {
          _smsStatus = sms;
          _cameraStatus = camera;
          _callStatus = mic;
          _storageStatus = mediaStatus;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // 1. Request SMS Permission
  Future<void> _requestSms() async {
    if (kIsWeb) {
      setState(() => _smsStatus = PermissionStatus.granted);
      return;
    }
    final status = await Permission.sms.request();
    if (mounted) setState(() => _smsStatus = status);
    if (status.isPermanentlyDenied) openAppSettings();
  }

  // 2. Request Camera (QR Agent) & Default Browser Role for URL Interception
  Future<void> _requestCamera() async {
    if (kIsWeb) {
      setState(() => _cameraStatus = PermissionStatus.granted);
      return;
    }
    final status = await Permission.camera.request();
    if (mounted) setState(() => _cameraStatus = status);
    if (status.isPermanentlyDenied) openAppSettings();

    // Also prompt Android to set leads as default link handler
    try {
      final isDef = await UrlDiagnosisService.isDefaultBrowser();
      if (!isDef) {
        await UrlDiagnosisService.requestDefaultBrowser();
      }
    } catch (_) {}
  }

  // 3. Request Call Recording (Microphone, Phone, Overlay) Permission
  Future<void> _requestCall() async {
    if (kIsWeb) {
      setState(() => _callStatus = PermissionStatus.granted);
      return;
    }
    final micStatus = await Permission.microphone.request();
    final phoneStatus = await Permission.phone.request();
    final overlayStatus = await Permission.systemAlertWindow.request();

    if (mounted) {
      setState(() {
        _callStatus = (micStatus.isGranted || phoneStatus.isGranted)
            ? PermissionStatus.granted
            : micStatus;
      });
    }
    if (micStatus.isPermanentlyDenied || overlayStatus.isPermanentlyDenied) openAppSettings();
  }

  // 4. Request Storage & Media (File Analysis) Permission for Android 10 - 16
  Future<void> _requestStorage() async {
    if (kIsWeb) {
      setState(() => _storageStatus = PermissionStatus.granted);
      return;
    }

    // Android 13+ (API 33+) granular media permissions
    final mediaMap = await [
      Permission.photos,
      Permission.videos,
      Permission.audio,
    ].request();

    final isAnyMediaGranted = (mediaMap[Permission.photos]?.isGranted ?? false) ||
        (mediaMap[Permission.videos]?.isGranted ?? false) ||
        (mediaMap[Permission.audio]?.isGranted ?? false);

    if (isAnyMediaGranted) {
      if (mounted) setState(() => _storageStatus = PermissionStatus.granted);
      return;
    }

    // Fallback for Android 12 and below or manageExternalStorage
    final storageStatus = await Permission.storage.request();
    if (storageStatus.isGranted) {
      if (mounted) setState(() => _storageStatus = PermissionStatus.granted);
      return;
    }

    final isPermanentlyDenied =
        (mediaMap[Permission.photos]?.isPermanentlyDenied ?? false) ||
            storageStatus.isPermanentlyDenied;

    if (mounted) {
      setState(() => _storageStatus = isPermanentlyDenied
          ? PermissionStatus.permanentlyDenied
          : PermissionStatus.denied);
    }

    if (isPermanentlyDenied) {
      openAppSettings();
    }
  }

  // Sequential Request for ungranted permissions
  Future<void> _requestRemainingPermissions() async {
    if (kIsWeb) {
      setState(() {
        _smsStatus = PermissionStatus.granted;
        _cameraStatus = PermissionStatus.granted;
        _callStatus = PermissionStatus.granted;
        _storageStatus = PermissionStatus.granted;
      });
      return;
    }

    if (!_smsStatus.isGranted) await _requestSms();
    if (!_cameraStatus.isGranted) await _requestCamera();
    if (!_callStatus.isGranted) await _requestCall();
    if (!_storageStatus.isGranted) await _requestStorage();
  }

  Future<void> _proceedToHome() async {
    if (!_allPermissionsGranted) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('has_completed_onboarding', true);
    } catch (_) {}

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const LeadsDashboardScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
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
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF5A5C61),
              letterSpacing: 1.2,
            ),
          ),
          centerTitle: false,
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF5A5C61),
                ),
              )
            : SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 8),
                        children: [
                          const SizedBox(height: 12),
                          Text(
                            'Permissions & Access',
                            style: GoogleFonts.outfit(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF1E201E),
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Grant all 4 core device permissions below to enable on-device threat detection across SMS, QR links, live calls, and files.',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: const Color(0xFF555A54),
                              height: 1.45,
                            ),
                          ),
                          const SizedBox(height: 28),

                          // 1. SMS Reading & Threat Analysis
                          _buildPermissionRow(
                            title: 'SMS Reading and Analysis',
                            subtitle:
                                'Accesses incoming messages to inspect links and detect smishing attempts.',
                            status: _smsStatus,
                            onRequest: _requestSms,
                          ),

                          const Divider(height: 32, color: Color(0xFFEEEEEE)),

                          // 2. URL Diagnosis & Link Shield
                          _buildPermissionRow(
                            title: 'URL Diagnosis (QR & Link Guard)',
                            subtitle:
                                'Intercepts and inspects links from WhatsApp, Telegram, SMS & QR codes to block malicious redirects.',
                            status: _cameraStatus,
                            onRequest: _requestCamera,
                          ),

                          const Divider(height: 32, color: Color(0xFFEEEEEE)),

                          // 3. Voice Leads (Live Call Recording & Scam Analysis)
                          _buildPermissionRow(
                            title: 'Voice Leads (Call Recording & Sentinel)',
                            subtitle:
                                'Enables microphone & call state access to record and analyze live calls with AI when you trigger "Record & Analyse with Voice Leads".',
                            status: _callStatus,
                            onRequest: _requestCall,
                          ),

                          const Divider(height: 32, color: Color(0xFFEEEEEE)),

                          // 4. Audio/Video & File Analysis
                          _buildPermissionRow(
                            title: 'File & Media Analysis',
                            subtitle:
                                'Pre-scans downloaded APKs, documents, images, and videos for malicious payloads.',
                            status: _storageStatus,
                            onRequest: _requestStorage,
                          ),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),

                    // Bottom Submit Button (Disabled until all 4 are allowed)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                      child: Column(
                        children: [
                          if (!_allPermissionsGranted)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: SizedBox(
                                width: double.infinity,
                                height: 44,
                                child: OutlinedButton(
                                  onPressed: _requestRemainingPermissions,
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFF1F2937),
                                    side: const BorderSide(color: Color(0xFFD1D5DB)),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    'Allow Remaining Permissions',
                                    style: GoogleFonts.inter(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _allPermissionsGranted ? _proceedToHome : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _allPermissionsGranted
                                    ? AppColors.leadsLime
                                    : const Color(0xFFE5E7EB),
                                disabledBackgroundColor: const Color(0xFFF3F4F6),
                                foregroundColor: const Color(0xFF2C302E),
                                disabledForegroundColor: const Color(0xFF9CA3AF),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: Text(
                                _allPermissionsGranted
                                    ? 'Submit & Continue'
                                    : 'Allow All 4 Permissions to Continue ($_grantedCount/4)',
                                style: GoogleFonts.outfit(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: _allPermissionsGranted
                                      ? const Color(0xFF2C302E)
                                      : const Color(0xFF9CA3AF),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _allPermissionsGranted
                                ? 'All required permissions granted.'
                                : 'All 4 permissions must be allowed to enable full cybersecurity coverage.',
                            style: GoogleFonts.inter(
                              fontSize: 11.5,
                              color: const Color(0xFF8C9289),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildPermissionRow({
    required String title,
    required String subtitle,
    required PermissionStatus status,
    required VoidCallback onRequest,
  }) {
    final isGranted = status.isGranted;
    final isPermanentlyDenied = status.isPermanentlyDenied;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
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
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: const Color(0xFF636A60),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        if (isGranted)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFDCFCE7)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check, size: 14, color: Color(0xFF16A34A)),
                const SizedBox(width: 4),
                Text(
                  'Allowed',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF16A34A),
                  ),
                ),
              ],
            ),
          )
        else if (isPermanentlyDenied)
          OutlinedButton(
            onPressed: openAppSettings,
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF4B5563),
              side: const BorderSide(color: Color(0xFFD1D5DB)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Settings',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        else
          ElevatedButton(
            onPressed: onRequest,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF3F4F6),
              foregroundColor: const Color(0xFF1F2937),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Allow',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1F2937),
              ),
            ),
          ),
      ],
    );
  }
}
