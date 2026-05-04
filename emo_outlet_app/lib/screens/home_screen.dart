import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/constants.dart';
import '../providers/app_providers.dart';
import '../services/auth_service.dart';
import '../widgets/auth/auth_visuals.dart';
import '../widgets/common/app_bottom_nav.dart';
import '../widgets/common/emo_ui.dart';
import 'emotion_report_screen.dart';
import 'history_screen.dart';
import 'profile_home_screen.dart';
import 'session_mode_screen.dart';
import 'settings_screen.dart';
import 'target_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _currentIndex;
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _authService.init();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TargetProvider>().loadTargets();
      context.read<SessionProvider>().loadSessions();
      context.read<EmotionProvider>().loadOverviewReport();
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const _HomeTab(),
      const TargetListScreen(),
      const HistoryScreen(),
      ProfileHomeScreen(
        onSwitchTab: (index) => setState(() => _currentIndex = index),
      ),
    ];

    return EmoPageScaffold(
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
      child: pages[_currentIndex],
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
    final targets = context.watch<TargetProvider>().targets;
    final topTarget = targets.isNotEmpty ? targets.first : null;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final horizontal = math.min(width * 0.05, 20.0);
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(horizontal, 18, horizontal, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const EmoTopBrandBar(trailing: EmoProfileBubble()),
              const SizedBox(height: 26),
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    color: AuthPalette.textPrimary,
                    fontSize: 38,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                  children: [
                    const TextSpan(text: 'Hi, '),
                    TextSpan(text: user?.nickname ?? '小太阳'),
                    const TextSpan(text: ' 👋'),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '今天想把哪些情绪说出来呢？',
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF746962),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 22),
              EmoSectionCard(
                radius: 34,
                padding: const EdgeInsets.fromLTRB(22, 22, 22, 24),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '把不舒服的情绪',
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w800,
                                  color: AuthPalette.textPrimary,
                                  height: 1.12,
                                ),
                              ),
                              Text(
                                '轻轻放出来',
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFFFF6D4C),
                                  height: 1.12,
                                ),
                              ),
                              SizedBox(height: 18),
                              Text(
                                '安全表达 · 即时疏解 · 专属陪伴',
                                style: TextStyle(
                                  fontSize: 17,
                                  color: Color(0xFF776B66),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        const EmoDecorationCloud(size: 190),
                      ],
                    ),
                    const SizedBox(height: 8),
                    GradientPrimaryButton(
                      text: '开始释放情绪',
                      height: 72,
                      fontSize: 28,
                      onTap: () {
                        if (topTarget != null) {
                          context
                              .read<TargetProvider>()
                              .setCurrentTarget(topTarget);
                        }
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const SessionModeScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              GridView.count(
                crossAxisCount: 2,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.08,
                children: [
                  _FeatureCard(
                    emoji: '💗',
                    emojiBg: const Color(0xFFFFB1BF),
                    title: '我的对象',
                    subtitle: '管理你关心的人',
                    onTap: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => const HomeScreen(
                            initialIndex: AppConstants.navIndexTarget),
                      ),
                    ),
                  ),
                  _FeatureCard(
                    emoji: '🕘',
                    emojiBg: const Color(0xFF9D93FF),
                    title: '历史记录',
                    subtitle: '查看过去的倾诉',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const HistoryScreen()),
                    ),
                  ),
                  _FeatureCard(
                    emoji: '📊',
                    emojiBg: const Color(0xFFFFB057),
                    title: '情绪报告',
                    subtitle: '探索你的情绪趋势',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const EmotionReportScreen()),
                    ),
                  ),
                  _FeatureCard(
                    emoji: '⚙️',
                    emojiBg: const Color(0xFFD8D8D8),
                    title: '设置中心',
                    subtitle: '个性化你的体验',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.emoji,
    required this.emojiBg,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String emoji;
  final Color emojiBg;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return EmoSectionCard(
      radius: 28,
      padding: const EdgeInsets.fromLTRB(18, 18, 16, 18),
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    gradient: LinearGradient(
                      colors: [
                        emojiBg.withValues(alpha: 0.95),
                        emojiBg.withValues(alpha: 0.65),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: emojiBg.withValues(alpha: 0.24),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(emoji, style: const TextStyle(fontSize: 42)),
                  ),
                ),
                const Spacer(),
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.86),
                  ),
                  child: const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFF999999),
                    size: 28,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AuthPalette.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF7C716C),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
