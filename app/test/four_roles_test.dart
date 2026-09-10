import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:ai_mom_baby/agent/role_prompts.dart';
import 'package:ai_mom_baby/agent/tool_acl.dart';
import 'package:ai_mom_baby/domain/agent_role.dart';

void main() {
  test('T11-01 xiaonuan prompt shared with module 08 (byte-identical)', () {
    final from08 = File(
      '../sdd/08-p1-agent-xiaonuan-demo/fixtures/xiaonuan_system_prompt.txt',
    ).readAsStringSync();
    final asset = File(
      '../assets/fixtures/prompts/xiaonuan_system_prompt.txt',
    ).readAsStringSync();
    expect(asset, from08);
  });

  test('T11-01 lin/suxin/ama prompts contain identity lines', () {
    for (final entry in {
      AgentRole.lin: '你是林医生',
      AgentRole.suxin: '你是苏心',
      AgentRole.ama: '你是阿嬷',
    }.entries) {
      final path = RolePrompts.assetPath(entry.key).replaceFirst(
        'assets/',
        '../assets/',
      );
      final text = File(path).readAsStringSync();
      expect(text.contains(entry.value), isTrue, reason: entry.key.wireId);
      expect(text.contains('不提供用药剂量'), isTrue);
    }
  });

  test('T11-01 xiaonuan orchestra anchors', () {
    final text = File(
      '../assets/fixtures/prompts/xiaonuan_system_prompt.txt',
    ).readAsStringSync();
    expect(text.contains('你是小暖'), isTrue);
    expect(text.contains('不提供用药剂量'), isTrue);
    expect(text.contains('Orchestra') || text.contains('编排'), isTrue);
    expect(text.contains('以谁为准'), isTrue);
  });

  test('T11-01 specialist prompts sync to sdd/11 mirrors', () {
    for (final name in ['lin', 'suxin', 'ama']) {
      final asset = File(
        '../assets/fixtures/prompts/${name}_system_prompt.txt',
      ).readAsStringSync();
      final mirror = File(
        '../sdd/11-four-roles-and-handoff/fixtures/prompts/'
        '${name}_system_prompt.txt',
      ).readAsStringSync();
      expect(asset, mirror, reason: name);
    }
  });

  test('T11-03 tool ACL table', () {
    expect(ToolAcl.canUse(AgentRole.xiaonuan, AgentTool.retrieveKb), isTrue);
    expect(ToolAcl.canUse(AgentRole.lin, AgentTool.toggleTask), isFalse);
    expect(ToolAcl.canUse(AgentRole.suxin, AgentTool.crisisTemplate), isTrue);
    expect(ToolAcl.canUse(AgentRole.ama, AgentTool.toggleTask), isTrue);
    expect(ToolAcl.canUse(AgentRole.ama, AgentTool.crisisTemplate), isFalse);
    expect(ToolAcl.canUse(AgentRole.xiaonuan, AgentTool.getCurrentTime), isTrue);
    expect(ToolAcl.suxinMayUseChunk('kb-emotion-01'), isTrue);
    expect(ToolAcl.suxinMayUseChunk('kb-nausea-01'), isFalse);
  });

  test('all four roles unlocked', () {
    for (final role in AgentRole.values) {
      expect(role.isUnlocked, isTrue);
    }
  });
}
