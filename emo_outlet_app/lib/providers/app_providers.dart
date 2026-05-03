import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/target_model.dart';
import '../models/session_model.dart';
import '../models/message_model.dart';
import '../models/emotion_report_model.dart';
import '../services/api_service.dart';

class TargetProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  List<TargetModel> _targets = [];
  TargetModel? _currentTarget;

  List<TargetModel> get targets => _targets;
  TargetModel? get currentTarget => _currentTarget;

  Future<void> loadTargets() async {
    // 使用模拟数据
    _targets = _api.mockTargets().map((e) => TargetModel.fromJson(e)).toList();
    notifyListeners();
  }

  void setCurrentTarget(TargetModel target) {
    _currentTarget = target;
    notifyListeners();
  }

  Future<TargetModel> createTarget(Map<String, dynamic> data) async {
    final target = TargetModel.fromJson(data);
    _targets.add(target);
    _currentTarget = target;
    notifyListeners();
    return target;
  }

  void removeTarget(String id) {
    _targets.removeWhere((t) => t.id == id);
    if (_currentTarget?.id == id) _currentTarget = null;
    notifyListeners();
  }
}

class SessionProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  SessionModel? _currentSession;
  List<MessageModel> _messages = [];
  List<SessionModel> _sessions = [];
  int _remainingSeconds = 0;
  bool _isRunning = false;

  SessionModel? get currentSession => _currentSession;
  List<MessageModel> get messages => _messages;
  List<SessionModel> get sessions => _sessions;
  int get remainingSeconds => _remainingSeconds;
  bool get isRunning => _isRunning;
  String get formattedTime {
    final min = _remainingSeconds ~/ 60;
    final sec = _remainingSeconds % 60;
    return '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  Future<void> loadSessions() async {
    _sessions = _api.mockSessions().map((e) => SessionModel.fromJson(e)).toList();
    notifyListeners();
  }

  void createSession({
    required String targetId,
    required String targetName,
    String? targetAvatarUrl,
    SessionMode mode = SessionMode.single,
    ChatStyle? chatStyle,
    String dialect = '普通话',
    int durationMinutes = 3,
  }) {
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
      isActive: true,
    );
    _messages = [];
    _messages.add(MessageModel(
      sessionId: _currentSession!.id!,
      content: '开始释放你的情绪吧，有什么想说的尽管说出来！',
      sender: MessageSender.ai,
      timestamp: DateTime.now(),
      isSystem: true,
    ));
    _remainingSeconds = durationMinutes * 60;
    _isRunning = true;
    notifyListeners();
  }

  void addMessage(String content, {MessageSender sender = MessageSender.user}) {
    if (_currentSession == null) return;
    _messages.add(MessageModel(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      sessionId: _currentSession!.id!,
      content: content,
      sender: sender,
      timestamp: DateTime.now(),
    ));
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

  void endSession() {
    _isRunning = false;
    if (_currentSession != null) {
      _currentSession = _currentSession!.copyWith(
        endTime: DateTime.now(),
        isActive: false,
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
}

class EmotionProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  EmotionReportModel? _currentReport;
  List<EmotionReportModel> _reports = [];
  String? _posterUrl;

  EmotionReportModel? get currentReport => _currentReport;
  List<EmotionReportModel> get reports => _reports;
  String? get posterUrl => _posterUrl;

  Future<void> generateReport(String sessionId) async {
    final data = _api.mockEmotionReport();
    _currentReport = EmotionReportModel.fromJson(data);
    notifyListeners();
  }

  Future<void> generatePoster(String sessionId) async {
    // 模拟生成海报
    _posterUrl = 'poster_$sessionId';
    notifyListeners();
  }

  Future<void> loadReports() async {
    // 模拟加载报告
    final data = _api.mockEmotionReport();
    _reports = [EmotionReportModel.fromJson(data)];
    notifyListeners();
  }

  void clearReport() {
    _currentReport = null;
    notifyListeners();
  }
}
