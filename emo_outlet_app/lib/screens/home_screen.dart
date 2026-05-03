import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../config/constants.dart';
import '../providers/app_providers.dart';
import '../services/auth_service.dart';
import '../widgets/common/app_bottom_nav.dart';
import 'target_list_screen.dart';
import 'session_mode_screen.dart';
import 'history_screen.dart';
import 'emotion_report_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentNavIndex = 0;
  final _authService = AuthService();

  final List<Widget> _pages = [
    const _HomePage(),
    const _EmotionTab(),
    const SizedBox(), // 中间按钮由 nav 处理
    const HistoryScreen(),
    const _ProfileTab(),
  ];

  @override
  void initState() {
    super.initState();
    _authService.init();
    // 加载目标数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TargetProvider>().loadTargets();
      context.read<SessionProvider>().loadSessions();
      context.read<EmotionProvider>().loadReports();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentNavIndex,
        children: _pages,
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          if (index == AppConstants.navIndexMain) {
            // 中间+按钮 -> 进入目标选择或创建
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const TargetListScreen(isSelectMode: true),
              ),
            );
            return;
          }
          setState(() => _currentNavIndex = index);
        },
      ),
    );
  }
}

// 首页内容
class _HomePage extends StatelessWidget {
  const _HomePage();

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
    final nickname = user?.nickname ?? '访客';
    final targetProvider = context.watch<TargetProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Hi, $nickname'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_outlined),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 主要 CTA
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF7A56), Color(0xFFFF9A76)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppRadius.xl),
                boxShadow: [AppColors.buttonShadow],
              ),
              child: Column(
                children: [
                  const Text(
                    '开始释放情绪',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '有什么想说的，尽管说出来',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.85),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (targetProvider.targets.isEmpty) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const TargetListScreen(
                                  isSelectMode: true),
                            ),
                          );
                        } else {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const SessionModeScreen(),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                        ),
                      ),
                      child: const Text(
                        '开始释放情绪',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // 快捷功能卡片
            const Text('快捷功能', style: AppTextStyles.heading3),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.person_add_outlined,
                    label: '我的对象',
                    color: AppColors.primary,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const TargetListScreen(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.history_outlined,
                    label: '历史记录',
                    color: AppColors.secondary,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const HistoryScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.insert_chart_outlined,
                    label: '情绪报告',
                    color: AppColors.accent,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const EmotionReportScreen(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.settings_outlined,
                    label: '设置',
                    color: AppColors.textHint,
                    onTap: () {},
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppRadius.md),
          boxShadow: [AppColors.cardShadow],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 情绪 Tab（占位）
class _EmotionTab extends StatelessWidget {
  const _EmotionTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('情绪')),
      body: const Center(
        child: Text('情绪分析功能开发中...', style: AppTextStyles.bodySmall),
      ),
    );
  }
}

// 个人 Tab
class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();
    return Scaffold(
      appBar: AppBar(title: const Text('我的')),
      body: Padding(
        padding: AppSpacing.screenPadding,
        child: Column(
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.primary,
              child: Text(
                auth.currentUser?.nickname?.substring(0, 1) ?? '?',
                style: const TextStyle(
                  fontSize: 28,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              auth.currentUser?.nickname ?? '访客用户',
              style: AppTextStyles.heading3,
            ),
            const SizedBox(height: 32),
            _profileMenuItem(Icons.person_outline, '个人信息', () {}),
            _profileMenuItem(Icons.settings_outlined, '设置', () {}),
            _profileMenuItem(Icons.help_outline, '帮助与反馈', () {}),
            _profileMenuItem(Icons.info_outline, '关于', () {}),
            const Spacer(),
            TextButton(
              onPressed: () async {
                await auth.logout();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (_) => const Scaffold(
                        body: Center(child: Text('已退出登录')),
                      ),
                    ),
                    (route) => false,
                  );
                }
              },
              child: const Text(
                '退出登录',
                style: TextStyle(color: AppColors.textHint),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileMenuItem(IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(label, style: AppTextStyles.bodyMedium),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textHint),
      onTap: onTap,
    );
  }
}
