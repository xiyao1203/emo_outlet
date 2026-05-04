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
    '嘴硬型': '不轻易服软',
    '道歉型': '更温和缓冲',
    '冷漠型': '偏克制简短',
    '阴阳型': '会带点反讽',
    '理性型': '偏讲逻辑',
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

  static const int maxDailyFreeSessions = 3;
  static const int maxMessageLength = 5000;
  static const int maxTargetsPerUser = 20;

  static const String complianceAgreedKey = 'compliance_agreed';
  static const String complianceVersion = '1.0.0';
  static const String ageRangeKey = 'user_age_range';
  static const List<String> ageRangeOptions = ['<14', '14-18', '>18'];

  static const int navIndexHome = 0;
  static const int navIndexTarget = 1;
  static const int navIndexHistory = 2;
  static const int navIndexProfile = 3;
}
