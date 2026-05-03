class UserModel {
  final String? id;
  final String? nickname;
  final String? avatar;
  final String? phone;
  final String? email;
  final bool isVisitor;
  final DateTime? createdAt;

  UserModel({
    this.id,
    this.nickname,
    this.avatar,
    this.phone,
    this.email,
    this.isVisitor = false,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String?,
      nickname: json['nickname'] as String?,
      avatar: json['avatar'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      isVisitor: json['is_visitor'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (nickname != null) 'nickname': nickname,
      if (avatar != null) 'avatar': avatar,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      'is_visitor': isVisitor,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? nickname,
    String? avatar,
    String? phone,
    String? email,
    bool? isVisitor,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      avatar: avatar ?? this.avatar,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      isVisitor: isVisitor ?? this.isVisitor,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
