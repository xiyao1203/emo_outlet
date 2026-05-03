import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_providers.dart';
import '../services/auth_service.dart';
import '../widgets/common/app_bottom_nav.dart';
import 'target_list_screen.dart';
import 'history_screen.dart';
import 'emotion_report_screen.dart';
import 'settings_screen.dart';

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
    const TargetListScreen(),
    const HistoryScreen(),
    const _MessagesTab(),
    const _ProfileTab(),
  ];

  @override
  void initState() {
    super.initState();
    _authService.init();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TargetProvider>().loadTargets();
      context.read<SessionProvider>().loadSessions();
      context.read<EmotionProvider>().loadOverviewReport();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentNavIndex],
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentNavIndex,
        onTap: (index) => setState(() => _currentNavIndex = index),
      ),
    );
  }
}

class _HomePage extends StatelessWidget {
  const _HomePage();

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthService>().currentUser;
    final isMinor = user?.ageRange == '<14' || user?.ageRange == '14-18';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '首页',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFF8F8F8),
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF8F8F8),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 未成年人保护横幅
            if (isMinor)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF7A56), Color(0xFFFF9A76)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.shield_outlined, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '青少年模式已开启 · 每日1次会话',
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),
            // 功能卡片网格
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(child: _buildFeatureCard(Icons.person_off_outlined, '我的对象', () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const TargetListScreen()),
                    );
                  })),
                  const SizedBox(width: 12),
                  Expanded(child: _buildFeatureCard(Icons.history_outlined, '历史记录', () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const HistoryScreen()),
                    );
                  })),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(child: _buildFeatureCard(Icons.bar_chart_outlined, '情绪报告', () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const EmotionReportScreen()),
                    );
                  })),
                  const SizedBox(width: 12),
                  Expanded(child: _buildFeatureCard(Icons.settings_outlined, '设置中心', () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    );
                  })),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: const Color(0xFFFF7A56)),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF333333),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessagesTab extends StatelessWidget {
  const _MessagesTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('消息', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        centerTitle: true,
        backgroundColor: const Color(0xFFF8F8F8),
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF8F8F8),
      body: const Center(
        child: Text('暂无消息', style: TextStyle(color: Color(0xFF999999))),
      ),
    );
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthService>().currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('我的', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        centerTitle: true,
        backgroundColor: const Color(0xFFF8F8F8),
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF8F8F8),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 用户信息卡片
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF7A56),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text('😤', style: TextStyle(fontSize: 30)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.nickname ?? '小木阳',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: ${user?.id ?? "123456789"}',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF999999)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // 开通会员卡片
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF7A56), Color(0xFFFF9A76)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.star, color: Colors.white, size: 28),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('开通会员', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                      SizedBox(height: 4),
                      Text('2.8元/月 解锁更多功能', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // 功能列表
          _buildProfileMenuItem(Icons.star_border, '权限收藏'),
          _buildProfileMenuItem(Icons.description_outlined, '草稿箱'),
          _buildProfileMenuItem(Icons.chat_bubble_outline, '意见反馈'),
          _buildProfileMenuItem(Icons.lightbulb_outline, '温馨提示'),
        ],
      ),
    );
  }

  Widget _buildProfileMenuItem(IconData icon, String label) {
    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      decoration: const BoxDecoration(color: Colors.white),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF666666), size: 24),
        title: Text(label, style: const TextStyle(fontSize: 15, color: Color(0xFF333333))),
        trailing: const Icon(Icons.chevron_right, color: Color(0xFFCCCCCC), size: 20),
      ),
    );
  }
}
