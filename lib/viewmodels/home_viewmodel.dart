import 'package:flutter/material.dart';
import '../core/models/user_model.dart';
import '../core/services/auth_service.dart';

class HomeViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _user;

  UserModel? get user => _user;

  // Lấy thông tin người dùng đăng nhập
  Future<void> fetchUserData() async {
    _user = _authService.getCurrentUser();
    notifyListeners();
  }

  // Đăng xuất
  Future<void> logout() async {
    await _authService.signOut();
    _user = null;
    notifyListeners();
  }
}