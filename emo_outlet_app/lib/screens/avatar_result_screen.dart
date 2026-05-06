import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_providers.dart';
import '../widgets/auth/auth_visuals.dart';
import '../widgets/common/emo_ui.dart';
import 'session_mode_screen.dart';

class AvatarResultScreen extends StatelessWidget {
  const AvatarResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final target = context.watch<TargetProvider>().currentTarget;
    final name = target?.name ?? '未知对象';
    final shortName = name.characters.take(2).toString();

    return EmoPageScaffold(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
        child: Column(
          children: [
            Row(
              children: [
                EmoRoundIconButton(
                  icon: Icons.close_rounded,
                  onTap: () =>
                      Navigator.of(context).popUntil((route) => route.isFirst),
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
                    width: 152,
                    height: 152,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFFFF7A56), Color(0xFFFF9A76)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x28FF9D82),
                          blurRadius: 24,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        shortName.isEmpty ? '?' : shortName,
                        style: const TextStyle(
                          fontSize: 46,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    '形象生成完成',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AuthPalette.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '这是 $name 的当前形象预览。',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AuthPalette.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: GradientPrimaryButton(
                      text: '开始释放情绪',
                      height: 54,
                      fontSize: 16,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const SessionModeScreen(),
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
                          onTap: () => Navigator.of(context).pop(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: EmoGradientOutlineButton(
                          text: '稍后再看',
                          onTap: () => Navigator.of(context)
                              .popUntil((route) => route.isFirst),
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
