import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  static const String _themePrefKey = 'app_theme_mode';
  final SharedPreferences? _prefs;

  ThemeCubit([this._prefs]) : super(ThemeMode.light) {
    _loadTheme();
  }

  void _loadTheme() {
    if (_prefs != null) {
      final isDark = _prefs.getBool(_themePrefKey) ?? false;
      emit(isDark ? ThemeMode.dark : ThemeMode.light);
    }
  }

  Future<void> toggleTheme() async {
    final nextMode = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    emit(nextMode);
    if (_prefs != null) {
      await _prefs.setBool(_themePrefKey, nextMode == ThemeMode.dark);
    }
  }

  bool get isDarkMode => state == ThemeMode.dark;
}
