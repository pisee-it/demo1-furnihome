import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import '../../viewmodels/otp_viewmodel.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;
  final String? displayName;
  final String? age;
  final String? gender;
  final bool? isHomeOwner;
  final File? avatarImageFile;
  final Function(String otpCode)? onOtpVerified;

  OtpVerificationScreen({
    required this.phoneNumber,
    required this.verificationId,
    this.displayName,
    this.age,
    this.gender,
    this.isHomeOwner,
    this.avatarImageFile,
    this.onOtpVerified,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final TextEditingController otpController = TextEditingController();

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  void showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const SplashLoadingDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OtpViewModel()
        ..verificationId = widget.verificationId
        ..startTimer(),
      child: Consumer<OtpViewModel>(
        builder: (context, otpViewModel, child) => Scaffold(
          resizeToAvoidBottomInset: true,
          body: Container(
            width: double.infinity,
            height: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1B4965), Color(0xFF62B6CB)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/logo/logo - removed.png',
                  height: 120,
                ),
                const SizedBox(height: 20),
                Text(
                  "Xác minh OTP",
                  style: GoogleFonts.poppins(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Nhập mã OTP được gửi tới\n${widget.phoneNumber}",
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
                      TextField(
                        controller: otpController,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        decoration: InputDecoration(
                          labelText: "Nhập mã OTP",
                          prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF1B4965)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          counterText: "",
                        ),
                        onChanged: (_) {
                          otpViewModel.clearError();
                        },
                      ),
                      if (otpViewModel.errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            otpViewModel.errorMessage!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      const SizedBox(height: 15),
                      ElevatedButton(
                        onPressed: () async {
                          FocusScope.of(context).unfocus();
                          final otpCode = otpController.text.trim();

                          showLoadingDialog();

                          final isValid = await otpViewModel.verifyOtp(
                            otpCode,
                            context,
                            widget.phoneNumber,
                            widget.displayName,
                            widget.age,
                            widget.gender,
                            widget.isHomeOwner,
                            widget.avatarImageFile,
                          );

                          if (Navigator.canPop(context)) {
                            Navigator.pop(context); // Đóng loading an toàn
                          }

                          if (isValid) {
                            await widget.onOtpVerified?.call(otpCode);
                            Navigator.pushReplacementNamed(context, "/home");
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1B4965),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: const Text(
                          "Xác nhận",
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                otpViewModel.canResend
                    ? TextButton(
                  onPressed: () => otpViewModel.resendOtp(widget.phoneNumber, context),
                  child: const Text(
                    "Gửi lại OTP",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                )
                    : Text(
                  "Gửi lại OTP sau ${otpViewModel.secondsRemaining}s",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
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