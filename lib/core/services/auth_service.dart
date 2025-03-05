import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'account_history_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: "934304345161-rrn330dcjsujums8vba8b2ng521lu1re.apps.googleusercontent.com",
  );
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _verificationId;

  String normalizePhoneNumber84(String phone) {
    phone = phone.replaceAll(RegExp(r'\s+'), ''); // Xóa khoảng trắng
    if (phone.startsWith('0')) {
      return '+84${phone.substring(1)}';
    }
    return phone; // Nếu đã là +84 thì giữ nguyên
  }

  // ✅ Gửi OTP
  Future<String?> sendOTP(String phoneNumber) async {
    String? verificationId;
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        throw Exception("🔥 Lỗi gửi OTP: ${e.message}");
      },
      codeSent: (String vId, int? resendToken) {
        verificationId = vId;
      },
      codeAutoRetrievalTimeout: (String vId) {
        verificationId = vId;
      },
    );

    // Đợi verificationId được set xong
    while (verificationId == null) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    return verificationId;
  }

  // ✅ Xác thực OTP
  Future<bool> verifyOTP(String otpCode) async {
    try {
      if (_verificationId == null) throw Exception("Không tìm thấy mã xác minh");

      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otpCode,
      );

      await _auth.signInWithCredential(credential);
      return true;
    } catch (e) {
      throw Exception("🔥 Lỗi xác thực OTP: $e");
    }
  }

  // ✅ Lưu thông tin người dùng vào Firestore
  Future<void> saveUserInfo(UserModel userModel) async {
    try {
      await _firestore.collection("users").doc(userModel.uid).set(
        userModel.toMap(),
        SetOptions(merge: true),
      );
    } catch (e) {
      throw Exception("🔥 Lỗi lưu thông tin: $e");
    }
  }

  // ✅ Đăng nhập bằng Google
  Future<UserModel?> signInWithGoogle() async {
    try {
      await _googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential result = await _auth.signInWithCredential(credential);
      User? user = result.user;

      if (user != null) {
        final docRef = _firestore.collection('users').doc(user.uid);
        final userDoc = await docRef.get();

        if (userDoc.exists) {
          // ✅ Nếu đã có tài khoản -> chỉ cập nhật emailAvatarUrl nếu cần
          await docRef.update({
            'emailAvatarUrl': user.photoURL ?? "",
            'updatedAt': FieldValue.serverTimestamp(),
          });
        } else {
          // ✅ Nếu tài khoản mới -> tạo đầy đủ thông tin cơ bản
          await docRef.set({
            'uid': user.uid,
            'email': user.email ?? '',
            'displayName': "Người dùng", // Không lấy từ Gmail để đồng nhất
            'emailAvatarUrl': user.photoURL ?? "",
            'photoUrl': "", // Chưa có avatar tự chọn
            'phoneNumber': "", // Chưa có, sẽ cập nhật sau
            'age': 0, // Mặc định
            'gender': "Không xác định",
            'role': "Không xác định",
            'isHomeOwner': false,
            'isNewUser': true,
            'isProfileComplete': false, // Chờ bổ sung thông tin
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
        final userModel = UserModel(
          uid: user.uid,
          email: user.email ?? '',
          displayName: "Người dùng",
          emailAvatarUrl: user.photoURL ?? "",
          photoUrl: "", // Tạm thời
          phoneNumber: "",
          age: 0,
          gender: "Không xác định",
          role: "Không xác định",
          isHomeOwner: false,
          isNewUser: true,
        );

        await AccountHistoryService.saveAccount(userModel);
        return userModel;
      }
      return null;
    } catch (e) {
      throw Exception("🔥 Lỗi đăng nhập Google: $e");
    }
  }

  // ✅ Đăng xuất toàn bộ
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
    } catch (e) {
      throw Exception("🔥 Lỗi đăng xuất: $e");
    }
  }

  // ✅ Lấy thông tin người dùng hiện tại
  Future<UserModel?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection("users").doc(user.uid).get();
      if (doc.exists) {
        final userModel = UserModel.fromMap(doc.data()!);

        // ✅ Lưu tài khoản vào lịch sử
        await AccountHistoryService.saveAccount(userModel);
        return userModel;
      }
    }
    return null;
  }

  // ✅ Cập nhật thông tin người dùng
  Future<void> updateUserInfo(String uid, Map<String, dynamic> updatedData) async {
    try {
      await _firestore.collection("users").doc(uid).update(updatedData);
    } catch (e) {
      throw Exception("🔥 Lỗi cập nhật thông tin: $e");
    }
  }
}