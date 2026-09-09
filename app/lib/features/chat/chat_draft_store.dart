import 'package:shared_preferences/shared_preferences.dart';

/// Shared draft persistence for solo and group chat sessions.
abstract final class ChatDraftStore {
  static String _key(int conversationId) => 'chat_draft_$conversationId';

  static Future<String?> load(int conversationId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key(conversationId));
  }

  static Future<void> save(int conversationId, String text) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key(conversationId), text);
  }
}
