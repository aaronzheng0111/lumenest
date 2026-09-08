/// Minimal P1 knowledge hit (full RAG is module 07 / TASK-201).
class KnowledgeHit {
  const KnowledgeHit({required this.title, required this.snippet});

  final String title;
  final String snippet;
}

abstract class KnowledgeRetriever {
  Future<List<KnowledgeHit>> retrieve(String query, {int k = 3});
}

/// Fixture-backed stub so 08 can run without full 07.
class FakeKnowledgeRetriever implements KnowledgeRetriever {
  FakeKnowledgeRetriever({this.hits = const []});

  final List<KnowledgeHit> hits;

  @override
  Future<List<KnowledgeHit>> retrieve(String query, {int k = 3}) async {
    if (hits.isEmpty) return const [];
    return hits.take(k).toList();
  }
}
