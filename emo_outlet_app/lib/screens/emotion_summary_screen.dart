import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/app_providers.dart';
import '../widgets/common/emotion_bar.dart';
import 'poster_preview_screen.dart';

class EmotionSummaryScreen extends StatelessWidget {
  const EmotionSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final emotionProvider = context.watch<EmotionProvider>();
    final sessionProvider = context.watch<SessionProvider>();
    final report = emotionProvider.currentReport;
    final emotions = report?.emotions ?? {};
    final targetName =
        sessionProvider.currentSession?.targetName ?? '未知对象';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('情绪总结'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context)
              .popUntil((route) => route.isFirst),
        ),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            Center(
              child: Column(
                children: [
                  Text(
                    '对 $targetName 的情绪分析',
                    style: AppTextStyles.heading2,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    report?.formattedDate ?? '',
                    style: AppTextStyles.label,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // 主导情绪
            if (emotions.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: AppSpacing.cardPadding,
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  boxShadow: [AppColors.cardShadow],
                ),
                child: Column(
                  children: [
                    const Text(
                      '情绪分布',
                      style: AppTextStyles.heading3,
                    ),
                    const SizedBox(height: 20),
                    EmotionPieChart(emotions: emotions),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 情绪条
              Container(
                width: double.infinity,
                padding: AppSpacing.cardPadding,
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  boxShadow: [AppColors.cardShadow],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '情绪强度',
                      style: AppTextStyles.heading3,
                    ),
                    const SizedBox(height: 16),
                    ...emotions.entries.map((entry) {
                      Color color;
                      switch (entry.key) {
                        case '愤怒':
                          color = AppColors.emotionAnger;
                          break;
                        case '焦虑':
                          color = AppColors.emotionAnxiety;
                          break;
                        case '悲伤':
                          color = AppColors.emotionSadness;
                          break;
                        case '疲惫':
                          color = AppColors.emotionPower;
                          break;
                        case '无奈':
                          color = AppColors.emotionCalm;
                          break;
                        default:
                          color = AppColors.emotionCalm;
                      }
                      return EmotionBar(
                        label: entry.key,
                        value: entry.value,
                        color: color,
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // 关键词
            if (report?.topKeyword != null)
              Container(
                width: double.infinity,
                padding: AppSpacing.cardPadding,
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  boxShadow: [AppColors.cardShadow],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('高频词', style: AppTextStyles.heading3),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _keywordChip(report!.topKeyword!),
                      ],
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),

            // 建议
            if (report?.suggestion != null)
              Container(
                width: double.infinity,
                padding: AppSpacing.cardPadding,
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.lightbulb_outline,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        report!.suggestion!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 40),

            // 生成海报按钮
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  final session = sessionProvider.currentSession;
                  if (session?.id != null) {
                    emotionProvider.generatePoster(session!.id!);
                  }
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const PosterPreviewScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                ),
                child: const Text(
                  '生成专属海报',
                  style: TextStyle(fontSize: 17),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _keywordChip(String keyword) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        keyword,
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
