import 'package:flutter/foundation.dart';

import '../config/constants.dart';
import '../models/emotion_report_model.dart';
import '../models/message_model.dart';
import '../models/session_model.dart';
import '../models/target_model.dart';
import '../services/api_service.dart';

class TargetProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  List<TargetModel> _targets = [];
  TargetModel? _currentTarget;
  bool _isLoading = false;

  List<TargetModel> get targets => _targets;
  TargetModel? get currentTarget => _currentTarget;
  bool get isLoading => _isLoading;

  Future<void> loadTargets() async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await _api.getTargets();
      _targets = data
          .map((e) => TargetModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setCurrentTarget(TargetModel target) {
    _currentTarget = target;
    notifyListeners();
  }

  Future<TargetModel?> createTarget(Map<String, dynamic> data) async {
    final result = await _api.createTarget(data);
    final target = TargetModel.fromJson(result);
    _targets.add(target);
    _currentTarget = target;
    notifyListeners();
    return target;
  }

  Future<void> updateTarget(String id, Map<String, dynamic> data) async {
    final result = await _api.updateTarget(id, data);
    final updated = TargetModel.fromJson(result);
    final idx = _targets.indexWhere((t) => t.id == id);
    if (idx != -1) {
      _targets[idx] = updated;
    }
    if (_currentTarget?.id == id) {
      _currentTarget = updated;
    }
    notifyListeners();
  }

  Future<void> removeTarget(String id) async {
    await _api.deleteTarget(id);
    _targets.removeWhere((t) => t.id == id);
    if (_currentTarget?.id == id) {
      _currentTarget = null;
    }
    notifyListeners();
  }

  Future<void> generateAvatar(String targetId) async {
    final result = await _api.generateAvatar(targetId);
    final updated = TargetModel.fromJson(result);
    final idx = _targets.indexWhere((t) => t.id == targetId);
    if (idx != -1) {
      _targets[idx] = updated;
    }
    if (_currentTarget?.id == targetId) {
      _currentTarget = updated;
    }
    notifyListeners();
  }

  Future<Map<String, dynamic>?> aiComplete(
    String name,
    String relationship,
  ) async {
    return _api.aiCompleteTarget(name, relationship);
  }
}

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

  Future<void> loadSessions() async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await _api.getSessions();
      _sessions = data
          .map((e) => SessionModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<SessionModel?> createSession({
    required String targetId,
    required String targetName,
    String? targetAvatarUrl,
    SessionMode mode = SessionMode.single,
    ChatStyle? chatStyle,
    String dialect = '普通话',
    int durationMinutes = 3,
  }) async {
    final String modeStr = mode == SessionMode.single ? 'single' : 'dual';
    final String? chatStyleStr = chatStyle != null
        ? AppConstants.chatStyleMap.values.elementAt(chatStyle.index)
        : null;
    final String dialectStr = AppConstants.dialectMap[dialect] ?? 'mandarin';

    final result = await _api.createSession({
      'target_id': targetId,
      'mode': modeStr,
      if (chatStyleStr != null) 'chat_style': chatStyleStr,
      'dialect': dialectStr,
      'duration_minutes': durationMinutes,
    });
    _currentSession = SessionModel.fromJson(result);
    _messages = [];
    _remainingSeconds = durationMinutes * 60;
    _isRunning = true;
    notifyListeners();
    return _currentSession;
  }

  Future<void> sendMessage(String content) async {
    final sessionId = _currentSession?.id;
    if (sessionId == null) {
      return;
    }

    final optimistic = MessageModel(
      sessionId: sessionId,
      content: content,
      sender: MessageSender.user,
      createdAt: DateTime.now(),
    );
    _messages = [..._messages, optimistic];
    notifyListeners();

    final result = await _api.sendMessage(sessionId, content);
    final aiMessage = MessageModel.fromJson(result);
    _messages = [..._messages, aiMessage];
    notifyListeners();
  }

  Future<void> loadMessages(String sessionId) async {
    final result = await _api.getMessages(sessionId);
    final messageItems = (result['messages'] as List<dynamic>? ?? <dynamic>[])
        .map((item) => MessageModel.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
    _messages = messageItems;
    _remainingSeconds = result['remaining_seconds'] as int? ?? 0;
    notifyListeners();
  }

  void seedMessages(List<MessageModel> messages) {
    _messages = messages;
    notifyListeners();
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

  Future<void> endSession() async {
    _isRunning = false;
    final sessionId = _currentSession?.id;
    if (sessionId != null) {
      final result = await _api.endSession(sessionId);
      _currentSession = SessionModel.fromJson(
        Map<String, dynamic>.from(result['session'] as Map),
      );
      _messages = (result['messages'] as List<dynamic>? ?? <dynamic>[])
          .map((item) => MessageModel.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
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
}

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

  Future<void> generateReport(String sessionId) async {
    await generatePoster(sessionId);
  }

  Future<void> loadOverviewReport({String period = 'weekly'}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await _api.getEmotionReport(period: period);
      _currentReport = EmotionReportModel.fromOverviewJson(data);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> generatePoster(String sessionId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final result = await _api.generatePoster(sessionId);
      _posterUrl = result['poster_url'] as String?;
      _posterData = result['poster_data'] as String?;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearReport() {
    _currentReport = null;
    _posterUrl = null;
    _posterData = null;
    notifyListeners();
  }

  void clearSensitiveCache() {
    _currentReport = null;
    _reports = [];
    _posterUrl = null;
    _posterData = null;
    notifyListeners();
  }
}
