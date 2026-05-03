import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/app_providers.dart';
import '../widgets/common/emotion_bar.dart';

class EmotionReportScreen extends StatefulWidget {
  const EmotionReportScreen({super.key});

  @override
  State<EmotionReportScreen> createState() => _EmotionReportScreenState();
}

class _EmotionReportScreenState extends State<EmotionReportScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EmotionProvider>().loadOverviewReport(period: 'weekly');
    });
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      final periods = ['weekly', 'monthly', 'yearly'];
      context.read<EmotionProvider>().loadOverviewReport(period: periods[_tabController.index]);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('情绪报告', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF333333))),
        centerTitle: true,
        backgroundColor: const Color(0xFFF8F8F8),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textHint,
          indicatorSize: TabBarIndicatorSize.label,
          tabs: const [
            Tab(text: '周报'), Tab(text: '月报'), Tab(text: '年报'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildReport(context, '本周情绪报告'),
          _buildReport(context, '本月情绪报告'),
          _buildReport(context, '本年情绪报告'),
        ],
      ),
    );
  }

  Widget _buildReport(BuildContext context, String title) {
    final emotionProvider = context.watch<EmotionProvider>();
    final report = emotionProvider.currentReport;
    final emotions = report?.emotions ?? {};

    if (emotionProvider.isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (report != null)
            Row(children: [
              _StatCard(label: '总次数', value: '${report.totalSessions}次'),
              const SizedBox(width: 12),
              _StatCard(label: '总时长', value: '${report.totalDurationMinutes}分钟'),
              _StatCard(label: '最高情绪', value: report.dominantEmotion),
            ]),
          const SizedBox(height: 20),

          // 情绪饼图
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 2))],
            ),
            child: Column(children: [
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF333333))),
              const SizedBox(height: 20),
              EmotionPieChart(emotions: emotions),
            ]),
          ),
          const SizedBox(height: 16),

          // 情绪趋势
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 2))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('情绪趋势', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF333333))),
                const SizedBox(height: 16),
                ...emotions.entries.map((entry) {
                  Color color;
                  switch (entry.key) {
                    case '愤怒': color = AppColors.emotionAnger; break;
                    case '焦虑': color = AppColors.emotionAnxiety; break;
                    case '悲伤': color = AppColors.emotionSadness; break;
                    case '疲惫': color = AppColors.emotionPower; break;
                    case '无奈': color = AppColors.emotionCalm; break;
                    default: color = AppColors.emotionCalm;
                  }
                  return EmotionBar(label: entry.key, value: entry.value, color: color);
                }),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 建议
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.lightbulb_outline, color: AppColors.primary, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('情绪建议', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF333333))),
                      const SizedBox(height: 8),
                      Text(
                        report?.suggestion ?? '继续保持良好的情绪释放习惯！',
                        style: const TextStyle(fontSize: 14, color: Color(0xFF666666), height: 1.6),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(children: [
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.primary)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF999999))),
        ]),
      ),
    );
  }
}
