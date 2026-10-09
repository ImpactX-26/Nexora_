import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:leads/domain/url_diagnosis_service.dart';
import 'package:leads/domain/call_detection_service.dart';
import 'core/theme/app_theme.dart';
import 'ui/screens/splash/splash_screen.dart';

import 'package:leads/ui/screens/voice_leads/voice_leads_overlay.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

@pragma("vm:entry-point")
void overlayMain() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: VoiceLeadsOverlay(),
    ),
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  UrlDiagnosisService.initialize(rootNavigatorKey);
  CallDetectionService.initialize();

  runApp(const LeadsFlutterApp());
}

class LeadsFlutterApp extends StatelessWidget {
  const LeadsFlutterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: rootNavigatorKey,
      title: 'leads',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => const SplashScreen(),
        );
      },
    );
  }
}

