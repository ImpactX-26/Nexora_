import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:leads/data/models/coordinated_incident.dart';
import 'package:leads/data/models/security_score.dart';
import 'package:leads/data/models/threat_models.dart';
import 'package:leads/data/repositories/incident_repository.dart';
import 'package:leads/data/repositories/security_repository.dart';

class DashboardViewModel extends ChangeNotifier {
  final SecurityRepository _securityRepository;
  final IncidentRepository _incidentRepository;

  SecurityScore _score;
  List<ThreatItem> _threats = [];
  CoordinatedIncident? _primaryIncident;
  final bool _isLoading = false;

  StreamSubscription? _scoreSub;
  StreamSubscription? _threatsSub;
  StreamSubscription? _incidentSub;

  DashboardViewModel({
    required SecurityRepository securityRepository,
    required IncidentRepository incidentRepository,
  })  : _securityRepository = securityRepository,
        _incidentRepository = incidentRepository,
        _score = securityRepository.currentScore {
    _threats = securityRepository.currentThreats;
    _primaryIncident = incidentRepository.currentIncident;

    _scoreSub = _securityRepository.securityScoreStream.listen((score) {
      _score = score;
      notifyListeners();
    });

    _threatsSub = _securityRepository.activeThreatsStream.listen((threats) {
      _threats = threats;
      notifyListeners();
    });

    _incidentSub = _incidentRepository.currentIncidentStream.listen((incident) {
      _primaryIncident = incident;
      notifyListeners();
    });
  }

  SecurityScore get score => _score;
  List<ThreatItem> get activeThreats => _threats.where((t) => t.status == ThreatStatus.active).toList();
  List<ThreatItem> get allThreats => _threats;
  CoordinatedIncident? get primaryIncident => _primaryIncident;
  bool get isLoading => _isLoading;

  Future<void> mitigateThreat(String id) async {
    await _securityRepository.mitigateThreat(id);
  }

  Future<void> ignoreThreat(String id) async {
    await _securityRepository.ignoreThreat(id);
  }

  @override
  void dispose() {
    _scoreSub?.cancel();
    _threatsSub?.cancel();
    _incidentSub?.cancel();
    super.dispose();
  }
}
