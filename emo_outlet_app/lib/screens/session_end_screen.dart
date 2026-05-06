import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_providers.dart';
import '../widgets/auth/auth_visuals.dart';
import '../widgets/common/emo_ui.dart';
import 'emotion_report_screen.dart';

class SessionEndScreen extends StatelessWidget {
  const SessionEndScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sessionProvider = context.read<SessionProvider>();
    final targetName = sessionProvider.currentSession?.targetName ?? '当前对象';

    return EmoPageScaffold(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: EmoSectionCard(
              radius: 32,
              padding: const EdgeInsets.fromLTRB(22, 28, 22, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 104,
                    height: 104,
                    decoration: BoxDecoration(
                      color: AuthPalette.coral.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.alarm_rounded,
                      size: 48,
                      color: AuthPalette.coral,
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    '时间到了',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      color: AuthPalette.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '你和 $targetName 的这次情绪释放已经结束。',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: AuthPalette.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    '看看这次情绪总结，整理一下刚刚说出来的心情。',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: AuthPalette.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    child: GradientPrimaryButton(
                      text: '结束并查看总结',
                      height: 54,
                      fontSize: 16,
                      onTap: () {
                        final session = sessionProvider.currentSession;
                        if (session?.id != null) {
                          context.read<EmotionProvider>().generateReport(session!.id!);
                        }
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (_) => const EmotionReportScreen(),
                          ),
                          (route) => route.isFirst,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
