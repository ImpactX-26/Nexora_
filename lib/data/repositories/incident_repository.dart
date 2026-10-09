import '../models/agent_settings.dart';
import '../models/chat_models.dart';
import '../models/coordinated_incident.dart';
import '../models/scan_models.dart';
import '../models/security_score.dart';

abstract class IncidentRepository {
  Stream<CoordinatedIncident> get currentIncidentStream;
  Stream<List<CoordinatedIncident>> get incidentsListStream;
  Stream<List<SecurityPermissionItem>> get permissionsStream;
  Stream<List<ChatMessage>> get chatMessagesStream;
  Stream<ScanProgressState> get manualScanStateStream;
  Stream<SecurityScore> get securityScoreStream;

  CoordinatedIncident get currentIncident;
  List<CoordinatedIncident> get incidentsList;
  List<SecurityPermissionItem> get permissions;
  List<ChatMessage> get chatMessages;
  ScanProgressState get manualScanState;
  SecurityScore get securityScore;

  Future<CoordinatedIncident?> getIncidentById(String id);
  Future<void> togglePermission(String permissionId, bool isGranted);
  Future<void> markActionCompleted(String actionId);
  Future<void> resetAllActions();
  Future<ChatMessage> askAiAssistant(String userPrompt);
  Future<void> startManualScan({required void Function(ScanProgressState) onProgress});
}
