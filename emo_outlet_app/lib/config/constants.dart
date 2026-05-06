class AppConstants {
  AppConstants._();

  static const String appName = '情绪释放';
  static const String appNameEn = 'Emo Outlet';
  static const String appVersion = '1.0.0';

  static const String baseUrl = 'http://localhost:8686/api';
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  static const List<int> sessionDurations = [1, 3, 5, 10];
  static const int defaultSessionDuration = 5;

  static const Map<String, String> dialectMap = {
    '普通话': 'mandarin',
    '粤语': 'cantonese',
    '四川话': 'sichuan',
    '东北话': 'northeastern',
    '上海话': 'shanghainese',
  };

  static const Map<String, String> dialectLabelMap = {
    'mandarin': '普通话',
    'cantonese': '粤语',
    'sichuan': '四川话',
    'northeastern': '东北话',
    'shanghainese': '上海话',
  };

  static const List<String> dialects = [
    '普通话',
    '粤语',
    '四川话',
    '东北话',
    '上海话',
  ];

  static const Map<String, String> chatStyleMap = {
    '嘴硬型': 'stubborn',
    '道歉型': 'apologetic',
    '冷漠型': 'cold',
    '阴阳型': 'sarcastic',
    '理性型': 'rational',
  };

  static const Map<String, String> chatStyles = {
    '嘴硬型': '嘴上别扭，但能听见你的委屈',
    '道歉型': '更柔和，会主动安抚和接住情绪',
    '冷漠型': '克制疏离，适合不想被过度哄着',
    '阴阳型': '带一点反讽感，更像真实对线',
    '理性型': '偏分析和拆解，适合想说清重点',
  };

  static const List<String> emotionTypes = [
    '愤怒',
    '悲伤',
    '焦虑',
    '疲惫',
    '无奈',
    '平静',
  ];

  static const Map<String, int> emotionColors = {
    '愤怒': 0xFFE57373,
    '悲伤': 0xFF64B5F6,
    '焦虑': 0xFFFFB74D,
    '疲惫': 0xFFA1887F,
    '无奈': 0xFF90A4AE,
    '平静': 0xFF81C784,
  };

  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String onboardingKey = 'onboarding_complete';
  static const String voiceAutoplayKey = 'voice_autoplay_enabled';
  static const String voiceOptionKey = 'tts_voice_option';

  static const int maxDailyFreeSessions = 3;
  static const int maxMessageLength = 5000;
  static const int maxTargetsPerUser = 20;

  static const String complianceAgreedKey = 'compliance_agreed';
  static const String complianceVersion = '1.0.0';
  static const String ageRangeKey = 'user_age_range';
  static const List<String> ageRangeOptions = ['<14', '14-18', '>18'];

  static const Map<String, String> ttsVoiceLabels = {
    'alloy': '晴暖',
    'nova': '轻柔',
    'sage': '知性',
    'shimmer': '元气',
    'echo': '沉稳',
  };

  static const int navIndexHome = 0;
  static const int navIndexTarget = 1;
  static const int navIndexHistory = 2;
  static const int navIndexProfile = 3;
}
