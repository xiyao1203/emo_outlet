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
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> register(
    String account,
    String password,
    String? nickname,
  ) async {
    final isEmail = account.contains('@');
    final response = await _dio.post('/auth/register', data: {
      if (isEmail) 'email': account else 'phone': account,
      'password': password,
      if (nickname != null && nickname.isNotEmpty) 'nickname': nickname,
    });
    return response.data as Map<String, dynamic>;
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
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> visitorLogin(
    String deviceUuid,
    String nickname,
  ) async {
    final response = await _dio.post('/auth/visitor', data: {
      'device_uuid': deviceUuid,
      'nickname': nickname,
    });
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getProfile() async {
    final response = await _dio.get('/auth/me');
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateProfile({
    String? nickname,
    String? avatarUrl,
  }) async {
    final response = await _dio.put('/auth/me', data: {
      if (nickname != null) 'nickname': nickname,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
    });
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getProfileDetail() async {
    final response = await _dio.get('/auth/profile-detail');
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateProfileDetail(
    Map<String, dynamic> data,
  ) async {
    final response = await _dio.put('/auth/profile-detail', data: data);
    return response.data as Map<String, dynamic>;
  }

  Future<void> deleteAccount() async {
    await _dio.delete('/auth/account');
  }

  Future<List<dynamic>> getTargets() async {
    final response = await _dio.get('/targets');
    if (response.data is List) {
      return response.data as List<dynamic>;
    }
    return (response.data is Map && response.data['data'] != null)
        ? response.data['data'] as List<dynamic>
        : [];
  }

  Future<Map<String, dynamic>> createTarget(Map<String, dynamic> data) async {
    final response = await _dio.post('/targets', data: data);
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateTarget(
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await _dio.put('/targets/$id', data: data);
    return response.data as Map<String, dynamic>;
  }

  Future<void> deleteTarget(String id) async {
    await _dio.delete('/targets/$id');
  }

  Future<Map<String, dynamic>> generateAvatar(String targetId) async {
    final response = await _dio.post('/targets/$targetId/generate-avatar');
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> aiCompleteTarget(
    String name,
    String relationship,
  ) async {
    final response = await _dio.post('/targets/ai-complete', data: {
      'name': name,
      'relationship': relationship,
    });
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> createSession(Map<String, dynamic> data) async {
    final response = await _dio.post('/sessions', data: data);
    return response.data as Map<String, dynamic>;
  }

  Future<List<dynamic>> getSessions({int page = 1, int pageSize = 20}) async {
    final response = await _dio.get('/sessions', queryParameters: {
      'page': page,
      'page_size': pageSize,
    });
    if (response.data is List) {
      return response.data as List<dynamic>;
    }
    return (response.data is Map && response.data['data'] != null)
        ? response.data['data'] as List<dynamic>
        : [];
  }

  Future<Map<String, dynamic>> getSession(String id) async {
    final response = await _dio.get('/sessions/$id');
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> endSession(
    String id, {
    bool force = false,
  }) async {
    final response = await _dio.post('/sessions/$id/end', data: {
      'force': force,
    });
    return response.data as Map<String, dynamic>;
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
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> sendMessage(
    String sessionId,
    String content,
  ) async {
    final response = await _dio.post('/sessions/$sessionId/messages', data: {
      'content': content,
    });
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> generatePoster(String sessionId) async {
    final response = await _dio.post('/posters/generate', data: {
      'session_id': sessionId,
    });
    return response.data as Map<String, dynamic>;
  }

  Future<List<dynamic>> listPosters() async {
    final response = await _dio.get('/posters');
    return response.data as List<dynamic>;
  }

  Future<Map<String, dynamic>> getPosterDetail(String posterId) async {
    final response = await _dio.get('/posters/detail/$posterId');
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getEmotionReport({
    String period = 'weekly',
  }) async {
    final response = await _dio.get(
      '/posters/report/overview',
      queryParameters: {'period': period},
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getEmotionReportDetail({
    String period = 'monthly',
  }) async {
    final response = await _dio.get(
      '/posters/report/detail',
      queryParameters: {'period': period},
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getSupportOverview() async {
    final response = await _dio.get('/support/overview');
    return response.data as Map<String, dynamic>;
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
    return response.data as Map<String, dynamic>;
  }

  Map<String, dynamic> mockLogin() {
    return {
      'access_token': 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
      'token_type': 'bearer',
      'user': {
        'id': 'user_001',
        'nickname': '小木阳',
        'phone': '138****8888',
        'email': null,
        'avatar_url': null,
        'is_visitor': false,
        'daily_session_count': 0,
        'created_at': DateTime.now().toIso8601String(),
      },
    };
  }

  List<Map<String, dynamic>> mockTargets() {
    return [
      {
        'id': 'target_001',
        'name': '讨厌的老板',
        'type': 'boss',
        'appearance': '中年男性，西装',
        'personality': '爱甩锅',
        'relationship': '直属领导',
        'style': '漫画',
        'avatar_url': null,
        'is_hidden': false,
        'created_at': DateTime.now()
            .subtract(const Duration(days: 3))
            .toIso8601String(),
      },
      {
        'id': 'target_002',
        'name': '前任',
        'type': 'partner',
        'appearance': null,
        'personality': '冷漠',
        'relationship': '前女友',
        'style': '漫画',
        'avatar_url': null,
        'is_hidden': false,
        'created_at': DateTime.now()
            .subtract(const Duration(days: 7))
            .toIso8601String(),
      },
    ];
  }

  List<Map<String, dynamic>> mockSessions() {
    return [
      {
        'id': 'session_001',
        'target_id': 'target_001',
        'mode': 'single',
        'chat_style': 'apologetic',
        'dialect': 'mandarin',
        'duration_minutes': 3,
        'status': 'completed',
        'is_completed': true,
        'start_time': DateTime.now()
            .subtract(const Duration(hours: 2))
            .toIso8601String(),
        'end_time': DateTime.now()
            .subtract(const Duration(hours: 1, minutes: 57))
            .toIso8601String(),
        'emotion_summary': null,
        'summary_text': null,
        'created_at': DateTime.now()
            .subtract(const Duration(hours: 2))
            .toIso8601String(),
      },
    ];
  }

  Map<String, dynamic> mockPoster(String sessionId) {
    return {
      'id': 'poster_${DateTime.now().millisecondsSinceEpoch}',
      'session_id': sessionId,
      'title': '说出来好多了',
      'emotion_type': '愤怒',
      'emotion_intensity': 79,
      'keywords': '["太过分","气死"]',
      'suggestion': '愤怒需要出口，你已经找到一个更安全的方式。',
      'poster_url': null,
      'poster_data':
          'data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSI0MDAiIGhlaWdodD0iNjAwIj48cmVjdCB3aWR0aD0iNDAwIiBoZWlnaHQ9IjYwMCIgZmlsbD0iI0ZGN0E1NiIvPjwvc3ZnPg==',
      'created_at': DateTime.now().toIso8601String(),
    };
  }

  Map<String, dynamic> mockEmotionReport() {
    return {
      'total_sessions': 6,
      'total_duration_minutes': 28,
      'dominant_emotion': '愤怒',
      'emotion_distribution': {
        '愤怒': 45.0,
        '悲伤': 25.0,
        '焦虑': 15.0,
        '疲惫': 10.0,
        '无奈': 5.0,
      },
      'daily_trend': [],
      'suggestion': '你的愤怒值较高，建议结合运动或深呼吸来释放压力。',
    };
  }
}
