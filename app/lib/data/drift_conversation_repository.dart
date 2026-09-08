import 'dart:convert';

import 'package:drift/drift.dart';

import '../domain/agent_role.dart';
import 'conversation_repository.dart';
import 'db/app_database.dart';
import 'db/database_provider.dart';
import 'db/domain_enums.dart';

class DriftConversationRepository implements ConversationRepository {
  DriftConversationRepository(this._databaseProvider);

  final DatabaseProvider _databaseProvider;

  AppDatabase get _db => _databaseProvider.db;

  @override
  Future<int> getOrCreateSolo({required AgentRole role}) async {
    final wire = role.wireId;
    final existing = await (_db.select(_db.conversations)
          ..where(
            (c) =>
                c.userId.equals(1) &
                c.role.equals(wire) &
                c.type.equals(ConversationTypeWire.solo),
          ))
        .get();
    if (existing.isNotEmpty) {
      return existing.first.id;
    }
    return _db.into(_db.conversations).insert(
          ConversationsCompanion.insert(
            userId: 1,
            role: wire,
            type: ConversationTypeWire.solo,
            createdAt: DateTime.now().toUtc(),
          ),
        );
  }

  @override
  Future<int> getOrCreateGroup() async {
    final existing = await (_db.select(_db.conversations)
          ..where(
            (c) =>
                c.userId.equals(1) &
                c.type.equals(ConversationTypeWire.group),
          ))
        .get();
    if (existing.isNotEmpty) {
      return existing.first.id;
    }
    return _db.into(_db.conversations).insert(
          ConversationsCompanion.insert(
            userId: 1,
            role: AgentRoleWire.xiaonuan,
            type: ConversationTypeWire.group,
            createdAt: DateTime.now().toUtc(),
          ),
        );
  }

  @override
  Future<List<ChatMessage>> listMessages(int conversationId) async {
    final rows = await (_db.select(_db.messages)
          ..where((m) => m.conversationId.equals(conversationId))
          ..orderBy([
            (m) => OrderingTerm.asc(m.createdAt),
            (m) => OrderingTerm.asc(m.id),
          ]))
        .get();
    return rows.map(_toMessage).toList();
  }

  @override
  Future<int> insertUserMessage({
    required int conversationId,
    required String content,
  }) {
    return _db.into(_db.messages).insert(
          MessagesCompanion.insert(
            conversationId: conversationId,
            role: MessageRoleWire.user,
            content: content,
            createdAt: DateTime.now().toUtc(),
          ),
        );
  }

  @override
  Future<int> insertAssistantMessage({
    required int conversationId,
    required String content,
    required AgentRole speaker,
    bool safetyBadge = false,
    List<String> sourceTitles = const [],
    String? agentReplyRef,
  }) {
    final meta = <String, dynamic>{
      if (safetyBadge) 'safetyBadge': true,
      if (sourceTitles.isNotEmpty) 'sources': sourceTitles,
      if (agentReplyRef != null) 'handoffRef': agentReplyRef,
    };
    return _db.into(_db.messages).insert(
          MessagesCompanion.insert(
            conversationId: conversationId,
            role: MessageRoleWire.assistant,
            speakerRole: Value(speaker.wireId),
            content: content,
            agentReplyRef:
                meta.isEmpty ? const Value.absent() : Value(jsonEncode(meta)),
            createdAt: DateTime.now().toUtc(),
          ),
        );
  }

  @override
  Future<List<ConversationListItem>> listConversations() async {
    final conversations = await (_db.select(_db.conversations)
          ..where((c) => c.userId.equals(1)))
        .get();
    final items = <ConversationListItem>[];
    for (final c in conversations) {
      final last = await (_db.select(_db.messages)
            ..where((m) => m.conversationId.equals(c.id))
            ..orderBy([
              (m) => OrderingTerm.desc(m.createdAt),
              (m) => OrderingTerm.desc(m.id),
            ])
            ..limit(1))
          .get();
      final lastAt =
          last.isEmpty ? c.createdAt : last.first.createdAt;
      items.add(
        ConversationListItem(
          id: c.id,
          role: AgentRoleX.fromWire(c.role),
          lastMessageAt: lastAt,
          preview: last.isEmpty ? null : last.first.content,
          type: c.type,
        ),
      );
    }
    items.sort((a, b) => b.lastMessageAt.compareTo(a.lastMessageAt));
    return items;
  }

  ChatMessage _toMessage(Message row) {
    var safety = false;
    var sources = <String>[];
    final ref = row.agentReplyRef;
    if (ref != null && ref.isNotEmpty) {
      try {
        final map = jsonDecode(ref) as Map<String, dynamic>;
        safety = map['safetyBadge'] == true;
        final raw = map['sources'];
        if (raw is List) {
          sources = raw.cast<String>();
        }
      } catch (_) {}
    }
    return ChatMessage(
      id: row.id,
      conversationId: row.conversationId,
      role: row.role,
      speakerRole: row.speakerRole,
      content: row.content,
      createdAt: row.createdAt,
      safetyBadge: safety,
      sourceTitles: sources,
    );
  }
}
