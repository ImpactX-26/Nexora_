import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:leads/data/models/agent_settings.dart';
import 'package:leads/data/repositories/security_repository.dart';

class SettingsViewModel extends ChangeNotifier {
  final SecurityRepository _repository;

  AgentSettings _settings;
  StreamSubscription? _sub;

  SettingsViewModel({required SecurityRepository repository})
      : _repository = repository,
        _settings = repository.currentAgentSettings {
    _sub = _repository.agentSettingsStream.listen((s) {
      _settings = s;
      notifyListeners();
    });
  }

  AgentSettings get settings => _settings;

  Future<void> updateSettings(AgentSettings newSettings) async {
    _settings = newSettings;
    notifyListeners();
    await _repository.updateAgentSettings(newSettings);
  }

  Future<void> toggleAutonomous(bool val) async {
    await updateSettings(_settings.copyWith(isAutonomousInterventionEnabled: val));
  }

  Future<void> setProtectionLevel(ProtectionLevel level) async {
    await updateSettings(_settings.copyWith(protectionLevel: level));
  }

  Future<void> toggleSms(bool val) async {
    await updateSettings(_settings.copyWith(isRealTimeSmsMonitoringEnabled: val));
  }

  Future<void> toggleDns(bool val) async {
    await updateSettings(_settings.copyWith(isNetworkDnsGuardEnabled: val));
  }

  Future<void> toggleSideload(bool val) async {
    await updateSettings(_settings.copyWith(isSideloadAppProtectionEnabled: val));
  }

  Future<void> toggleDarkWeb(bool val) async {
    await updateSettings(_settings.copyWith(isDarkWebTelemetryEnabled: val));
  }

  Future<void> toggleLocalAi(bool val) async {
    await updateSettings(_settings.copyWith(isLocalAiProcessingOnly: val));
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
