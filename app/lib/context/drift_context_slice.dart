import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../data/conversation_repository.dart';
import '../data/db/app_database.dart';
import '../data/db/database_provider.dart';
import '../data/db/domain_enums.dart';
import '../data/user_profile_repository.dart';
import '../domain/user_profile_snapshot.dart';
import '../llm/llm_types.dart';
import 'context_slice.dart';

const kMaxRecentMessages = 20;
const kMaxSummaryChars = 80;
const kMaxHabitChars = 500;
const kMaxHabitEvents = 10;
const kMaxSummariesInPrompt = 5;

/// Drift-backed slicer (AC-09-B01 / B02).
class DriftContextSlicer implements ContextSlicer {
  DriftContextSlicer({
    required DatabaseProvider databaseProvider,
    required UserProfileRepository profiles,
    required ConversationRepository messages,
  })  : _dbProvider = databaseProvider,
        _profiles = profiles,
        _messages = messages;

  final DatabaseProvider _dbProvider;
  final UserProfileRepository _profiles;
  final ConversationRepository _messages;

  AppDatabase get _db => _dbProvider.db;

  @override
  Future<ContextSlice> build({
    required int userId,
    required int conversationId,
  }) async {
    try {
      final snapshot = await _profiles.getSnapshot();
      final habits = await _loadHabits(userId);
      final summaries = await _loadSummaries(userId);
      final promptBlock = buildPromptBlock(
        snapshot: snapshot,
        habitsText: habits,
        summariesText: summaries,
      );
      final recent = await _loadRecentTurns(conversationId);
      return ContextSlice(promptBlock: promptBlock, recentTurns: recent);
    } catch (e, st) {
      debugPrint('DriftContextSlicer.build failed: $e\n$st');
      List<ChatMessageWire> recent = const [];
      try {
        recent = await _loadRecentTurns(conversationId);
      } catch (_) {}
      return ContextSlice(
        promptBlock: buildPromptBlock(
          snapshot: UserProfileSnapshot.fallback,
          habitsText: '无',
          summariesText: '无',
        ),
        recentTurns: recent,
      );
    }
  }

  Future<String> _loadHabits(int userId) async {
    final rows = await (_db.select(_db.profileEvents)
          ..where(
            (e) =>
                e.userId.equals(userId) &
                e.category.equals(ProfileCategoryWire.habit),
          )
          ..orderBy([(e) => OrderingTerm.desc(e.id)])
          ..limit(kMaxHabitEvents))
        .get();
    if (rows.isEmpty) return '无';
    // Newest last for stable reading order.
    final texts = rows.reversed.map((r) => r.summary.trim()).where((s) => s.isNotEmpty);
    var joined = texts.join('；');
    if (joined.length > kMaxHabitChars) {
      joined = joined.substring(0, kMaxHabitChars);
    }
    return joined.isEmpty ? '无' : joined;
  }

  Future<String> _loadSummaries(int userId) async {
    final rows = await (_db.select(_db.profileEvents)
          ..where(
            (e) =>
                e.userId.equals(userId) &
                e.category.equals(ProfileCategoryWire.summary),
          )
          ..orderBy([(e) => OrderingTerm.asc(e.id)]))
        .get();
    if (rows.isEmpty) return '无';
    final last = rows.length > kMaxSummariesInPrompt
        ? rows.sublist(rows.length - kMaxSummariesInPrompt)
        : rows;
    final joined = last.map((r) => r.summary.trim()).where((s) => s.isNotEmpty).join('；');
    return joined.isEmpty ? '无' : joined;
  }

  Future<List<ChatMessageWire>> _loadRecentTurns(int conversationId) async {
    final all = await _messages.listMessages(conversationId);
    final turns = all.where((m) => m.isUser || m.isAssistant).toList();
    if (turns.isNotEmpty && turns.last.isUser) {
      turns.removeLast();
    }
    final window = turns.length > kMaxRecentMessages
        ? turns.sublist(turns.length - kMaxRecentMessages)
        : turns;
    return [
      for (final m in window)
        ChatMessageWire(
          role: m.isUser ? 'user' : 'assistant',
          // Shared-model multi-agent: label who spoke so one model can stay in role.
          content: formatHistoryContent(m),
        ),
    ];
  }
}

/// Pure builder for tests (T09-01 title order).
String buildPromptBlock({
  required UserProfileSnapshot snapshot,
  required String habitsText,
  required String summariesText,
}) {
  final archive = snapshot.agentArchiveLine;
  return '【档案】$archive\n'
      '【习惯】$habitsText\n'
      '【近期摘要】$summariesText';
}

class DriftSummaryWriter implements SummaryWriter {
  DriftSummaryWriter({
    required DatabaseProvider databaseProvider,
    required UserProfileRepository profiles,
  })  : _dbProvider = databaseProvider,
        _profiles = profiles;

  final DatabaseProvider _dbProvider;
  final UserProfileRepository _profiles;

  AppDatabase get _db => _dbProvider.db;

  @override
  Future<void> writeTurnSummary({
    required int userId,
    required String assistantContent,
    required String rawRef,
  }) async {
    final summary = truncateSummary(assistantContent, maxChars: kMaxSummaryChars);
    if (summary.isEmpty) return;

    final snapshot = await _profiles.getSnapshot();
    final now = DateTime.now().toUtc();
    final weekStart = DateTime.utc(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));

    await _db.into(_db.profileEvents).insert(
          ProfileEventsCompanion.insert(
            userId: userId,
            weekStart: weekStart,
            weekValue: snapshot.weekValue ?? 0,
            weekUnit: snapshot.weekUnit ?? WeekUnitWire.pregnancyWeek,
            category: ProfileCategoryWire.summary,
            summary: summary,
            rawRef: Value(rawRef),
          ),
        );
  }

  @override
  Future<void> clearSummaries({required int userId}) async {
    await (_db.delete(_db.profileEvents)
          ..where(
            (e) =>
                e.userId.equals(userId) &
                e.category.equals(ProfileCategoryWire.summary),
          ))
        .go();
  }
}

/// No-op slicer for tests that only care about safety / LLM counts.
class EmptyContextSlicer implements ContextSlicer {
  @override
  Future<ContextSlice> build({
    required int userId,
    required int conversationId,
  }) async {
    return const ContextSlice(
      promptBlock: '【档案】昵称=妈妈；阶段=备孕\n【习惯】无\n【近期摘要】无',
      recentTurns: [],
    );
  }
}

class NoopSummaryWriter implements SummaryWriter {
  @override
  Future<void> writeTurnSummary({
    required int userId,
    required String assistantContent,
    required String rawRef,
  }) async {}

  @override
  Future<void> clearSummaries({required int userId}) async {}
}
