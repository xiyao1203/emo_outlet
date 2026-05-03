import 'package:flutter/material.dart';
import '../../config/theme.dart';

class EmotionBar extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final bool showPercentage;

  const EmotionBar({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    this.showPercentage = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              if (showPercentage)
                Text(
                  '${value.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value / 100,
              backgroundColor: color.withOpacity(0.15),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}

class EmotionPieChart extends StatelessWidget {
  final Map<String, double> emotions;

  const EmotionPieChart({super.key, required this.emotions});

  @override
  Widget build(BuildContext context) {
    final colors = {
      '愤怒': AppColors.emotionAnger,
      '焦虑': AppColors.emotionAnxiety,
      '悲伤': AppColors.emotionSadness,
      '疲惫': AppColors.emotionPower,
      '无奈': AppColors.emotionCalm,
      '平静': AppColors.emotionCalm,
    };

    final total = emotions.values.fold(0.0, (a, b) => a + b);
    if (total <= 0) return const SizedBox();

    return Column(
      children: [
        // 饼图
        SizedBox(
          height: 160,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(160, 160),
                painter: _PieChartPainter(
                  emotions: emotions,
                  colors: colors,
                  total: total,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    emotions.entries
                        .reduce((a, b) => a.value > b.value ? a : b)
                        .key,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '主导情绪',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // 图例
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: emotions.entries.map((entry) {
            final c = colors[entry.key] ?? Colors.grey;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: c,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '${entry.key} ${(entry.value / total * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _PieChartPainter extends CustomPainter {
  final Map<String, double> emotions;
  final Map<String, Color> colors;
  final double total;

  _PieChartPainter({
    required this.emotions,
    required this.colors,
    required this.total,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    double startAngle = -90 * (3.14159 / 180);

    for (final entry in emotions.entries) {
      final sweepAngle = (entry.value / total) * 360 * (3.14159 / 180);
      final color = colors[entry.key] ?? Colors.grey;

      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      canvas.drawArc(rect, startAngle, sweepAngle, true, paint);
      startAngle += sweepAngle;
    }

    // 内圈白色（挖空效果）
    final innerPaint = Paint()..color = Colors.white;
    canvas.drawCircle(center, radius * 0.55, innerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
