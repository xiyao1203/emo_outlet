import 'package:flutter/material.dart';

import '../config/constants.dart';
import '../widgets/auth/auth_visuals.dart';
import '../widgets/common/app_bottom_nav.dart';
import '../widgets/common/emo_ui.dart';
import 'home_screen.dart';

class ReleaseStatsScreen extends StatelessWidget {
  const ReleaseStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return EmoPageScaffold(
      bottomNavigationBar: AppBottomNav(
        currentIndex: AppConstants.navIndexProfile,
        onTap: (index) => Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => HomeScreen(initialIndex: index),
          ),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
        child: Column(
          children: [
            _SubHeader(
              title: '释放统计',
              onBack: () => Navigator.of(context).pop(),
            ),
            const SizedBox(height: 22),
            Container(
              height: 214,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(34),
                gradient: const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Color(0xFFFFCCBC), Color(0xFFFFE7B9)],
                ),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: 24,
                    top: 28,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          '累计释放',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: AuthPalette.textPrimary,
                          ),
                        ),
                        SizedBox(height: 14),
                        Text(
                          '48',
                          style: TextStyle(
                            fontSize: 86,
                            height: 0.95,
                            fontWeight: FontWeight.w800,
                            color: AuthPalette.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Positioned(
                    left: 156,
                    top: 88,
                    child: Text(
                      '次',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        color: AuthPalette.textPrimary,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 24,
                    bottom: 28,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: Colors.white),
                      ),
                      child: const Text(
                        '✨ 坚持表达，让情绪自由流动',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6F645F),
                        ),
                      ),
                    ),
                  ),
                  const Positioned(
                    right: 14,
                    bottom: 8,
                    child: EmoDecorationCloud(size: 176),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            EmoSectionCard(
              radius: 32,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
              child: Row(
                children: const [
                  Expanded(
                    child: _MetricCell(
                      emoji: '🕒',
                      title: '总时长',
                      main: '6',
                      unit: '小时 28 分',
                      subtitle: '释放总时长',
                      iconBg: Color(0xFFE5D9FF),
                    ),
                  ),
                  Expanded(
                    child: _MetricCell(
                      emoji: '🗓️',
                      title: '本周',
                      main: '5',
                      unit: '次',
                      subtitle: '较上周 +2',
                      subtitleColor: Color(0xFFFF6E61),
                      iconBg: Color(0xFFFFD7E5),
                    ),
                  ),
                  Expanded(
                    child: _MetricCell(
                      emoji: '📅',
                      title: '本月',
                      main: '14',
                      unit: '次',
                      subtitle: '较上月 +6',
                      subtitleColor: Color(0xFFFF6E61),
                      iconBg: Color(0xFFFFE5BF),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            EmoSectionCard(
              radius: 32,
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Text(
                        '情绪释放趋势',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AuthPalette.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.62),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Row(
                          children: [
                            Text(
                              '近 7 天',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF6F6560),
                              ),
                            ),
                            SizedBox(width: 6),
                            Icon(Icons.keyboard_arrow_down_rounded,
                                size: 18, color: Color(0xFF6F6560)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  const _TrendChart(),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: const [
                Expanded(child: _RecentTargetsCard()),
                SizedBox(width: 14),
                Expanded(child: _EncourageCard()),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCell extends StatelessWidget {
  const _MetricCell({
    required this.emoji,
    required this.title,
    required this.main,
    required this.unit,
    required this.subtitle,
    required this.iconBg,
    this.subtitleColor = const Color(0xFF8C817B),
  });

  final String emoji;
  final String title;
  final String main;
  final String unit;
  final String subtitle;
  final Color iconBg;
  final Color subtitleColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 24))),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF5F5854),
            ),
          ),
          const SizedBox(height: 6),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: main,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AuthPalette.textPrimary,
                  ),
                ),
                TextSpan(
                  text: unit,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AuthPalette.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: subtitleColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendChart extends StatelessWidget {
  const _TrendChart();

  @override
  Widget build(BuildContext context) {
    const values = [2, 4, 6, 3, 7, 5, 5];
    const labels = ['05/10', '05/11', '05/12', '05/13', '05/14', '05/15', '今天'];
    return SizedBox(
      height: 260,
      child: Stack(
        children: [
          for (final y in [0, 1, 2, 3])
            Positioned(
              left: 34,
              right: 10,
              top: 16 + y * 54,
              child: Container(
                height: 1,
                color: const Color(0xFFF0E4DE),
              ),
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(values.length, (index) {
              final height = values[index] * 22.0;
              return Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '${values[index]}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF7A716B),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: 26,
                      height: height,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFFFF8D95), Color(0xFFFFC9CC)],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      labels[index],
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF8B817C),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _RecentTargetsCard extends StatelessWidget {
  const _RecentTargetsCard();

  @override
  Widget build(BuildContext context) {
    const avatars = [
      ('👦', '小明', '12 次', Color(0xFFE5F1FF)),
      ('👩', '妈妈', '9 次', Color(0xFFFFE7E9)),
      ('👒', '闺蜜', '7 次', Color(0xFFF7E3D4)),
    ];
    return EmoSectionCard(
      radius: 30,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Expanded(
                child: Text(
                  '最近释放对象',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AuthPalette.textPrimary,
                  ),
                ),
              ),
              Icon(Icons.chevron_right_rounded, size: 28),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: avatars.map((item) {
              return Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 74,
                      height: 74,
                      decoration: BoxDecoration(
                        color: item.$4,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: Center(
                        child:
                            Text(item.$1, style: const TextStyle(fontSize: 36)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      item.$2,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AuthPalette.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.$3,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF8E837D),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _EncourageCard extends StatelessWidget {
  const _EncourageCard();

  @override
  Widget build(BuildContext context) {
    return EmoSectionCard(
      radius: 30,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      child: SizedBox(
        height: 236,
        child: Stack(
          children: [
            const Positioned(
              left: 0,
              top: 0,
              child: Text(
                '给你的鼓励',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFFF744E),
                ),
              ),
            ),
            const Positioned(
              left: 0,
              top: 48,
              right: 6,
              child: Text(
                '你正在学会温柔地照顾自己，\n每一次释放，都是成长的印记\n继续保持，你很棒！',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.7,
                  color: Color(0xFF695E59),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Text(
                '💗',
                style: TextStyle(fontSize: 86, color: Colors.pink.shade200),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubHeader extends StatelessWidget {
  const _SubHeader({
    required this.title,
    required this.onBack,
  });

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: EmoRoundIconButton(
              icon: Icons.arrow_back_ios_new_rounded,
              size: 52,
              onTap: onBack,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: AuthPalette.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
