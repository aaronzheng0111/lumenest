/// Formats timestamps shown in conversation history.
///
/// The value is converted to the device's local timezone before formatting.
String formatConversationTimestamp(
  DateTime timestamp, {
  DateTime? now,
}) {
  final localTimestamp = timestamp.toLocal();
  final current = (now ?? DateTime.now()).toLocal();

  if (_isSameDay(localTimestamp, current)) {
    return _formatTime(localTimestamp);
  }
  if (_isYesterday(localTimestamp, current)) {
    return '昨天';
  }
  if (localTimestamp.year == current.year) {
    return '${localTimestamp.month}/${localTimestamp.day}';
  }
  return '${localTimestamp.year}/${localTimestamp.month}/${localTimestamp.day}';
}

/// Formats a compact timestamp displayed inside a chat bubble.
///
/// The value is converted to the device's local timezone before formatting.
String formatChatBubbleTimestamp(
  DateTime timestamp, {
  DateTime? now,
}) {
  final localTimestamp = timestamp.toLocal();
  final current = (now ?? DateTime.now()).toLocal();
  final time = _formatTime(localTimestamp);

  if (_isSameDay(localTimestamp, current)) {
    return time;
  }
  if (_isYesterday(localTimestamp, current)) {
    return '昨天 $time';
  }
  if (localTimestamp.year == current.year) {
    return '${localTimestamp.month}月${localTimestamp.day}日 $time';
  }
  return '${localTimestamp.year}/${localTimestamp.month}/${localTimestamp.day} '
      '$time';
}

String _formatTime(DateTime timestamp) {
  final hour = timestamp.hour.toString().padLeft(2, '0');
  final minute = timestamp.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

bool _isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

bool _isYesterday(DateTime timestamp, DateTime now) {
  final yesterday =
      DateTime(now.year, now.month, now.day).subtract(const Duration(days: 1));
  return _isSameDay(timestamp, yesterday);
}
