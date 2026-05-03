class EmotionReportModel {
  final String? id;
  final String sessionId;
  final String? title;
  final Map<String, double> emotions;
  final String? emotionType;
  final double emotionIntensity;
  final String? topKeyword;
  final String? suggestion;
  final String? posterUrl;
  final String? posterData;
  final DateTime? createdAt;

  // 周期报告字段
  final int totalSessions;
  final int totalDurationMinutes;

  EmotionReportModel({
    this.id,
    required this.sessionId,
    this.title,
    required this.emotions,
    this.emotionType,
    this.emotionIntensity = 0,
    this.topKeyword,
    this.suggestion,
    this.posterUrl,
    this.posterData,
    this.createdAt,
    this.totalSessions = 0,
    this.totalDurationMinutes = 0,
  });

  /// 从海报响应解析（POST /api/posters/generate / GET /api/posters/{id}）
  factory EmotionReportModel.fromJson(Map<String, dynamic> json) {
    // 解析关键词 JSON 字符串
    String? topKeyword;
    if (json['keywords'] != null) {
      try {
        final list = _parseKeywords(json['keywords'] as String);
        if (list.isNotEmpty) topKeyword = list.first;
      } catch (_) {
        topKeyword = json['keywords'] as String?;
      }
    }

    final emotionType = json['emotion_type'] as String? ?? '平静';
    final intensity = (json['emotion_intensity'] as num?)?.toDouble() ?? 0;
    final emotions = <String, double>{};
    if (emotionType != '平静' || intensity > 0) {
      emotions[emotionType] = intensity;
    }

    return EmotionReportModel(
      id: json['id'] as String?,
      sessionId: json['session_id'] as String? ?? '',
      title: json['title'] as String?,
      emotions: emotions,
      emotionType: emotionType,
      emotionIntensity: intensity,
      topKeyword: topKeyword,
      suggestion: json['suggestion'] as String?,
      posterUrl: json['poster_url'] as String?,
      posterData: json['poster_data'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  /// 从周期报告解析（GET /api/posters/report/overview）
  factory EmotionReportModel.fromOverviewJson(Map<String, dynamic> json) {
    final distributionRaw =
        json['emotion_distribution'] as Map<String, dynamic>? ?? {};
    final emotions = <String, double>{};
    distributionRaw.forEach((key, value) {
      emotions[key] = (value as num).toDouble();
    });

    return EmotionReportModel(
      id: json['id'] as String?,
      sessionId: '',
      emotions: emotions,
      emotionType: json['dominant_emotion'] as String?,
      suggestion: json['suggestion'] as String?,
      totalSessions: json['total_sessions'] as int? ?? 0,
      totalDurationMinutes: json['total_duration_minutes'] as int? ?? 0,
    );
  }

  /// 获取主导情绪
  String get dominantEmotion {
    if (emotionType != null && emotionType != '平静') return emotionType!;
    if (emotions.isEmpty) return '平静';
    return emotions.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  double get dominantEmotionValue {
    if (emotionIntensity > 0) return emotionIntensity;
    if (emotions.isEmpty) return 0;
    return emotions.values.reduce((a, b) => a > b ? a : b);
  }

  String get formattedDate {
    if (createdAt == null) return '';
    return '${createdAt!.month}月${createdAt!.day}日';
  }

  static List<String> _parseKeywords(String jsonStr) {
    // 简单解析：去掉 [ ] " 后按逗号分割
    final cleaned = jsonStr
        .replaceAll('[', '')
        .replaceAll(']', '')
        .replaceAll('"', '')
        .replaceAll("'", '')
        .trim();
    if (cleaned.isEmpty) return [];
    return cleaned.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
  }
}
