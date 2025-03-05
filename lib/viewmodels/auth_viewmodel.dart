import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../core/models/user_model.dart';
import '../core/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _user;
  String? _errorMessage;

  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;

  void setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  // ✅ Gửi OTP
  Future<String?> sendOTP(String phoneNumber) async {
    try {
      final verificationId = await _authService.sendOTP(phoneNumber);
      setError(null);
      return verificationId;
    } catch (e) {
      setError("Lỗi gửi OTP: ${e.toString()}");
      return null;
    }
  }

  // ✅ Xác thực OTP
  Future<bool> verifyOTP(String otpCode) async {
    try {
      bool success = await _authService.verifyOTP(otpCode);
      if (!success) {
        setError("OTP không hợp lệ");
        return false;
      }
      setError(null);
      return true;
    } catch (e) {
      setError("Lỗi xác thực OTP: ${e.toString()}");
      return false;
    }
  }

  // ✅ Lưu thông tin cá nhân vào Firestore
  Future<void> saveUserInfo(UserModel userModel) async {
    try {
      await _authService.saveUserInfo(userModel);
      _user = userModel;
      notifyListeners();
    } catch (e) {
      setError("Lỗi lưu thông tin: ${e.toString()}");
    }
  }

  Future<void> fetchUserInfo() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(firebaseUser.uid).get();
      if (doc.exists) {
        _user = UserModel.fromMap(doc.data()!);
        notifyListeners();
      }
    }
  }

  Future<void> fetchUserInfoByPhone(String phoneNumber) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('phoneNumber', isEqualTo: phoneNumber)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final userData = querySnapshot.docs.first.data();
        _user = UserModel.fromMap(userData);
        notifyListeners();
      } else {
        _user = null;
        setError("Không tìm thấy người dùng.");
      }
    } catch (e) {
      setError("Lỗi khi lấy thông tin người dùng: $e");
    }
  }

  // ✅ Kiểm tra nếu người dùng đã đăng nhập
  void checkUserLoggedIn() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _user = UserModel(
        uid: user.uid,
        email: user.email ?? "",
        displayName: user.displayName,
        photoUrl: user.photoURL,
      );
      notifyListeners();
    }
  }

  // ✅ Đăng nhập Google và điều hướng về Home
  Future<void> loginWithGoogle(BuildContext context) async {
    try {
      _user = await _authService.signInWithGoogle();
      setError(null);

      if (_user != null) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          "/home",
              (route) => false,
        );
      } else {
        setError("Đăng nhập Google thất bại.");
      }
    } catch (e) {
      setError("Lỗi đăng nhập Google: ${e.toString()}");
    }
  }

  // ✅ Đăng xuất toàn bộ
  Future<void> logout(BuildContext context) async {
    try {
      await _authService.signOut();
      _user = null;
      setError(null);

      Navigator.pushNamedAndRemoveUntil(
        context,
        "/login",
            (route) => false,
      );
    } catch (e) {
      setError("Lỗi đăng xuất: ${e.toString()}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Lỗi đăng xuất: ${e.toString()}",
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}