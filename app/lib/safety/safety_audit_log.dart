import 'dart:io';

/// Append-only local audit lines (AC-05-B04). Never writes message bodies.
class SafetyAuditLog {
  SafetyAuditLog({Directory? directory}) : _directory = directory;

  final Directory? _directory;

  Future<void> write({
    required String category,
    required String patternId,
    String? conversationId,
  }) async {
    final dir = _directory ??
        Directory(
          [
            Directory.systemTemp.path,
            'ai_mom_baby_safety_audit',
          ].join(Platform.pathSeparator),
        );
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    final file = File('${dir.path}${Platform.pathSeparator}safety_audit.log');
    final line =
        '${DateTime.now().toUtc().toIso8601String()},$category,$patternId,${conversationId ?? ''}\n';
    await file.writeAsString(line, mode: FileMode.append, flush: true);
  }
}
