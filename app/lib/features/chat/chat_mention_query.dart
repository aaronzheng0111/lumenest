/// Active `@mention` fragment under the caret (incomplete until space/newline).
final class ChatMentionQuery {
  const ChatMentionQuery({
    required this.atIndex,
    required this.query,
  });

  /// Index of the `@` that starts this mention.
  final int atIndex;

  /// Text after `@` up to the caret (may be empty).
  final String query;
}

/// Finds an incomplete `@…` mention at [cursor] in [text], or `null`.
ChatMentionQuery? findActiveMention(String text, int cursor) {
  if (cursor < 0 || cursor > text.length) return null;
  final before = text.substring(0, cursor);
  final at = before.lastIndexOf('@');
  if (at < 0) return null;
  if (at > 0) {
    final prev = before[at - 1];
    if (prev != ' ' && prev != '\n') return null;
  }
  final fragment = before.substring(at + 1);
  if (fragment.contains(' ') || fragment.contains('\n')) return null;
  return ChatMentionQuery(atIndex: at, query: fragment);
}

/// Roles whose [displayName] matches the typed prefix (case-insensitive).
List<T> filterMentionRoles<T>(
  Iterable<T> roles,
  String query,
  String Function(T role) displayName,
) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return roles.toList();
  return [
    for (final role in roles)
      if (displayName(role).toLowerCase().startsWith(q)) role,
  ];
}
