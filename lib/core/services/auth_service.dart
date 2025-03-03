import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: "934304345161-rrn330dcjsujums8vba8b2ng521lu1re.apps.googleusercontent.com",
  );
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _verificationId;

  // ✅ Tạo email giả lập từ số điện thoại
  String _generateFakeEmail(String phoneNumber) {
    return "$phoneNumber@furnihome.vn";
  }

  // ✅ Đăng ký bằng SĐT & mật khẩu (thay cho registerWithEmail)
  Future<UserModel?> registerWithPhone(String phoneNumber, String password) async {
    try {
      String fakeEmail = _generateFakeEmail(phoneNumber);

      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: fakeEmail,
        password: password,
      );

      User? user = result.user;

      if (user != null) {
        DocumentSnapshot userDoc = await _firestore.collection("users").doc(user.uid).get();

        if (!userDoc.exists) {
          return UserModel(
            uid: user.uid,
            email: fakeEmail,
            phoneNumber: phoneNumber,
            isNewUser: true,
          );
        }

        return UserModel(
          uid: user.uid,
          email: fakeEmail,
          phoneNumber: phoneNumber,
          displayName: userDoc["displayName"] ?? "Người dùng",
          photoUrl: userDoc["photoUrl"] ?? "",
        );
      }
      return null;
    } catch (e) {
      throw Exception("🔥 Lỗi đăng ký SĐT: $e");
    }
  }

  // Gửi OTP
  Future<void> sendOTP(String phoneNumber) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) {},
        verificationFailed: (FirebaseAuthException e) {
          throw Exception("🔥 Lỗi gửi OTP: ${e.message}");
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      throw Exception("🔥 Lỗi gửi OTP: $e");
    }
  }

  // Xác thực OTP
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

  // ✅ Lưu thông tin cá nhân vào Firestore
  Future<void> saveUserInfo(UserModel userModel) async {
    int retryCount = 3;
    while (retryCount > 0) {
      try {
        await _firestore.collection("users").doc(userModel.uid).set(
          userModel.toMap(),
          SetOptions(merge: true),
        );
        return;
      } catch (e) {
        if (e.toString().contains("unavailable")) {
          retryCount--;
          await Future.delayed(Duration(seconds: 2));
        } else {
          throw Exception("🔥 Lỗi lưu thông tin: $e");
        }
      }
    }
  }

  // ✅ Đăng nhập bằng SĐT & mật khẩu (thay cho loginWithEmail)
  Future<UserModel?> loginWithPhone(String phoneNumber, String password) async {
    try {
      String fakeEmail = _generateFakeEmail(phoneNumber);

      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: fakeEmail,
        password: password,
      );

      User? user = result.user;

      if (user != null) {
        DocumentSnapshot userDoc = await _firestore.collection("users").doc(user.uid).get();

        if (userDoc.exists) {
          return UserModel(
            uid: user.uid,
            email: fakeEmail,
            phoneNumber: phoneNumber,
            displayName: userDoc["displayName"] ?? "Người dùng",
            photoUrl: userDoc["photoUrl"] ?? "",
          );
        }
      }
      return null;
    } catch (e) {
      throw Exception("🔥 Lỗi đăng nhập SĐT: $e");
    }
  }

  // ✅ Đăng nhập bằng Google
  Future<UserModel?> signInWithGoogle() async {
    try {
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut(); // ✅ Xoá phiên cũ nếu có
      }

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return null; // Người dùng huỷ đăng nhập
      }

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential result =
      await _auth.signInWithCredential(credential);
      User? user = result.user;

      if (user != null) {
        DocumentSnapshot userDoc =
        await _firestore.collection("users").doc(user.uid).get();

        if (!userDoc.exists) {
          await saveUserInfo(UserModel(
            uid: user.uid,
            email: user.email!,
            displayName: user.displayName ?? "Người dùng",
            photoUrl: user.photoURL ?? "",
          ));
        }

        return UserModel(
          uid: user.uid,
          email: user.email!,
          displayName: user.displayName ?? "Người dùng",
          photoUrl: user.photoURL ?? "",
        );
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

      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut(); // ✅ Chỉ signOut nếu có phiên Google
      }

    } catch (e) {
      throw Exception("🔥 Lỗi đăng xuất: $e");
    }
  }

  // ✅ Lấy thông tin người dùng hiện tại
  UserModel? getCurrentUser() {
    final user = _auth.currentUser;
    if (user != null) {
      return UserModel(
        uid: user.uid,
        email: user.email!,
        displayName: user.displayName ?? "Người dùng",
        photoUrl: user.photoURL ?? "",
      );
    }
    return null;
  }

  // ✅ Cập nhật thông tin người dùng
  Future<void> updateUserInfo(
      String uid, Map<String, dynamic> updatedData) async {
    try {
      await _firestore.collection("users").doc(uid).update(updatedData);
    } catch (e) {
      throw Exception("🔥 Lỗi cập nhật thông tin: $e");
    }
  }
}