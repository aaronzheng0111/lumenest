/// Local tool: current wall-clock time (AC-style graph tool, not LLM function-calling).
abstract final class GetCurrentTimeTool {
  static const name = 'get_current_time';

  /// Keywords that trigger this tool on a user turn.
  static bool shouldInvoke(String userText) {
    final t = userText.trim().toLowerCase();
    if (t.isEmpty) return false;
    const needles = [
      '几点',
      '现在时间',
      '当前时间',
      '什么时候了',
      '现在几时',
      'what time',
      'current time',
    ];
    for (final n in needles) {
      if (t.contains(n)) return true;
    }
    return RegExp(r'现在.*(几点|时间)|时间.*(多少|几点)').hasMatch(t);
  }

  /// Returns a stable, human-readable local timestamp.
  static String invoke({DateTime? now, String? timeZoneLabel}) {
    final t = now ?? DateTime.now();
    final y = t.year.toString().padLeft(4, '0');
    final mo = t.month.toString().padLeft(2, '0');
    final d = t.day.toString().padLeft(2, '0');
    final h = t.hour.toString().padLeft(2, '0');
    final mi = t.minute.toString().padLeft(2, '0');
    final s = t.second.toString().padLeft(2, '0');
    final tz = timeZoneLabel ?? t.timeZoneName;
    return '$y-$mo-$d $h:$mi:$s ($tz)';
  }
}
