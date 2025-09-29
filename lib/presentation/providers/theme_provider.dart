import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  Color _primaryColor = Colors.blue;
  bool _isInitialized = false;

  ThemeProvider() {
    _loadPreferences();
  }

  ThemeMode get themeMode => _themeMode;
  Color get primaryColor => _primaryColor;
  bool get isInitialized => _isInitialized;

  void setThemeMode(ThemeMode themeMode) {
    _themeMode = themeMode;
    _savePreferences();
    notifyListeners();
  }

  void setPrimaryColor(Color color) {
    _primaryColor = color;
    _savePreferences();
    notifyListeners();
  }

  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      return WidgetsBinding.instance.platformDispatcher.platformBrightness ==
          Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeModeIndex = prefs.getInt('theme_mode');
      final colorValue = prefs.getInt('primary_color');

      if (themeModeIndex != null && themeModeIndex < ThemeMode.values.length) {
        _themeMode = ThemeMode.values[themeModeIndex];
      }

      if (colorValue != null) {
        _primaryColor = Color(colorValue);
      }
    } catch (e) {
      debugPrint('Error loading theme preferences: $e');
    } finally {
      _isInitialized = true;
      notifyListeners(); // ✅ always notifies after loading
    }
  }

  Future<void> _savePreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('theme_mode', _themeMode.index);
      await prefs.setInt('primary_color', _primaryColor.value); // .value is not deprecated for Color
    } catch (e) {
      debugPrint('Error saving theme preferences: $e');
    }
  }
}
