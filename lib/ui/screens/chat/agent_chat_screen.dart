import 'package:flutter/material.dart';
import 'package:leads/core/theme/app_colors.dart';
import 'package:leads/core/theme/app_typography.dart';
import 'package:leads/data/models/chat_models.dart';
import 'package:leads/ui/components/glass_card.dart';
import 'package:leads/ui/components/severity_badge.dart';
import 'package:leads/ui/screens/chat/agent_chat_view_model.dart';

class AgentChatScreen extends StatefulWidget {
  final AgentChatViewModel viewModel;

  const AgentChatScreen({super.key, required this.viewModel});

  @override
  State<AgentChatScreen> createState() => _AgentChatScreenState();
}

class _AgentChatScreenState extends State<AgentChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleSend([String? presetText]) {
    final text = presetText ?? _textController.text;
    if (text.trim().isEmpty) return;
    _textController.clear();
    widget.viewModel.sendMessage(text);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final messages = widget.viewModel.messages;
        final isTyping = widget.viewModel.isTyping;

        // Collect latest suggestions
        final latestSuggestions = messages.isNotEmpty
            ? messages.last.suggestedReplies
            : [
                'What is the active scam on my phone?',
                'Why is wf-verify-auth.apk dangerous?',
                'Run a full security scan',
              ];

        return Scaffold(
          backgroundColor: AppColors.cyberBackground,
          appBar: AppBar(
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.cyberCyan.withAlpha(30),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.cyberCyan, width: 1.5),
                  ),
                  child: const Icon(Icons.smart_toy, color: AppColors.cyberCyan, size: 18),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('LEADS CYBER AGENT', style: AppTypography.titleMedium.copyWith(letterSpacing: 0.5)),
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppColors.severitySafe,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'ON-DEVICE NEURAL REASONING',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.severitySafe,
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          body: Column(
            children: [
              // Chat Message History
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: messages.length + (isTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == messages.length && isTyping) {
                      return _buildTypingIndicator();
                    }
                    final msg = messages[index];
                    return _buildMessageBubble(msg);
                  },
                ),
              ),

              // Suggestion Chips Row
              if (latestSuggestions.isNotEmpty && !isTyping)
                Container(
                  height: 42,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: latestSuggestions.length,
                    itemBuilder: (context, index) {
                      final chipText = latestSuggestions[index];
                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: ActionChip(
                          label: Text(chipText),
                          labelStyle: AppTypography.labelSmall.copyWith(
                            color: AppColors.cyberCyan,
                            fontSize: 11,
                          ),
                          backgroundColor: AppColors.cyberSurface,
                          side: const BorderSide(color: AppColors.cyberCyanDark),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          onPressed: () => _handleSend(chipText),
                        ),
                      );
                    },
                  ),
                ),

              // Input Bar
              Container(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                decoration: const BoxDecoration(
                  color: AppColors.cyberSurface,
                  border: Border(top: BorderSide(color: AppColors.borderCyber)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.cyberSurfaceVariant,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppColors.borderCyber),
                        ),
                        child: TextField(
                          controller: _textController,
                          style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
                          decoration: InputDecoration(
                            hintText: 'Ask LEADS about threats, APKs, or links...',
                            hintStyle: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          onSubmitted: (_) => _handleSend(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: const BoxDecoration(
                        color: AppColors.cyberCyan,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_upward, color: Colors.black, size: 20),
                        onPressed: () => _handleSend(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    final isUser = msg.sender == SenderType.user;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.cyberCyanDark,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.cyberCyan, width: 1),
              ),
              child: const Icon(Icons.smart_toy, color: AppColors.cyberCyan, size: 14),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isUser
                        ? AppColors.cyberCyanDark.withAlpha(190)
                        : AppColors.cyberSurfaceVariant.withAlpha(200),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: isUser ? const Radius.circular(16) : const Radius.circular(4),
                      bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(16),
                    ),
                    border: Border.all(
                      color: isUser
                          ? AppColors.cyberCyan.withAlpha(120)
                          : AppColors.borderCyber,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    msg.text,
                    style: AppTypography.bodyMedium.copyWith(
                      color: isUser ? AppColors.textPrimary : AppColors.textPrimary,
                      height: 1.4,
                    ),
                  ),
                ),
                if (msg.cardData != null) ...[
                  const SizedBox(height: 8),
                  _buildInteractiveChatCard(msg.cardData!),
                ],
              ],
            ),
          ),
          if (isUser) const SizedBox(width: 4),
        ],
      ),
    );
  }

  Widget _buildInteractiveChatCard(ChatCardData card) {
    return GlassCard(
      borderColor: AppColors.severityCritical.withAlpha(120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  card.title,
                  style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
              ),
              SeverityBadge.fromSeverity(severity: card.severity),
            ],
          ),
          if (card.subtitle != null) ...[
            const SizedBox(height: 4),
            Text(card.subtitle!, style: AppTypography.labelSmall.copyWith(color: AppColors.cyberCyan)),
          ],
          if (card.keyPoints.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Divider(color: AppColors.borderCyber),
            const SizedBox(height: 6),
            ...card.keyPoints.map((point) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(color: AppColors.cyberCyan, fontWeight: FontWeight.bold)),
                    Expanded(child: Text(point, style: AppTypography.bodySmall)),
                  ],
                ),
              );
            }),
          ],
          if (card.actionLabel != null) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Executed defense playbook: ${card.actionLabel}')),
                  );
                },
                icon: const Icon(Icons.security, size: 14),
                label: Text(card.actionLabel!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.severityCritical.withAlpha(40),
                  foregroundColor: AppColors.severityCritical,
                  side: const BorderSide(color: AppColors.severityCritical),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.cyberSurfaceVariant,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderCyber),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.cyberCyan),
                  ),
                ),
                const SizedBox(width: 8),
                Text('LEADS Agent is synthesizing response...', style: AppTypography.labelSmall.copyWith(color: AppColors.cyberCyan)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
