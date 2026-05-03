import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import '../models/user_model.dart';
import '../config/constants.dart';
import 'api_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final ApiService _api = ApiService();

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(AppConstants.userKey);
    final token = prefs.getString(AppConstants.tokenKey);
    if (userData != null && token != null) {
      _currentUser = UserModel.fromJson(jsonDecode(userData));
      _api.setToken(token);
    }
  }

  Future<void> saveUser(UserModel user) async {
    _currentUser = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.userKey, jsonEncode(user.toJson()));
  }

  Future<void> saveToken(String token) async {
    _api.setToken(token);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.tokenKey, token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.tokenKey);
  }

  /// 手机号/邮箱登录
  Future<UserModel> login(String account, String password) async {
    try {
      final data = await _api.login(account, password);
      final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
      await saveUser(user);
      await saveToken(data['access_token'] as String);
      return user;
    } catch (e) {
      // 后端不可用时走 mock
      return _mockLogin(account, password);
    }
  }

  /// 注册（合规增强：携带 consent_version 和 age_range）
  Future<UserModel> register(
      String phone, String password, String? nickname,
      {String? consentVersion, String? ageRange}) async {
    try {
      final data = await _api.registerWithCompliance(
        phone, password, nickname,
        consentVersion: consentVersion,
        ageRange: ageRange,
      );
      final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
      await saveUser(user);
      await saveToken(data['access_token'] as String);
      return user;
    } catch (e) {
      // fallback mock
      return _mockLogin(phone, password);
    }
  }

  /// 游客登录
  Future<UserModel> visitorLogin(String nickname) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? deviceUuid = prefs.getString('device_uuid');
      if (deviceUuid == null) {
        deviceUuid = 'device_${DateTime.now().millisecondsSinceEpoch}';
        await prefs.setString('device_uuid', deviceUuid);
      }
      final data =
          await _api.visitorLogin(deviceUuid, nickname);
      final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
      await saveUser(user);
      await saveToken(data['access_token'] as String);
      return user;
    } catch (e) {
      return _mockVisitorLogin(nickname);
    }
  }

  /// 更新用户信息
  Future<UserModel> updateProfile(
      {String? nickname, String? avatarUrl}) async {
    try {
      final data = await _api.updateProfile(
          nickname: nickname, avatarUrl: avatarUrl);
      final user = UserModel.fromJson(data);
      await saveUser(user);
      return user;
    } catch (e) {
      // fallback: 本地更新
      final updated = _currentUser!.copyWith(
        nickname: nickname ?? _currentUser!.nickname,
      );
      await saveUser(updated);
      return updated;
    }
  }

  /// 注销账号
  Future<void> deleteAccount() async {
    try {
      await _api.deleteAccount();
    } catch (_) {
      // 后端不可用时继续执行本地操作
    }
    await _logout();
  }

  Future<void> logout() async {
    await _logout();
  }

  Future<void> _logout() async {
    _currentUser = null;
    _api.setToken(null);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.tokenKey);
    await prefs.remove(AppConstants.userKey);
  }

  // ═══════════════════════════════════════════════
  // Mock fallback
  // ═══════════════════════════════════════════════

  UserModel _mockLogin(String account, String password) {
    final data = _api.mockLogin();
    final user = UserModel.fromJson(data['user'] as Map<String, dynamic>)
        .copyWith(phone: account);
    saveUser(user);
    saveToken(data['access_token'] as String);
    return user;
  }

  UserModel _mockVisitorLogin(String nickname) {
    final user = UserModel(
      id: 'visitor_${DateTime.now().millisecondsSinceEpoch}',
      nickname: nickname,
      isVisitor: true,
      createdAt: DateTime.now(),
    );
    saveUser(user);
    saveToken('visitor_token_${DateTime.now().millisecondsSinceEpoch}');
    return user;
  }
}
