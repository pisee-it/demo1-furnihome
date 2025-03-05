import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:qldd_demo/views/auth/otp_verification_screen.dart';

import '../../core/models/user_model.dart';

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
              repeat: true,
            ),
            const SizedBox(height: 20),
            Text(
              "FurniHome",
              style: const TextStyle(
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

class UserInfoScreen extends StatefulWidget {
  @override
  _UserInfoScreenState createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  String? selectedAge;
  String? selectedGender;
  bool isHomeOwner = false;
  String? errorMessage;
  File? avatarImageFile;
  String? avatarUrl;
  String? registeredPhoneNumber;
  bool isPhoneSignIn = true;
  UserModel? currentUser;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      if (user.phoneNumber != null && user.phoneNumber!.isNotEmpty) {
        // 👉 Đăng nhập bằng SĐT
        isPhoneSignIn = true;
        phoneController.text = user.phoneNumber!;
      } else {
        // 👉 Đăng nhập bằng Google
        isPhoneSignIn = false;
        FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get()
            .then((doc) {
          if (doc.exists) {
            setState(() {
              phoneController.text = doc.data()?['phoneNumber'] ?? '';
            });
          }
        });
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    registeredPhoneNumber = ModalRoute.of(context)?.settings.arguments as String?;
    if (registeredPhoneNumber != null) {
      phoneController.text = registeredPhoneNumber!;
    }
    _loadCurrentUser();
  }

  void showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const SplashLoadingDialog(),
    );
  }

  Future<void> _loadCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        setState(() {
          currentUser = UserModel.fromMap(doc.data()!);
        });
      }
    }
  }

  Future<void> pickAvatar() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        avatarImageFile = File(pickedFile.path);
      });
    }
  }

  Future<String?> uploadAvatar(String uid) async {
    if (avatarImageFile == null) return null;

    final storageRef = FirebaseStorage.instance
        .ref()
        .child('avatars')
        .child('$uid.jpg');

    await storageRef.putFile(avatarImageFile!);
    return await storageRef.getDownloadURL();
  }

  String normalizePhoneNumber84(String phone) {
    phone = phone.replaceAll(RegExp(r'\s+'), ''); // Xóa khoảng trắng
    if (phone.startsWith('0')) {
      return '+84${phone.substring(1)}';
    }
    return phone; // Nếu đã là +84 thì giữ nguyên
  }

  Future<void> _proceedToOTP() async {
    if (nameController.text.trim().isEmpty) {
      setState(() => errorMessage = "Chúng tôi cần biết tên của bạn.");
      return;
    }

    if (selectedAge == null) {
      setState(() => errorMessage = "Chúng tôi cần biết tuổi của bạn.");
      return;
    }

    if (selectedGender == null) {
      setState(() => errorMessage = "Chúng tôi cần biết giới tính của bạn.");
      return;
    }

    if (phoneController.text.trim().isEmpty) {
      setState(() => errorMessage = "Chúng tôi cần biết SĐT của bạn.");
      return;
    }

    setState(() {
      errorMessage = null;
      showLoadingDialog();
      if (Navigator.canPop(context)) {
        Navigator.pop(context); // Đóng loading an toàn
      }
    });

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: normalizePhoneNumber84(phoneController.text.trim()),
        timeout: const Duration(seconds: 60),
        verificationCompleted: (_) {},
        verificationFailed: (FirebaseAuthException e) {
          setState(() {
            errorMessage = "Gửi OTP thất bại: ${e.message}";
            showLoadingDialog();
            if (Navigator.canPop(context)) {
              Navigator.pop(context); // Đóng loading an toàn
            }
          });
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() => errorMessage = null);
          showLoadingDialog();
          if (Navigator.canPop(context)) {
            Navigator.pop(context); // Đóng loading an toàn
          }

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OtpVerificationScreen(
                phoneNumber: phoneController.text.trim(),
                verificationId: verificationId,
                displayName: nameController.text.trim(),
                age: selectedAge!,
                gender: selectedGender!,
                isHomeOwner: isHomeOwner,
                avatarImageFile: avatarImageFile,
                onOtpVerified: (otpCode) async {
                  await verifyOtpAndLinkPhone(verificationId, otpCode);
                  await _saveUserInfo(); // ✅ Lưu thông tin đầy đủ
                  Navigator.pushReplacementNamed(context, "/home");
                },
              ),
            ),
          );
        },
        codeAutoRetrievalTimeout: (_) {},
      );
    } catch (e) {
      setState(() {
        errorMessage = "Đã xảy ra lỗi khi gửi OTP. Vui lòng thử lại.";
        showLoadingDialog();
        if (Navigator.canPop(context)) {
          Navigator.pop(context); // Đóng loading an toàn
        }
      });
    }
  }

  Future<void> _saveUserInfo() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Không tìm thấy thông tin người dùng.", textAlign: TextAlign.center),
          backgroundColor: Color(0xFFCA3E47),
        ),
      );
      return;
    }

    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Chúng tôi cần biết tên của bạn.", textAlign: TextAlign.center),
          backgroundColor: Color(0xFFCA3E47),
        ),
      );
      return;
    }

    if (selectedAge == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Chúng tôi cần biết tuổi của bạn.", textAlign: TextAlign.center),
          backgroundColor: Color(0xFFCA3E47),
        ),
      );
      return;
    }

    if (selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Chúng tôi cần biết giới tính của bạn.", textAlign: TextAlign.center),
          backgroundColor: Color(0xFFCA3E47),
        ),
      );
      return;
    }

    setState(() {
      errorMessage = null;
      showLoadingDialog();
      if (Navigator.canPop(context)) {
        Navigator.pop(context); // Đóng loading an toàn
      }
    });

    try {
      String? avatarUrl;

      // ✅ Upload avatar mới nếu có
      if (avatarImageFile != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('avatars')
            .child('${user.uid}.jpg');
        await storageRef.putFile(avatarImageFile!);
        avatarUrl = await storageRef.getDownloadURL();
      } else {
        // ✅ Giữ avatar cũ nếu không đổi
        avatarUrl = currentUser?.photoUrl ?? '';
      }

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email ?? '',
        'emailAvatarUrl': user.photoURL ?? '',
        'displayName': nameController.text.trim(),
        'age': int.tryParse(selectedAge ?? '') ?? 0,
        'gender': selectedGender ?? 'Không xác định',
        'isHomeOwner': isHomeOwner,
        'phoneNumber': phoneController.text.trim(),
        'photoUrl': avatarUrl ?? '',
        'role': currentUser?.role ?? 'Người dùng',
        'isProfileComplete': true,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)); // ✅ merge giữ lại dữ liệu cũ nếu có

      Navigator.pushReplacementNamed(context, "/home");
    } catch (e) {
      setState(() => errorMessage = "Lưu thông tin thất bại. Vui lòng thử lại.");
    } finally {
      setState(() => errorMessage = null);
      showLoadingDialog();
      if (Navigator.canPop(context)) {
        Navigator.pop(context); // Đóng loading an toàn
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () async {
                    await pickAvatar();
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: avatarImageFile != null
                            ? FileImage(avatarImageFile!)
                            : AssetImage("assets/avatar_placeholder.png") as ImageProvider,
                        backgroundColor: Colors.grey[400],
                      ),
                      Positioned(
                        bottom: 0,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 20,
                            color: Color(0xFF1B4965),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "FurniHome",
                  style: GoogleFonts.audiowide(
                    fontSize: 28,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Chào mừng bạn!\nĐiền chút thông tin nữa là xong",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 30),
                _buildForm(),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Container(
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
          _buildTextField(controller: nameController, label: "Tên bạn là?"),
          const SizedBox(height: 15),
          _buildDropdownField(
            label: "Tuổi bạn là?",
            value: selectedAge,
            items: List.generate(83, (index) => (18 + index).toString()),
            onChanged: (value) => setState(() => selectedAge = value),
          ),
          const SizedBox(height: 15),
          _buildDropdownField(
            label: "Giới tính bạn là?",
            value: selectedGender,
            items: ['Nam', 'Nữ', 'Khác'],
            onChanged: (value) => setState(() => selectedGender = value),
          ),
          const SizedBox(height: 15),
          _buildTextField(
            controller: phoneController,
            label: "Số điện thoại của bạn",
            enabled: !isPhoneSignIn,
          ),
          const SizedBox(height: 15),
          CheckboxListTile(
            title: const Text("Bạn có phải là chủ nhà không?"),
            value: isHomeOwner,
            onChanged: (value) => setState(() => isHomeOwner = value!),
            controlAffinity: ListTileControlAffinity.leading,
          ),
          if (errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                errorMessage!,
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _proceedToOTP,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1B4965),
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text(
              "Lấy mã OTP",
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool enabled = true,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      items: items.map(
            (item) => DropdownMenuItem(
          value: item,
          child: Text(item),
        ),
      ).toList(),
      onChanged: onChanged,
    );
  }
  Future<void> verifyOtpAndLinkPhone(String verificationId, String otpCode) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otpCode,
      );

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.linkWithCredential(credential); // ✅ Liên kết SĐT với tài khoản Google
        print('✅ Đã liên kết số điện thoại vào tài khoản Google.');
      }
    } catch (e) {
      print('🔥 Lỗi liên kết OTP: $e');
      setState(() => errorMessage = "Liên kết OTP thất bại: $e");
    }
  }

}