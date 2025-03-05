import 'package:flutter/material.dart';
import '../core/models/user_model.dart';
import '../core/services/account_history_service.dart';
import '../core/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _user;
  // bool isLoading = false;
  UserModel? get user => _user;

  // ✅ Lấy thông tin người dùng từ Firestore
  Future<void> fetchUserData() async {
    try {
      // isLoading = true;
      notifyListeners();

      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(firebaseUser.uid)
            .get();

        if (doc.exists) {
          _user = UserModel.fromMap(doc.data()!);
          print('✅ Lấy displayName từ Firestore: ${_user?.displayName}');

          // ✅ Lưu vào lịch sử thiết bị
          await AccountHistoryService.saveAccount(_user!);

          // ✅ Nếu muốn update lại thời gian truy cập cuối cùng:
          await FirebaseFirestore.instance.collection('users').doc(firebaseUser.uid).update({
            'updatedAt': FieldValue.serverTimestamp(),
          });
        } else {
          print('❌ Không tìm thấy user trên Firestore');
        }
      } else {
        print('❌ Chưa đăng nhập');
      }
    } catch (e) {
      print('🔥 Lỗi khi fetch user data: $e');
    } finally {
      // isLoading = false;
      notifyListeners();
    }
  }

  // Đăng xuất
  Future<void> logout() async {
    await _authService.signOut();
    _user = null;
    notifyListeners();
  }
}