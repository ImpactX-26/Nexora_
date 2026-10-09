import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:leads/data/models/tools_models.dart';
import 'package:leads/data/repositories/security_repository.dart';
import 'package:leads/domain/heuristic_analyzer.dart';

class ToolsViewModel extends ChangeNotifier {
  final SecurityRepository _repository;

  List<AppPrivacyInfo> _appPrivacyList = [];
  List<MonitoredAccount> _monitoredAccounts = [];
  WifiAuditResult? _wifiAudit;

  // Phishing Analyzer State
  String _analyzedQuery = '';
  PhishingAnalysisVerdict? _phishingVerdict;
  bool _isAnalyzingPhishing = false;

  StreamSubscription? _appPrivacySub;
  StreamSubscription? _accountsSub;
  StreamSubscription? _wifiSub;

  ToolsViewModel({required SecurityRepository repository})
      : _repository = repository,
        _appPrivacyList = repository.currentAppPrivacyList,
        _monitoredAccounts = repository.currentMonitoredAccounts,
        _wifiAudit = repository.currentWifiAudit {
    _appPrivacySub = _repository.appPrivacyListStream.listen((list) {
      _appPrivacyList = list;
      notifyListeners();
    });

    _accountsSub = _repository.monitoredAccountsStream.listen((accounts) {
      _monitoredAccounts = accounts;
      notifyListeners();
    });

    _wifiSub = _repository.wifiAuditStream.listen((audit) {
      _wifiAudit = audit;
      notifyListeners();
    });
  }

  List<AppPrivacyInfo> get appPrivacyList => _appPrivacyList;
  List<MonitoredAccount> get monitoredAccounts => _monitoredAccounts;
  WifiAuditResult? get wifiAudit => _wifiAudit;
  PhishingAnalysisVerdict? get phishingVerdict => _phishingVerdict;
  bool get isAnalyzingPhishing => _isAnalyzingPhishing;
  String get analyzedQuery => _analyzedQuery;

  Future<void> analyzePhishingQuery(String textOrUrl) async {
    if (textOrUrl.trim().isEmpty) return;
    _analyzedQuery = textOrUrl.trim();
    _isAnalyzingPhishing = true;
    notifyListeners();

    try {
      _phishingVerdict = await _repository.analyzeUrlOrSms(_analyzedQuery);
    } finally {
      _isAnalyzingPhishing = false;
      notifyListeners();
    }
  }

  Future<void> revokePermission(String packageName, String permission) async {
    await _repository.revokeAppPermission(packageName, permission);
  }

  Future<void> addAccountToMonitor(String emailOrPhone) async {
    await _repository.addMonitoredAccount(emailOrPhone);
  }

  @override
  void dispose() {
    _appPrivacySub?.cancel();
    _accountsSub?.cancel();
    _wifiSub?.cancel();
    super.dispose();
  }
}
