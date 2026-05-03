import 'package:shared_preferences/shared_preferences.dart';
import '../config/constants.dart';

/// 合规配置中心
/// 管理合规版本号、敏感词本地缓存、合规检查等
class ComplianceManager {
  static final ComplianceManager _instance = ComplianceManager._internal();
  factory ComplianceManager() => _instance;
  ComplianceManager._internal();

  /// 合规版本号
  static const String currentVersion = '1.0.0';

  /// 用户是否已同意当前版本的协议
  Future<bool> hasAgreedCurrentVersion() async {
    final prefs = await SharedPreferences.getInstance();
    final agreed = prefs.getBool(AppConstants.complianceAgreedKey) ?? false;
    final version = prefs.getString('compliance_version') ?? '';
    return agreed && version == currentVersion;
  }

  /// 保存同意记录
  Future<void> saveConsent(String ageRange) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.complianceAgreedKey, true);
    await prefs.setString('compliance_version', currentVersion);
    if (ageRange.isNotEmpty) {
      await prefs.setString(AppConstants.ageRangeKey, ageRange);
    }
  }

  /// 获取已保存的年龄段
  Future<String?> getAgeRange() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.ageRangeKey);
  }

  /// 检查是否未成年
  Future<bool> isMinor() async {
    final range = await getAgeRange();
    return range == '<14' || range == '14-18';
  }

  /// 前端敏感词简易检查（基础过滤）
  /// 返回 true 表示内容安全，false 表示包含敏感词
  bool quickCheck(String text) {
    final basicSensitive = [
      '自杀', '跳楼', '上吊', '割腕', '服毒', '杀人',
      '贩毒', '吸毒', '毒品', '强奸', '抢劫', '炸弹',
    ];
    for (final word in basicSensitive) {
      if (text.contains(word)) return false;
    }
    return true;
  }

  /// 获取合规提示消息
  String getLimitMessage(String ageRange) {
    if (ageRange == '<14') {
      return '你的每日使用次数已用完。14岁以下用户每日可会话1次，注意休息哦！';
    } else if (ageRange == '14-18') {
      return '今天的次数已用完。14-18岁用户每日可会话2次，明天再来吧！';
    } else {
      return '今天的免费次数已用完。每日可免费会话3次，明天再来吧！';
    }
  }
}
