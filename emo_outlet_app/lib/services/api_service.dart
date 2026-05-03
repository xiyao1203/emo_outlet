import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/constants.dart';
import '../../models/user_model.dart';
import '../../models/target_model.dart';
import '../../models/session_model.dart';
import '../../models/message_model.dart';
import '../../models/emotion_report_model.dart';

/// 后端 API 服务
/// 所有接口与后端 FastAPI 严格对齐
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late final Dio _dio;
  String? _token;

  ApiService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: AppConstants.connectTimeout,
      receiveTimeout: AppConstants.receiveTimeout,
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (_token != null) {
          options.headers['Authorization'] = 'Bearer $_token';
        }
        return handler.next(options);
      },
      onError: (error, handler) {
        // 网络错误时静默处理，让调用方走 fallback
        return handler.next(error);
      },
    ));
  }

  void setToken(String? token) => _token = token;

  // ═══════════════════════════════════════════════
  // 认证 API
  // ═══════════════════════════════════════════════

  /// 登录 — POST /api/auth/login { account, password }
  Future<Map<String, dynamic>> login(String account, String password) async {
    final response = await _dio.post('/auth/login', data: {
      'account': account,
      'password': password,
    });
    return response.data as Map<String, dynamic>;
  }

  /// 注册 — POST /api/auth/register { nickname, phone/email, password }
  Future<Map<String, dynamic>> register(
      String account, String password, String? nickname) async {
    final isEmail = account.contains('@');
    final response = await _dio.post('/auth/register', data: {
      if (isEmail) 'email': account else 'phone': account,
      'password': password,
      if (nickname != null && nickname.isNotEmpty) 'nickname': nickname,
    });
    return response.data as Map<String, dynamic>;
  }

  /// 游客登录 — POST /api/auth/visitor { device_uuid, nickname }
  Future<Map<String, dynamic>> visitorLogin(
      String deviceUuid, String nickname) async {
    final response = await _dio.post('/auth/visitor', data: {
      'device_uuid': deviceUuid,
      'nickname': nickname,
    });
    return response.data as Map<String, dynamic>;
  }

  /// 获取当前用户 — GET /api/auth/me
  Future<Map<String, dynamic>> getProfile() async {
    final response = await _dio.get('/auth/me');
    return response.data as Map<String, dynamic>;
  }

  /// 更新用户 — PUT /api/auth/me
  Future<Map<String, dynamic>> updateProfile(
      {String? nickname, String? avatarUrl}) async {
    final response = await _dio.put('/auth/me', data: {
      if (nickname != null) 'nickname': nickname,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
    });
    return response.data as Map<String, dynamic>;
  }

  /// 注销 — DELETE /api/auth/account
  Future<void> deleteAccount() async {
    await _dio.delete('/auth/account');
  }

  // ═══════════════════════════════════════════════
  // 泄愤对象 API
  // ═══════════════════════════════════════════════

  /// 获取对象列表 — GET /api/targets
  /// 后端直接返回 List，不包 data
  Future<List<dynamic>> getTargets() async {
    final response = await _dio.get('/targets');
    // 后端直接返回数组 []
    if (response.data is List) {
      return response.data as List<dynamic>;
    }
    // 兼容 { data: [...] } 格式
    return (response.data is Map && response.data['data'] != null)
        ? response.data['data'] as List<dynamic>
        : [];
  }

  /// 创建对象 — POST /api/targets
  Future<Map<String, dynamic>> createTarget(Map<String, dynamic> data) async {
    final response = await _dio.post('/targets', data: data);
    return response.data as Map<String, dynamic>;
  }

  /// 更新对象 — PUT /api/targets/{id}
  Future<Map<String, dynamic>> updateTarget(
      String id, Map<String, dynamic> data) async {
    final response = await _dio.put('/targets/$id', data: data);
    return response.data as Map<String, dynamic>;
  }

  /// 删除对象 — DELETE /api/targets/{id}
  Future<void> deleteTarget(String id) async {
    await _dio.delete('/targets/$id');
  }

  /// AI 生成形象 — POST /api/targets/{id}/generate-avatar
  Future<Map<String, dynamic>> generateAvatar(String targetId) async {
    final response = await _dio.post('/targets/$targetId/generate-avatar');
    return response.data as Map<String, dynamic>;
  }

  /// AI 补全对象 — POST /api/targets/ai-complete
  Future<Map<String, dynamic>> aiCompleteTarget(
      String name, String relationship) async {
    final response = await _dio.post('/targets/ai-complete', data: {
      'name': name,
      'relationship': relationship,
    });
    return response.data as Map<String, dynamic>;
  }

  // ═══════════════════════════════════════════════
  // 会话 API
  // ═══════════════════════════════════════════════

  /// 创建会话 — POST /api/sessions
  Future<Map<String, dynamic>> createSession(Map<String, dynamic> data) async {
    final response = await _dio.post('/sessions', data: data);
    return response.data as Map<String, dynamic>;
  }

  /// 获取会话列表 — GET /api/sessions?page=1&page_size=20
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

  /// 获取活跃会话 — GET /api/sessions/active
  Future<Map<String, dynamic>?> getActiveSession() async {
    try {
      final response = await _dio.get('/sessions/active');
      if (response.data == null || response.data is! Map) return null;
      return response.data as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  /// 获取会话详情 — GET /api/sessions/{id}
  Future<Map<String, dynamic>> getSession(String id) async {
    final response = await _dio.get('/sessions/$id');
    return response.data as Map<String, dynamic>;
  }

  /// 结束会话 — POST /api/sessions/{id}/end
  Future<Map<String, dynamic>> endSession(
      String id, {bool force = false}) async {
    final response = await _dio.post('/sessions/$id/end', data: {
      'force': force,
    });
    return response.data as Map<String, dynamic>;
  }

  // ═══════════════════════════════════════════════
  // 消息 API
  // ═══════════════════════════════════════════════

  /// 获取消息列表 — GET /api/sessions/{id}/messages
  Future<Map<String, dynamic>> getMessages(
    String sessionId, {
    int page = 1,
    int pageSize = 50,
  }) async {
    final response = await _dio.get('/sessions/$sessionId/messages',
        queryParameters: {'page': page, 'page_size': pageSize});
    return response.data as Map<String, dynamic>;
  }

  /// 发送消息 — POST /api/sessions/{id}/messages { content }
  /// 返回 AI 回复消息（MessageResponse）
  Future<Map<String, dynamic>> sendMessage(
      String sessionId, String content) async {
    final response = await _dio.post('/sessions/$sessionId/messages', data: {
      'content': content,
    });
    return response.data as Map<String, dynamic>;
  }

  // ═══════════════════════════════════════════════
  // 海报 & 情绪报告 API
  // ═══════════════════════════════════════════════

  /// 生成海报 — POST /api/posters/generate { session_id }
  Future<Map<String, dynamic>> generatePoster(String sessionId) async {
    final response = await _dio.post('/posters/generate', data: {
      'session_id': sessionId,
    });
    return response.data as Map<String, dynamic>;
  }

  /// 获取海报 — GET /api/posters/{sessionId}
  Future<Map<String, dynamic>> getPoster(String sessionId) async {
    final response = await _dio.get('/posters/$sessionId');
    return response.data as Map<String, dynamic>;
  }

  /// 获取情绪报告 — GET /api/posters/report/overview?period=weekly
  Future<Map<String, dynamic>> getEmotionReport(
      {String period = 'weekly'}) async {
    final response = await _dio.get('/posters/report/overview',
        queryParameters: {'period': period});
    return response.data as Map<String, dynamic>;
  }

  // ═══════════════════════════════════════════════
  // 模拟数据（后端不可用时的 fallback）
  // ═══════════════════════════════════════════════

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

  Future<String?> _getDeviceUuid() async {
    final prefs = await SharedPreferences.getInstance();
    String? uuid = prefs.getString('device_uuid');
    if (uuid == null) {
      uuid = 'device_${DateTime.now().millisecondsSinceEpoch}';
      await prefs.setString('device_uuid', uuid);
    }
    return uuid;
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
        'created_at': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
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
        'created_at': DateTime.now().subtract(const Duration(days: 7)).toIso8601String(),
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
        'start_time': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
        'end_time': DateTime.now().subtract(const Duration(hours: 1, minutes: 57)).toIso8601String(),
        'emotion_summary': null,
        'summary_text': null,
        'created_at': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
      },
    ];
  }

  Map<String, dynamic> mockPoster(String sessionId) {
    return {
      'id': 'poster_${DateTime.now().millisecondsSinceEpoch}',
      'session_id': sessionId,
      'title': '说出来好多了！',
      'emotion_type': '愤怒',
      'emotion_intensity': 79,
      'keywords': '["太过分","气死"]',
      'suggestion': '愤怒需要出口，你已经找到了安全的方式 💪',
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
