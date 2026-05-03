class UserModel {
  final String? id;
  final String? nickname;
  final String? avatarUrl;
  final String? phone;
  final String? email;
  final bool isVisitor;
  final int dailySessionCount;
  final DateTime? createdAt;

  UserModel({
    this.id,
    this.nickname,
    this.avatarUrl,
    this.phone,
    this.email,
    this.isVisitor = false,
    this.dailySessionCount = 0,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String?,
      nickname: json['nickname'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      isVisitor: json['is_visitor'] as bool? ?? false,
      dailySessionCount: json['daily_session_count'] as int? ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (nickname != null) 'nickname': nickname,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      'is_visitor': isVisitor,
      'daily_session_count': dailySessionCount,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? nickname,
    String? avatarUrl,
    String? phone,
    String? email,
    bool? isVisitor,
    int? dailySessionCount,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      isVisitor: isVisitor ?? this.isVisitor,
      dailySessionCount: dailySessionCount ?? this.dailySessionCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
