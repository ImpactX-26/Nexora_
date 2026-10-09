import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:leads/domain/url_diagnosis_service.dart';
import 'package:leads/ui/screens/dashboard/leads_dashboard_screen.dart';
import 'package:leads/ui/screens/onboarding/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<double> _textSpacingAnimation;
  late Animation<Offset> _textSlideAnimation;
  Timer? _navigationTimer;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();

    final hasPendingUrl = UrlDiagnosisService.pendingUrl != null;

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: hasPendingUrl ? 800 : 2000),
    );

    // 1. Logo Animation (Fade & Smooth Scale)
    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _logoScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOutCubic),
      ),
    );

    // 2. "leads" Text Animation (Fade, Slide & Letter Spacing Reveal)
    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.35, 0.8, curve: Curves.easeOut),
      ),
    );

    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.35, 0.85, curve: Curves.easeOutCubic),
      ),
    );

    _textSpacingAnimation = Tween<double>(begin: 2.0, end: 6.5).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.35, 0.95, curve: Curves.easeOutCubic),
      ),
    );

    _controller.forward();

    // Auto navigate after splash animation completes (fast-track if URL intercepted)
    final delayMs = hasPendingUrl ? 600 : 2500;
    _navigationTimer = Timer(Duration(milliseconds: delayMs), () {
      _navigateToNextScreen();
    });
  }

  Future<void> _navigateToNextScreen() async {
    if (!mounted || _hasNavigated) return;
    _hasNavigated = true;

    bool hasCompletedOnboarding = false;
    try {
      final prefs = await SharedPreferences.getInstance();
      hasCompletedOnboarding = prefs.getBool('has_completed_onboarding') ?? false;
    } catch (_) {}

    // If flag is false, check if user already granted the core permissions
    if (!hasCompletedOnboarding && !kIsWeb) {
      try {
        final sms = await Permission.sms.isGranted;
        final camera = await Permission.camera.isGranted;
        final mic = await Permission.microphone.isGranted;
        final photos = await Permission.photos.isGranted;
        final storage = await Permission.storage.isGranted;
        final isMedia = photos || storage;

        if (sms && camera && mic && isMedia) {
          hasCompletedOnboarding = true;
          try {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool('has_completed_onboarding', true);
          } catch (_) {}
        }
      } catch (_) {}
    }

    final Widget targetScreen = hasCompletedOnboarding
        ? const LeadsDashboardScreen()
        : const OnboardingScreen();

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (context, animation, secondaryAnimation) => targetScreen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _controller.dispose();
    super.dispose();
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
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _navigateToNextScreen,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo with smooth scale and fade
                FadeTransition(
                  opacity: _logoFadeAnimation,
                  child: ScaleTransition(
                    scale: _logoScaleAnimation,
                    child: Image.asset(
                      'assets/app-logo.png',
                      width: 130,
                      height: 130,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'assets/leads-logo.jpeg',
                          width: 130,
                          height: 130,
                          fit: BoxFit.contain,
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // Animated "leads" text
                SlideTransition(
                  position: _textSlideAnimation,
                  child: FadeTransition(
                    opacity: _textFadeAnimation,
                    child: AnimatedBuilder(
                      animation: _textSpacingAnimation,
                      builder: (context, _) {
                        return Text(
                          'leads',
                          style: GoogleFonts.outfit(
                            fontSize: 38,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF5A5C61),
                            letterSpacing: _textSpacingAnimation.value,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

