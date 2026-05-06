import '../config/constants.dart';

enum SessionMode { single, dual }

enum ChatStyle { stubborn, apologetic, cold, sarcastic, rational }

class SessionModel {
  final String? id;
  final String targetId;
  final String targetName;
  final String? targetAvatarUrl;
  final SessionMode mode;
  final ChatStyle? chatStyle;
  final String dialect;
  final int durationMinutes;
  final DateTime? startTime;
  final DateTime? endTime;
  final String status;
  final bool isCompleted;
  final String? emotionSummary;
  final String? summaryText;

  SessionModel({
    this.id,
    required this.targetId,
    required this.targetName,
    this.targetAvatarUrl,
    this.mode = SessionMode.single,
    this.chatStyle,
    this.dialect = '普通话',
    this.durationMinutes = 5,
    this.startTime,
    this.endTime,
    this.status = 'active',
    this.isCompleted = false,
    this.emotionSummary,
    this.summaryText,
  });

  bool get isActive => status == 'active';

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      id: json['id'] as String?,
      targetId: json['target_id'] as String? ?? '',
      targetName: json['target_name'] as String? ?? '',
      targetAvatarUrl: json['target_avatar_url'] as String?,
      mode: json['mode'] == 'dual' ? SessionMode.dual : SessionMode.single,
      chatStyle: _parseChatStyle(json['chat_style'] as String?),
      dialect: _parseDialect(json['dialect'] as String?),
      durationMinutes: json['duration_minutes'] as int? ?? 5,
      startTime: json['start_time'] != null
          ? DateTime.parse(json['start_time'] as String)
          : null,
      endTime: json['end_time'] != null
          ? DateTime.parse(json['end_time'] as String)
          : null,
      status: json['status'] as String? ?? 'active',
      isCompleted: json['is_completed'] as bool? ?? false,
      emotionSummary: json['emotion_summary'] as String?,
      summaryText: json['summary_text'] as String?,
    );
  }

  static String _parseDialect(String? value) {
    return AppConstants.dialectLabelMap[value] ?? value ?? '普通话';
  }

  static ChatStyle? _parseChatStyle(String? value) {
    switch (value) {
      case 'stubborn':
        return ChatStyle.stubborn;
      case 'apologetic':
        return ChatStyle.apologetic;
      case 'cold':
        return ChatStyle.cold;
      case 'sarcastic':
        return ChatStyle.sarcastic;
      case 'rational':
        return ChatStyle.rational;
      default:
        return null;
    }
  }

  String get chatStyleLabel {
    if (chatStyle == null) return '';
    const labels = {
      ChatStyle.stubborn: '嘴硬型',
      ChatStyle.apologetic: '道歉型',
      ChatStyle.cold: '冷漠型',
      ChatStyle.sarcastic: '阴阳型',
      ChatStyle.rational: '理性型',
    };
    return labels[chatStyle] ?? '';
  }

  String get modeLabel => mode == SessionMode.single ? '单向模式' : '双向模式';

  Duration get elapsed {
    if (startTime == null) return Duration.zero;
    final end = endTime ?? DateTime.now();
    return end.difference(startTime!);
  }

  String get formattedDuration {
    final minutes = elapsed.inMinutes;
    final seconds = elapsed.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  SessionModel copyWith({
    String? id,
    String? targetId,
    String? targetName,
    String? targetAvatarUrl,
    SessionMode? mode,
    ChatStyle? chatStyle,
    String? dialect,
    int? durationMinutes,
    DateTime? startTime,
    DateTime? endTime,
    String? status,
    bool? isCompleted,
    String? emotionSummary,
    String? summaryText,
  }) {
    return SessionModel(
      id: id ?? this.id,
      targetId: targetId ?? this.targetId,
      targetName: targetName ?? this.targetName,
      targetAvatarUrl: targetAvatarUrl ?? this.targetAvatarUrl,
      mode: mode ?? this.mode,
      chatStyle: chatStyle ?? this.chatStyle,
      dialect: dialect ?? this.dialect,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      isCompleted: isCompleted ?? this.isCompleted,
      emotionSummary: emotionSummary ?? this.emotionSummary,
      summaryText: summaryText ?? this.summaryText,
    );
  }
}
