import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../widgets/password_textfield.dart';
import 'register_screen.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isValidPhoneNumber(String phone) {
    final regex = RegExp(r'^(0|\+84)[3|5|7|8|9][0-9]{8}$');
    return regex.hasMatch(phone);
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
                  // Logo ứng dụng
                  Image.asset(
                    'assets/logo/logo - removed.png',
                    height: 160,
                  ),
                  SizedBox(height: 5),

                  // Tên ứng dụng
                  Text(
                    "FurniHome",
                    style: GoogleFonts.audiowide(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.normal,
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

                  // Form đăng nhập
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
                        // Số điện thoại
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
                        SizedBox(height: 15),

                        // Mật khẩu
                        PasswordTextField(
                          controller: passwordController,
                          labelText: "Mật khẩu",
                          borderColor: Color(0xFF1B4965),
                          iconColor: Color(0xFF1B4965),
                          labelColor: Colors.black54,
                        ),
                        SizedBox(height: 20),

                        // Nút đăng nhập
                        authViewModel.isLoading
                            ? CircularProgressIndicator()
                            : ElevatedButton(
                          onPressed: () async {
                            String phone = phoneController.text.trim();
                            String password = passwordController.text;

                            if (phone.isEmpty || password.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Vui lòng nhập đầy đủ thông tin",
                                    textAlign: TextAlign.center,
                                  ),
                                  backgroundColor: Color(0xFFCA3E47),
                                ),
                              );
                              return;
                            }

                            if (!isValidPhoneNumber(phone)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Số điện thoại không hợp lệ",
                                    textAlign: TextAlign.center,
                                  ),
                                  backgroundColor: Color(0xFFCA3E47),
                                ),
                              );
                              return;
                            }

                            String fakeEmail = "$phone@furnihome.vn";

                            bool success = await authViewModel.loginWithPhone(
                              fakeEmail,
                              password,
                              context,
                            );

                            if (!success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    authViewModel.errorMessage ?? "Đăng nhập thất bại",
                                    textAlign: TextAlign.center,
                                  ),
                                  backgroundColor: Color(0xFFCA3E47),
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
                            "Đăng Nhập",
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                        SizedBox(height: 15),

                        // Nút đăng nhập Google
                        OutlinedButton.icon(
                          onPressed: () async {
                            await authViewModel.loginWithGoogle(context);
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

                  // Điều hướng sang đăng ký
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