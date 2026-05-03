import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../config/theme.dart';
import '../providers/app_providers.dart';
import '../widgets/common/avatar_circle.dart';

class PosterPreviewScreen extends StatelessWidget {
  const PosterPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final emotionProvider = context.watch<EmotionProvider>();
    final sessionProvider = context.watch<SessionProvider>();
    final posterData = emotionProvider.posterData;
    final posterUrl = emotionProvider.posterUrl;
    final report = emotionProvider.currentReport;
    final targetName =
        sessionProvider.currentSession?.targetName ?? '未知对象';
    final dominantEmotion = report?.dominantEmotion ?? '平静';
    final dominantValue =
        (report?.dominantEmotionValue ?? 0).toStringAsFixed(0);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('专属海报'),
        actions: [
          IconButton(
            onPressed: () async {
              // 下载/保存海报
              if (posterUrl != null) {
                HapticFeedback.mediumImpact();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('海报已保存到相册'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            icon: const Icon(Icons.download_outlined),
          ),
          IconButton(
            onPressed: () async {
              // 分享海报
              try {
                await SharePlus.instance.share(
                  ShareParams(
                    text: '我刚在「情绪出口」释放了情绪！\n'
                        '今天的主要情绪是 $dominantEmotion，强度 $dominantValue%\n'
                        '说出来好多了！😤➡️😌',
                  ),
                );
              } catch (e) {
                // share_plus 不可用时 fallback
                await Clipboard.setData(
                  ClipboardData(
                    text: '我刚在「情绪出口」释放了情绪！\n'
                        '主要情绪：$dominantEmotion $dominantValue%\n'
                        '说出来好多了！😤➡️😌',
                  ),
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('分享内容已复制到剪贴板'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            icon: const Icon(Icons.share_outlined),
          ),
        ],
      ),
      body: Padding(
        padding: AppSpacing.screenPadding,
        child: Column(
          children: [
            const Spacer(),

            // 海报卡片
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxHeight: 460),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.xl),
                gradient: LinearGradient(
                  colors: [
                    _emotionGradientColor(dominantEmotion),
                    _emotionGradientColor(dominantEmotion).withOpacity(0.8),
                    const Color(0xFFFFD4B0),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 虚拟对象
                    if (posterData != null && posterData.startsWith('data:'))
                      ClipOval(
                        child: Image.memory(
                          Base64Decoder().convert(
                            posterData.split(',')[1],
                          ),
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _defaultAvatar(targetName),
                        ),
                      )
                    else
                      _defaultAvatar(targetName),
                    const SizedBox(height: 20),

                    // 心情文案
                    Text(
                      report?.title ?? '说出来好多了！',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 情绪关键词
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$dominantEmotion $dominantValue%',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 插画装饰
                    const Text(
                      '😤➡️😌',
                      style: TextStyle(fontSize: 36),
                    ),
                    const SizedBox(height: 16),

                    // 时间
                    Text(
                      report?.formattedDate ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),

            // 使用按钮
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context)
                      .popUntil((route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                ),
                child: const Text('立即使用', style: TextStyle(fontSize: 17)),
              ),
            ),
            const SizedBox(height: 20),

            // 底部提示
            const Text(
              '❤️ 不会展示原始对话内容',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textHint,
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _defaultAvatar(String name) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          name.length >= 2 ? name.substring(0, 2) : name[0],
          style: const TextStyle(
            fontSize: 32,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Color _emotionGradientColor(String emotion) {
    switch (emotion) {
      case '愤怒':
        return const Color(0xFFE57373);
      case '悲伤':
        return const Color(0xFF64B5F6);
      case '焦虑':
        return const Color(0xFFFFB74D);
      case '疲惫':
        return const Color(0xFFA1887F);
      case '无奈':
        return const Color(0xFF90A4AE);
      default:
        return const Color(0xFFFF7A56);
    }
  }
}
