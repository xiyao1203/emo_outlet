import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_providers.dart';
import '../widgets/auth/auth_visuals.dart';
import '../widgets/common/app_bottom_nav.dart';
import '../widgets/common/emo_ui.dart';
import 'home_screen.dart';
import 'target_detail_screen.dart';

class GenerateAvatarScreen extends StatefulWidget {
  const GenerateAvatarScreen({super.key});

  @override
  State<GenerateAvatarScreen> createState() => _GenerateAvatarScreenState();
}

class _GenerateAvatarScreenState extends State<GenerateAvatarScreen> {
  late Timer _timer;
  double _progress = 0.12;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 350), (timer) {
      setState(() {
        _progress += 0.08;
        if (_progress >= 0.78) {
          _progress = 0.78;
          timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final target = context.watch<TargetProvider>().currentTarget;
    final current = target;
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
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
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
                  '生成形象中',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                const EmoDecorationCloud(size: 116),
              ],
            ),
            const SizedBox(height: 10),
            EmoSectionCard(
              radius: 36,
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
              child: Column(
                children: [
                  Container(
                    width: 196,
                    height: 196,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFFFFB28A), Color(0xFFFF7A7F)],
                      ),
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: EmoAvatar(
                          label: avatarEmojiByType(current?.type ?? 'boss'),
                          background: avatarBgByType(current?.type ?? 'boss'),
                          size: 152,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    '正在为你生成专属形象',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '请稍候，马上就好...',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: Color(0xFFC8A79A),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.68),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: Colors.white),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: LinearProgressIndicator(
                              value: _progress,
                            minHeight: 20,
                              backgroundColor: const Color(0xFFF7E8E0),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  Color(0xFFFF7B7A)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Text(
                          '${(_progress * 100).round()}%',
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFFF7E73),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Row(
                    children: [
                      Expanded(
                        child: _StepChip(
                          title: '分析描述',
                          active: false,
                          done: true,
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: _StepChip(
                          title: '生成形象',
                          active: true,
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: _StepChip(
                          title: '优化细节',
                          active: false,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  const EmoSectionCard(
                    radius: 24,
                    child: Row(
                      children: [
                        Icon(Icons.lightbulb_outline_rounded,
                            color: Color(0xFFFFB356), size: 28),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '小提示：形象会根据外貌、性格和关系描述进行生成',
                            style: TextStyle(
                              fontSize: 12.5,
                              height: 1.45,
                              color: Color(0xFF8A6255),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            GradientPrimaryButton(
              text: '生成完成后查看详情',
              height: 54,
              fontSize: 15.5,
              onTap: () {
                if (current != null) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => TargetDetailScreen(target: current),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _StepChip extends StatelessWidget {
  const _StepChip({
    required this.title,
    required this.active,
    this.done = false,
  });

  final String title;
  final bool active;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final color = active
        ? const Color(0xFFFF7B7A)
        : done
            ? const Color(0xFF8E5A4E)
            : const Color(0xFF9A9A9A);
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: active ? const Color(0xFFFFD3C7) : const Color(0xFFF2E8E3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            done ? Icons.check_circle_rounded : Icons.trip_origin_rounded,
            size: 20,
            color: color,
          ),
          const SizedBox(width: 8),
          Text(
            title,
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
}
