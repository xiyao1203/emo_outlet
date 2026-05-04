import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../config/constants.dart';
import '../models/user_model.dart';
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
      _currentUser = UserModel.fromJson(jsonDecode(userData) as Map<String, dynamic>);
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

  Future<UserModel> refreshProfile() async {
    final data = await _api.getProfile();
    final user = UserModel.fromJson(data);
    await saveUser(user);
    return user;
  }

  Future<UserModel> login(String account, String password) async {
    final data = await _api.login(account, password);
    final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
    await saveUser(user);
    await saveToken(data['access_token'] as String);
    return user;
  }

  Future<UserModel> register(
    String phone,
    String password,
    String? nickname, {
    String? consentVersion,
    String? ageRange,
  }) async {
    final data = await _api.registerWithCompliance(
      phone,
      password,
      nickname,
      consentVersion: consentVersion,
      ageRange: ageRange,
    );
    final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
    await saveUser(user);
    await saveToken(data['access_token'] as String);
    return user;
  }

  Future<UserModel> visitorLogin(String nickname) async {
    final prefs = await SharedPreferences.getInstance();
    String? deviceUuid = prefs.getString('device_uuid');
    if (deviceUuid == null) {
      deviceUuid = 'device_${DateTime.now().millisecondsSinceEpoch}';
      await prefs.setString('device_uuid', deviceUuid);
    }
    final data = await _api.visitorLogin(deviceUuid, nickname);
    final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
    await saveUser(user);
    await saveToken(data['access_token'] as String);
    return user;
  }

  Future<UserModel> updateProfile({
    String? nickname,
    String? avatarUrl,
  }) async {
    final data = await _api.updateProfile(
      nickname: nickname,
      avatarUrl: avatarUrl,
    );
    final user = UserModel.fromJson(data);
    await saveUser(user);
    return user;
  }

  Future<void> deleteAccount() async {
    await _api.deleteAccount();
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
}
