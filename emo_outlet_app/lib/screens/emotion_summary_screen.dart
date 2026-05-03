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
    final targetName = sessionProvider.currentSession?.targetName ?? '未知对象';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('情绪总结', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF333333))),
        centerTitle: true,
        backgroundColor: const Color(0xFFF8F8F8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF666666)),
          onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(children: [
                Text('对 $targetName 的情绪分析', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF333333)), textAlign: TextAlign.center),
                const SizedBox(height: 4),
                Text(report?.formattedDate ?? '', style: const TextStyle(fontSize: 13, color: Color(0xFF999999))),
              ]),
            ),
            const SizedBox(height: 24),

            if (emotions.isNotEmpty) ...[
              _buildCard(
                child: Column(children: [
                  const Text('情绪分布', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF333333))),
                  const SizedBox(height: 16),
                  EmotionPieChart(emotions: emotions),
                ]),
              ),
              const SizedBox(height: 16),
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('情绪强度', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF333333))),
                    const SizedBox(height: 16),
                    ...emotions.entries.map((entry) {
                      Color color;
                      switch (entry.key) {
                        case '愤怒': color = AppColors.emotionAnger; break;
                        case '焦虑': color = AppColors.emotionAnxiety; break;
                        case '悲伤': color = AppColors.emotionSadness; break;
                        case '疲惫': color = AppColors.emotionPower; break;
                        case '无奈': color = AppColors.emotionCalm; break;
                        default: color = AppColors.emotionCalm;
                      }
                      return EmotionBar(label: entry.key, value: entry.value, color: color);
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            if (report?.topKeyword != null)
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('高频词', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF333333))),
                    const SizedBox(height: 12),
                    Wrap(spacing: 8, runSpacing: 8, children: [_keywordChip(report!.topKeyword!)]),
                  ],
                ),
              ),
            if (report?.topKeyword != null) const SizedBox(height: 16),

            if (report?.suggestion != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.lightbulb_outline, color: AppColors.primary, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(report!.suggestion!, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.5)),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  final session = sessionProvider.currentSession;
                  if (session?.id != null) {
                    emotionProvider.generatePoster(session!.id!);
                  }
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PosterPreviewScreen()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 4,
                  shadowColor: AppColors.accent.withOpacity(0.3),
                ),
                child: const Text('生成专属海报', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: child,
    );
  }

  Widget _keywordChip(String keyword) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(keyword, style: const TextStyle(fontSize: 14, color: AppColors.primary, fontWeight: FontWeight.w500)),
    );
  }
}
