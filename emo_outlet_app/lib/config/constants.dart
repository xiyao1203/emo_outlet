class AppConstants {
  AppConstants._();

  // App 信息
  static const String appName = '情绪出口';
  static const String appNameEn = 'Emo Outlet';
  static const String appVersion = '1.0.0';

  // API
  static const String baseUrl = 'http://localhost:8000/api';
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // 会话时长（分钟）
  static const List<int> sessionDurations = [1, 3, 5, 10];
  static const int defaultSessionDuration = 3;

  // 方言列表（中文显示 → 后端代码）
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

  // 对话风格（中文显示 → 后端代码）
  static const Map<String, String> chatStyleMap = {
    '嘴硬型': 'stubborn',
    '道歉型': 'apologetic',
    '冷漠型': 'cold',
    '阴阳型': 'sarcastic',
    '理性型': 'rational',
  };

  // 对话风格
  static const Map<String, String> chatStyles = {
    '嘴硬型': '不认错',
    '道歉型': '软化冲突',
    '冷漠型': '不在乎',
    '阴阳型': '带点嘲讽',
    '理性型': '讲道理',
  };

  // 情绪类型（与后端 emotion_service 保持一致）
  static const List<String> emotionTypes = [
    '愤怒',
    '悲伤',
    '焦虑',
    '疲惫',
    '无奈',
    '平静',
  ];

  // 情绪颜色
  static const Map<String, int> emotionColors = {
    '愤怒': 0xFFE57373,
    '悲伤': 0xFF64B5F6,
    '焦虑': 0xFFFFB74D,
    '疲惫': 0xFFA1887F,
    '无奈': 0xFF90A4AE,
    '平静': 0xFF81C784,
  };

  // 存储 key
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String onboardingKey = 'onboarding_complete';

  // 限制
  static const int maxDialyFreeSessions = 3;
  static const int maxMessageLength = 5000;
  static const int maxTargetsPerUser = 20;

  // 底部导航栏
  static const int navIndexHome = 0;
  static const int navIndexEmotion = 1;
  static const int navIndexMain = 2;
  static const int navIndexHistory = 3;
  static const int navIndexProfile = 4;
}
