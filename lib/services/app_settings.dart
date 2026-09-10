import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings extends ChangeNotifier {
  static const String _keyTheme = 'app_theme_mode';
  static const String _keyCommunity = 'app_community_id';
  static const String defaultCommunityId = 'kumpul_001';

  ThemeMode _themeMode = ThemeMode.light;
  String? _communityId;

  ThemeMode get themeMode => _themeMode;
  String get communityId => _communityId ?? defaultCommunityId;

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final theme = prefs.getString(_keyTheme);
      switch (theme) {
        case 'dark':
          _themeMode = ThemeMode.dark;
          break;
        case 'light':
          _themeMode = ThemeMode.light;
          break;
        default:
          _themeMode = ThemeMode.system;
      }
      _communityId = prefs.getString(_keyCommunity);
      notifyListeners();
    } catch (e) {
      debugPrint('AppSettings init error: $e');
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyTheme, mode.name);
    } catch (e) {
      debugPrint('setThemeMode persist error: $e');
    }
  }

  Future<void> selectCommunity(String id) async {
    _communityId = id;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyCommunity, id);
    } catch (e) {
      debugPrint('selectCommunity persist error: $e');
    }
  }
}