import 'package:dio/dio.dart';

import '../config/constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late final Dio _dio;
  String? _token;

  ApiService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: AppConstants.connectTimeout,
        receiveTimeout: AppConstants.receiveTimeout,
        headers: {'Content-Type': 'application/json'},
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_token != null) {
            options.headers['Authorization'] = 'Bearer $_token';
          }
          handler.next(options);
        },
      ),
    );
  }

  void setToken(String? token) => _token = token;

  Future<Map<String, dynamic>> login(String account, String password) async {
    final response = await _dio.post('/auth/login', data: {
      'account': account,
      'password': password,
    });
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> registerWithCompliance(
    String account,
    String password,
    String? nickname, {
    String? consentVersion,
    String? ageRange,
  }) async {
    final isEmail = account.contains('@');
    final response = await _dio.post('/auth/register', data: {
      if (isEmail) 'email': account else 'phone': account,
      'password': password,
      if (nickname != null && nickname.isNotEmpty) 'nickname': nickname,
      if (consentVersion != null) 'consent_version': consentVersion,
      if (ageRange != null) 'age_range': ageRange,
    });
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> visitorLogin(
    String deviceUuid,
    String nickname,
  ) async {
    final response = await _dio.post('/auth/visitor', data: {
      'device_uuid': deviceUuid,
      'nickname': nickname,
    });
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> getProfile() async {
    final response = await _dio.get('/auth/me');
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> updateProfile({
    String? nickname,
    String? avatarUrl,
  }) async {
    final response = await _dio.put('/auth/me', data: {
      if (nickname != null) 'nickname': nickname,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
    });
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> getProfileDetail() async {
    final response = await _dio.get('/auth/profile-detail');
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> updateProfileDetail(
    Map<String, dynamic> data,
  ) async {
    final response = await _dio.put('/auth/profile-detail', data: data);
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<void> deleteAccount() async {
    await _dio.delete('/auth/account');
  }

  Future<List<dynamic>> getTargets() async {
    final response = await _dio.get('/targets');
    return List<dynamic>.from(response.data as List);
  }

  Future<Map<String, dynamic>> createTarget(Map<String, dynamic> data) async {
    final response = await _dio.post('/targets', data: data);
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> updateTarget(
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await _dio.put('/targets/$id', data: data);
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<void> deleteTarget(String id) async {
    await _dio.delete('/targets/$id');
  }

  Future<Map<String, dynamic>> generateAvatar(String targetId) async {
    final response = await _dio.post('/targets/$targetId/generate-avatar');
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> aiCompleteTarget(
    String name,
    String relationship,
  ) async {
    final response = await _dio.post('/targets/ai-complete', data: {
      'name': name,
      'relationship': relationship,
    });
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> createSession(Map<String, dynamic> data) async {
    final response = await _dio.post('/sessions', data: data);
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<List<dynamic>> getSessions({int page = 1, int pageSize = 20}) async {
    final response = await _dio.get('/sessions', queryParameters: {
      'page': page,
      'page_size': pageSize,
    });
    return List<dynamic>.from(response.data as List);
  }

  Future<Map<String, dynamic>?> getActiveSession() async {
    final response = await _dio.get('/sessions/active');
    if (response.data == null) {
      return null;
    }
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> getSession(String id) async {
    final response = await _dio.get('/sessions/$id');
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> endSession(
    String id, {
    bool force = false,
  }) async {
    final response = await _dio.post('/sessions/$id/end', data: {
      'force': force,
    });
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> getMessages(
    String sessionId, {
    int page = 1,
    int pageSize = 50,
  }) async {
    final response = await _dio.get(
      '/sessions/$sessionId/messages',
      queryParameters: {'page': page, 'page_size': pageSize},
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> sendMessage(
    String sessionId,
    String content,
  ) async {
    final response = await _dio.post('/sessions/$sessionId/messages', data: {
      'content': content,
    });
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> generatePoster(String sessionId) async {
    final response = await _dio.post('/posters/generate', data: {
      'session_id': sessionId,
    });
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<List<dynamic>> listPosters() async {
    final response = await _dio.get('/posters');
    return List<dynamic>.from(response.data as List);
  }

  Future<Map<String, dynamic>> getPosterDetail(String posterId) async {
    final response = await _dio.get('/posters/detail/$posterId');
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> getPosterBySession(String sessionId) async {
    final response = await _dio.get('/posters/session/$sessionId');
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> updatePosterFavorite(
    String posterId,
    bool isFavorite,
  ) async {
    final response = await _dio.put('/posters/$posterId/favorite', data: {
      'is_favorite': isFavorite,
    });
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<void> deletePoster(String posterId) async {
    await _dio.delete('/posters/$posterId');
  }

  Future<Map<String, dynamic>> getEmotionReport({
    String period = 'weekly',
  }) async {
    final response = await _dio.get(
      '/posters/report/overview',
      queryParameters: {'period': period},
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> getEmotionReportDetail({
    String period = 'monthly',
  }) async {
    final response = await _dio.get(
      '/posters/report/detail',
      queryParameters: {'period': period},
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> submitFeedback({
    required String content,
    List<String>? imageUrls,
    String source = 'help_feedback',
  }) async {
    final response = await _dio.post('/support/feedback', data: {
      'content': content,
      'image_urls': imageUrls ?? <String>[],
      'source': source,
    });
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> getPreferences() async {
    final response = await _dio.get('/support/preferences');
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> updatePreferences(
    Map<String, dynamic> data,
  ) async {
    final response = await _dio.put('/support/preferences', data: data);
    return Map<String, dynamic>.from(response.data as Map);
  }
}
