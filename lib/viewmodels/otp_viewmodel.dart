import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class OtpViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? verificationId;
  // bool isLoading = false;
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

  String normalizePhoneNumber84(String phone) {
    phone = phone.replaceAll(RegExp(r'\s+'), ''); // Xóa khoảng trắng
    if (phone.startsWith('0')) {
      return '+84${phone.substring(1)}';
    }
    return phone; // Nếu đã là +84 thì giữ nguyên
  }


  // ✅ Xác minh OTP và lưu thông tin người dùng
  Future<bool> verifyOtp(
      String otpCode,
      BuildContext context,
      String phoneNumber,
      String? displayName,
      String? age,
      String? gender,
      bool? isHomeOwner,
      File? avatarImageFile,
      ) async {
    if (verificationId == null) {
      errorMessage = "Không tìm thấy mã xác minh. Vui lòng thử lại.";
      notifyListeners();
      return false;
    }

    try {
      // isLoading = true;
      notifyListeners();

      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId!,
        smsCode: otpCode,
      );

      UserCredential result = await _auth.signInWithCredential(credential);
      User? user = result.user;

      if (user != null) {
        String? avatarUrl;
        if (avatarImageFile != null) {
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('avatars')
              .child('${user.uid}.jpg');
          await storageRef.putFile(avatarImageFile);
          avatarUrl = await storageRef.getDownloadURL();
        }

        if (displayName != null) {
          // ✅ Đây là đăng ký mới → Lưu dữ liệu đầy đủ
          String? avatarUrl;
          if (avatarImageFile != null) {
            final storageRef = FirebaseStorage.instance
                .ref()
                .child('avatars')
                .child('${user.uid}.jpg');
            await storageRef.putFile(avatarImageFile);
            avatarUrl = await storageRef.getDownloadURL();
          }

          await _firestore.collection('users').doc(user.uid).set({
            'uid': user.uid,
            'displayName': displayName,
            'age': int.tryParse(age ?? '') ?? 0,
            'gender': gender ?? 'Không xác định',
            'isHomeOwner': isHomeOwner ?? false,
            'phoneNumber': phoneNumber,
            'photoUrl': avatarUrl ?? '',
            'emailAvatarUrl': '',
            'updatedAt': FieldValue.serverTimestamp(),
            'isProfileComplete': true,
          }, SetOptions(merge: true));
        } else {
          // ✅ Đây là đăng nhập lại → Không ghi đè gì cả
          print("✅ Đăng nhập lại, không cập nhật thông tin Firestore.");
        }
      }

      // isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      // isLoading = false;
      errorMessage = _mapFirebaseErrorToMessage(e);
      notifyListeners();
      return false;
    } catch (e) {
      // isLoading = false;
      errorMessage = "Đã xảy ra lỗi không xác định. Vui lòng thử lại.";
      notifyListeners();
      return false;
    }
  }

  // ✅ Gửi lại OTP
  Future<void> resendOtp(String phoneNumber, BuildContext context) async {
    try {
      // isLoading = true;
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
          // isLoading = false;
          notifyListeners();
        },
        codeSent: (String newVerificationId, int? resendToken) {
          verificationId = newVerificationId;
          // isLoading = false;
          notifyListeners();
        },
        codeAutoRetrievalTimeout: (_) {},
      );
    } catch (e) {
      // isLoading = false;
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