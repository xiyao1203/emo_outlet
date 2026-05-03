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
  final bool isActive;
  final bool isCompleted;
  final String? summary;

  SessionModel({
    this.id,
    required this.targetId,
    required this.targetName,
    this.targetAvatarUrl,
    this.mode = SessionMode.single,
    this.chatStyle,
    this.dialect = '普通话',
    this.durationMinutes = 3,
    this.startTime,
    this.endTime,
    this.isActive = false,
    this.isCompleted = false,
    this.summary,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      id: json['id'] as String?,
      targetId: json['target_id'] as String? ?? '',
      targetName: json['target_name'] as String? ?? '',
      targetAvatarUrl: json['target_avatar_url'] as String?,
      mode: json['mode'] == 'dual' ? SessionMode.dual : SessionMode.single,
      chatStyle: _parseChatStyle(json['chat_style'] as String?),
      dialect: json['dialect'] as String? ?? '普通话',
      durationMinutes: json['duration_minutes'] as int? ?? 3,
      startTime: json['start_time'] != null
          ? DateTime.parse(json['start_time'] as String)
          : null,
      endTime: json['end_time'] != null
          ? DateTime.parse(json['end_time'] as String)
          : null,
      isActive: json['is_active'] as bool? ?? false,
      isCompleted: json['is_completed'] as bool? ?? false,
      summary: json['summary'] as String?,
    );
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
    bool? isActive,
    bool? isCompleted,
    String? summary,
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
      isActive: isActive ?? this.isActive,
      isCompleted: isCompleted ?? this.isCompleted,
      summary: summary ?? this.summary,
    );
  }
}
