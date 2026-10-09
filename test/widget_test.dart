import 'package:flutter_test/flutter_test.dart';
import 'package:leads/main.dart';
import 'package:leads/domain/heuristic_analyzer.dart';

void main() {
  group('LEADS Cybersecurity App Tests', () {
    testWidgets('App initializes and renders Leads SplashScreen', (WidgetTester tester) async {
      await tester.pumpWidget(const LeadsFlutterApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify Brand title "leads" is visible
      expect(find.text('leads'), findsOneWidget);
    });

    test('Heuristic Analyzer detects high risk phishing signals', () {
      final analyzer = HeuristicAnalyzer();
      final result = analyzer.analyze(
        'URGENT: Your bank account is suspended! Update KYC immediately at http://192.168.1.1/login.apk to avoid block',
      );

      expect(result.score, greaterThan(50));
      expect(result.category, 'Phishing / Malware');
      expect(result.detectedFlags, isNotEmpty);
      expect(result.detectedFlags.any((f) => f.toLowerCase().contains('urgency')), isTrue);
      expect(result.detectedFlags.any((f) => f.toLowerCase().contains('raw ip')), isTrue);
      expect(result.detectedFlags.any((f) => f.toLowerCase().contains('apk')), isTrue);
    });

    test('Heuristic Analyzer marks clean inputs as safe', () {
      final analyzer = HeuristicAnalyzer();
      final result = analyzer.analyze('https://google.com/search?q=cybersecurity+best+practices');

      expect(result.score, lessThan(30));
      expect(result.category, 'Safe');
    });
  });
}

