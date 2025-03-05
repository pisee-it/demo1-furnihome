import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/user_model.dart';
import '../../core/services/account_history_service.dart';
import '../../viewmodels/home_viewmodel.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      showLoadingDialog();
      final homeViewModel = Provider.of<HomeViewModel>(context, listen: false);
      await homeViewModel.fetchUserData();
      if (Navigator.canPop(context)) {
        Navigator.pop(context); // Đóng loading an toàn
      }
      _checkProfileCompletion(homeViewModel.user);
    });
  }

  void showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const SplashLoadingDialog(),
    );
  }

  void _checkProfileCompletion(UserModel? user) {
    if (user != null && user.isProfileComplete == false) {
      Navigator.pushReplacementNamed(context, '/user-info');
    }
  }

  String _formatPhoneNumber(String phoneNumber) {
    if (phoneNumber.length >= 9) {
      return phoneNumber.replaceRange(3, phoneNumber.length - 3, "*" * (phoneNumber.length - 6));
    }
    return phoneNumber;
  }

  @override
  Widget build(BuildContext context) {
    final homeViewModel = Provider.of<HomeViewModel>(context);
    final user = homeViewModel.user;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xFF1B4965),
        title: Text(
          "FurniHome",
          style: GoogleFonts.audiowide(
            color: Colors.white,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle, color: Colors.white),
            onPressed: () => _showAccountSwitcher(context, homeViewModel),
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1B4965), Color(0xFF62B6CB)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/personal-settings');
                  },
                  child: _buildUserInfo(user),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: ListTile(
                        leading: Icon(Icons.inventory_2, color: Colors.blueAccent),
                        title: Text("Món đồ ${index + 1}"),
                        subtitle: Text("Mô tả ngắn gọn về món đồ"),
                        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              backgroundColor: Colors.orange,
              onPressed: () {
                Navigator.pushNamed(context, "/add_item");
              },
              child: Icon(Icons.add, size: 30),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfo(UserModel? user) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF1B4965).withOpacity(0.99),
            blurRadius: 10,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.pushNamed(context, '/personal-settings');
          },
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: (user?.photoUrl?.isNotEmpty ?? false)
                      ? NetworkImage(user!.photoUrl!)
                      : (user?.emailAvatarUrl?.isNotEmpty ?? false)
                      ? NetworkImage(user!.emailAvatarUrl!)
                      : AssetImage("assets/avatar_placeholder.png") as ImageProvider,
                ),
                SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Xin chào, ${user?.displayName ?? "Người dùng"}!",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      (user?.isHomeOwner == true) ? "Chủ nhà" : "Người ở",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    Text(
                      _formatPhoneNumber(user?.phoneNumber ?? ""),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                    if ((user?.email?.isNotEmpty ?? false))
                      Text(
                        user!.email!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ✅ Hiển thị chọn tài khoản hoặc đăng xuất
  void _showAccountSwitcher(BuildContext context, HomeViewModel homeViewModel) async {
    final accounts = await AccountHistoryService.loadAccounts();
    print("📝 Danh sách tài khoản đã lưu: ${accounts.length}");
    final pages = List.generate(
      (accounts.length / 3).ceil(),
          (index) => accounts.skip(index * 3).take(3).toList(),
    );

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1B4965), Color(0xFF62B6CB)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ✅ Thanh kéo
            Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.6),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            SizedBox(height: 20),

            Text(
              "Chuyển tài khoản",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 20),

            // ✅ Danh sách tài khoản (phân trang nếu > 3)
            SizedBox(
              height: 230,
              child: PageView.builder(
                itemCount: pages.length,
                itemBuilder: (context, pageIndex) {
                  final pageAccounts = pages[pageIndex];
                  return SingleChildScrollView(
                    child: Column(
                      children: pageAccounts.map<Widget>((UserModel account) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.8),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 66,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              radius: 28,
                              backgroundImage: (account.photoUrl != null && account.photoUrl!.isNotEmpty)
                                  ? NetworkImage(account.photoUrl!)
                                  : (account.emailAvatarUrl != null && account.emailAvatarUrl!.isNotEmpty)
                                  ? NetworkImage(account.emailAvatarUrl!)
                                  : const AssetImage("assets/avatar_placeholder.png") as ImageProvider,
                            ),
                            title: Text(
                              account.displayName ?? "Người dùng",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  (account.isHomeOwner == true) ? "Chủ nhà" : "Người ở",
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  (account.email ?? "").isNotEmpty
                                      ? account.email!
                                      : _formatPhoneNumber(account.phoneNumber ?? ""),
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: 20),

            // ⭐ Container nút đăng xuất
            GestureDetector(
              onTap: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  barrierDismissible: false, // Người dùng phải chọn hành động
                  builder: (context) => Dialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Color(0xFFCA3E47),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.logout, size: 50, color: Colors.white),
                          SizedBox(height: 20),
                          Text(
                            "Xác nhận đăng xuất",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Bạn có chắc chắn muốn đăng xuất khỏi tài khoản không?",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 30),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.blueAccent,
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    "Huỷ",
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                              ),
                              SizedBox(width: 15),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFFAE393D),
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    "Đăng xuất",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
                if (confirm == true) {
                  await homeViewModel.logout();
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context); // Đóng loading an toàn
                  }
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    "/login",
                        (route) => false, // Xoá toàn bộ stack
                  );
                }
              },
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout, color: Colors.white),
                    SizedBox(width: 10),
                    Text(
                      "Đăng xuất",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

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
            ),
            const SizedBox(height: 20),
            const Text(
              "FurniHome",
              style: TextStyle(
                fontFamily: "Audiowide",
                fontSize: 28,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Đang tải dữ liệu...",
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