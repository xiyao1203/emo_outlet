import 'dart:convert';

import 'session_model.dart';

class HistoryRecordModel {
  const HistoryRecordModel({
    required this.id,
    required this.sessionId,
    required this.name,
    required this.avatarUrl,
    required this.mode,
    required this.timestamp,
    required this.durationMinutes,
    required this.emotions,
    required this.releaseRate,
    required this.summary,
    required this.keywords,
    required this.modeLabel,
    required this.language,
  });

  final String id;
  final String sessionId;
  final String name;
  final String? avatarUrl;
  final String mode;
  final DateTime timestamp;
  final int durationMinutes;
  final List<String> emotions;
  final int releaseRate;
  final String summary;
  final List<String> keywords;
  final String modeLabel;
  final String language;

  bool get isDual => mode == 'dual';

  factory HistoryRecordModel.fromSession(SessionModel session) {
    final summaryData = _parseJson(session.emotionSummary);
    final emotionsMap =
        Map<String, dynamic>.from(summaryData['emotions'] as Map? ?? const {});
    final emotions = emotionsMap.keys.where((key) => key.trim().isNotEmpty).toList();
    final keywords = (summaryData['keywords'] as List<dynamic>? ?? const <dynamic>[])
        .map((item) => item.toString())
        .where((item) => item.trim().isNotEmpty)
        .toList();

    return HistoryRecordModel(
      id: session.id ?? session.targetId,
      sessionId: session.id ?? '',
      name: session.targetName.isEmpty ? '未命名对象' : session.targetName,
      avatarUrl: session.targetAvatarUrl,
      mode: session.mode == SessionMode.dual ? 'dual' : 'single',
      timestamp: session.endTime ?? session.startTime ?? DateTime.now(),
      durationMinutes: session.durationMinutes,
      emotions: emotions.isEmpty ? <String>['平静'] : emotions.take(3).toList(),
      releaseRate: (summaryData['intensity'] as num?)?.round() ?? 20,
      summary: (summaryData['summary'] as String?) ??
          session.summaryText ??
          '这次会话已经完成，情绪总结会继续随着新的记录逐步丰富。',
      keywords: keywords,
      modeLabel: session.mode == SessionMode.dual ? '双向模式' : '单向模式',
      language: session.dialect,
    );
  }

  static Map<String, dynamic> _parseJson(String? value) {
    if (value == null || value.trim().isEmpty) {
      return <String, dynamic>{};
    }
    try {
      return Map<String, dynamic>.from(jsonDecode(value) as Map);
    } catch (_) {
      return <String, dynamic>{};
    }
  }
}
