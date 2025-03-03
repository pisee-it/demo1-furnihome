import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OtpViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? verificationId;
  bool isLoading = false;
  String? errorMessage;

  int secondsRemaining = 60;
  bool canResend = false;
  Timer? _timer;

  // ✅ Bắt đầu đếm ngược OTP
  void startTimer() {
    secondsRemaining = 60;
    canResend = false;
    notifyListeners();

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (secondsRemaining == 0) {
        canResend = true;
        timer.cancel();
      } else {
        secondsRemaining--;
      }
      notifyListeners();
    });
  }

  // ✅ Dừng timer khi không dùng nữa
  void stopTimer() {
    _timer?.cancel();
  }

  // ✅ Xác minh OTP
  Future<bool> verifyOtp(String otpCode, BuildContext context) async {
    if (verificationId == null) {
      errorMessage = "Không tìm thấy mã xác minh. Vui lòng thử lại.";
      notifyListeners();
      return false;
    }

    if (otpCode.isEmpty || otpCode.length != 6) {
      errorMessage = "Vui lòng nhập chính xác mã OTP gồm 6 chữ số.";
      notifyListeners();
      return false;
    }

    try {
      isLoading = true;
      notifyListeners();

      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId!,
        smsCode: otpCode,
      );

      await _auth.signInWithCredential(credential);

      isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      isLoading = false;
      errorMessage = _mapFirebaseErrorToMessage(e);
      notifyListeners();
      return false;
    } catch (e) {
      isLoading = false;
      errorMessage = "Đã xảy ra lỗi không xác định. Vui lòng thử lại.";
      notifyListeners();
      return false;
    }
  }

  // ✅ Gửi lại OTP
  Future<void> resendOtp(String phoneNumber, BuildContext context) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      canResend = false;
      startTimer();

      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (_) {},
        verificationFailed: (FirebaseAuthException e) {
          errorMessage = "Không thể gửi lại OTP. Lỗi: ${_mapFirebaseErrorToMessage(e)}";
          isLoading = false;
          notifyListeners();
        },
        codeSent: (String newVerificationId, int? resendToken) {
          verificationId = newVerificationId;
          isLoading = false;
          notifyListeners();
        },
        codeAutoRetrievalTimeout: (_) {},
      );
    } catch (e) {
      isLoading = false;
      errorMessage = "Đã xảy ra lỗi khi gửi lại OTP. Vui lòng kiểm tra kết nối hoặc thử lại sau.";
      notifyListeners();
    }
  }

  // ✅ Xóa lỗi khi người dùng sửa dữ liệu
  void clearError() {
    errorMessage = null;
    notifyListeners();
  }

  // ✅ Chuyển lỗi kỹ thuật Firebase thành thông báo thân thiện
  String _mapFirebaseErrorToMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-verification-code':
        return "Mã OTP không hợp lệ. Vui lòng kiểm tra lại.";
      case 'session-expired':
        return "Phiên xác thực đã hết hạn. Vui lòng gửi lại OTP.";
      case 'too-many-requests':
        return "Quá nhiều yêu cầu. Vui lòng thử lại sau.";
      default:
        return "Đã xảy ra lỗi xác minh. Vui lòng thử lại.";
    }
  }

  @override
  void dispose() {
    stopTimer();
    super.dispose();
  }
}