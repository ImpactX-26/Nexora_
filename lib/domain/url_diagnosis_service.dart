import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:leads/domain/heuristic_analyzer.dart';
import 'package:leads/ui/widgets/url_interception_popup.dart';

class UrlDiagnosisService {
  static const MethodChannel _channel = MethodChannel('com.leads.leads/url_interceptor');
  static final LocalAuthentication _localAuth = LocalAuthentication();
  static final StreamController<String> _urlStreamController = StreamController<String>.broadcast();

  static Stream<String> get onUrlIntercepted => _urlStreamController.stream;
  static GlobalKey<NavigatorState>? _navigatorKey;
  static bool _isInitialized = false;
  static String? _pendingUrl;

  static String? get pendingUrl => _pendingUrl;
  static void clearPendingUrl() => _pendingUrl = null;

  /// Initialize URL Interception listener and bind to Global Navigator
  static void initialize(GlobalKey<NavigatorState> navigatorKey) {
    _navigatorKey = navigatorKey;
    if (_isInitialized) return;
    _isInitialized = true;

    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onUrlIntercepted') {
        final url = call.arguments as String?;
        if (url != null && url.isNotEmpty) {
          _handleIncomingUrl(url);
        }
      }
    });

    // Check for initial URL passed during cold launch
    checkInitialUrl();
  }

  static Future<void> checkInitialUrl() async {
    try {
      final initialUrl = await _channel.invokeMethod<String>('getInitialUrl');
      if (initialUrl != null && initialUrl.isNotEmpty) {
        _pendingUrl = initialUrl;
        _handleIncomingUrl(initialUrl);
      }
    } catch (_) {}
  }

  static void _handleIncomingUrl(String url) {
    _pendingUrl = url;
    _urlStreamController.add(url);

    // If app navigator is mounted and ready, show popup immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _navigatorKey?.currentContext;
      if (ctx != null) {
        UrlInterceptionPopup.show(ctx, url);
      }
    });
  }

  /// Analyze a given URL and return detailed threat verdict
  static PhishingAnalysisVerdict diagnose(String url) {
    return HeuristicAnalyzer.analyzeTextOrUrl(url);
  }

  /// Authenticate user via Device Password / PIN / Biometric before allowing risky redirection
  static Future<bool> authenticateWithDevicePassword({
    required String reason,
  }) async {
    try {
      final bool canAuthenticateWithBiometrics = await _localAuth.canCheckBiometrics;
      final bool canAuthenticate = canAuthenticateWithBiometrics || await _localAuth.isDeviceSupported();

      if (!canAuthenticate) {
        // Fallback: If device doesn't have lock/biometrics configured, return true
        return true;
      }

      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: reason,
      );

      return didAuthenticate;
    } on PlatformException catch (_) {
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Check if leads is set as the Default Browser / Link Handler
  static Future<bool> isDefaultBrowser() async {
    try {
      final bool? isDefault = await _channel.invokeMethod<bool>('isDefaultBrowser');
      return isDefault ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Trigger the native Android prompt to set leads as the Default Browser / Link Interceptor
  static Future<void> requestDefaultBrowser() async {
    try {
      await _channel.invokeMethod('requestDefaultBrowser');
    } catch (_) {}
  }

  /// Safely launch real browser (Chrome, Edge, Firefox, etc.) without looping
  static Future<bool> launchInExternalBrowser(String rawUrl) async {
    try {
      String formattedUrl = rawUrl.trim();
      if (!formattedUrl.startsWith('http://') && !formattedUrl.startsWith('https://')) {
        formattedUrl = 'https://$formattedUrl';
      }

      // 1. Try native launcher first (picks actual browser, bypasses self)
      try {
        final bool? nativeResult = await _channel.invokeMethod<bool>(
          'openInExternalBrowser',
          {'url': formattedUrl},
        );
        if (nativeResult == true) return true;
      } catch (_) {}

      // 2. Fallback to url_launcher
      final uri = Uri.parse(formattedUrl);
      if (await canLaunchUrl(uri)) {
        return await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}
