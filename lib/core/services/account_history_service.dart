import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AccountHistoryService {
  static const String _key = 'account_history';

  // ✅ Lưu tài khoản vào danh sách lịch sử
  static Future<void> saveAccount(UserModel account) async {
    final prefs = await SharedPreferences.getInstance();
    final accounts = prefs.getStringList(_key) ?? [];

    accounts.removeWhere((item) {
      final existingAccount = UserModel.fromMap(jsonDecode(item));
      return existingAccount.uid == account.uid;
    });

    accounts.insert(0, jsonEncode(account.toMap()));

    if (accounts.length > 10) {
      accounts.removeLast();
    }

    await prefs.setStringList(_key, accounts);
  }

  // ✅ Lấy danh sách tài khoản đã lưu
  static Future<List<UserModel>> loadAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    final accountStrings = prefs.getStringList(_key) ?? [];
    return accountStrings.map((jsonString) {
      return UserModel.fromMap(jsonDecode(jsonString));
    }).toList();
  }
}