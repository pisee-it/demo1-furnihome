import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../viewmodels/otp_viewmodel.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;
  final String password;

  OtpVerificationScreen({
    required this.phoneNumber,
    required this.verificationId,
    required this.password,
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
                      otpViewModel.isLoading
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                        onPressed: () async {
                          FocusScope.of(context).unfocus();
                          final isValid = await otpViewModel.verifyOtp(
                            otpController.text.trim(),
                            context,
                          );
                          if (isValid) {
                            Navigator.pushReplacementNamed(context, "/user-info");
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
                      decoration: TextDecoration.underline,
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