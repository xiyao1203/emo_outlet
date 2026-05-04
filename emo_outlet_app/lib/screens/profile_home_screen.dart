import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/constants.dart';
import '../providers/app_providers.dart';
import '../services/auth_service.dart';
import '../widgets/auth/auth_visuals.dart';
import '../widgets/common/emo_ui.dart';
import 'posters_screen.dart';
import 'release_stats_screen.dart';
import 'settings_screen.dart';

class ProfileHomeScreen extends StatelessWidget {
  const ProfileHomeScreen({
    super.key,
    this.onSwitchTab,
  });

  final ValueChanged<int>? onSwitchTab;

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
    final nickname = user?.nickname ?? '小太阳';
    final targets = context.watch<TargetProvider>().targets;
    final companionDays = DateTime.now()
        .difference(user?.createdAt ?? DateTime(2025, 1, 1))
        .inDays;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
      child: Column(
        children: [
          const SizedBox(height: 6),
          const Center(
            child: Text(
              '我的',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                color: AuthPalette.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 28),
          EmoSectionCard(
            radius: 34,
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
            child: SizedBox(
              height: 238,
              child: Stack(
                children: [
                  Positioned(
                    right: -8,
                    top: 8,
                    child: Opacity(
                      opacity: 0.2,
                      child: Container(
                        width: 132,
                        height: 88,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(44),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 2,
                    bottom: -6,
                    child: SizedBox(
                      width: 168,
                      height: 132,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned(
                            left: 14,
                            top: 18,
                            child: Icon(
                              Icons.favorite_rounded,
                              color: const Color(0xFFFF8781),
                              size: 26,
                            ),
                          ),
                          const Positioned(
                            right: 14,
                            bottom: 0,
                            child: EmoDecorationCloud(size: 138),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 122,
                            height: 122,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 4),
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFFF8D8C8), Color(0xFFFFF0E7)],
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x18E2BAAA),
                                  blurRadius: 24,
                                  offset: Offset(0, 14),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text('👒', style: TextStyle(fontSize: 56)),
                            ),
                          ),
                          Positioned(
                            right: 2,
                            bottom: 2,
                            child: Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                border:
                                    Border.all(color: Colors.white, width: 2),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x14DEB7A7),
                                    blurRadius: 14,
                                    offset: Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.camera_alt_rounded,
                                color: Color(0xFFFF845E),
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$nickname ☀',
                                style: const TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w800,
                                  color: AuthPalette.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 14),
                              const Text(
                                '拥抱情绪，遇见更好的自己',
                                style: TextStyle(
                                  fontSize: 17,
                                  height: 1.4,
                                  color: Color(0xFF7E726C),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 18, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.66),
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: const Color(0xFFF3D5CB),
                                  ),
                                ),
                                child: Text.rich(
                                  TextSpan(
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF7E726C),
                                    ),
                                    children: [
                                      const TextSpan(text: '✨ 已陪伴你 '),
                                      TextSpan(
                                        text:
                                            '${companionDays.clamp(128, 128)}',
                                        style: const TextStyle(
                                          color: Color(0xFFFF7B5D),
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const TextSpan(text: ' 天'),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 22),
          _ProfileStatsCard(
            targetCount: targets.isEmpty ? 12 : targets.length,
            sessionCount: 48,
            onTargetsTap: () => onSwitchTab?.call(AppConstants.navIndexTarget),
            onStatsTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ReleaseStatsScreen()),
              );
            },
          ),
          const SizedBox(height: 22),
          _ProfileEntryCard(
            emoji: '📘',
            title: '我的海报',
            subtitle: '查看与管理我的专属海报',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MyPostersScreen()),
              );
            },
          ),
          const SizedBox(height: 18),
          _ProfileEntryCard(
            emoji: '⚙️',
            title: '设置中心',
            subtitle: '偏好设置与账户管理',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ProfileStatsCard extends StatelessWidget {
  const _ProfileStatsCard({
    required this.targetCount,
    required this.sessionCount,
    required this.onTargetsTap,
    required this.onStatsTap,
  });

  final int targetCount;
  final int sessionCount;
  final VoidCallback onTargetsTap;
  final VoidCallback onStatsTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(34),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFFFFC8BC), Color(0xFFFFE2B3)],
        ),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x20E6B9AA),
            blurRadius: 30,
            offset: Offset(0, 16),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatsHalf(
              emoji: '👥',
              number: '$targetCount',
              title: '我的对象数量',
              onTap: onTargetsTap,
            ),
          ),
          Container(
              width: 1, height: 86, color: Colors.white.withValues(alpha: 0.7)),
          Expanded(
            child: _StatsHalf(
              emoji: '💗',
              number: '$sessionCount',
              title: '累计释放次数',
              onTap: onStatsTap,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsHalf extends StatelessWidget {
  const _StatsHalf({
    required this.emoji,
    required this.number,
    required this.title,
    required this.onTap,
  });

  final String emoji;
  final String number;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(34),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 22, 18, 22),
        child: Row(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(22),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x12E1B8A7),
                    blurRadius: 16,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 32))),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    number,
                    style: const TextStyle(
                      fontSize: 36,
                      height: 1,
                      fontWeight: FontWeight.w800,
                      color: AuthPalette.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF4A403B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.chevron_right_rounded,
                        size: 18,
                        color: Color(0xFF7B6F6A),
                      ),
                    ],
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

class _ProfileEntryCard extends StatelessWidget {
  const _ProfileEntryCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return EmoSectionCard(
      radius: 30,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: Row(
          children: [
            Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  colors: [Color(0xFFE9EEFF), Color(0xFFFDF4F8)],
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x16DBB7A7),
                    blurRadius: 14,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 38))),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w800,
                      color: AuthPalette.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF8A7D77),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                shape: BoxShape.circle,
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14E0B8AA),
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.chevron_right_rounded,
                size: 28,
                color: Color(0xFF77706C),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
