class AppConstants {
  AppConstants._();

  // App 信息
  static const String appName = '情绪出口';
  static const String appNameEn = 'Emo Outlet';
  static const String appVersion = '1.0.0';

  // API
  static const String baseUrl = 'http://localhost:8080/api';
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // 会话
  static const List<int> sessionDurations = [1, 3, 5, 10];
  static const int defaultSessionDuration = 3;

  // 方言列表
  static const List<String> dialects = [
    '普通话',
    '粤语',
    '四川话',
    '东北话',
    '上海话',
  ];

  // 对话风格
  static const Map<String, String> chatStyles = {
    '嘴硬型': '不认错',
    '道歉型': '软化冲突',
    '冷漠型': '不在乎',
    '阴阳型': '带点嘲讽',
    '理性型': '讲道理',
  };

  // 目标类型
  static const List<String> targetTypes = [
    'boss',
    'colleague',
    'partner',
    'family',
    'friend',
    'other',
  ];

  // 目标类型中文映射
  static const Map<String, String> targetTypeLabels = {
    'boss': '老板',
    'colleague': '同事',
    'partner': '伴侣',
    'family': '家人',
    'friend': '朋友',
    'other': '其他',
  };

  // 对象形象风格
  static const List<String> avatarStyles = [
    '漫画',
    '写实',
    'Q版',
    '简约',
  ];

  // 情绪类型
  static const List<String> emotionTypes = [
    '愤怒',
    '焦虑',
    '悲伤',
    '力量',
    '平静',
  ];

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
