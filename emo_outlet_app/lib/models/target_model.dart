class TargetModel {
  final String? id;
  final String name;
  final String type;
  final String? appearance;
  final String? personality;
  final String? relationship;
  final String style;
  final String? avatarUrl;
  final bool isHidden;
  final DateTime? createdAt;

  TargetModel({
    this.id,
    required this.name,
    required this.type,
    this.appearance,
    this.personality,
    this.relationship,
    this.style = '漫画',
    this.avatarUrl,
    this.isHidden = false,
    this.createdAt,
  });

  factory TargetModel.fromJson(Map<String, dynamic> json) {
    return TargetModel(
      id: json['id'] as String?,
      name: json['name'] as String? ?? '',
      type: json['type'] as String? ?? 'other',
      appearance: json['appearance'] as String?,
      personality: json['personality'] as String?,
      relationship: json['relationship'] as String?,
      style: json['style'] as String? ?? '漫画',
      avatarUrl: json['avatar_url'] as String?,
      isHidden: json['is_hidden'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'type': type,
      if (appearance != null) 'appearance': appearance,
      if (personality != null) 'personality': personality,
      if (relationship != null) 'relationship': relationship,
      'style': style,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      'is_hidden': isHidden,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }

  TargetModel copyWith({
    String? id,
    String? name,
    String? type,
    String? appearance,
    String? personality,
    String? relationship,
    String? style,
    String? avatarUrl,
    bool? isHidden,
    DateTime? createdAt,
  }) {
    return TargetModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      appearance: appearance ?? this.appearance,
      personality: personality ?? this.personality,
      relationship: relationship ?? this.relationship,
      style: style ?? this.style,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isHidden: isHidden ?? this.isHidden,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get typeLabel {
    const labels = {
      'boss': '老板',
      'colleague': '同事',
      'partner': '伴侣',
      'family': '家人',
      'friend': '朋友',
      'other': '其他',
    };
    return labels[type] ?? type;
  }
}
