import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B4965),
        title: Text(
          "About FurniHome",
          style: GoogleFonts.audiowide(
            color: Colors.white,
            fontSize: 22,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1B4965), Color(0xFF62B6CB)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/logo/logo - removed.png',
                height: 120,
              ),
              const SizedBox(height: 20),
              Text(
                "FurniHome",
                style: GoogleFonts.audiowide(
                  fontSize: 26,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Phiên bản: 1.0.0",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 30),
              Text(
                "FurniHome là ứng dụng giúp bạn quản lý đồ đạc trong nhà một cách dễ dàng và tiện lợi. "
                    "Bạn có thể theo dõi, ghi chú và quản lý các món đồ ít sử dụng nhưng quan trọng, "
                    "giúp tiết kiệm không gian và thời gian tìm kiếm.\n\n"
                    "Ứng dụng được phát triển nhằm phục vụ nhu cầu quản lý cá nhân và hỗ trợ cho công việc gia đình.",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.white,
                  height: 1.5,
                ),
              ),
              const Spacer(),
              Text(
                "© 2025 - Dương Phú Cường",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white60,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}