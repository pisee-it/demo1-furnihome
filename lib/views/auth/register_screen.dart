import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../viewmodels/auth_viewmodel.dart';
import 'login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final phoneController = TextEditingController();
  String? _errorMessage;

  String normalizePhoneNumber(String phone) {
    phone = phone.replaceAll(RegExp(r'\s+'), '');
    if (phone.startsWith('+84')) {
      phone = '0${phone.substring(3)}';
    }
    return phone;
  }

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

  void showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const SplashLoadingDialog(),
    );
  }

  Future<void> _validateAndProceed() async {
    setState(() => _errorMessage = null);

    final rawPhone = phoneController.text.trim();

    if (rawPhone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Chúng tôi cần biết SĐT của bạn", textAlign: TextAlign.center),
          backgroundColor: Color(0xFFCA3E47),
        ),
      );
      return;
    }

    if (!isValidPhoneNumber(rawPhone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Số điện thoại không hợp lệ", textAlign: TextAlign.center),
          backgroundColor: Color(0xFFCA3E47),
        ),
      );
      return;
    }

    showLoadingDialog();

    final exists = await checkPhoneNumberExists(rawPhone);
    if (Navigator.canPop(context)) {
      Navigator.pop(context); // Đóng loading an toàn
    }

    if (exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Số điện thoại đã tồn tại. Vui lòng dùng số khác.", textAlign: TextAlign.center),
          backgroundColor: Color(0xFFCA3E47),
        ),
      );
      return;
    }

    Navigator.pushNamed(
      context,
      '/user-info',
      arguments: rawPhone,
    );
  }

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1B4965), Color(0xFF62B6CB)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/logo/logo - removed.png', height: 150),
                    const SizedBox(height: 10),
                    Text(
                      "Tạo tài khoản",
                      style: GoogleFonts.poppins(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Đăng ký ngay để quản lý đồ đạc của bạn hiệu quả!",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              labelText: "Nhập số điện thoại để bắt đầu",
                              prefixIcon: const Icon(Icons.phone, color: Color(0xFF1B4965)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onChanged: (_) {
                              if (_errorMessage != null) {
                                setState(() => _errorMessage = null);
                              }
                            },
                          ),
                          const SizedBox(height: 20),
                          if (_errorMessage != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ElevatedButton(
                            onPressed: _validateAndProceed,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1B4965),
                              minimumSize: const Size(double.infinity, 50),
                            ),
                            child: const Text(
                              "Tiếp tục",
                              style: TextStyle(fontSize: 18, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      ),
                      child: const Text(
                        "Đã có tài khoản? Đăng nhập ngay",
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
            Lottie.asset(
              'assets/animations/LoadingAnimation.json',
              width: 100,
              height: 100,
            ),
            const SizedBox(height: 20),
            const Text(
              "FurniHome",
              style: TextStyle(
                fontFamily: "Audiowide",
                fontSize: 28,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Đang xử lý...",
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}