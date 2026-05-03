class EmotionReportModel {
  final String? id;
  final String sessionId;
  final Map<String, double> emotions;
  final String? topKeyword;
  final String? suggestion;
  final String? posterUrl;
  final DateTime? createdAt;

  EmotionReportModel({
    this.id,
    required this.sessionId,
    required this.emotions,
    this.topKeyword,
    this.suggestion,
    this.posterUrl,
    this.createdAt,
  });

  factory EmotionReportModel.fromJson(Map<String, dynamic> json) {
    final emotionsRaw = json['emotions'] as Map<String, dynamic>? ?? {};
    final emotions = <String, double>{};
    emotionsRaw.forEach((key, value) {
      emotions[key] = (value as num).toDouble();
    });

    return EmotionReportModel(
      id: json['id'] as String?,
      sessionId: json['session_id'] as String? ?? '',
      emotions: emotions,
      topKeyword: json['top_keyword'] as String?,
      suggestion: json['suggestion'] as String?,
      posterUrl: json['poster_url'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  String get dominantEmotion {
    if (emotions.isEmpty) return '平静';
    return emotions.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  double get dominantEmotionValue {
    if (emotions.isEmpty) return 0;
    return emotions.values.reduce((a, b) => a > b ? a : b);
  }

  String get formattedDate {
    if (createdAt == null) return '';
    return '${createdAt!.month}月${createdAt!.day}日';
  }
}
