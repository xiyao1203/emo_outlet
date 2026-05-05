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
  late int _previousIndex;
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _previousIndex = AppConstants.navIndexHome;
    _authService.init();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TargetProvider>().loadTargets();
      context.read<SessionProvider>().loadSessions();
      context.read<EmotionProvider>().loadOverviewReport();
    });
  }

  void _switchTab(int index) {
    if (_currentIndex == index) return;
    setState(() {
      _previousIndex = _currentIndex;
      _currentIndex = index;
    });
  }

  void _returnToPreviousTab(int currentTab) {
    final fallbackIndex = _previousIndex == currentTab
        ? AppConstants.navIndexHome
        : _previousIndex;
    setState(() => _currentIndex = fallbackIndex);
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      _HomeTab(onSwitchTab: _switchTab),
      TargetListScreen(
        onBackFallback: () => _returnToPreviousTab(AppConstants.navIndexTarget),
      ),
      const HistoryScreen(),
      ProfileHomeScreen(
        onSwitchTab: _switchTab,
      ),
    ];

    return EmoPageScaffold(
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onTap: _switchTab,
      ),
      child: pages[_currentIndex],
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab({required this.onSwitchTab});

  final ValueChanged<int> onSwitchTab;

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
    final targets = context.watch<TargetProvider>().targets;
    final topTarget = targets.isNotEmpty ? targets.first : null;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final compact = constraints.maxHeight < 860;
        final horizontal = EmoResponsive.edgePadding(width);
        final gridCount = EmoResponsive.featureGridCount(width);
        final gridAspectRatio = width >= 980
            ? 1.42
            : width >= 760
                ? 1.24
                : 1.02;

        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(horizontal, 8, horizontal, 12),
          child: EmoResponsiveContent(
            width: width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _HomeTopBar(),
                SizedBox(height: compact ? 18 : 24),
                Text(
                  'Hi, ${user?.nickname ?? '\u5c0f\u592a\u9633'} \uD83D\uDC4B',
                  style: const TextStyle(
                    color: AuthPalette.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    height: 1.08,
                    letterSpacing: -0.6,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '\u4eca\u5929\u60f3\u628a\u54ea\u4e9b\u60c5\u7eea\u8bf4\u51fa\u6765\u5462\uff1f',
                  style: TextStyle(
                    fontSize: 13.5,
                    color: Color(0xFF746962),
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: compact ? 16 : 20),
                _HeroReleaseCard(
                  compact: compact,
                  onTap: () {
                    if (topTarget != null) {
                      context
                          .read<TargetProvider>()
                          .setCurrentTarget(topTarget);
                    }
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const SessionModeScreen(),
                      ),
                    );
                  },
                ),
                SizedBox(height: compact ? 16 : 20),
                GridView.count(
                  crossAxisCount: gridCount,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: gridAspectRatio,
                  children: [
                    _FeatureCard(
                      imageAsset: 'assets/images/home_icon_target.png',
                      title: '\u6211\u7684\u5bf9\u8c61',
                      subtitle: '\u7ba1\u7406\u4f60\u5173\u5fc3\u7684\u4eba',
                      onTap: () => onSwitchTab(AppConstants.navIndexTarget),
                    ),
                    _FeatureCard(
                      imageAsset: 'assets/images/home_icon_history.png',
                      title: '\u5386\u53f2\u8bb0\u5f55',
                      subtitle: '\u67e5\u770b\u8fc7\u53bb\u7684\u503e\u8bc9',
                      onTap: () => onSwitchTab(AppConstants.navIndexHistory),
                    ),
                    _FeatureCard(
                      imageAsset: 'assets/images/home_icon_report.png',
                      title: '\u60c5\u7eea\u62a5\u544a',
                      subtitle:
                          '\u63a2\u7d22\u4f60\u7684\u60c5\u7eea\u8d8b\u52bf',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const EmotionReportScreen(),
                        ),
                      ),
                    ),
                    _FeatureCard(
                      imageAsset: 'assets/images/home_icon_settings.png',
                      title: '\u8bbe\u7f6e\u4e2d\u5fc3',
                      subtitle: '\u4e2a\u6027\u5316\u4f60\u7684\u4f53\u9a8c',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const SettingsScreen()),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HomeTopBar extends StatelessWidget {
  const _HomeTopBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppBrand(fontSize: 20, logoSize: 36, spacing: 8),
            SizedBox(height: 5),
            Text(
              '\u628a\u4e0d\u8212\u670d\u7684\u60c5\u7eea\uff0c\u8f7b\u8f7b\u653e\u51fa\u6765',
              style: TextStyle(
                fontSize: 12.5,
                color: Color(0xFF7C6C63),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const Spacer(),
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: const [
              BoxShadow(
                color: Color(0x10DCA596),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFFD9C9), Color(0xFFFFF4EE)],
            ),
          ),
          child: ClipOval(
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Image.asset(
                'assets/images/home_avatar_profile.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroReleaseCard extends StatelessWidget {
  const _HeroReleaseCard({
    required this.compact,
    required this.onTap,
  });

  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return EmoSectionCard(
      radius: 34,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        children: [
          SizedBox(
            height: compact ? 216 : 232,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  right: -22,
                  top: -24,
                  child: IgnorePointer(
                    child: Container(
                      width: 260,
                      height: 260,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [Color(0x22FFC7BD), Color(0x00FFC7BD)],
                        ),
                      ),
                    ),
                  ),
                ),
                const Positioned(
                  left: 4,
                  top: 18,
                  right: 148,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '\u628a\u4e0d\u8212\u670d\u7684\u60c5\u7eea',
                        style: TextStyle(
                          fontSize: 18.5,
                          fontWeight: FontWeight.w800,
                          color: AuthPalette.textPrimary,
                          height: 1.12,
                          letterSpacing: -0.9,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '\u8f7b\u8f7b\u653e\u51fa\u6765',
                        style: TextStyle(
                          fontSize: 18.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFFF6D4C),
                          height: 1.06,
                          letterSpacing: -0.9,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        '\u5b89\u5168\u8868\u8fbe\u00b7\u5373\u65f6\u758f\u89e3\u00b7\u4e13\u5c5e\u966a\u4f34',
                        style: TextStyle(
                          fontSize: 12.8,
                          color: Color(0xFF776B66),
                          fontWeight: FontWeight.w500,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const Positioned(
                  top: -4,
                  right: -8,
                  bottom: 0,
                  width: 236,
                  child: _HomeHeroCloud(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          GradientPrimaryButton(
            text: '\u5f00\u59cb\u91ca\u653e\u60c5\u7eea',
            height: 56,
            fontSize: 17,
            onTap: onTap,
          ),
        ],
      ),
    );
  }
}

class _HomeHeroCloud extends StatelessWidget {
  const _HomeHeroCloud();

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Positioned(
          left: -8,
          right: -6,
          bottom: 8,
          child: Image.asset(
            'assets/images/splash_base_glow.png',
            fit: BoxFit.contain,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 0, 18),
          child: Image.asset(
            'assets/images/home_cloud_hero.png',
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.imageAsset,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String imageAsset;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return EmoSectionCard(
      radius: 28,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: Stack(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 60,
                  height: 60,
                  child: Image.asset(
                    imageAsset,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 28, top: 2),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AuthPalette.textPrimary,
                            height: 1.22,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: Color(0xFF7C716C),
                            fontWeight: FontWeight.w500,
                            height: 1.36,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              right: 0,
              bottom: 2,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.92),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x10D7B3A3),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF9B938F),
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
