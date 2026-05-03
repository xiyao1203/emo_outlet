enum MessageSender { user, ai }

class MessageModel {
  final String? id;
  final String sessionId;
  final String content;
  final MessageSender sender;
  final String? dialect;
  final DateTime? createdAt;
  final bool isSystem;
  final bool isSensitive;
  final String? emotionType;
  final int? emotionIntensity;

  MessageModel({
    this.id,
    required this.sessionId,
    required this.content,
    required this.sender,
    this.dialect,
    this.createdAt,
    this.isSystem = false,
    this.isSensitive = false,
    this.emotionType,
    this.emotionIntensity,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String?,
      sessionId: json['session_id'] as String? ?? '',
      content: json['content'] as String? ?? '',
      sender: json['sender'] == 'ai' ? MessageSender.ai : MessageSender.user,
      dialect: json['dialect'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      isSystem: json['is_system'] as bool? ?? false,
      isSensitive: json['is_sensitive'] as bool? ?? false,
      emotionType: json['emotion_type'] as String?,
      emotionIntensity: json['emotion_intensity'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'session_id': sessionId,
      'content': content,
      'sender': sender == MessageSender.ai ? 'ai' : 'user',
      if (dialect != null) 'dialect': dialect,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      'is_system': isSystem,
      'is_sensitive': isSensitive,
    };
  }

  bool get isUser => sender == MessageSender.user;
  bool get isAi => sender == MessageSender.ai;
}
