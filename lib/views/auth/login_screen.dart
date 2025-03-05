import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../viewmodels/auth_viewmodel.dart';
import 'register_screen.dart';
import 'otp_verification_screen.dart';
import 'package:lottie/lottie.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController phoneController = TextEditingController();

  bool isValidPhoneNumber(String phone) {
    final regex = RegExp(r'^(0|\+84)([35789])[0-9]{8}$');
    return regex.hasMatch(phone);
  }

  Future<bool> checkPhoneNumberExists(String phoneNumber) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('phoneNumber', isEqualTo: phoneNumber)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }

  String cleanPhoneNumber(String phone) {
    phone = phone.replaceAll(RegExp(r'\s+'), '');
    phone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    if (phone.startsWith('+84')) {
      phone = '0${phone.substring(3)}';
    }
    return phone;
  }

  void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const SplashLoadingDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1B4965), Color(0xFF62B6CB)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/logo/logo - removed.png',
                    height: 160,
                  ),
                  SizedBox(height: 5),
                  Text(
                    "FurniHome",
                    style: GoogleFonts.audiowide(
                      color: Colors.white,
                      fontSize: 26,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "Quản lý đồ đạc dễ dàng, tiện lợi.",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 30),
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: "Số điện thoại",
                            prefixIcon: Icon(Icons.phone, color: Color(0xFF1B4965)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () async {
                            String rawPhone = phoneController.text.trim();
                            String phone = cleanPhoneNumber(rawPhone);

                            if (phone.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Vui lòng nhập số điện thoại", textAlign: TextAlign.center),
                                  backgroundColor: Color(0xFFCA3E47),
                                ),
                              );
                              return;
                            }

                            if (!isValidPhoneNumber(phone)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Số điện thoại không hợp lệ", textAlign: TextAlign.center),
                                  backgroundColor: Color(0xFFCA3E47),
                                ),
                              );
                              return;
                            }

                            showLoadingDialog(context);

                            final exists = await checkPhoneNumberExists(phone);
                            if (!exists) {
                              if (Navigator.canPop(context)) {
                                Navigator.pop(context); // Đóng loading an toàn
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Số điện thoại không tồn tại trong hệ thống", textAlign: TextAlign.center),
                                  backgroundColor: Color(0xFFCA3E47),
                                ),
                              );
                              return;
                            }

                            final fullPhoneNumber = '+84${phone.substring(1)}';
                            final verificationId = await authViewModel.sendOTP(fullPhoneNumber);
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context); // Đóng loading an toàn
                            }


                            if (verificationId != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OtpVerificationScreen(
                                    phoneNumber: fullPhoneNumber,
                                    verificationId: verificationId,
                                  ),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF1B4965),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 14),
                            minimumSize: Size(double.infinity, 50),
                          ),
                          child: Text(
                            "Đăng nhập",
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                        SizedBox(height: 15),
                        OutlinedButton.icon(
                          onPressed: () async {
                            showLoadingDialog(context);
                            await authViewModel.loginWithGoogle(context);
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context); // Đóng loading an toàn
                            }

                          },
                          icon: Image.asset('assets/google_icon.png', height: 24),
                          label: Text(
                            "Đăng nhập với Google",
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF1B4965),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            minimumSize: Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: BorderSide(color: Color(0xFF1B4965)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RegisterScreen()),
                      );
                    },
                    child: Text(
                      "Chưa có tài khoản? Đăng ký ngay",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SplashLoadingDialog extends StatelessWidget {
  const SplashLoadingDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1B4965),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset('assets/animations/LoadingAnimation.json', width: 100, height: 100),
            const SizedBox(height: 20),
            const Text(
              "FurniHome",
              style: TextStyle(fontFamily: "Audiowide", fontSize: 28, color: Colors.white, letterSpacing: 2),
            ),
            const SizedBox(height: 10),
            Text(
              "Đang xử lý...",
              style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.8)),
            ),
          ],
        ),
      ),
    );
  }
}