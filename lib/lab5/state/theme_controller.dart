import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Лише інтерфейсні налаштування. Паролі / Firebase токени тут НЕ зберігаємо.
class ThemeController extends ChangeNotifier {
  static const _key = 'jobcatalog_dark_mode';
  final SharedPreferencesAsync _preferences = SharedPreferencesAsync();
  bool _isDark = false;
  bool _loaded = false;

  bool get isDark => _isDark;
  bool get loaded => _loaded;
  ThemeMode get themeMode => _isDark ? ThemeMode.dark : ThemeMode.light;

  Future<void> load() async {
    try {
      _isDark = await _preferences.getBool(_key) ?? false;
    } catch (_) {
      _isDark = false;
    } finally {
      _loaded = true;
      notifyListeners();
    }
  }

  Future<void> setDark(bool value) async {
    _isDark = value;
    notifyListeners();
    await _preferences.setBool(_key, value);
  }
}
