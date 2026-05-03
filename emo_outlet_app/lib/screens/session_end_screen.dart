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
    final targetName = sessionProvider.currentSession?.targetName ?? '未知对象';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              // 闹钟图标
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.alarm, size: 56, color: AppColors.primary),
              ),
              const SizedBox(height: 32),
              const Text('时间到啦！', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Color(0xFF333333))),
              const SizedBox(height: 12),
              Text(
                '对 $targetName 的情绪释放结束',
                style: const TextStyle(fontSize: 15, color: Color(0xFF999999)),
              ),
              const SizedBox(height: 4),
              const Text(
                '来看看你的情绪分析吧',
                style: const TextStyle(fontSize: 15, color: Color(0xFF999999)),
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
                      context.read<EmotionProvider>().generateReport(session!.id!);
                    }
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const EmotionSummaryScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 4,
                    shadowColor: AppColors.primary.withOpacity(0.3),
                  ),
                  child: const Text('结束并查看', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
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
