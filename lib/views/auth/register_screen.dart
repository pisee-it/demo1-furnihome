import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../widgets/password_textfield.dart';
import 'login_screen.dart';
import 'otp_verification_screen.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  String? _errorMessage;

  bool isValidPhoneNumber(String phone) {
    final regex = RegExp(r'^(0|\+84)[3|5|7|8|9][0-9]{8}$');
    return regex.hasMatch(phone);
  }

  String formatPhoneNumber(String phone) {
    if (phone.startsWith('0')) {
      return '+84${phone.substring(1)}';
    }
    return phone;
  }

  Future<void> _sendOTP(String phoneNumber) async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    authViewModel.setLoading(true);

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (_) {},
        verificationFailed: (e) {
          setState(() {
            _errorMessage = "Không thể gửi OTP. Vui lòng kiểm tra số điện thoại hoặc thử lại sau.";
          });
        },
        codeSent: (verificationId, _) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OtpVerificationScreen(
                phoneNumber: phoneNumber,
                verificationId: verificationId,
                password: passwordController.text,
              ),
            ),
          );
        },
        codeAutoRetrievalTimeout: (_) {},
      );
    } catch (_) {
      setState(() {
        _errorMessage = "Đã xảy ra lỗi khi gửi OTP. Vui lòng thử lại.";
      });
    } finally {
      authViewModel.setLoading(false);
    }
  }

  void _validateAndSendOTP() async {
    setState(() => _errorMessage = null);

    if (_formKey.currentState!.validate()) {
      final phone = phoneController.text.trim();
      final password = passwordController.text.trim();
      final confirmPassword = confirmPasswordController.text.trim();

      if (password.length < 6) {
        setState(() => _errorMessage = "Mật khẩu phải có ít nhất 6 ký tự.");
        return;
      }
      if (password != confirmPassword) {
        setState(() => _errorMessage = "Mật khẩu xác nhận không khớp.");
        return;
      }

      await _sendOTP(formatPhoneNumber(phone));
    }
  }

  @override
  void dispose() {
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);

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
                              labelText: "Số điện thoại",
                              prefixIcon: const Icon(Icons.phone, color: Color(0xFF1B4965)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Vui lòng nhập số điện thoại";
                              }
                              if (!isValidPhoneNumber(value.trim())) {
                                return "Số điện thoại không hợp lệ";
                              }
                              return null;
                            },
                            onChanged: (_) {
                              if (_errorMessage != null) {
                                setState(() => _errorMessage = null);
                              }
                            },
                          ),
                          const SizedBox(height: 15),
                          PasswordTextField(
                            controller: passwordController,
                            labelText: "Mật khẩu",
                            borderColor: const Color(0xFF1B4965),
                            iconColor: const Color(0xFF1B4965),
                            labelColor: Colors.black54,
                            onChanged: (_) {
                              if (_errorMessage != null) {
                                setState(() => _errorMessage = null);
                              }
                            },
                          ),
                          const SizedBox(height: 15),
                          PasswordTextField(
                            controller: confirmPasswordController,
                            labelText: "Xác nhận mật khẩu",
                            borderColor: const Color(0xFF1B4965),
                            iconColor: const Color(0xFF1B4965),
                            labelColor: Colors.black54,
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
                                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),

                          authViewModel.isLoading
                              ? const CircularProgressIndicator()
                              : ElevatedButton(
                            onPressed: _validateAndSendOTP,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1B4965),
                              minimumSize: const Size(double.infinity, 50),
                            ),
                            child: const Text(
                              "Gửi OTP",
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