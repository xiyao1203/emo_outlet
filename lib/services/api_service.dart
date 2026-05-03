import 'dart:convert';
import 'package:dio/dio.dart';
import '../../config/constants.dart';

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
        return handler.next(error);
      },
    ));
  }

  void setToken(String? token) => _token = token;

  // 用户相关
  Future<Map<String, dynamic>> login(String phone, String password) async {
    final response = await _dio.post('/auth/login', data: {
      'phone': phone,
      'password': password,
    });
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> register(
      String phone, String password, String? nickname) async {
    final response = await _dio.post('/auth/register', data: {
      'phone': phone,
      'password': password,
      if (nickname != null) 'nickname': nickname,
    });
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> visitorLogin() async {
    final response = await _dio.post('/auth/visitor');
    return response.data as Map<String, dynamic>;
  }

  // 目标相关
  Future<Map<String, dynamic>> createTarget(Map<String, dynamic> data) async {
    final response = await _dio.post('/targets', data: data);
    return response.data as Map<String, dynamic>;
  }

  Future<List<dynamic>> getTargets() async {
    final response = await _dio.get('/targets');
    return response.data['data'] as List<dynamic>? ?? [];
  }

  Future<Map<String, dynamic>> generateAvatar(String targetId) async {
    final response = await _dio.post('/targets/$targetId/avatar');
    return response.data as Map<String, dynamic>;
  }

  // 会话相关
  Future<Map<String, dynamic>> createSession(Map<String, dynamic> data) async {
    final response = await _dio.post('/sessions', data: data);
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> sendMessage(
      String sessionId, String content) async {
    final response = await _dio.post('/messages', data: {
      'session_id': sessionId,
      'content': content,
    });
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> endSession(String sessionId) async {
    final response = await _dio.post('/sessions/$sessionId/end');
    return response.data as Map<String, dynamic>;
  }

  Future<List<dynamic>> getSessions() async {
    final response = await _dio.get('/sessions');
    return response.data['data'] as List<dynamic>? ?? [];
  }

  // 海报相关
  Future<Map<String, dynamic>> generatePoster(String sessionId) async {
    final response = await _dio.post('/poster', data: {
      'session_id': sessionId,
    });
    return response.data as Map<String, dynamic>;
  }

  // 情绪报告
  Future<Map<String, dynamic>> getEmotionReport(String sessionId) async {
    final response = await _dio.get('/reports/$sessionId');
    return response.data as Map<String, dynamic>;
  }

  Future<List<dynamic>> getEmotionReports() async {
    final response = await _dio.get('/reports');
    return response.data['data'] as List<dynamic>? ?? [];
  }

  // 模拟数据（用于开发阶段无后端时）
  Map<String, dynamic> mockLogin() {
    return {
      'token': 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
      'user': {
        'id': 'user_001',
        'nickname': '小木阳',
        'avatar': null,
        'phone': '138****8888',
        'is_visitor': false,
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
        'is_generating': false,
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
        'is_generating': false,
      },
      {
        'id': 'target_003',
        'name': '隔壁老王',
        'type': 'other',
        'appearance': null,
        'personality': '爱炫耀',
        'relationship': '邻居',
        'style': 'Q版',
        'avatar_url': null,
        'is_generating': false,
      },
      {
        'id': 'target_004',
        'name': '烦人客户',
        'type': 'colleague',
        'appearance': null,
        'personality': '要求多',
        'relationship': '客户',
        'style': '写实',
        'avatar_url': null,
        'is_generating': false,
      },
    ];
  }

  List<Map<String, dynamic>> mockSessions() {
    return [
      {
        'id': 'session_001',
        'target_name': '讨厌的老板',
        'mode': 'single',
        'duration_minutes': 3,
        'created_at': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
        'is_completed': true,
      },
      {
        'id': 'session_002',
        'target_name': '前任',
        'mode': 'dual',
        'duration_minutes': 5,
        'created_at': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        'is_completed': true,
      },
    ];
  }

  Map<String, dynamic> mockEmotionReport() {
    return {
      'id': 'report_001',
      'session_id': 'session_001',
      'emotions': {
        '愤怒': 79.0,
        '混乱': 5.0,
        '力量': 4.0,
        '内置': 23.0,
      },
      'top_keyword': '太过分',
      'suggestion': '试着深呼吸三次，给自己一点平静的时间。',
      'poster_url': null,
      'created_at': DateTime.now().toIso8601String(),
    };
  }
}
