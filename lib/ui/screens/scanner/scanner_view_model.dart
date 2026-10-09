import 'package:flutter/foundation.dart';
import 'package:leads/data/models/scan_models.dart';
import 'package:leads/data/models/threat_models.dart';
import 'package:leads/data/repositories/security_repository.dart';

class ScannerViewModel extends ChangeNotifier {
  final SecurityRepository repository;

  ScanProgressState _scanState = const ScanProgressState();
  List<ThreatItem> _scannedThreats = [];
  bool _isScanning = false;

  ScannerViewModel({required this.repository});

  ScanProgressState get scanState => _scanState;
  List<ThreatItem> get scannedThreats => _scannedThreats;
  bool get isScanning => _isScanning;

  Future<void> startDeepScan() async {
    if (_isScanning) return;
    _isScanning = true;
    _scanState = const ScanProgressState(
      status: ScanStatus.scanning,
      currentStage: ScanStage.initializing,
      progress: 0.05,
      logMessages: ['Starting neural heuristic engine...'],
    );
    notifyListeners();

    try {
      final results = await repository.runSecurityScan(
        onProgressUpdate: (state) {
          _scanState = state;
          notifyListeners();
        },
      );
      _scannedThreats = results;
    } finally {
      _isScanning = false;
      notifyListeners();
    }
  }

  Future<void> mitigate(String threatId) async {
    await repository.mitigateThreat(threatId);
    _scannedThreats = repository.currentThreats;
    notifyListeners();
  }
}
