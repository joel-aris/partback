import 'package:shared_preferences/shared_preferences.dart';

/// Non-sensitive user preferences (theme, language). Never put the auth
/// token or any credential here — see [TokenStorage] for that.
///
/// Calls are bounded by a timeout so a stalled storage backend degrades to
/// "use the default" instead of freezing the UI (see TokenStorage for the
/// same rationale on the auth side).
class PreferencesStorage {
  static const _themeModeKey = 'validika.theme_mode';
  static const _timeout = Duration(seconds: 3);

  Future<String?> readThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance().timeout(_timeout);
      return prefs.getString(_themeModeKey);
    } catch (_) {
      return null;
    }
  }

  Future<void> writeThemeMode(String mode) async {
    try {
      final prefs = await SharedPreferences.getInstance().timeout(_timeout);
      await prefs.setString(_themeModeKey, mode).timeout(_timeout);
    } catch (_) {
      // Best-effort: the in-memory ThemeController state is already updated.
    }
  }
}
