import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../config/constants.dart';
import '../config/compliance.dart';
import '../providers/app_providers.dart';
import '../services/auth_service.dart';
import '../widgets/common/app_bottom_nav.dart';
import 'target_list_screen.dart';
import 'session_mode_screen.dart';
import 'history_screen.dart';
import 'emotion_report_screen.dart';
import 'chat_screen.dart';
import 'login_screen.dart';

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
      context.read<EmotionProvider>().loadOverviewReport();
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
    final compliance = ComplianceManager();
    final ageRange = user?.ageRange;
    final isMinorUser = ageRange == '<14' || ageRange == '14-18';

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
            // 未成年保护提示
            if (isMinorUser)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.shield_outlined,
                        size: 20, color: AppColors.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        ageRange == '<14'
                            ? '青少年模式已开启 · 每日限1次会话'
                            : '青少年模式已开启 · 每日限2次会话',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

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
          const SizedBox(height: 12),
          // 快速出气按钮
          SizedBox(
            width: double.infinity,
            child: _QuickActionCard(
              icon: Icons.flash_on,
              label: '快速出气（匿名模式）',
              color: AppColors.emotionAnger,
              onTap: () {
                // 直接创建匿名会话进入聊天
                final session = context.read<SessionProvider>();
                session.createSession(
                  targetId: 'quick_vent',
                  targetName: '出气筒',
                  mode: SessionMode.single,
                  dialect: '普通话',
                  durationMinutes: 3,
                );
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ChatScreen(),
                  ),
                );
              },
            ),
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

// 情绪 Tab
class _EmotionTab extends StatelessWidget {
  const _EmotionTab();

  @override
  Widget build(BuildContext context) {
    final emotionProvider = context.watch<EmotionProvider>();
    final report = emotionProvider.currentReport;

    return Scaffold(
      appBar: AppBar(title: const Text('情绪')),
      body: Padding(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // 今日统计卡片
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF7A56), Color(0xFFFF9A76)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('本周情绪概览',
                      style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 16),
                  if (report != null) ...[
                    _StatRow('总会话', '${report.totalSessions} 次'),
                    _StatRow('总时长', '${report.totalDurationMinutes} 分钟'),
                    _StatRow('主导情绪', report.dominantEmotion),
                  ] else
                    const Text('暂无数据，快去释放情绪吧~',
                        style: TextStyle(color: Colors.white70, fontSize: 14)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (report != null && report.emotions.isNotEmpty) ...[
              const Text('情绪分布', style: AppTextStyles.heading3),
              const SizedBox(height: 16),
              ...report.emotions.entries.map((e) => _EmotionBar(
                    label: e.key,
                    value: e.value,
                  )),
            ],
            if (report?.suggestion != null) ...[
              const SizedBox(height: 24),
              const Text('贴心建议', style: AppTextStyles.heading3),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Text(report!.suggestion!,
                    style: AppTextStyles.bodyMedium),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  const _StatRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _EmotionBar extends StatelessWidget {
  final String label;
  final double value;
  const _EmotionBar({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final color = _emotionColor(label);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: AppTextStyles.bodySmall),
              Text('${value.toStringAsFixed(0)}%',
                  style: AppTextStyles.bodySmall),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value / 100,
              backgroundColor: color.withOpacity(0.15),
              color: color,
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Color _emotionColor(String emotion) {
    switch (emotion) {
      case '愤怒':
        return AppColors.emotionAnger;
      case '悲伤':
        return AppColors.emotionSadness;
      case '焦虑':
        return AppColors.emotionAnxiety;
      case '疲惫':
        return AppColors.emotionPower;
      default:
        return AppColors.emotionCalm;
    }
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
                auth.currentUser?.nickname?.isNotEmpty == true
                    ? auth.currentUser!.nickname!.substring(0, 1)
                    : '?',
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
            if (!(auth.currentUser?.isVisitor ?? true))
              TextButton(
                onPressed: () => _showDeleteAccountDialog(context, auth),
                child: const Text(
                  '注销账号',
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () async {
                await auth.logout();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (_) => const LoginScreen(),
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
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, AuthService auth) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('注销账号'),
        content: const Text(
          '注销后所有数据将被清除，此操作不可恢复。\n确定要注销吗？',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await auth.deleteAccount();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (_) => const LoginScreen(),
                  ),
                  (route) => false,
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text('确认注销'),
          ),
        ],
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
