import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/target_model.dart';
import '../providers/app_providers.dart';
import '../widgets/auth/auth_visuals.dart';
import '../widgets/common/app_bottom_nav.dart';
import '../widgets/common/emo_ui.dart';
import 'edit_target_screen.dart';
import 'home_screen.dart';
import 'session_mode_screen.dart';

class TargetDetailScreen extends StatelessWidget {
  const TargetDetailScreen({super.key, this.target});

  final TargetModel? target;

  @override
  Widget build(BuildContext context) {
    final current = target ?? context.watch<TargetProvider>().currentTarget;
    if (current == null) {
      return const HomeScreen(initialIndex: 1);
    }
    final color = typeColor(current.type);
    return EmoPageScaffold(
      bottomNavigationBar: AppBottomNav(
        currentIndex: 1,
        onTap: (index) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => HomeScreen(initialIndex: index)),
          );
        },
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
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
                  '对象详情',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white70,
                  ),
                  child: const Icon(
                    Icons.more_horiz_rounded,
                    color: AuthPalette.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            EmoSectionCard(
              child: Column(
                children: [
                  Row(
                    children: [
                      EmoAvatar(
                        label: avatarEmojiByType(current.type),
                        background: avatarBgByType(current.type),
                        size: 92,
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  current.name,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                EmoTypePill(
                                  text: current.typeLabel,
                                  color: color,
                                  background: color.withValues(alpha: 0.12),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              current.relationship ?? '管理你的泄愤对象',
                              style: const TextStyle(
                                fontSize: 13,
                                height: 1.5,
                                color: Color(0xFF6B625F),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                _softTag(Icons.work_outline_rounded, '工作关系',
                                    const Color(0xFF7CA6F3)),
                                const SizedBox(width: 10),
                                _softTag(Icons.bolt_rounded, '压力触发',
                                    const Color(0xFFFFA14B)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: GradientPrimaryButton(
                          text: '开始释放情绪',
                          height: 54,
                          fontSize: 16,
                          onTap: () {
                            context
                                .read<TargetProvider>()
                                .setCurrentTarget(current);
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const SessionModeScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: EmoGradientOutlineButton(
                          text: '编辑对象',
                          icon: Icons.edit_outlined,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    EditTargetScreen(target: current),
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
            const SizedBox(height: 18),
            _detailCard(
              icon: Icons.face_rounded,
              title: '外貌描述',
              body: current.appearance ?? '中年男性，戴眼镜，发型整齐，穿着正式，给人一种严谨、专业的感觉。',
              color: const Color(0xFFFF8A76),
            ),
            const SizedBox(height: 14),
            _detailCard(
              icon: Icons.star_rounded,
              title: '性格描述',
              body: current.personality ?? '做事认真，对细节要求高，追求完美，有时显得比较严厉和固执。',
              color: const Color(0xFFFF8B70),
            ),
            const SizedBox(height: 14),
            _detailCard(
              icon: Icons.people_alt_rounded,
              title: '关系描述',
              body: current.relationship ?? '我的直属上司，负责团队管理和项目决策，对我的工作表现有直接影响。',
              color: const Color(0xFFFF7B63),
            ),
            const SizedBox(height: 14),
            _detailCard(
              icon: Icons.bolt_rounded,
              title: '触发事件',
              body: current.triggers ??
                  '• 工作出现失误或进度延迟时\n• 方案未达到他的预期时\n• 当众指出问题或批评我时',
              color: const Color(0xFFFF915C),
            ),
          ],
        ),
      ),
    );
  }

  Widget _softTag(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailCard({
    required IconData icon,
    required String title,
    required String body,
    required Color color,
  }) {
    return EmoSectionCard(
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 132),
        child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF211B18),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  body,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: Color(0xFF6D6560),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
        ),
      ),
    );
  }
}
