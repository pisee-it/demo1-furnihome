class UserModel {
  final String uid;
  final String email; // ✅ Bắt buộc phải có cho Google Sign-In
  final String? displayName;
  final String? photoUrl;
  final int? age;
  final String? role; // "Chủ nhà" hoặc "Người thuê"
  final String? gender; // "Nam", "Nữ", "Khác"
  final String? phoneNumber; // ✅ Thêm số điện thoại thực tế
  final bool isNewUser; // ✅ Đánh dấu user mới

  UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.age,
    this.role,
    this.gender,
    this.phoneNumber,
    this.isNewUser = false,
  });

  // ✅ Lấy dữ liệu từ Firestore
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      email: map['email'],
      displayName: map['displayName'],
      photoUrl: map['photoUrl'],
      age: map['age'],
      role: map['role'],
      gender: map['gender'],
      phoneNumber: map['phoneNumber'],
      isNewUser: map['isNewUser'] ?? false,
    );
  }

  // ✅ Lưu dữ liệu lên Firestore
  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "email": email,
      "displayName": displayName,
      "photoUrl": photoUrl,
      "age": age ?? 0,
      "role": role ?? "Không xác định",
      "gender": gender ?? "Không xác định",
      "phoneNumber": phoneNumber ?? "",
      "isNewUser": isNewUser,
    };
  }
}