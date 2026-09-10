import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ai_mom_baby/agent/tool_acl.dart';
import 'package:ai_mom_baby/agent/tools/update_profile_tool.dart';
import 'package:ai_mom_baby/agent/xiaonuan_graph.dart';
import 'package:ai_mom_baby/data/active_user_store.dart';
import 'package:ai_mom_baby/data/db/database_provider.dart';
import 'package:ai_mom_baby/data/drift_conversation_repository.dart';
import 'package:ai_mom_baby/data/drift_user_profile_repository.dart';
import 'package:ai_mom_baby/data/user_profile_repository.dart';
import 'package:ai_mom_baby/domain/agent_role.dart';
import 'package:ai_mom_baby/domain/rich_user_profile.dart';
import 'package:ai_mom_baby/domain/stage.dart';
import 'package:ai_mom_baby/knowledge/knowledge_retriever.dart';
import 'package:ai_mom_baby/llm/llm_types.dart';
import 'package:ai_mom_baby/safety/safety_gate.dart';

void main() {
  group('RichUserProfile.copyWith', () {
    test('explicit null clears nullable fields', () {
      const rich = RichUserProfile(
        bloodType: 'A+',
        heightCm: 165,
        fullName: '甲',
      );
      final cleared = rich.copyWith(
        bloodType: null,
        heightCm: null,
        fullName: null,
      );
      expect(cleared.bloodType, isNull);
      expect(cleared.heightCm, isNull);
      expect(cleared.fullName, isNull);
      expect(rich.copyWith().bloodType, 'A+');
    });
  });

  group('UpdateProfileTool', () {
    test('shouldInvoke matches profile intents', () {
      expect(UpdateProfileTool.shouldInvoke('我怀孕12周了'), isTrue);
      expect(UpdateProfileTool.shouldInvoke('我吃了叶酸'), isTrue);
      expect(UpdateProfileTool.shouldInvoke('更新档案：过敏花生'), isTrue);
      expect(UpdateProfileTool.shouldInvoke('今天有点累'), isFalse);
      expect(UpdateProfileTool.shouldInvoke('这周了吗'), isFalse);
      expect(UpdateProfileTool.shouldInvoke('产后抑郁怎么办'), isFalse);
      expect(UpdateProfileTool.shouldInvoke('想了解备孕知识'), isFalse);
    });

    test('identity without explicit intent is propose-only', () async {
      final db = DriftDatabaseProvider(executor: NativeDatabase.memory());
      await db.init();
      addTearDown(db.close);
      final profiles = DriftUserProfileRepository(
        db,
        activeUserStore: MemoryActiveUserStore(),
      );
      await profiles.saveEdits(
        ProfileEdits(
          dueDate: DateTime(2026, 12, 1),
          lastMenstruationDate: DateTime(2026, 2, 25),
        ),
        today: DateTime(2026, 9, 9),
      );
      final result = await UpdateProfileTool.invoke(
        profiles: profiles,
        userText: '我在备孕',
        now: DateTime(2026, 9, 9),
      );
      expect(result.applied, isFalse);
      expect(result.proposeOnly, isTrue);
      final snap = await profiles.getSnapshot(today: DateTime(2026, 9, 9));
      expect(snap.dueDate, isNotNull);
    });

    test('allergy clear without explicit intent does not wipe', () async {
      final db = DriftDatabaseProvider(executor: NativeDatabase.memory());
      await db.init();
      addTearDown(db.close);
      final profiles = DriftUserProfileRepository(
        db,
        activeUserStore: MemoryActiveUserStore(),
      );
      await profiles.saveRichProfile(
        const RichUserProfile(
          allergies: AllergyBag(
            certainty: FieldCertainty.known,
            other: ['花生'],
          ),
        ),
      );
      final result = await UpdateProfileTool.invoke(
        profiles: profiles,
        userText: '无过敏',
        now: DateTime(2026, 9, 9),
      );
      expect(result.applied, isFalse);
      expect(result.proposeOnly, isTrue);
      final rich = await profiles.loadRichProfile();
      expect(rich.allergies.other, ['花生']);
    });

    test('invoke writes rich profile via repository', () async {
      final db = DriftDatabaseProvider(executor: NativeDatabase.memory());
      await db.init();
      addTearDown(db.close);
      final profiles = DriftUserProfileRepository(
        db,
        activeUserStore: MemoryActiveUserStore(),
      );
      final result = await UpdateProfileTool.invoke(
        profiles: profiles,
        userText: '我孕12周了，更新档案：过敏花生，我吃了叶酸',
        now: DateTime(2026, 9, 9),
      );
      expect(result.applied, isTrue);
      expect(result.summary, contains('孕周'));
      final rich = await profiles.loadRichProfile();
      expect(rich.pregnancyStatus, PregnancyStatus.pregnant);
      // Week override is write-through then cleared; Stage week is SSOT.
      expect(rich.pregnancyWeekOverride, isNull);
      expect(rich.allergies.certainty, FieldCertainty.known);
      expect(rich.allergies.other, contains('花生'));
      expect(rich.todayCheckIn.prenatalVitaminTaken, isTrue);
      final snap = await profiles.getSnapshot(today: DateTime(2026, 9, 9));
      expect(snap.stage, Stage.pregnant);
      expect(snap.weekValue, 12);
      expect(snap.stage, isNot(Stage.prep));
      expect(snap.agentArchiveLine.contains('妊娠状态='), isFalse);
    });

    test('explicit trying-to-conceive clears pregnancy dates', () async {
      final db = DriftDatabaseProvider(executor: NativeDatabase.memory());
      await db.init();
      addTearDown(db.close);
      final profiles = DriftUserProfileRepository(
        db,
        activeUserStore: MemoryActiveUserStore(),
      );
      await profiles.saveEdits(
        ProfileEdits(
          dueDate: DateTime(2026, 12, 1),
          lastMenstruationDate: DateTime(2026, 2, 25),
        ),
        today: DateTime(2026, 9, 9),
      );
      await profiles.saveRichProfile(
        const RichUserProfile(
          pregnancyStatus: PregnancyStatus.pregnant,
          pregnancyWeekOverride: 20,
        ),
      );
      final result = await UpdateProfileTool.invoke(
        profiles: profiles,
        userText: '更新档案：我在备孕',
        now: DateTime(2026, 9, 9),
      );
      expect(result.applied, isTrue);
      final snap = await profiles.getSnapshot(today: DateTime(2026, 9, 9));
      expect(snap.stage, Stage.prep);
      expect(snap.dueDate, isNull);
      expect(snap.rich.pregnancyWeekOverride, isNull);
      expect(snap.agentArchiveLine, isNot(contains('孕20')));
      expect(snap.weekLabel, isNot(contains('孕')));
    });

    test('allergy tags merge instead of replace', () async {
      final db = DriftDatabaseProvider(executor: NativeDatabase.memory());
      await db.init();
      addTearDown(db.close);
      final profiles = DriftUserProfileRepository(
        db,
        activeUserStore: MemoryActiveUserStore(),
      );
      await profiles.saveRichProfile(
        const RichUserProfile(
          allergies: AllergyBag(
            certainty: FieldCertainty.known,
            other: ['花生'],
          ),
        ),
      );
      final result = await UpdateProfileTool.invoke(
        profiles: profiles,
        userText: '更新档案：过敏海鲜',
        now: DateTime(2026, 9, 9),
      );
      expect(result.applied, isTrue);
      final rich = await profiles.loadRichProfile();
      expect(rich.allergies.other, containsAll(['花生', '海鲜']));
    });

    test('rejects out-of-range vitals', () async {
      final db = DriftDatabaseProvider(executor: NativeDatabase.memory());
      await db.init();
      addTearDown(db.close);
      final profiles = DriftUserProfileRepository(
        db,
        activeUserStore: MemoryActiveUserStore(),
      );
      final result = await UpdateProfileTool.invoke(
        profiles: profiles,
        userText: '体重 5kg',
        now: DateTime(2026, 9, 9),
      );
      expect(result.applied, isFalse);
      final rich = await profiles.loadRichProfile();
      expect(rich.currentWeightKg, isNull);
    });

    test('manual and agent share same persistence', () async {
      final db = DriftDatabaseProvider(executor: NativeDatabase.memory());
      await db.init();
      addTearDown(db.close);
      final profiles = DriftUserProfileRepository(
        db,
        activeUserStore: MemoryActiveUserStore(),
      );
      await profiles.saveRichProfile(
        const RichUserProfile(bloodType: 'A+', heightCm: 165),
      );
      await UpdateProfileTool.invoke(
        profiles: profiles,
        userText: '体重 58kg',
        now: DateTime(2026, 9, 9),
      );
      final rich = await profiles.loadRichProfile();
      expect(rich.bloodType, 'A+');
      expect(rich.heightCm, 165);
      expect(rich.currentWeightKg, 58);
    });

    test('multi-user isolates profile json', () async {
      final db = DriftDatabaseProvider(executor: NativeDatabase.memory());
      await db.init();
      addTearDown(db.close);
      final store = MemoryActiveUserStore();
      final profiles = DriftUserProfileRepository(
        db,
        activeUserStore: store,
      );
      await profiles.saveRichProfile(
        const RichUserProfile(fullName: '甲'),
      );
      final id2 = await profiles.createAccount(nickname: '乙');
      expect(id2, greaterThan(1));
      var rich = await profiles.loadRichProfile();
      expect(rich.fullName, isNull);
      await profiles.saveRichProfile(
        const RichUserProfile(fullName: '乙'),
      );
      await profiles.switchAccount(1);
      rich = await profiles.loadRichProfile();
      expect(rich.fullName, '甲');
    });
  });

  test('graph invokes update_profile in offline mode', () async {
    final db = DriftDatabaseProvider(executor: NativeDatabase.memory());
    await db.init();
    addTearDown(db.close);
    final profiles = DriftUserProfileRepository(
      db,
      activeUserStore: MemoryActiveUserStore(),
    );
    final repo = DriftConversationRepository(db);
    final graph = XiaonuanGraph(
      safety: _PassGate(),
      retriever: FakeKnowledgeRetriever(),
      llm: _OfflineLlm(),
      messages: repo,
      systemPrompt: '你是小暖',
      profiles: profiles,
      offlineReplyDelay: Duration.zero,
      clock: () => DateTime(2026, 9, 9, 10),
    );
    final cid = await repo.getOrCreateSolo(role: AgentRole.xiaonuan);
    final result = await graph.handle(
      conversationId: cid,
      userText: '我吃了叶酸',
    );
    expect(result.toolsUsed, contains(AgentTool.updateProfile));
    expect(result.assistantContent, contains('档案'));
    final rich = await profiles.loadRichProfile();
    expect(rich.todayCheckIn.prenatalVitaminTaken, isTrue);
  });

  test('solo Lin graph cannot updateProfile', () async {
    final db = DriftDatabaseProvider(executor: NativeDatabase.memory());
    await db.init();
    addTearDown(db.close);
    final profiles = DriftUserProfileRepository(
      db,
      activeUserStore: MemoryActiveUserStore(),
    );
    final repo = DriftConversationRepository(db);
    final graph = XiaonuanGraph(
      safety: _PassGate(),
      retriever: FakeKnowledgeRetriever(),
      llm: _OfflineLlm(),
      messages: repo,
      systemPrompt: '你是林医生',
      speaker: AgentRole.lin,
      profiles: profiles,
      offlineReplyDelay: Duration.zero,
      clock: () => DateTime(2026, 9, 9, 10),
    );
    final cid = await repo.getOrCreateSolo(role: AgentRole.lin);
    final result = await graph.handle(
      conversationId: cid,
      userText: '我吃了叶酸',
    );
    expect(result.toolsUsed, isNot(contains(AgentTool.updateProfile)));
    final rich = await profiles.loadRichProfile();
    expect(rich.todayCheckIn.prenatalVitaminTaken, isNot(true));
  });

  test('ToolAcl allows updateProfile only for Xiaonuan', () {
    expect(ToolAcl.canUse(AgentRole.xiaonuan, AgentTool.updateProfile), isTrue);
    for (final role in [
      AgentRole.lin,
      AgentRole.suxin,
      AgentRole.ama,
    ]) {
      expect(
        ToolAcl.canUse(role, AgentTool.updateProfile),
        isFalse,
        reason: role.wireId,
      );
    }
  });
}

class _PassGate implements SafetyGate {
  @override
  SafetyDecision inspect(String userText) => const SafetyDecision.pass();
}

class _OfflineLlm extends LlmClient {
  @override
  bool get canCallRemote => false;

  @override
  Future<LlmResult> complete({
    required List<ChatMessageWire> messages,
    required String requestId,
  }) async {
    return const LlmResult(status: LlmStatus.missingKey);
  }
}
