import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_model.dart';
import '../config/constants.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(AppConstants.userKey);
    if (userData != null) {
      _currentUser = UserModel.fromJson(jsonDecode(userData));
    }
  }

  Future<void> saveUser(UserModel user) async {
    _currentUser = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.userKey, jsonEncode(user.toJson()));
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.tokenKey, token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.tokenKey);
  }

  Future<void> login(String phone, String password) async {
    // 模拟登录 - 后续对接真实API
    final user = UserModel(
      id: 'user_001',
      nickname: '小木阳',
      phone: phone,
      isVisitor: false,
      createdAt: DateTime.now(),
    );
    await saveUser(user);
    await saveToken('mock_token_${DateTime.now().millisecondsSinceEpoch}');
  }

  Future<void> visitorLogin() async {
    final user = UserModel(
      id: 'visitor_${DateTime.now().millisecondsSinceEpoch}',
      nickname: '访客用户',
      isVisitor: true,
      createdAt: DateTime.now(),
    );
    await saveUser(user);
    await saveToken('visitor_token_${DateTime.now().millisecondsSinceEpoch}');
  }

  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.tokenKey);
    await prefs.remove(AppConstants.userKey);
  }
}
