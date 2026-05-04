import 'package:flutter/material.dart';

import '../models/history_record_model.dart';
import '../widgets/auth/auth_visuals.dart';
import '../widgets/common/app_bottom_nav.dart';
import '../widgets/common/emo_ui.dart';
import 'home_screen.dart';

class HistoryDetailScreen extends StatelessWidget {
  const HistoryDetailScreen({super.key, required this.record});

  final HistoryRecordModel record;

  @override
  Widget build(BuildContext context) {
    return EmoPageScaffold(
      bottomNavigationBar: AppBottomNav(
        currentIndex: 2,
        onTap: (index) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => HomeScreen(initialIndex: index)),
          );
        },
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
        child: Column(
          children: [
            Row(
              children: [
                EmoRoundIconButton(
                  icon: Icons.chevron_left_rounded,
                  onTap: () => Navigator.of(context).pop(),
                ),
                const Spacer(),
                const Text(
                  '记录详情',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
                ),
                const Spacer(),
                const _DotAction(),
              ],
            ),
            const SizedBox(height: 18),
            EmoSectionCard(
              radius: 34,
              child: Column(
                children: [
                  Row(
                    children: [
                      _HistoryAvatar(avatar: record.avatar, size: 120),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              record.name,
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                color: AuthPalette.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              '管理你关心的人',
                              style: TextStyle(
                                fontSize: 18,
                                color: Color(0xFF7B716B),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const EmoDecorationCloud(size: 170),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(26),
                    ),
                    child: Row(
                      children: [
                        _miniStat(Icons.cloud_outlined, '模式', record.modeLabel),
                        _divider(),
                        _miniStat(Icons.access_time_rounded, '时长',
                            '${record.durationMinutes}分钟'),
                        _divider(),
                        _miniStat(
                            Icons.mic_none_rounded, '语言', record.language),
                        _divider(),
                        _miniStat(Icons.calendar_month_outlined, '日期',
                            _detailDate(record.timestamp)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            EmoSectionCard(
              radius: 30,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionTitle(Icons.bar_chart_rounded, '情绪释放概览'),
                        const SizedBox(height: 16),
                        _bar('愤怒', 0.62, const Color(0xFFFF5B57), '😠'),
                        _bar('委屈', 0.24, const Color(0xFFFF8A53), '😟'),
                        _bar('焦虑', 0.10, const Color(0xFFFFB63D), '😥'),
                        _bar('难过', 0.04, const Color(0xFF58A8F5), '😢'),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  _circleRate(record.releaseRate),
                ],
              ),
            ),
            const SizedBox(height: 16),
            EmoSectionCard(
              radius: 30,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle(Icons.sell_outlined, '关键词'),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: record.keywords
                        .map(
                          (item) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0x14FF7C68),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              item,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFFFF6E57),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            EmoSectionCard(
              radius: 30,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionTitle(Icons.favorite_rounded, '安抚总结'),
                        const SizedBox(height: 14),
                        Text(
                          record.summary,
                          style: const TextStyle(
                            fontSize: 17,
                            height: 1.7,
                            color: Color(0xFF4F4844),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  const EmoDecorationCloud(size: 130),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: EmoSectionCard(
                    radius: 30,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 18),
                    child: Column(
                      children: [
                        _actionRow(
                          icon: Icons.image_outlined,
                          title: '查看海报',
                          subtitle: '查看本次生成的专属海报',
                        ),
                        const Divider(height: 30, color: Color(0xFFF2E6E0)),
                        _actionRow(
                          icon: Icons.refresh_rounded,
                          title: '再次释放',
                          subtitle: '继续倾诉，释放更多情绪',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        '本次生成海报',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 10),
                      EmoSectionCard(
                        radius: 28,
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            Container(
                              height: 210,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(22),
                                gradient: const LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Color(0xFFFFF2EA),
                                    Color(0xFFFFD8CC)
                                  ],
                                ),
                              ),
                              child: Stack(
                                children: [
                                  const Positioned(
                                    left: 14,
                                    top: 14,
                                    child: AppBrand(
                                        fontSize: 10, logoSize: 18, spacing: 4),
                                  ),
                                  Positioned(
                                    left: 16,
                                    top: 58,
                                    child: Text(
                                      record.posterTitle,
                                      style: const TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFF332522),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 16,
                                    top: 120,
                                    child: Text(
                                      record.posterSubtitle,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF6F635C),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  const Positioned(
                                    right: 12,
                                    bottom: 10,
                                    child: EmoDecorationCloud(size: 110),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            EmoGradientOutlineButton(
                              text: '保存到历史',
                              icon: Icons.download_rounded,
                              onTap: () {},
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniStat(IconData icon, String title, String value) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: const Color(0xFFFF7D67), size: 22),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF665D59),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF2F2825),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() {
    return Container(width: 1, height: 54, color: const Color(0x1EFF7D67));
  }

  Widget _sectionTitle(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFFF8A74), size: 28),
        const SizedBox(width: 10),
        Text(
          text,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
      ],
    );
  }

  Widget _bar(String label, double value, Color color, String emoji) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 30)),
          const SizedBox(width: 10),
          SizedBox(
            width: 56,
            child: Text(
              label,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: value,
                minHeight: 18,
                backgroundColor: const Color(0xFFF8ECE7),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 48,
            child: Text(
              '${(value * 100).round()}%',
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 16, color: Color(0xFF574E4A)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleRate(int value) {
    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 170,
            height: 170,
            child: CircularProgressIndicator(
              value: value / 100,
              strokeWidth: 16,
              backgroundColor: const Color(0xFFF6E8E2),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xFFFF7D6C)),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const EmoDecorationCloud(size: 90),
              const SizedBox(height: 8),
              const Text(
                '情绪释放度',
                style: TextStyle(fontSize: 16, color: Color(0xFF6E625C)),
              ),
              Text(
                '$value%',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFFF7B5D),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionRow({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              colors: [Color(0xFFFFC1B0), Color(0xFFFF7E72)],
            ),
          ),
          child: Icon(icon, color: Colors.white, size: 30),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF726863),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const Icon(Icons.chevron_right_rounded,
            color: Color(0xFF9C9C9C), size: 30),
      ],
    );
  }
}

class _DotAction extends StatelessWidget {
  const _DotAction();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white70,
      ),
      child:
          const Icon(Icons.more_horiz_rounded, color: AuthPalette.textPrimary),
    );
  }
}

class _HistoryAvatar extends StatelessWidget {
  const _HistoryAvatar({required this.avatar, required this.size});

  final String avatar;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 4),
        gradient: const LinearGradient(
          colors: [Color(0xFFFFEEE8), Color(0xFFFFDCD2)],
        ),
      ),
      child: Center(
        child: Text(
          avatar,
          style: TextStyle(fontSize: size * 0.42),
        ),
      ),
    );
  }
}

String _detailDate(DateTime value) {
  final hh = value.hour.toString().padLeft(2, '0');
  final mm = value.minute.toString().padLeft(2, '0');
  return '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')} $hh:$mm';
}
