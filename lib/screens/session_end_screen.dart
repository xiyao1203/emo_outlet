import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/app_providers.dart';
import 'emotion_summary_screen.dart';

class SessionEndScreen extends StatelessWidget {
  const SessionEndScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sessionProvider = context.read<SessionProvider>();
    final targetName =
        sessionProvider.currentSession?.targetName ?? '未知对象';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.screenPadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // 闹钟图标
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.alarm,
                  size: 48,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),

              // 文案
              const Text(
                '时间到啦！',
                style: AppTextStyles.displayMedium,
              ),
              const SizedBox(height: 12),

              Text(
                '对 $targetName 的情绪释放结束',
                style: AppTextStyles.bodySmall,
              ),
              const SizedBox(height: 8),

              Text(
                '来看看你的情绪分析吧',
                style: AppTextStyles.bodySmall,
              ),

              const Spacer(flex: 2),

              // 按钮
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    final session = sessionProvider.currentSession;
                    if (session?.id != null) {
                      context
                          .read<EmotionProvider>()
                          .generateReport(session!.id!);
                    }
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const EmotionSummaryScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                  ),
                  child: const Text(
                    '结束并查看',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}
