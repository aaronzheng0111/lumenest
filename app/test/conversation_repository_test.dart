import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ai_mom_baby/data/db/database_provider.dart';
import 'package:ai_mom_baby/data/drift_conversation_repository.dart';
import 'package:ai_mom_baby/domain/agent_role.dart';

void main() {
  late DriftDatabaseProvider db;
  late DriftConversationRepository repo;

  setUp(() async {
    db = DriftDatabaseProvider(executor: NativeDatabase.memory());
    await db.init();
    repo = DriftConversationRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('AC-04-B02 getOrCreateSolo is idempotent', () async {
    final a = await repo.getOrCreateSolo(role: AgentRole.xiaonuan);
    final b = await repo.getOrCreateSolo(role: AgentRole.xiaonuan);
    expect(a, b);
  });

  test('AC-04-B01 insert user message', () async {
    final id = await repo.getOrCreateSolo(role: AgentRole.xiaonuan);
    await repo.insertUserMessage(conversationId: id, content: '今天有点累');
    final msgs = await repo.listMessages(id);
    expect(msgs, hasLength(1));
    expect(msgs.single.role, 'user');
    expect(msgs.single.speakerRole, isNull);
  });

  test('AC-04-F02 assistant speaker display name', () async {
    final id = await repo.getOrCreateSolo(role: AgentRole.xiaonuan);
    await repo.insertAssistantMessage(
      conversationId: id,
      content: '先休息一下',
      speaker: AgentRole.xiaonuan,
    );
    final msgs = await repo.listMessages(id);
    expect(msgs.single.speakerDisplayName, '小暖');
  });
}
