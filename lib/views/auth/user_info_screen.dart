import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../core/models/user_model.dart';

class UserInfoScreen extends StatefulWidget {
  @override
  _UserInfoScreenState createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  String role = "Chủ nhà";
  String gender = "Nam";
  final TextEditingController phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: Text("Thông tin cá nhân")),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: "Tên hiển thị"),
            ),
            TextField(
              controller: ageController,
              decoration: InputDecoration(labelText: "Tuổi"),
              keyboardType: TextInputType.number,
            ),
            DropdownButton<String>(
              value: role,
              items: ["Chủ nhà", "Người thuê"].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  role = newValue!;
                });
              },
            ),
            DropdownButton<String>(
              value: gender,
              items: ["Nam", "Nữ", "Khác"].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  gender = newValue!;
                });
              },
            ),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(labelText: "Số điện thoại"),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                UserModel newUser = UserModel(
                  uid: authViewModel.user!.uid,
                  email: authViewModel.user!.email,
                  displayName: nameController.text,
                  age: int.tryParse(ageController.text) ?? 0,
                  role: role,
                  gender: gender,
                  phoneNumber: phoneController.text,
                );

                await authViewModel.saveUserInfo(newUser);
                Navigator.pushReplacementNamed(context, "/home");
              },
              child: Text("Xác nhận"),
            ),
          ],
        ),
      ),
    );
  }
}