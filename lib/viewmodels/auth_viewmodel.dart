import 'package:flutter/material.dart';
import '../core/models/user_model.dart';
import '../core/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  // ✅ Gửi OTP
  Future<bool> sendOTP(String phoneNumber) async {
    setLoading(true);
    try {
      await _authService.sendOTP(phoneNumber);
      setError(null);
      setLoading(false);
      return true;
    } catch (e) {
      setError("Lỗi gửi OTP: ${e.toString()}");
      setLoading(false);
      return false;
    }
  }

  // ✅ Xác thực OTP
  Future<bool> verifyOTP(String otpCode) async {
    setLoading(true);
    try {
      bool success = await _authService.verifyOTP(otpCode);
      setLoading(false);
      if (!success) {
        setError("OTP không hợp lệ");
        return false;
      }
      setError(null);
      return true;
    } catch (e) {
      setError("Lỗi xác thực OTP: ${e.toString()}");
      setLoading(false);
      return false;
    }
  }

  // ✅ Đăng nhập bằng số điện thoại
  Future<bool> loginWithPhone(
      String phoneNumber, String password, BuildContext context) async {
    setLoading(true);
    try {
      _user = await _authService.loginWithPhone(phoneNumber, password);
      if (_user != null) {
        setError(null);
        setLoading(false);

        if (_user!.isNewUser) {
          Navigator.pushReplacementNamed(context, "/user-info");
        } else {
          Navigator.pushReplacementNamed(context, "/home");
        }
        return true;
      } else {
        setError("Sai số điện thoại hoặc mật khẩu");
        setLoading(false);
        return false;
      }
    } catch (e) {
      setError("Lỗi đăng nhập: ${e.toString()}");
      setLoading(false);
      return false;
    }
  }

  // ✅ Đăng ký bằng số điện thoại
  Future<bool> registerWithPhone(
      String phoneNumber, String password, BuildContext context) async {
    setLoading(true);
    try {
      UserModel? newUser =
      await _authService.registerWithPhone(phoneNumber, password);
      if (newUser != null) {
        setError(null);
        setLoading(false);

        Navigator.pushReplacementNamed(context, "/user-info");
        return true;
      } else {
        setError("Đăng ký không thành công");
        setLoading(false);
        return false;
      }
    } catch (e) {
      setError("Lỗi đăng ký: ${e.toString()}");
      setLoading(false);
      return false;
    }
  }

  // ✅ Lưu thông tin cá nhân vào Firestore
  Future<void> saveUserInfo(UserModel userModel) async {
    setLoading(true);
    try {
      await _authService.saveUserInfo(userModel);
      _user = userModel;
      notifyListeners();
    } catch (e) {
      setError("Lỗi lưu thông tin: ${e.toString()}");
    }
    setLoading(false);
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

  // ✅ Đăng nhập Google
  Future<void> loginWithGoogle(BuildContext context) async {
    setLoading(true);
    try {
      _user = await _authService.signInWithGoogle();
      setError(null);

      if (_user != null) {
        Navigator.pushReplacementNamed(context, "/home");
      }
    } catch (e) {
      setError("Lỗi đăng nhập Google: ${e.toString()}");
    }
    setLoading(false);
  }

  // ✅ Đăng xuất toàn bộ
  Future<void> logout(BuildContext context) async {
    setLoading(true);
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
    setLoading(false);
  }
}