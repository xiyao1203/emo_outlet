class HistoryRecordModel {
  const HistoryRecordModel({
    required this.id,
    required this.name,
    required this.avatar,
    required this.mode,
    required this.timestamp,
    required this.durationMinutes,
    required this.emotions,
    required this.releaseRate,
    required this.summary,
    required this.keywords,
    required this.modeLabel,
    required this.language,
    required this.posterTitle,
    required this.posterSubtitle,
  });

  final String id;
  final String name;
  final String avatar;
  final String mode;
  final DateTime timestamp;
  final int durationMinutes;
  final List<String> emotions;
  final int releaseRate;
  final String summary;
  final List<String> keywords;
  final String modeLabel;
  final String language;
  final String posterTitle;
  final String posterSubtitle;

  bool get isDual => mode == 'dual';
}
