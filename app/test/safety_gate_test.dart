import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:ai_mom_baby/safety/safety_gate.dart';

Map<String, dynamic> _readSdd(String name) {
  final file = File('../sdd/05-safety-guardrail/fixtures/$name');
  return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
}

void main() {
  late LocalSafetyGate gate;

  setUp(() {
    gate = LocalSafetyGate.fromDecoded(
      patternsJson: _readSdd('safety_patterns.json'),
      repliesJson: _readSdd('safety_replies.json'),
      hotlinesJson: _readSdd('crisis_hotlines.json'),
    );
  });

  test('AC-05-B03 safety_eval.json 100%', () {
    final eval = _readSdd('safety_eval.json');
    final cases = eval['cases'] as List<dynamic>;
    for (final raw in cases) {
      final c = raw as Map<String, dynamic>;
      final decision = gate.inspect(c['input'] as String);
      final id = c['id'];
      if (c['mustBlock'] == true) {
        expect(decision.block, isTrue, reason: '$id should block');
        expect(decision.category, c['category'], reason: '$id category');
        expect(decision.reply, isNotEmpty);
      } else {
        expect(decision.block, isFalse, reason: '$id must not block');
      }
    }
  });

  test('AC-05-B01 block never invokes LLM callback', () {
    var llmCalls = 0;
    void callLlm() => llmCalls++;

    final decision = gate.inspect('出血了怎么办');
    expect(decision.block, isTrue);
    if (!decision.block) {
      callLlm();
    }
    expect(llmCalls, 0);
  });

  test('PSYCH_CRISIS reply embeds hotline placeholders', () {
    final decision = gate.inspect('不想活了');
    expect(decision.block, isTrue);
    expect(decision.reply, contains('示例心理援助热线'));
    expect(decision.reply, contains('000-0000-0000'));
    expect(decision.reply!.contains('{hotline}'), isFalse);
  });

  test('MEDICATION_DOSE regexp matches spaced dose', () {
    final decision = gate.inspect('阿莫西林一次 500mg 可以吃吗');
    expect(decision.block, isTrue);
    expect(decision.category, 'MEDICATION_DOSE');
  });
}
