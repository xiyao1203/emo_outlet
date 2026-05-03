import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/target_model.dart';
import '../models/session_model.dart';
import '../models/message_model.dart';
import '../models/emotion_report_model.dart';
import '../services/api_service.dart';
import '../config/constants.dart';

/// 泄愤对象 Provider
class TargetProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  List<TargetModel> _targets = [];
  TargetModel? _currentTarget;
  bool _isLoading = false;

  List<TargetModel> get targets => _targets;
  TargetModel? get currentTarget => _currentTarget;
  bool get isLoading => _isLoading;

  /// 加载对象列表（真实 API → Mock fallback）
  Future<void> loadTargets() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _api.getTargets();
      _targets = data.map((e) => TargetModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      // 后端不可用，走 mock 数据
      _targets = _api.mockTargets().map((e) => TargetModel.fromJson(e)).toList();
    }

    _isLoading = false;
    notifyListeners();
  }

  void setCurrentTarget(TargetModel target) {
    _currentTarget = target;
    notifyListeners();
  }

  /// 创建对象
  Future<TargetModel?> createTarget(Map<String, dynamic> data) async {
    try {
      final result = await _api.createTarget(data);
      final target = TargetModel.fromJson(result);
      _targets.add(target);
      _currentTarget = target;
      notifyListeners();
      return target;
    } catch (e) {
      // fallback: 本地创建
      final target = TargetModel.fromJson(data);
      _targets.add(target);
      _currentTarget = target;
      notifyListeners();
      return target;
    }
  }

  /// 更新对象
  Future<void> updateTarget(String id, Map<String, dynamic> data) async {
    try {
      final result = await _api.updateTarget(id, data);
      final updated = TargetModel.fromJson(result);
      final idx = _targets.indexWhere((t) => t.id == id);
      if (idx != -1) _targets[idx] = updated;
      if (_currentTarget?.id == id) _currentTarget = updated;
      notifyListeners();
    } catch (_) {
      // 本地更新
      final idx = _targets.indexWhere((t) => t.id == id);
      if (idx != -1) {
        _targets[idx] = TargetModel.fromJson({..._targets[idx].toJson(), ...data});
      }
      notifyListeners();
    }
  }

  /// 删除对象
  Future<void> removeTarget(String id) async {
    try {
      await _api.deleteTarget(id);
    } catch (_) {
      // 本地删除
    }
    _targets.removeWhere((t) => t.id == id);
    if (_currentTarget?.id == id) _currentTarget = null;
    notifyListeners();
  }

  /// AI 生成形象
  Future<void> generateAvatar(String targetId) async {
    try {
      final result = await _api.generateAvatar(targetId);
      final idx = _targets.indexWhere((t) => t.id == targetId);
      if (idx != -1 && result['avatar_url'] != null) {
        _targets[idx] = _targets[idx].copyWith(avatarUrl: result['avatar_url']);
        if (_currentTarget?.id == targetId) {
          _currentTarget = _targets[idx];
        }
        notifyListeners();
      }
    } catch (_) {
      // mock: 设置虚拟头像URL
      final idx = _targets.indexWhere((t) => t.id == targetId);
      if (idx != -1) {
        _targets[idx] = _targets[idx].copyWith(
          avatarUrl: 'mock_avatar_$targetId',
        );
        if (_currentTarget?.id == targetId) {
          _currentTarget = _targets[idx];
        }
        notifyListeners();
      }
    }
  }

  /// AI 补全对象
  Future<Map<String, dynamic>?> aiComplete(String name, String relationship) async {
    try {
      return await _api.aiCompleteTarget(name, relationship);
    } catch (_) {
      return null;
    }
  }
}

