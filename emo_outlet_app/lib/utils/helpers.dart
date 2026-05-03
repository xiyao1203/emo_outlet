import 'package:flutter/material.dart';
import '../../config/theme.dart';

/// 通用工具类
class Helpers {
  /// 获取名字前两个字符作为头像占位
  static String getInitials(String? name) {
    if (name == null || name.isEmpty) return '?';
    if (name.length >= 2) return name.substring(0, 2);
    return name[0];
  }

  /// 格式化持续时间
  static String formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// 格式化日期
  static String formatDate(DateTime date) {
    return '${date.month}月${date.day}日';
  }

  /// 格式化相对时间
  static String formatRelativeTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return '刚刚';
    if (diff.inMinutes < 60) return '${diff.inMinutes}分钟前';
    if (diff.inHours < 24) return '${diff.inHours}小时前';
    if (diff.inDays < 7) return '${diff.inDays}天前';
    return formatDate(date);
  }
}

/// 内容安全过滤工具
class ContentFilter {
  /// 危险内容关键词（前端前置过滤）
  static const List<String> _blockedWords = [
    '自杀', '跳楼', '上吊', '割腕', '服毒', '杀人',
    '贩毒', '吸毒', '毒品', '强奸', '抢劫', '炸弹',
    '恐怖袭击', '贩毒', '卖淫', '裸聊', '约炮',
  ];

  /// 检查输入是否安全
  /// 返回 null 表示安全，返回 String 表示提示信息
  static String? checkInput(String text) {
    if (text.trim().isEmpty) return '请输入内容';
    if (text.length > 5000) return '内容过长，请控制在5000字以内';

    for (final word in _blockedWords) {
      if (text.contains(word)) {
        return '输入内容包含不合适的内容，请重新输入';
      }
    }

    return null;
  }

  /// 检查内容是否包含禁词（不提示，直接阻止发送）
  static bool containsBlockedContent(String text) {
    for (final word in _blockedWords) {
      if (text.contains(word)) return true;
    }
    return false;
  }
}

/// SnackBar 工具
class SnackBarUtils {
  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green,
      ),
    );
  }

  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.emotionAnger,
      ),
    );
  }

  static void showInfo(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
