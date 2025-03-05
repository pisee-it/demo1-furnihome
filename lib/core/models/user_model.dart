class UserModel {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoUrl; // Ảnh do người dùng thay đổi
  final String? emailAvatarUrl; // Ảnh mặc định từ Gmail
  final int? age;
  final String? role;
  final String? gender;
  final String? phoneNumber;
  final bool isNewUser;
  final bool isHomeOwner;
  final bool isProfileComplete;


  UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.emailAvatarUrl, // ✅ Thêm field này
    this.age,
    this.role,
    this.gender,
    this.phoneNumber,
    this.isNewUser = false,
    this.isHomeOwner = false,
    this.isProfileComplete = false,
  });

  // ✅ Lấy dữ liệu từ Firestore
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? 'Người dùng',
      photoUrl: map['photoUrl'] ?? '', // Ảnh do user cập nhật
      emailAvatarUrl: map['emailAvatarUrl'] ?? '', // Ảnh Gmail
      age: map['age'] is int ? map['age'] : int.tryParse(map['age']?.toString() ?? ''),
      role: map['role'] ?? 'Không xác định',
      gender: map['gender'] ?? 'Không xác định',
      phoneNumber: map['phoneNumber'] ?? '',
      isNewUser: map['isNewUser'] ?? false,
      isHomeOwner: map['isHomeOwner'] ?? false,
      isProfileComplete: map['isProfileComplete'] ?? false,
    );
  }

  // ✅ Lưu dữ liệu lên Firestore
  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "email": email,
      "displayName": displayName,
      "photoUrl": photoUrl, // Ảnh do user cập nhật
      "emailAvatarUrl": emailAvatarUrl, // Ảnh Gmail
      "age": age ?? 0,
      "role": role ?? "Không xác định",
      "gender": gender ?? "Không xác định",
      "phoneNumber": phoneNumber ?? "",
      "isNewUser": isNewUser,
      "isHomeOwner": isHomeOwner,
      "isProfileComplete": isProfileComplete,
    };
  }
}
