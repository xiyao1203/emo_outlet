enum MessageSender { user, ai }

class MessageModel {
  final String? id;
  final String sessionId;
  final String content;
  final MessageSender sender;
  final String? dialect;
  final DateTime? timestamp;
  final bool isSystem;

  MessageModel({
    this.id,
    required this.sessionId,
    required this.content,
    required this.sender,
    this.dialect,
    this.timestamp,
    this.isSystem = false,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String?,
      sessionId: json['session_id'] as String? ?? '',
      content: json['content'] as String? ?? '',
      sender: json['sender'] == 'ai' ? MessageSender.ai : MessageSender.user,
      dialect: json['dialect'] as String?,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : null,
      isSystem: json['is_system'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'session_id': sessionId,
      'content': content,
      'sender': sender == MessageSender.ai ? 'ai' : 'user',
      if (dialect != null) 'dialect': dialect,
      if (timestamp != null) 'timestamp': timestamp!.toIso8601String(),
      'is_system': isSystem,
    };
  }

  bool get isUser => sender == MessageSender.user;
  bool get isAi => sender == MessageSender.ai;
}
