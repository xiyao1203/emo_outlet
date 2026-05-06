import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../widgets/common/emo_ui.dart';
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
  String? _errorMessage;
  Map<String, dynamic>? _overview;
  Map<String, dynamic>? _detail;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
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
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = '报告加载失败，请稍后重试';
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final horizontal = EmoResponsive.edgePadding(width);

        return SoftPage(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(horizontal, 18, horizontal, 24),
                  child: EmoResponsiveContent(
                    width: width,
                    maxWidth: 760,
                    child: _errorMessage != null ? _buildErrorState() : _buildContent(width),
                  ),
                ),
        );
      },
    );
  }

  Widget _buildErrorState() {
    return Column(
      children: [
        SoftHeader(
          title: '情绪报告',
          onBack: () => Navigator.of(context).pop(),
        ),
        const SizedBox(height: 28),
        SoftCard(
          padding: const EdgeInsets.fromLTRB(22, 26, 22, 24),
          child: Column(
            children: [
              const Icon(
                Icons.insert_chart_outlined_rounded,
                size: 48,
                color: Color(0xFFFF8A70),
              ),
              const SizedBox(height: 14),
              Text(
                _errorMessage!,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: SoftColors.text,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '可能是网络波动，或者当前报告数据还在生成中。',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.45,
                  color: SoftColors.subtext,
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: SoftGradientButton(
                  text: '重新加载',
                  onTap: _load,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContent(double width) {
    final compact = width < 430;
    final distributionVertical = width < 560;

    return Column(
      children: [
        SoftHeader(
          title: '情绪报告',
          onBack: () => Navigator.of(context).pop(),
        ),
        const SizedBox(height: 18),
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
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '你的情绪正在慢慢变好',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: SoftColors.text,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      (_overview?['suggestion'] as String?) ?? '你已经开始认真面对自己的情绪了。',
                      style: const TextStyle(
                        fontSize: 12.8,
                        height: 1.5,
                        color: SoftColors.subtext,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Icon(
                Icons.favorite_rounded,
                color: Color(0xFFFFA1A5),
                size: 58,
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _MetricBox(
                icon: Icons.chat_bubble_outline_rounded,
                iconColors: const [Color(0xFFFFD9D0), Color(0xFFFF7562)],
                title: '累计释放',
                value: _safeInt(_overview?['total_sessions']).toString(),
                unit: '次',
                footer: '主导情绪 $_dominantEmotion',
                footerColor: const Color(0xFF16C37D),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricBox(
                icon: Icons.schedule_rounded,
                iconColors: const [Color(0xFFE7DFFF), Color(0xFF8B6EFF)],
                title: '累计时长',
                value: _safeInt(_overview?['total_duration_minutes']).toString(),
                unit: '分钟',
                footer: '统计周期 $_periodLabel',
                footerColor: SoftColors.coral,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricBox(
                icon: Icons.dashboard_customize_outlined,
                iconColors: const [Color(0xFFFFEDC9), Color(0xFFFFBE48)],
                title: '情绪种类',
                value: _distributionEntries.length.toString(),
                unit: '类',
                footer: '趋势点 ${_trendPoints.length} 个',
                footerColor: const Color(0xFF16C37D),
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
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: SoftColors.text,
                    ),
                  ),
                  Spacer(),
                  Text(
                    '强度评分',
                    style: TextStyle(fontSize: 12.8, color: SoftColors.subtext),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: compact ? 210 : 236,
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
                          reservedSize: 30,
                          interval: 25,
                          getTitlesWidget: (value, _) => Text(
                            '${value.toInt()}',
                            style: const TextStyle(
                              fontSize: 12,
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
                            if (index < 0 || index >= _trendPoints.length) {
                              return const SizedBox.shrink();
                            }
                            final label =
                                (_trendPoints[index]['date'] as String?) ?? '';
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                label,
                                style: const TextStyle(
                                  fontSize: 11.5,
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
                              const Color(0xFFD799FF).withValues(alpha: 0.28),
                              Colors.transparent,
                            ],
                          ),
                        ),
                        dotData: const FlDotData(show: true),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        distributionVertical
            ? Column(
                children: [
                  _buildDistributionCard(),
                  const SizedBox(height: 14),
                  _buildKeywordsCard(),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildDistributionCard()),
                  const SizedBox(width: 14),
                  Expanded(child: _buildKeywordsCard()),
                ],
              ),
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => EmotionAnalysisDetailScreen(detail: _detail),
                ),
              );
            },
            borderRadius: BorderRadius.circular(30),
            child: Ink(
              height: 72,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: const LinearGradient(
                  colors: [SoftColors.coral, SoftColors.orange],
                ),
              ),
              child: const Row(
                children: [
                  SizedBox(width: 28),
                  Text(
                    '查看详细分析',
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                  Spacer(),
                  Padding(
                    padding: EdgeInsets.only(right: 24),
                    child: Icon(
                      Icons.manage_search_rounded,
                      color: Colors.white,
                      size: 34,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDistributionCard() {
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '情绪分布',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: SoftColors.text,
            ),
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final narrow = constraints.maxWidth < 300;
              final chart = SizedBox(
                width: 136,
                height: 136,
                child: PieChart(
                  PieChartData(
                    centerSpaceRadius: 32,
                    sectionsSpace: 2,
                    sections: _distributionSections,
                  ),
                ),
              );
              final legend = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _distributionEntries
                    .map(
                      (entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _LegendItem(
                          entry.key,
                          '${entry.value.toStringAsFixed(1)}%',
                          _emotionColor(entry.key),
                        ),
                      ),
                    )
                    .toList(),
              );

              if (narrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    chart,
                    const SizedBox(height: 14),
                    legend,
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  chart,
                  const SizedBox(width: 12),
                  Expanded(child: legend),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildKeywordsCard() {
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '高频关键词',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: SoftColors.text,
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _keywordItems
                .map(
                  (item) => SoftTag(
                    text: item,
                    color: _emotionColor(item),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  String get _dominantEmotion =>
      (_overview?['dominant_emotion'] as String?)?.trim().isNotEmpty == true
          ? _overview!['dominant_emotion'] as String
          : '平静';

  String get _periodLabel {
    switch (_overviewPeriod) {
      case 'monthly':
        return '本月';
      case 'all':
        return '全部';
      default:
        return '本周';
    }
  }

  List<MapEntry<String, double>> get _distributionEntries {
    final distribution =
        (_overview?['emotion_distribution'] as Map<String, dynamic>? ?? {})
            .map(
              (key, value) => MapEntry(
                key,
                value is num ? value.toDouble() : double.tryParse('$value') ?? 0,
              ),
            )
            .entries
            .where((entry) => entry.value > 0)
            .toList();
    if (distribution.isEmpty) {
      return [const MapEntry('暂无数据', 100)];
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
        entry.key.toDouble(),
        (item['score'] as num?)?.toDouble() ?? 0,
      );
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

  int _safeInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('$value') ?? 0;
  }

  Color _emotionColor(String key) {
    switch (key) {
      case '愤怒':
      case '生气':
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

class EmotionAnalysisDetailScreen extends StatelessWidget {
  const EmotionAnalysisDetailScreen({super.key, required this.detail});

  final Map<String, dynamic>? detail;

  @override
  Widget build(BuildContext context) {
    final safeDetail = detail ?? <String, dynamic>{};
    final targetDistribution =
        safeDetail['target_distribution'] as List<dynamic>? ?? <dynamic>[];
    final timeDistribution =
        safeDetail['time_distribution'] as List<dynamic>? ?? <dynamic>[];
    final modeDistribution =
        safeDetail['mode_distribution'] as Map<String, dynamic>? ?? <String, dynamic>{};

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final horizontal = EmoResponsive.edgePadding(width);

        return SoftPage(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(horizontal, 18, horizontal, 24),
            child: EmoResponsiveContent(
              width: width,
              maxWidth: 760,
              child: Column(
                children: [
                  SoftHeader(
                    title: '详细分析',
                    onBack: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(height: 18),
                  SoftCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '聊天模式分布',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: SoftColors.text,
                          ),
                        ),
                        const SizedBox(height: 18),
                        _ProgressItem(
                          label: '单向聊天',
                          value: (modeDistribution['single'] as num?)?.toDouble() ?? 0,
                          color: SoftColors.coral,
                        ),
                        const SizedBox(height: 14),
                        _ProgressItem(
                          label: '双向聊天',
                          value: (modeDistribution['dual'] as num?)?.toDouble() ?? 0,
                          color: const Color(0xFF8B6EFF),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  SoftCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '对象分布',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: SoftColors.text,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (targetDistribution.isEmpty)
                          const Text(
                            '还没有足够的数据形成对象分布。',
                            style: TextStyle(fontSize: 12.5, color: SoftColors.subtext),
                          )
                        else
                          ...targetDistribution.map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: _ProgressItem(
                                label: (item as Map<String, dynamic>)['name'] as String? ?? '-',
                                value: (item['percent'] as num?)?.toDouble() ?? 0,
                                color: const Color(0xFFFFB15B),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  SoftCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '时间分布',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: SoftColors.text,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (timeDistribution.isEmpty)
                          const Text(
                            '还没有足够的数据形成时间分布。',
                            style: TextStyle(fontSize: 12.5, color: SoftColors.subtext),
                          )
                        else
                          ...timeDistribution.map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: _ProgressItem(
                                label: (item as Map<String, dynamic>)['name'] as String? ?? '-',
                                value: (item['percent'] as num?)?.toDouble() ?? 0,
                                color: const Color(0xFF67B0FF),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white),
      ),
      child: Row(
        children: labels.asMap().entries.map((entry) {
          final active = entry.key == selectedIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => onSelected(entry.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: active
                      ? const LinearGradient(
                          colors: [SoftColors.coral, SoftColors.orange],
                        )
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  entry.value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: active ? Colors.white : SoftColors.text,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
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
    required this.footer,
    required this.footerColor,
  });

  final IconData icon;
  final List<Color> iconColors;
  final String title;
  final String value;
  final String unit;
  final String footer;
  final Color footerColor;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 154),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SoftIconBadge(icon: icon, colors: iconColors, size: 42),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: SoftColors.subtext,
              ),
            ),
            const SizedBox(height: 10),
            RichText(
              text: TextSpan(
                text: value,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: SoftColors.text,
                ),
                children: [
                  TextSpan(
                    text: unit,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: SoftColors.subtext,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Text(
              footer,
              style: TextStyle(
                fontSize: 12.5,
                height: 1.35,
                color: footerColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
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
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12.8,
              color: SoftColors.text,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12.5,
            color: SoftColors.subtext,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _ProgressItem extends StatelessWidget {
  const _ProgressItem({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final safeValue = value.clamp(0, 100);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: SoftColors.text,
                ),
              ),
            ),
            Text(
              '${safeValue.toStringAsFixed(1)}%',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: SoftColors.subtext,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: safeValue / 100,
            minHeight: 10,
            backgroundColor: const Color(0xFFF2E7E0),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
