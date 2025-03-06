// lib/core/models/theme_settings_model.dart

class ThemeSettings {
  final bool isDarkMode;
  final double fontSize;
  final double cornerRadius;

  ThemeSettings({
    required this.isDarkMode,
    required this.fontSize,
    required this.cornerRadius,
  });

  factory ThemeSettings.fromMap(Map<String, dynamic> map) {
    return ThemeSettings(
      isDarkMode: map['isDarkMode'] ?? false,
      fontSize: (map['fontSize'] ?? 16).toDouble(),
      cornerRadius: (map['cornerRadius'] ?? 12).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isDarkMode': isDarkMode,
      'fontSize': fontSize,
      'cornerRadius': cornerRadius,
    };
  }
}