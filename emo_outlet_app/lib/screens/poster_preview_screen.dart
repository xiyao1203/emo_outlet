import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/app_providers.dart';
import '../widgets/common/avatar_circle.dart';

class PosterPreviewScreen extends StatelessWidget {
  const PosterPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final emotionProvider = context.watch<EmotionProvider>();
    final sessionProvider = context.watch<SessionProvider>();
    final report = emotionProvider.currentReport;
    final targetName =
        sessionProvider.currentSession?.targetName ?? '未知对象';
    final dominantEmotion = report?.dominantEmotion ?? '平静';
    final dominantValue = report?.dominantEmotionValue?.toStringAsFixed(0) ?? '0';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('专属海报'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.share_outlined),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.download_outlined),
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
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFFF7A56),
                    Color(0xFFFFB088),
                    Color(0xFFFFD4B0),
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
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          targetName.length >= 2
                              ? targetName.substring(0, 2)
                              : targetName[0],
                          style: const TextStyle(
                            fontSize: 32,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 心情文案
                    const Text(
                      '说出来好多了！',
                      style: TextStyle(
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
                onPressed: () {},
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
}
