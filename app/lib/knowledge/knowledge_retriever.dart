import 'dart:convert';

import 'package:flutter/services.dart';

/// Single knowledge hit (AC-07-B01). Shape stays vector-retriever compatible.
class KnowledgeHit {
  const KnowledgeHit({
    required this.id,
    required this.title,
    required this.text,
    required this.score,
  });

  final String id;
  final String title;
  final String text;

  /// 0–1; fake ranks use 1.0 / 0.5 / 0.2.
  final double score;

  /// Alias used by older graph prompt formatting.
  String get snippet => text;
}

abstract class KnowledgeRetriever {
  /// AC-07-B01 primary API.
  Future<List<KnowledgeHit>> search(String query, {int k = 3});
}

/// P1 fake substring retriever (AC-07-B02). Never performs HTTP.
class FakeSubstringRetriever implements KnowledgeRetriever {
  FakeSubstringRetriever(this._chunks);

  final List<_KnowledgeChunk> _chunks;

  static const assetChunksPath =
      'assets/fixtures/knowledge/knowledge_chunks.json';

  static const rankScores = [1.0, 0.5, 0.2];

  static Future<FakeSubstringRetriever> load({
    AssetBundle? bundle,
    String? jsonOverride,
  }) async {
    final raw = jsonOverride ??
        await (bundle ?? rootBundle).loadString(assetChunksPath);
    return FakeSubstringRetriever.fromDecoded(
      jsonDecode(raw) as Map<String, dynamic>,
    );
  }

  factory FakeSubstringRetriever.fromDecoded(Map<String, dynamic> json) {
    final list = <_KnowledgeChunk>[];
    for (final raw in json['chunks'] as List<dynamic>? ?? const []) {
      final m = raw as Map<String, dynamic>;
      list.add(
        _KnowledgeChunk(
          id: m['id'] as String,
          title: m['title'] as String,
          text: m['text'] as String,
        ),
      );
    }
    return FakeSubstringRetriever(list);
  }

  /// Sync factory for unit tests that pass pre-decoded maps or empty corpus.
  factory FakeSubstringRetriever.fromChunks(
    List<Map<String, dynamic>> chunks,
  ) {
    return FakeSubstringRetriever([
      for (final m in chunks)
        _KnowledgeChunk(
          id: m['id'] as String,
          title: m['title'] as String,
          text: m['text'] as String,
        ),
    ]);
  }

  @override
  Future<List<KnowledgeHit>> search(String query, {int k = 3}) async {
    final q = query.trim();
    if (q.isEmpty || k <= 0) return const [];

    final tokens = tokenize(q);
    if (tokens.isEmpty) return const [];

    final scored = <({_KnowledgeChunk chunk, int hits})>[];
    for (final chunk in _chunks) {
      var hits = 0;
      for (final t in tokens) {
        if (chunk.text.contains(t)) hits++;
      }
      if (hits > 0) {
        scored.add((chunk: chunk, hits: hits));
      }
    }
    if (scored.isEmpty) return const [];

    scored.sort((a, b) {
      final byHits = b.hits.compareTo(a.hits);
      if (byHits != 0) return byHits;
      return a.chunk.id.compareTo(b.chunk.id);
    });

    final top = scored.take(k).toList();
    return [
      for (var i = 0; i < top.length; i++)
        KnowledgeHit(
          id: top[i].chunk.id,
          title: top[i].chunk.title,
          text: top[i].chunk.text,
          score: rankScores[i < rankScores.length ? i : rankScores.length - 1],
        ),
    ];
  }

  /// Space-split plus CJK character bigrams (AC-07-B02).
  static List<String> tokenize(String query) {
    final tokens = <String>{};
    for (final part in query.split(RegExp(r'\s+'))) {
      if (part.isEmpty) continue;
      tokens.add(part);
      final runes = part.runes.toList();
      if (runes.length >= 2) {
        for (var i = 0; i < runes.length - 1; i++) {
          tokens.add(String.fromCharCodes([runes[i], runes[i + 1]]));
        }
      } else if (runes.length == 1) {
        tokens.add(String.fromCharCodes(runes));
      }
    }
    return tokens.toList();
  }
}

/// Test double that returns a fixed hit list (no corpus scoring).
class FakeKnowledgeRetriever implements KnowledgeRetriever {
  FakeKnowledgeRetriever({this.hits = const []});

  final List<KnowledgeHit> hits;

  @override
  Future<List<KnowledgeHit>> search(String query, {int k = 3}) async {
    if (query.trim().isEmpty || hits.isEmpty) return const [];
    return hits.take(k).toList();
  }
}

class _KnowledgeChunk {
  const _KnowledgeChunk({
    required this.id,
    required this.title,
    required this.text,
  });

  final String id;
  final String title;
  final String text;
}
