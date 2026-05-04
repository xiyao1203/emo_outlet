import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../widgets/common/soft_ui.dart';

class EmotionReportScreen extends StatefulWidget {
  const EmotionReportScreen({super.key});

  @override
  State<EmotionReportScreen> createState() => _EmotionReportScreenState();
}

class _EmotionReportScreenState extends State<EmotionReportScreen> {
  final ApiService _api = ApiService();
  int _periodIndex = 0;
  bool _loading = true;
  Map<String, dynamic>? _overview;
  Map<String, dynamic>? _detail;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final period = _overviewPeriod;
    try {
      final overview = await _api.getEmotionReport(period: period);
      final detail = await _api.getEmotionReportDetail(
        period: period == 'all' ? 'monthly' : period,
      );
      if (!mounted) return;
      setState(() {
        _overview = overview;
        _detail = detail;
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  String get _overviewPeriod {
    switch (_periodIndex) {
      case 1:
        return 'monthly';
      case 2:
        return 'all';
      default:
        return 'weekly';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SoftPage(
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                    onSelected: (index) async {
                      setState(() => _periodIndex = index);
                      await _load();
                    },
                  ),
                  const SizedBox(height: 18),
                  SoftCard(
                    padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '你的情绪正在慢慢变好',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: SoftColors.text,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                _overview?['suggestion'] as String? ?? '',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: SoftColors.subtext,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.favorite_rounded,
                          color: Color(0xFFFFA1A5),
                          size: 72,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: _MetricBox(
                          icon: Icons.cloud_upload_rounded,
                          iconColors: const [
                            Color(0xFFFFD9D0),
                            Color(0xFFFF7562)
                          ],
                          title: '累计释放',
                          value: '${_overview?['total_sessions'] ?? 0}',
                          unit: '次',
                          delta:
                              _overview?['dominant_emotion'] as String? ?? '-',
                          deltaColor: const Color(0xFF16C37D),
                          deltaPrefix: '主导情绪 ',
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _MetricBox(
                          icon: Icons.timelapse_rounded,
                          iconColors: const [
                            Color(0xFFE7DFFF),
                            Color(0xFF8B6EFF)
                          ],
                          title: '累计时长',
                          value: '${_overview?['total_duration_minutes'] ?? 0}',
                          unit: '分钟',
                          delta: _detail?['period'] as String? ?? '-',
                          deltaColor: SoftColors.coral,
                          deltaPrefix: '统计周期 ',
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _MetricBox(
                          icon: Icons.shield_rounded,
                          iconColors: const [
                            Color(0xFFFFEDC9),
                            Color(0xFFFFBE48)
                          ],
                          title: '情绪种类',
                          value:
                              '${(_overview?['emotion_distribution'] as Map<String, dynamic>? ?? {}).length}',
                          unit: '类',
                          delta: '${_trendPoints.length}条',
                          deltaColor: const Color(0xFF16C37D),
                          deltaPrefix: '趋势点 ',
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
                              '趋势变化',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: SoftColors.text,
                              ),
                            ),
                            Spacer(),
                            Text(
                              '强度评分',
                              style: TextStyle(
                                fontSize: 14,
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
                                    getTitlesWidget: (value, _) => Text(
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
                                    getTitlesWidget: (value, _) {
                                      final index = value.toInt();
                                      if (index < 0 ||
                                          index >= _trendPoints.length) {
                                        return const SizedBox.shrink();
                                      }
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Text(
                                          (_trendPoints[index]['date']
                                                  as String?) ??
                                              '',
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
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFFFB640),
                                      Color(0xFF67D48B),
                                      Color(0xFF4EB9FF),
                                      Color(0xFFC56BFF),
                                      Color(0xFFFF7FB3),
                                    ],
                                  ),
                                  spots: _trendSpots,
                                  belowBarData: BarAreaData(
                                    show: true,
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        const Color(0xFFD799FF)
                                            .withValues(alpha: 0.28),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                  dotData: FlDotData(show: true),
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
                                  fontSize: 18,
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
                                        sections: _distributionSections,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: _distributionEntries
                                          .map((entry) => Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 10),
                                                child: _LegendItem(
                                                  entry.key,
                                                  '${entry.value.toStringAsFixed(1)}%',
                                                  _emotionColor(entry.key),
                                                ),
                                              ))
                                          .toList(),
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
                              const Text(
                                '高频关键词',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: SoftColors.text,
                                ),
                              ),
                              const SizedBox(height: 18),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: _keywordItems
                                    .map((item) => SoftTag(
                                          text: item,
                                          color: _emotionColor(item),
                                        ))
                                    .toList(),
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
                            builder: (_) =>
                                EmotionAnalysisDetailScreen(detail: _detail),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(30),
                      child: Ink(
                        height: 82,
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
                                fontSize: 18,
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
                                size: 44,
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

  List<MapEntry<String, double>> get _distributionEntries {
    final distribution =
        (_overview?['emotion_distribution'] as Map<String, dynamic>? ?? {})
            .map((key, value) => MapEntry(key, (value as num).toDouble()))
            .entries
            .toList();
    if (distribution.isEmpty) {
      return [const MapEntry('暂无', 100)];
    }
    return distribution;
  }

  List<PieChartSectionData> get _distributionSections {
    return _distributionEntries
        .map(
          (entry) => PieChartSectionData(
            value: entry.value,
            color: _emotionColor(entry.key),
            radius: 26,
            showTitle: false,
          ),
        )
        .toList();
  }

  List<dynamic> get _trendPoints =>
      _detail?['trend_points'] as List<dynamic>? ?? <dynamic>[];

  List<FlSpot> get _trendSpots {
    if (_trendPoints.isEmpty) {
      return const [FlSpot(0, 0)];
    }
    return _trendPoints.asMap().entries.map((entry) {
      final item = entry.value as Map<String, dynamic>;
      return FlSpot(
          entry.key.toDouble(), (item['score'] as num?)?.toDouble() ?? 0);
    }).toList();
  }

  List<String> get _keywordItems {
    final items = _detail?['keyword_counts'] as List<dynamic>? ?? <dynamic>[];
    if (items.isEmpty) {
      return ['暂无关键词'];
    }
    return items
        .take(6)
        .map((item) => (item as Map<String, dynamic>)['name'] as String? ?? '-')
        .toList();
  }

  Color _emotionColor(String key) {
    switch (key) {
      case '愤怒':
      case '加班':
        return const Color(0xFFFF7270);
      case '委屈':
      case '压力':
        return const Color(0xFFFFB15B);
      case '焦虑':
        return const Color(0xFFB48BFF);
      case '平静':
      case '休息':
        return const Color(0xFF67B0FF);
      default:
        return const Color(0xFF38C787);
    }
  }
}

class EmotionAnalysisDetailScreen extends StatefulWidget {
  const EmotionAnalysisDetailScreen({super.key, required this.detail});

  final Map<String, dynamic>? detail;

  @override
  State<EmotionAnalysisDetailScreen> createState() =>
      _EmotionAnalysisDetailScreenState();
}

class _EmotionAnalysisDetailScreenState
    extends State<EmotionAnalysisDetailScreen> {
  int _mode = 2;

  @override
  Widget build(BuildContext context) {
    final detail = widget.detail ?? <String, dynamic>{};
    final targetDistribution =
        detail['target_distribution'] as List<dynamic>? ?? <dynamic>[];
    final timeDistribution =
        detail['time_distribution'] as List<dynamic>? ?? <dynamic>[];
    final modeDistribution =
        detail['mode_distribution'] as Map<String, dynamic>? ??
            <String, dynamic>{};
    final trendPoints = detail['trend_points'] as List<dynamic>? ?? <dynamic>[];

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
                  const Text(
                    '趋势详情',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: SoftColors.text,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 240,
                    child: LineChart(
                      LineChartData(
                        minY: 0,
                        maxY: 100,
                        gridData: FlGridData(drawVerticalLine: false),
                        borderData: FlBorderData(show: false),
                        titlesData: FlTitlesData(
                          topTitles: const AxisTitles(),
                          rightTitles: const AxisTitles(),
                          leftTitles: const AxisTitles(),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, _) {
                                final index = value.toInt();
                                if (index < 0 || index >= trendPoints.length) {
                                  return const SizedBox.shrink();
                                }
                                return Text(
                                  (trendPoints[index]
                                              as Map<String, dynamic>)['date']
                                          as String? ??
                                      '',
                                  style: const TextStyle(
                                      fontSize: 12, color: SoftColors.subtext),
                                );
                              },
                            ),
                          ),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            isCurved: true,
                            spots: trendPoints.asMap().entries.map((entry) {
                              final point = entry.value as Map<String, dynamic>;
                              return FlSpot(entry.key.toDouble(),
                                  (point['score'] as num?)?.toDouble() ?? 0);
                            }).toList(),
                            color: SoftColors.coral,
                            barWidth: 4,
                            dotData: FlDotData(show: true),
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
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: SoftColors.text,
                          ),
                        ),
                        const SizedBox(height: 18),
                        _LegendItem(
                            '单向',
                            '${(modeDistribution['single'] ?? 0)}%',
                            const Color(0xFFFF7270)),
                        const SizedBox(height: 10),
                        _LegendItem('双向', '${(modeDistribution['dual'] ?? 0)}%',
                            const Color(0xFFB48BFF)),
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
                        const Text(
                          '对象类型',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: SoftColors.text,
                          ),
                        ),
                        const SizedBox(height: 18),
                        ...targetDistribution.take(4).map((item) {
                          final map = item as Map<String, dynamic>;
                          final percent =
                              ((map['percent'] as num?)?.toDouble() ?? 0) / 100;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _RankItem(
                              label: map['name'] as String? ?? '-',
                              value: percent,
                              color: const Color(0xFFFF7270),
                              icon: Icons.person_rounded,
                            ),
                          );
                        }),
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
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: SoftColors.text,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 220,
                    child: BarChart(
                      BarChartData(
                        gridData: FlGridData(drawVerticalLine: false),
                        borderData: FlBorderData(show: false),
                        titlesData: FlTitlesData(
                          topTitles: const AxisTitles(),
                          rightTitles: const AxisTitles(),
                          leftTitles: const AxisTitles(),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, _) {
                                final index = value.toInt();
                                if (index < 0 ||
                                    index >= timeDistribution.length) {
                                  return const SizedBox.shrink();
                                }
                                return Text(
                                  (timeDistribution[index]
                                              as Map<String, dynamic>)['name']
                                          as String? ??
                                      '',
                                  style: const TextStyle(
                                      fontSize: 14, color: SoftColors.text),
                                );
                              },
                            ),
                          ),
                        ),
                        barGroups:
                            timeDistribution.asMap().entries.map((entry) {
                          final item = entry.value as Map<String, dynamic>;
                          return BarChartGroupData(
                            x: entry.key,
                            barRods: [
                              BarChartRodData(
                                toY: (item['percent'] as num?)?.toDouble() ?? 0,
                                width: 28,
                                color: const Color(0xFFFF7A67),
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(10)),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
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

class _MetricBox extends StatelessWidget {
  const _MetricBox({
    required this.icon,
    required this.iconColors,
    required this.title,
    required this.value,
    required this.unit,
    required this.delta,
    required this.deltaColor,
    required this.deltaPrefix,
  });

  final IconData icon;
  final List<Color> iconColors;
  final String title;
  final String value;
  final String unit;
  final String delta;
  final Color deltaColor;
  final String deltaPrefix;

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
                    fontSize: 24,
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
            '$deltaPrefix$delta',
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
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 16, color: SoftColors.text),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: value.clamp(0, 1),
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
