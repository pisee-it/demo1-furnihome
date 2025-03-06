import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/models/theme_settings_model.dart';
import '../../../core/providers/theme_provider.dart';

class ThemeSettingsScreen extends StatefulWidget {
  @override
  _ThemeSettingsScreenState createState() => _ThemeSettingsScreenState();
}

class _ThemeSettingsScreenState extends State<ThemeSettingsScreen> {
  late bool isDarkMode;
  late double fontSize;
  late double cornerRadius;

  @override
  void initState() {
    super.initState();
    final themeSettings = Provider.of<ThemeProvider>(context, listen: false).settings;
    isDarkMode = themeSettings.isDarkMode;
    fontSize = themeSettings.fontSize;
    cornerRadius = themeSettings.cornerRadius;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF1B4965),
        title: Text(
          "Cài đặt giao diện",
          style: GoogleFonts.audiowide(
            color: Colors.white,
            fontSize: 22,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1B4965), Color(0xFF62B6CB)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildSectionTitle("Chế độ hiển thị"),
            SwitchListTile(
              value: isDarkMode,
              activeColor: Colors.orange,
              title: Text(
                "Chế độ tối",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              onChanged: (value) {
                setState(() {
                  isDarkMode = value;
                });
              },
            ),
            SizedBox(height: 20),

            _buildSectionTitle("Cỡ chữ"),
            Slider(
              value: fontSize,
              min: 12,
              max: 24,
              divisions: 6,
              label: "${fontSize.toInt()}",
              onChanged: (value) {
                setState(() {
                  fontSize = value;
                });
              },
            ),
            Text(
              "Cỡ chữ hiện tại: ${fontSize.toInt()}",
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            SizedBox(height: 20),

            _buildSectionTitle("Độ cong góc"),
            Slider(
              value: cornerRadius,
              min: 0,
              max: 30,
              divisions: 6,
              label: "${cornerRadius.toInt()}",
              onChanged: (value) {
                setState(() {
                  cornerRadius = value;
                });
              },
            ),
            Text(
              "Độ cong hiện tại: ${cornerRadius.toInt()}",
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            SizedBox(height: 30),

            ElevatedButton(
              onPressed: () async {
                final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
                await themeProvider.updateSettings(
                  ThemeSettings(
                    isDarkMode: isDarkMode,
                    fontSize: fontSize,
                    cornerRadius: cornerRadius,
                  ),
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Đã lưu cài đặt giao diện!", textAlign: TextAlign.center),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                "Lưu thay đổi",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}