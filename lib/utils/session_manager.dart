import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const _playerIdKey = 'player_id';

  static Future<void> savePlayerId(int playerId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_playerIdKey, playerId);
  }

  static Future<int?> getPlayerId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_playerIdKey);
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_playerIdKey);
  }
}
