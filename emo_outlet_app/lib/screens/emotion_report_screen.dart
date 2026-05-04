import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../widgets/common/soft_ui.dart';

class EmotionReportScreen extends StatefulWidget {
  const EmotionReportScreen({super.key});

  @override
  State<EmotionReportScreen> createState() => _EmotionReportScreenState();
}

class _EmotionReportScreenState extends State<EmotionReportScreen> {
  int _periodIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SoftPage(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        child: Column(
          children: [
            SoftHeader(
              title: '情绪报告',
              onBack: () => Navigator.of(context).pop(),
            ),
            const SizedBox(height: 20),
            _SegmentedTabs(
              labels: const ['本周', '本月', '全部'],
              selectedIndex: _periodIndex,
              onSelected: (index) => setState(() => _periodIndex = index),
            ),
            const SizedBox(height: 18),
            SoftCard(
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '你的情绪正在慢慢变好',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: SoftColors.text,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          '坚持释放，情绪会越来越轻松',
                          style: TextStyle(
                            fontSize: 16,
                            color: SoftColors.subtext,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.favorite_rounded,
                    color: Color(0xFFFFA1A5),
                    size: 94,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: const [
                Expanded(
                  child: _MetricBox(
                    icon: Icons.cloud_upload_rounded,
                    iconColors: [Color(0xFFFFD9D0), Color(0xFFFF7562)],
                    title: '累计释放',
                    value: '26',
                    unit: '次',
                    delta: '+8次',
                    deltaColor: Color(0xFF16C37D),
                  ),
                ),
                SizedBox(width: 14),
                Expanded(
                  child: _MetricBox(
                    icon: Icons.timelapse_rounded,
                    iconColors: [Color(0xFFE7DFFF), Color(0xFF8B6EFF)],
                    title: '平均时长',
                    value: '6',
                    unit: '分钟',
                    delta: '+1分钟',
                    deltaColor: SoftColors.coral,
                  ),
                ),
                SizedBox(width: 14),
                Expanded(
                  child: _MetricBox(
                    icon: Icons.shield_rounded,
                    iconColors: [Color(0xFFFFEDC9), Color(0xFFFFBE48)],
                    title: '情绪稳定度',
                    value: '78',
                    unit: '%',
                    delta: '+12%',
                    deltaColor: Color(0xFF16C37D),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            SoftCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Text(
                        '近7天情绪趋势',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: SoftColors.text,
                        ),
                      ),
                      Spacer(),
                      Text(
                        '情绪稳定度评分（0-100）',
                        style: TextStyle(
                          fontSize: 16,
                          color: SoftColors.subtext,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    height: 230,
                    child: LineChart(
                      LineChartData(
                        minY: 0,
                        maxY: 100,
                        gridData: FlGridData(
                          horizontalInterval: 25,
                          drawVerticalLine: false,
                          getDrawingHorizontalLine: (_) => const FlLine(
                            color: Color(0xFFF2E7E0),
                            strokeWidth: 1,
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        titlesData: FlTitlesData(
                          topTitles: const AxisTitles(),
                          rightTitles: const AxisTitles(),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 28,
                              interval: 25,
                              getTitlesWidget: (value, meta) => Text(
                                '${value.toInt()}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: SoftColors.subtext,
                                ),
                              ),
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 1,
                              getTitlesWidget: (value, meta) {
                                const labels = ['周四', '周五', '周六', '周日', '周一', '周二', '今天'];
                                final index = value.toInt();
                                if (index < 0 || index >= labels.length) {
                                  return const SizedBox.shrink();
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    labels[index],
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: SoftColors.subtext,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            isCurved: true,
                            barWidth: 4,
                            color: Colors.transparent,
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFFFB640),
                                Color(0xFF67D48B),
                                Color(0xFF4EB9FF),
                                Color(0xFFC56BFF),
                                Color(0xFFFF7FB3),
                              ],
                            ),
                            spots: const [
                              FlSpot(0, 48),
                              FlSpot(1, 78),
                              FlSpot(2, 60),
                              FlSpot(3, 45),
                              FlSpot(4, 68),
                              FlSpot(5, 84),
                              FlSpot(6, 72),
                            ],
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  const Color(0xFFD799FF).withValues(alpha: 0.28),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, bar, index) {
                                final colors = [
                                  const Color(0xFFFFA640),
                                  const Color(0xFFFFC335),
                                  const Color(0xFF8ED266),
                                  const Color(0xFF4CC9BE),
                                  const Color(0xFF57B6FF),
                                  const Color(0xFFB66DFF),
                                  const Color(0xFFFF84B5),
                                ];
                                return FlDotCirclePainter(
                                  radius: 5,
                                  color: colors[index],
                                  strokeWidth: 3,
                                  strokeColor: Colors.white,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: SoftCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '情绪分布',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: SoftColors.text,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            SizedBox(
                              width: 136,
                              height: 136,
                              child: PieChart(
                                PieChartData(
                                  centerSpaceRadius: 32,
                                  sectionsSpace: 2,
                                  sections: [
                                    PieChartSectionData(
                                      value: 22,
                                      color: Color(0xFFFF7270),
                                      radius: 26,
                                      showTitle: false,
                                    ),
                                    PieChartSectionData(
                                      value: 28,
                                      color: Color(0xFFFFB15B),
                                      radius: 26,
                                      showTitle: false,
                                    ),
                                    PieChartSectionData(
                                      value: 25,
                                      color: Color(0xFFB48BFF),
                                      radius: 26,
                                      showTitle: false,
                                    ),
                                    PieChartSectionData(
                                      value: 25,
                                      color: Color(0xFF67B0FF),
                                      radius: 26,
                                      showTitle: false,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _LegendItem('愤怒', '22%', Color(0xFFFF7270)),
                                  SizedBox(height: 10),
                                  _LegendItem('委屈', '28%', Color(0xFFFFB15B)),
                                  SizedBox(height: 10),
                                  _LegendItem('焦虑', '25%', Color(0xFFB48BFF)),
                                  SizedBox(height: 10),
                                  _LegendItem('平静', '25%', Color(0xFF67B0FF)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: SoftCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          '高频关键词',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: SoftColors.text,
                          ),
                        ),
                        SizedBox(height: 18),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            SoftTag(text: '加班', color: Color(0xFFFF5F5C)),
                            SoftTag(text: '压力', color: Color(0xFFFF9C31)),
                            SoftTag(text: '委屈', color: Color(0xFF9D7CFF)),
                            SoftTag(text: '沟通', color: Color(0xFF4F9DFF)),
                            SoftTag(text: '休息', color: Color(0xFF38C787)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const EmotionAnalysisDetailScreen(),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(30),
                child: Ink(
                  height: 96,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: const LinearGradient(
                      colors: [SoftColors.coral, SoftColors.orange],
                    ),
                  ),
                  child: const Row(
                    children: [
                      SizedBox(width: 36),
                      Text(
                        '查看详细分析',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 10),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                      Spacer(),
                      Padding(
                        padding: EdgeInsets.only(right: 28),
                        child: Icon(
                          Icons.manage_search_rounded,
                          color: Colors.white,
                          size: 60,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EmotionAnalysisDetailScreen extends StatefulWidget {
  const EmotionAnalysisDetailScreen({super.key});

  @override
  State<EmotionAnalysisDetailScreen> createState() =>
      _EmotionAnalysisDetailScreenState();
}

class _EmotionAnalysisDetailScreenState
    extends State<EmotionAnalysisDetailScreen> {
  int _mode = 2;

  @override
  Widget build(BuildContext context) {
    return SoftPage(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        child: Column(
          children: [
            SoftHeader(
              title: '详细分析',
              onBack: () => Navigator.of(context).pop(),
            ),
            const SizedBox(height: 18),
            _SegmentedTabs(
              labels: const ['日', '周', '月'],
              selectedIndex: _mode,
              onSelected: (index) => setState(() => _mode = index),
            ),
            const SizedBox(height: 18),
            SoftCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        '30天情绪变化',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: SoftColors.text,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.82),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: const Color(0xFFF2E2D9)),
                        ),
                        child: const Row(
                          children: [
                            Text(
                              '压力指数',
                              style: TextStyle(
                                fontSize: 16,
                                color: SoftColors.subtext,
                              ),
                            ),
                            SizedBox(width: 6),
                            Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 18,
                              color: SoftColors.subtext,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 310,
                    child: LineChart(
                      LineChartData(
                        minY: 0,
                        maxY: 3,
                        gridData: FlGridData(
                          horizontalInterval: 1,
                          drawVerticalLine: false,
                          getDrawingHorizontalLine: (_) => const FlLine(
                            color: Color(0xFFF0E5DE),
                            strokeWidth: 1,
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        titlesData: FlTitlesData(
                          topTitles: const AxisTitles(),
                          rightTitles: const AxisTitles(),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 32,
                              getTitlesWidget: (value, meta) {
                                const labels = ['平静', '低', '中', '高'];
                                return Text(
                                  labels[value.toInt()],
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: SoftColors.subtext,
                                  ),
                                );
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 1,
                              getTitlesWidget: (value, meta) {
                                const labels = [
                                  '03-28',
                                  '04-03',
                                  '04-10',
                                  '04-14',
                                  '04-18',
                                  '04-25',
                                  '04-29'
                                ];
                                final index = value.toInt();
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    labels[index],
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: SoftColors.subtext,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        extraLinesData: ExtraLinesData(horizontalLines: const []),
                        lineTouchData: const LineTouchData(enabled: false),
                        lineBarsData: [
                          LineChartBarData(
                            isCurved: true,
                            color: const Color(0xFFFF7D70),
                            barWidth: 4,
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  const Color(0xFFFF8B7E).withValues(alpha: 0.28),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                            spots: const [
                              FlSpot(0, 0.6),
                              FlSpot(1, 0.1),
                              FlSpot(2, 1.5),
                              FlSpot(3, 0.8),
                              FlSpot(4, 2.2),
                              FlSpot(5, 1.2),
                              FlSpot(6, 2.25),
                            ],
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, bar, index) =>
                                  FlDotCirclePainter(
                                radius: 5,
                                color: const Color(0xFFFF8A7A),
                                strokeWidth: 3,
                                strokeColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: SoftCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '模式占比',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: SoftColors.text,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            SizedBox(
                              width: 150,
                              height: 150,
                              child: PieChart(
                                PieChartData(
                                  centerSpaceRadius: 42,
                                  sectionsSpace: 0,
                                  sections: [
                                    PieChartSectionData(
                                      value: 65,
                                      color: Color(0xFFFF8C5E),
                                      radius: 18,
                                      showTitle: false,
                                    ),
                                    PieChartSectionData(
                                      value: 35,
                                      color: Color(0xFF9A84FF),
                                      radius: 18,
                                      showTitle: false,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _LegendItem('单向', '65%', Color(0xFFFF8C5E)),
                                  SizedBox(height: 18),
                                  _LegendItem('双向', '35%', Color(0xFF9A84FF)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: SoftCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Text(
                              '对象类型',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: SoftColors.text,
                              ),
                            ),
                            Spacer(),
                            Text(
                              '查看更多',
                              style: TextStyle(
                                fontSize: 14,
                                color: SoftColors.subtext,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const _RankItem(
                          label: '老板',
                          value: 0.4,
                          color: Color(0xFFFF6D68),
                          icon: Icons.person_rounded,
                        ),
                        const SizedBox(height: 16),
                        const _RankItem(
                          label: '同事',
                          value: 0.3,
                          color: Color(0xFF9A84FF),
                          icon: Icons.groups_rounded,
                        ),
                        const SizedBox(height: 16),
                        const _RankItem(
                          label: '前任',
                          value: 0.2,
                          color: Color(0xFF78D49C),
                          icon: Icons.favorite_border_rounded,
                        ),
                        const SizedBox(height: 16),
                        const _RankItem(
                          label: '客户',
                          value: 0.1,
                          color: Color(0xFFFFC167),
                          icon: Icons.handshake_rounded,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            SoftCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '释放时段偏好',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: SoftColors.text,
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    height: 240,
                    child: BarChart(
                      BarChartData(
                        maxY: 60,
                        gridData: FlGridData(
                          horizontalInterval: 20,
                          drawVerticalLine: false,
                          getDrawingHorizontalLine: (_) => const FlLine(
                            color: Color(0xFFF0E5DE),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        titlesData: FlTitlesData(
                          topTitles: const AxisTitles(),
                          rightTitles: const AxisTitles(),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 20,
                              reservedSize: 30,
                              getTitlesWidget: (value, meta) => Text(
                                '${value.toInt()}%',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: SoftColors.subtext,
                                ),
                              ),
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                const labels = ['上午', '下午', '晚上', '深夜'];
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    labels[value.toInt()],
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: SoftColors.text,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        barGroups: [
                          BarChartGroupData(
                            x: 0,
                            barRods: [
                              BarChartRodData(
                                toY: 13,
                                width: 28,
                                color: Color(0xFFFF7A67),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                              ),
                            ],
                          ),
                          BarChartGroupData(
                            x: 1,
                            barRods: [
                              BarChartRodData(
                                toY: 28,
                                width: 28,
                                color: Color(0xFFFF7A67),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                              ),
                            ],
                          ),
                          BarChartGroupData(
                            x: 2,
                            barRods: [
                              BarChartRodData(
                                toY: 46,
                                width: 28,
                                color: Color(0xFFFF7A67),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                              ),
                            ],
                          ),
                          BarChartGroupData(
                            x: 3,
                            barRods: [
                              BarChartRodData(
                                toY: 13,
                                width: 28,
                                color: Color(0xFFFF7A67),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            SoftCard(
              child: Row(
                children: const [
                  Icon(
                    Icons.favorite_rounded,
                    color: Color(0xFFFFA0A4),
                    size: 90,
                  ),
                  SizedBox(width: 18),
                  Expanded(
                    child: Text(
                      '最近你的高压情绪主要集中在工作日晚 上，建议在高压后尽快进行短时释放。',
                      style: TextStyle(
                        fontSize: 18,
                        height: 1.75,
                        color: SoftColors.text,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _showFilterSheet,
                icon: const Icon(Icons.filter_alt_outlined),
                label: const Text('筛选'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showFilterSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: Colors.black.withValues(alpha: 0.32),
      builder: (context) => const _FilterSheet(),
    );
  }
}

class _MetricBox extends StatelessWidget {
  const _MetricBox({
    required this.icon,
    required this.iconColors,
    required this.title,
    required this.value,
    required this.unit,
    required this.delta,
    required this.deltaColor,
  });

  final IconData icon;
  final List<Color> iconColors;
  final String title;
  final String value;
  final String unit;
  final String delta;
  final Color deltaColor;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SoftIconBadge(icon: icon, colors: iconColors),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(fontSize: 16, color: SoftColors.subtext),
          ),
          const SizedBox(height: 10),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: SoftColors.text,
                  ),
                ),
                TextSpan(
                  text: unit,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: SoftColors.text,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '较上周  $delta',
            style: TextStyle(fontSize: 15, color: deltaColor),
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem(this.label, this.value, this.color);

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 16, color: SoftColors.text),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(fontSize: 16, color: SoftColors.subtext),
        ),
      ],
    );
  }
}

class _RankItem extends StatelessWidget {
  const _RankItem({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String label;
  final double value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 42,
          child: Text(
            label,
            style: const TextStyle(fontSize: 16, color: SoftColors.text),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 12,
              backgroundColor: const Color(0xFFF3ECE7),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          '${(value * 100).round()}%',
          style: const TextStyle(fontSize: 16, color: SoftColors.text),
        ),
      ],
    );
  }
}

class _SegmentedTabs extends StatelessWidget {
  const _SegmentedTabs({
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.66),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white),
      ),
      child: Row(
        children: List.generate(labels.length, (index) {
          final selected = index == selectedIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => onSelected(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: selected
                      ? const LinearGradient(
                          colors: [SoftColors.coral, Color(0xFFFF8E61)],
                        )
                      : null,
                  color: selected ? null : Colors.transparent,
                ),
                child: Text(
                  labels[index],
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: selected ? Colors.white : SoftColors.subtext,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _FilterSheet extends StatelessWidget {
  const _FilterSheet();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 120),
      child: SoftCard(
        radius: 30,
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 56,
                  height: 6,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE7DFDA),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Center(
                child: Text(
                  '筛选报告',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: SoftColors.text,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                '时间范围',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: SoftColors.text,
                ),
              ),
              const SizedBox(height: 16),
              const Wrap(
                spacing: 14,
                runSpacing: 14,
                children: [
                  _Chip('近7天', false),
                  _Chip('近30天', true),
                  _Chip('近90天', false),
                  _Chip('自定义', false),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                '报告维度',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: SoftColors.text,
                ),
              ),
              const SizedBox(height: 16),
              const _CheckCard(
                icon: Icons.show_chart_rounded,
                color: Color(0xFFFF7270),
                title: '情绪趋势',
                subtitle: '查看情绪随时间的变化趋势',
              ),
              const SizedBox(height: 12),
              const _CheckCard(
                icon: Icons.pie_chart_rounded,
                color: Color(0xFFFFBE48),
                title: '情绪分布',
                subtitle: '了解不同情绪类型的占比情况',
              ),
              const SizedBox(height: 12),
              const _CheckCard(
                icon: Icons.tag_rounded,
                color: Color(0xFF9A84FF),
                title: '高频关键词',
                subtitle: '识别情绪相关的高频词汇',
              ),
              const SizedBox(height: 12),
              const _CheckCard(
                icon: Icons.groups_rounded,
                color: Color(0xFF67B0FF),
                title: '对象类型',
                subtitle: '分析不同对象相关的情绪分布',
              ),
              const SizedBox(height: 12),
              const _CheckCard(
                icon: Icons.donut_large_rounded,
                color: Color(0xFFFFC468),
                title: '模式占比',
                subtitle: '发现你的情绪模式分布情况',
              ),
              const SizedBox(height: 24),
              const Text(
                '排序方式',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: SoftColors.text,
                ),
              ),
              const SizedBox(height: 16),
              const Row(
                children: [
                  Expanded(child: _RadioCard('按时间', true)),
                  SizedBox(width: 14),
                  Expanded(child: _RadioCard('按情绪波动', false)),
                ],
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: SoftOutlineButton(
                      text: '重置',
                      textColor: SoftColors.coral,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: SoftGradientButton(
                      text: '应用筛选',
                      onTap: () => Navigator.of(context).pop(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip(this.label, this.selected);

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 58,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withValues(alpha: 0.78),
        border: Border.all(
          color: selected ? const Color(0xFFFFC9BD) : const Color(0xFFF2E3DB),
          width: 1.4,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: selected ? SoftColors.coral : SoftColors.subtext,
        ),
      ),
    );
  }
}

class _CheckCard extends StatelessWidget {
  const _CheckCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      radius: 22,
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: SoftColors.coral,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 14),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: SoftColors.text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: SoftColors.subtext,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RadioCard extends StatelessWidget {
  const _RadioCard(this.label, this.selected);

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      radius: 22,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? SoftColors.coral : const Color(0xFFC9CDD4),
                width: 2,
              ),
            ),
            child: selected
                ? const Center(
                    child: CircleAvatar(
                      radius: 6,
                      backgroundColor: SoftColors.coral,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 18,
              color: SoftColors.text,
            ),
          ),
        ],
      ),
    );
  }
}
