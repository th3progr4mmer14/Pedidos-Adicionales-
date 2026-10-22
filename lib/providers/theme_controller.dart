import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Controla el tema de la app (sistema / claro / oscuro) y lo guarda
/// en el dispositivo para que se respete al volver a abrir la app.
class ThemeController extends ValueNotifier<ThemeMode> {
  ThemeController._(ThemeMode mode, this._prefs) : super(mode);

  static const _key = 'theme_mode';
  final SharedPreferences _prefs;

  /// Llamar una sola vez en main() antes de runApp().
  static Future<ThemeController> load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_key);
    final mode = ThemeMode.values.firstWhere(
      (m) => m.name == saved,
      orElse: () => ThemeMode.system,
    );
    return ThemeController._(mode, prefs);
  }

  Future<void> setMode(ThemeMode mode) async {
    if (mode == value) return;
    value = mode;
    await _prefs.setString(_key, mode.name);
  }
}
