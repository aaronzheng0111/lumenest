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
  });

  final int id;
  final AgentRole role;
  final DateTime lastMessageAt;
  final String? preview;
}

abstract class ConversationRepository {
  Future<int> getOrCreateSolo({required AgentRole role});

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
  });

  Future<List<ConversationListItem>> listConversations();
}
