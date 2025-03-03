import 'package:flutter/material.dart';

class UserInfoScreen extends StatefulWidget {
  @override
  _UserInfoScreenState createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  bool isHomeOwner = false; // 🏡 Người dùng có phải chủ nhà không

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Thông tin cá nhân"),
        backgroundColor: Color(0xFF20A2A5),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: "Tên của bạn",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 15),
            TextField(
              controller: ageController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Tuổi của bạn",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 15),
            CheckboxListTile(
              title: Text("Bạn có phải là chủ nhà không?"),
              value: isHomeOwner,
              onChanged: (value) {
                setState(() {
                  isHomeOwner = value!;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Xử lý lưu thông tin và điều hướng về màn hình chính
                Navigator.pushReplacementNamed(context, "/home");
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF20A2A5),
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text("Hoàn tất", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}