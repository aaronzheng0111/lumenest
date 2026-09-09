import '../domain/agent_role.dart';

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.conversationId,
    required this.role,
    required this.content,
    required this.createdAt,
    this.speakerRole,
    this.safetyBadge = false,
    this.sourceTitles = const [],
  });

  final int id;
  final int conversationId;

  /// user | assistant | system
  final String role;
  final String? speakerRole;
  final String content;
  final DateTime createdAt;
  final bool safetyBadge;
  final List<String> sourceTitles;

  bool get isUser => role == 'user';
  bool get isAssistant => role == 'assistant';

  String? get speakerDisplayName {
    if (speakerRole == null) return null;
    return AgentRoleX.fromWire(speakerRole).displayName;
  }
}

class ConversationListItem {
  const ConversationListItem({
    required this.id,
    required this.role,
    required this.lastMessageAt,
    this.preview,
    this.type = 'SOLO',
  });

  final int id;
  final AgentRole role;
  final DateTime lastMessageAt;
  final String? preview;

  /// SOLO | GROUP
  final String type;

  bool get isGroup => type == 'GROUP';
}

abstract class ConversationRepository {
  Future<int> getOrCreateSolo({required AgentRole role});

  Future<int> getOrCreateGroup();

  Future<List<ChatMessage>> listMessages(int conversationId);

  Future<int> insertUserMessage({
    required int conversationId,
    required String content,
  });

  Future<int> insertAssistantMessage({
    required int conversationId,
    required String content,
    required AgentRole speaker,
    bool safetyBadge = false,
    List<String> sourceTitles = const [],
    String? agentReplyRef,
  });

  Future<List<ConversationListItem>> listConversations();

  /// Deletes all messages in one conversation (bubbles gone; session row kept).
  Future<void> clearMessages(int conversationId);

  /// Deletes every message for the local user (all solo + group threads).
  Future<void> clearAllMessages();

  /// Deletes a single message by id (ChatGPT-style per-bubble delete).
  Future<void> deleteMessage(int messageId);
}
