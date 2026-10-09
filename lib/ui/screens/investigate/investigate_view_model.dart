import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:leads/data/models/coordinated_incident.dart';
import 'package:leads/data/repositories/incident_repository.dart';

class InvestigateViewModel extends ChangeNotifier {
  final IncidentRepository _repository;

  CoordinatedIncident _incident;
  int _selectedTabIndex = 0;
  GraphNode? _selectedNode;

  StreamSubscription? _sub;

  InvestigateViewModel({required IncidentRepository repository})
      : _repository = repository,
        _incident = repository.currentIncident {
    _sub = _repository.currentIncidentStream.listen((inc) {
      _incident = inc;
      notifyListeners();
    });
  }

  CoordinatedIncident get incident => _incident;
  int get selectedTabIndex => _selectedTabIndex;
  GraphNode? get selectedNode => _selectedNode;

  void selectTab(int index) {
    _selectedTabIndex = index;
    notifyListeners();
  }

  void selectNode(GraphNode? node) {
    _selectedNode = node;
    notifyListeners();
  }

  Future<void> toggleAction(String actionId) async {
    final action = _incident.recommendedActions.firstWhere((a) => a.id == actionId);
    if (action.isCompleted) {
      await _repository.resetAllActions();
    } else {
      await _repository.markActionCompleted(actionId);
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
