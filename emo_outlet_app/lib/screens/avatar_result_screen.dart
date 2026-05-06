import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_providers.dart';
import '../widgets/auth/auth_visuals.dart';
import '../widgets/common/emo_ui.dart';
import 'generate_avatar_screen.dart';
import 'target_detail_screen.dart';

class AvatarResultScreen extends StatelessWidget {
  const AvatarResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final target = context.watch<TargetProvider>().currentTarget;
    if (target == null) {
      return const GenerateAvatarScreen();
    }

    return EmoPageScaffold(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
        child: Column(
          children: [
            Row(
              children: [
                EmoRoundIconButton(
                  icon: Icons.chevron_left_rounded,
                  onTap: () => Navigator.of(context).pop(),
                ),
                const Spacer(),
                const Text(
                  '生成结果',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                const SizedBox(width: 46),
              ],
            ),
            const Spacer(),
            EmoSectionCard(
              radius: 34,
              padding: const EdgeInsets.fromLTRB(22, 28, 22, 22),
              child: Column(
                children: [
                  Container(
                    width: 248,
                    height: 248,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(42),
                      gradient: const LinearGradient(
                        colors: [Color(0x1AFFFFFF), Color(0x26FFD7C7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: EmoAvatar(
                        label: avatarEmojiByType(target.type),
                        background: avatarBgByType(target.type),
                        imageUrl: target.avatarUrl,
                        size: 220,
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    '${target.name} 的形象已经准备好了',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AuthPalette.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '风格：${target.style} · 可以继续微调，也可以直接确认使用。',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.45,
                      color: AuthPalette.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    child: GradientPrimaryButton(
                      text: '确认使用',
                      height: 54,
                      fontSize: 16,
                      onTap: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => TargetDetailScreen(target: target),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: EmoGradientOutlineButton(
                          text: '重新生成',
                          onTap: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (_) => const GenerateAvatarScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: EmoGradientOutlineButton(
                          text: '返回对象',
                          onTap: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (_) => TargetDetailScreen(target: target),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