/// 会话 Provider
class SessionProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  SessionModel? _currentSession;
  List<MessageModel> _messages = [];
  List<SessionModel> _sessions = [];
  int _remainingSeconds = 0;
  bool _isRunning = false;
  bool _isLoading = false;

  SessionModel? get currentSession => _currentSession;
  List<MessageModel> get messages => _messages;
  List<SessionModel> get sessions => _sessions;
  int get remainingSeconds => _remainingSeconds;
  bool get isRunning => _isRunning;
  bool get isLoading => _isLoading;

  String get formattedTime {
    final min = _remainingSeconds ~/ 60;
    final sec = _remainingSeconds % 60;
    return '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  /// 加载历史会话
  Future<void> loadSessions() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _api.getSessions();
      _sessions = data.map((e) => SessionModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      _sessions = _api.mockSessions().map((e) => SessionModel.fromJson(e)).toList();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// 创建会话（优先调后端）
  Future<SessionModel?> createSession({
    required String targetId,
    required String targetName,
    String? targetAvatarUrl,
    SessionMode mode = SessionMode.single,
    ChatStyle? chatStyle,
    String dialect = '普通话',
    int durationMinutes = 3,
  }) async {
    // 构建请求体，中文字段名映射为后端英文代码
    final String modeStr = mode == SessionMode.single ? 'single' : 'dual';
    final String? chatStyleStr =
        chatStyle != null ? AppConstants.chatStyleMap.values.elementAt(chatStyle.index) : null;
    final String dialectStr = AppConstants.dialectMap[dialect] ?? 'mandarin';

    try {
      final result = await _api.createSession({
        'target_id': targetId,
        'mode': modeStr,
        if (chatStyleStr != null) 'chat_style': chatStyleStr,
        'dialect': dialectStr,
        'duration_minutes': durationMinutes,
      });
      _currentSession = SessionModel.fromJson(result);
    } catch (_) {
      // fallback: 本地创建会话
      _currentSession = SessionModel(
        id: 'session_${DateTime.now().millisecondsSinceEpoch}',
        targetId: targetId,
        targetName: targetName,
        targetAvatarUrl: targetAvatarUrl,
        mode: mode,
        chatStyle: chatStyle,
        dialect: dialect,
        durationMinutes: durationMinutes,
        startTime: DateTime.now(),
        status: 'active',
      );
    }

    _messages = [
      MessageModel(
        sessionId: _currentSession!.id!,
        content: '开始释放你的情绪吧，有什么想说的尽管说出来！',
        sender: MessageSender.ai,
        createdAt: DateTime.now(),
        isSystem: true,
      ),
    ];
    _remainingSeconds = durationMinutes * 60;
    _isRunning = true;
    notifyListeners();
    return _currentSession;
  }

  /// 发送消息 → 接收 AI 回复
  Future<void> sendMessage(String content) async {
    if (_currentSession?.id == null) return;

    // 添加用户消息
    _messages.add(MessageModel(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      sessionId: _currentSession!.id!,
      content: content,
      sender: MessageSender.user,
      createdAt: DateTime.now(),
    ));
    notifyListeners();

    // 调后端
    try {
      final result = await _api.sendMessage(_currentSession!.id!, content);
      if (result['ai_reply'] != null) {
        _messages.add(MessageModel(
          id: result['ai_reply']['id'],
          sessionId: _currentSession!.id!,
          content: result['ai_reply']['content'],
          sender: MessageSender.ai,
          createdAt: DateTime.now(),
          isSensitive: result['ai_reply']['is_sensitive'] == true,
        ));
        notifyListeners();
      }
    } catch (_) {
      // fallback: 模拟 AI 回复
      _messages.add(MessageModel(
        sessionId: _currentSession!.id!,
        content: _mockAiReply(content),
        sender: MessageSender.ai,
        createdAt: DateTime.now(),
      ));
      notifyListeners();
    }
  }

  void tick() {
    if (_remainingSeconds > 0 && _isRunning) {
      _remainingSeconds--;
      notifyListeners();
      if (_remainingSeconds <= 0) {
        endSession();
      }
    }
  }

  void addTime(int minutes) {
    _remainingSeconds += minutes * 60;
    notifyListeners();
  }

  /// 结束会话
  Future<void> endSession() async {
    _isRunning = false;

    if (_currentSession?.id != null) {
      try {
        await _api.endSession(_currentSession!.id!);
      } catch (_) {
        // mock: 本地结束
      }

      _currentSession = _currentSession!.copyWith(
        endTime: DateTime.now(),
        status: 'completed',
        isCompleted: true,
      );
    }

    notifyListeners();
  }

  void clearCurrentSession() {
    _currentSession = null;
    _messages = [];
    _remainingSeconds = 0;
    _isRunning = false;
    notifyListeners();
  }

  String _mockAiReply(String userContent) {
    if (userContent.contains('?')) return '咋了嘛，有什么好疑问的？';
    if (userContent.contains('!')) return '你说得对… 行吧你说了算。';
    if (userContent.length > 20) return '说这么多，我也听不懂你想表达啥。';
    return '嗯，然后呢？';
  }
}

/// 情绪报告 & 海报 Provider
class EmotionProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  EmotionReportModel? _currentReport;
  List<EmotionReportModel> _reports = [];
  String? _posterUrl;
  String? _posterData;
  bool _isLoading = false;

  EmotionReportModel? get currentReport => _currentReport;
  List<EmotionReportModel> get reports => _reports;
  String? get posterUrl => _posterUrl;
  String? get posterData => _posterData;
  bool get isLoading => _isLoading;

  /// 生成会话情绪报告
  Future<void> generateReport(String sessionId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 生成海报以触发情绪分析
      final poster = await _api.generatePoster(sessionId);
      _posterUrl = poster['poster_url'];
      _posterData = poster['poster_data'];
    } catch (_) {
      final data = _api.mockPoster(sessionId);
      _posterUrl = data['poster_url'];
      _posterData = data['poster_data'];
    }
    _isLoading = false;
    notifyListeners();
  }

  /// 获取周期情绪报告
  Future<void> loadOverviewReport({String period = 'weekly'}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _api.getEmotionReport(period: period);
      _currentReport = EmotionReportModel.fromOverviewJson(data);
    } catch (_) {
      final data = _api.mockEmotionReport();
      _currentReport = EmotionReportModel.fromOverviewJson(data);
    }

    _isLoading = false;
    notifyListeners();
  }

  /// 生成海报
  Future<void> generatePoster(String sessionId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _api.generatePoster(sessionId);
      _posterUrl = result['poster_url'];
      _posterData = result['poster_data'];
    } catch (_) {
      final data = _api.mockPoster(sessionId);
      _posterUrl = data['poster_url'];
      _posterData = data['poster_data'];
    }

    _isLoading = false;
    notifyListeners();
  }

  void clearReport() {
    _currentReport = null;
    _posterUrl = null;
    _posterData = null;
    notifyListeners();
  }

  /// 清除敏感缓存数据（注销时调用）
  void clearSensitiveCache() {
    _currentReport = null;
    _reports = [];
    _posterUrl = null;
    _posterData = null;
    notifyListeners();
  }
}
