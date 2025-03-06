// lib/core/providers/theme_provider.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/theme_settings_model.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeSettings _settings = ThemeSettings(
    isDarkMode: false,
    fontSize: 16.0,
    cornerRadius: 12.0,
  );

  ThemeSettings get settings => _settings;

  ThemeProvider() {
    loadSettings();
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _settings = ThemeSettings(
      isDarkMode: prefs.getBool('isDarkMode') ?? false,
      fontSize: prefs.getDouble('fontSize') ?? 16.0,
      cornerRadius: prefs.getDouble('cornerRadius') ?? 12.0,
    );
    notifyListeners();
  }

  Future<void> updateSettings(ThemeSettings newSettings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', newSettings.isDarkMode);
    await prefs.setDouble('fontSize', newSettings.fontSize);
    await prefs.setDouble('cornerRadius', newSettings.cornerRadius);

    _settings = newSettings;
    notifyListeners();
  }
}