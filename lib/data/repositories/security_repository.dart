import '../models/agent_settings.dart';
import '../models/chat_models.dart';
import '../models/scan_models.dart';
import '../models/security_score.dart';
import '../models/threat_models.dart';
import '../models/tools_models.dart';
import '../../domain/heuristic_analyzer.dart';

abstract class SecurityRepository {
  Stream<SecurityScore> get securityScoreStream;
  Stream<List<ThreatItem>> get activeThreatsStream;
  Stream<List<ChatMessage>> get chatMessagesStream;
  Stream<List<AppPrivacyInfo>> get appPrivacyListStream;
  Stream<List<MonitoredAccount>> get monitoredAccountsStream;
  Stream<WifiAuditResult> get wifiAuditStream;
  Stream<AgentSettings> get agentSettingsStream;

  SecurityScore get currentScore;
  List<ThreatItem> get currentThreats;
  List<ChatMessage> get currentChatMessages;
  List<AppPrivacyInfo> get currentAppPrivacyList;
  List<MonitoredAccount> get currentMonitoredAccounts;
  WifiAuditResult get currentWifiAudit;
  AgentSettings get currentAgentSettings;

  Future<List<ThreatItem>> runSecurityScan({required void Function(ScanProgressState) onProgressUpdate});
  Future<void> mitigateThreat(String threatId);
  Future<void> ignoreThreat(String threatId);
  Future<ChatMessage> sendChatMessage(String userText);
  Future<PhishingAnalysisVerdict> analyzeUrlOrSms(String query);
  Future<void> revokeAppPermission(String packageName, String permission);
  Future<void> addMonitoredAccount(String emailOrPhone);
  Future<void> updateAgentSettings(AgentSettings newSettings);
}
