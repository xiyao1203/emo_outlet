class UserModel {
  final String? id;
  final String? nickname;
  final String? avatarUrl;
  final String? phone;
  final String? email;
  final bool isVisitor;
  final int dailySessionCount;
  final DateTime? createdAt;
  // 合规字段
  final String? ageRange;
  final bool isBanned;
  final bool isAdmin;

  UserModel({
    this.id,
    this.nickname,
    this.avatarUrl,
    this.phone,
    this.email,
    this.isVisitor = false,
    this.dailySessionCount = 0,
    this.createdAt,
    this.ageRange,
    this.isBanned = false,
    this.isAdmin = false,
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
      ageRange: json['age_range'] as String?,
      isBanned: json['is_banned'] as bool? ?? false,
      isAdmin: json['is_admin'] as bool? ?? false,
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
      if (ageRange != null) 'age_range': ageRange,
      'is_banned': isBanned,
      'is_admin': isAdmin,
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
    String? ageRange,
    bool? isBanned,
    bool? isAdmin,
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
      ageRange: ageRange ?? this.ageRange,
      isBanned: isBanned ?? this.isBanned,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }
}
