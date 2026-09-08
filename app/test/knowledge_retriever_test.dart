import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:ai_mom_baby/knowledge/knowledge_retriever.dart';

Map<String, dynamic> _readSdd(String name) {
  final file = File('../sdd/07-local-knowledge-retrieval/fixtures/$name');
  return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
}

void main() {
  late FakeSubstringRetriever retriever;

  setUp(() {
    retriever = FakeSubstringRetriever.fromDecoded(_readSdd('knowledge_chunks.json'));
  });

  test('T07-02 retrieval_cases top1 title / id', () async {
    final cases = _readSdd('retrieval_cases.json')['cases'] as List<dynamic>;
    for (final raw in cases) {
      final c = raw as Map<String, dynamic>;
      final query = c['query'] as String;
      final expectTopId = c['expectTopId'] as String?;
      final hits = await retriever.search(query, k: 3);
      if (expectTopId == null) {
        expect(hits, isEmpty, reason: query);
      } else {
        expect(hits, isNotEmpty, reason: query);
        expect(hits.first.id, expectTopId, reason: query);
      }
    }
  });

  test('T07-03 empty query returns []', () async {
    expect(await retriever.search(''), isEmpty);
    expect(await retriever.search('   '), isEmpty);
  });

  test('AC-07-B01 hit shape id/title/text/score', () async {
    final hits = await retriever.search('孕吐吃什么', k: 3);
    expect(hits, isNotEmpty);
    final h = hits.first;
    expect(h.id, isNotEmpty);
    expect(h.title, isNotEmpty);
    expect(h.text, isNotEmpty);
    expect(h.score, greaterThan(0));
    expect(h.score, lessThanOrEqualTo(1));
  });

  test('AC-07-B02 top-k rank scores 1.0/0.5/0.2', () async {
    final multi = FakeSubstringRetriever.fromChunks([
      {'id': 'a', 'title': 'A', 'text': '测试 命中 甲'},
      {'id': 'b', 'title': 'B', 'text': '测试 命中'},
      {'id': 'c', 'title': 'C', 'text': '测试'},
    ]);
    final hits = await multi.search('测试 命中 甲', k: 3);
    expect(hits.length, 3);
    expect(hits.map((e) => e.score).toList(), [1.0, 0.5, 0.2]);
  });

  test('no HTTP — search is local only', () async {
    // Smoke: completes without network; corpus is fixture-backed.
    final hits = await retriever.search('情绪', k: 1);
    expect(hits.first.id, 'kb-emotion-01');
  });
}
