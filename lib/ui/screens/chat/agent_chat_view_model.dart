import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:leads/data/models/chat_models.dart';
import 'package:leads/data/repositories/security_repository.dart';

class AgentChatViewModel extends ChangeNotifier {
  final SecurityRepository _repository;

  List<ChatMessage> _messages = [];
  bool _isTyping = false;

  StreamSubscription? _sub;

  AgentChatViewModel({required SecurityRepository repository})
      : _repository = repository,
        _messages = repository.currentChatMessages {
    _sub = _repository.chatMessagesStream.listen((msgs) {
      _messages = msgs;
      notifyListeners();
    });
  }

  List<ChatMessage> get messages => _messages;
  bool get isTyping => _isTyping;

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    _isTyping = true;
    notifyListeners();

    try {
      await _repository.sendChatMessage(text.trim());
    } finally {
      _isTyping = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
