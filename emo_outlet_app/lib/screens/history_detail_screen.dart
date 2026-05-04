import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../models/history_record_model.dart';
import '../models/message_model.dart';
import '../services/api_service.dart';
import '../widgets/common/app_bottom_nav.dart';
import '../widgets/common/emo_ui.dart';
import 'home_screen.dart';
import 'posters_screen.dart';

class HistoryDetailScreen extends StatefulWidget {
  const HistoryDetailScreen({super.key, required this.record});

  final HistoryRecordModel record;

  @override
  State<HistoryDetailScreen> createState() => _HistoryDetailScreenState();
}

class _HistoryDetailScreenState extends State<HistoryDetailScreen> {
  final ApiService _api = ApiService();

  bool _loading = true;
  List<MessageModel> _messages = [];
  Map<String, dynamic>? _poster;
  Map<String, dynamic>? _posterDetail;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final messagesResult = await _api.getMessages(widget.record.sessionId);
      Map<String, dynamic>? poster;
      Map<String, dynamic>? detail;
      try {
        poster = await _api.getPosterBySession(widget.record.sessionId);
        detail = await _api.getPosterDetail(poster['id'] as String);
      } catch (_) {
        poster = null;
        detail = null;
      }

      if (!mounted) return;
      setState(() {
        _messages = (messagesResult['messages'] as List<dynamic>? ?? <dynamic>[])
            .map((item) => MessageModel.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList();
        _poster = poster;
        _posterDetail = detail;
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final record = widget.record;
    return EmoPageScaffold(
      bottomNavigationBar: AppBottomNav(
        currentIndex: 2,
        onTap: (index) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => HomeScreen(initialIndex: index)),
          );
        },
      ),
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                      EmoRoundIconButton(
                        icon: Icons.refresh_rounded,
                        onTap: _load,
                        size: 48,
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  EmoSectionCard(
                    radius: 34,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            _HistoryAvatar(name: record.name, size: 110),
                            const SizedBox(width: 18),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    record.name,
                                    style: const TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF2D2522),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    record.summary,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF7B716B),
                                      height: 1.6,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const EmoDecorationCloud(size: 120),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.55),
                            borderRadius: BorderRadius.circular(26),
                          ),
                          child: Row(
                            children: [
                              _miniStat(Icons.swap_horiz_rounded, '模式', record.modeLabel),
                              _divider(),
                              _miniStat(
                                Icons.access_time_rounded,
                                '时长',
                                '${record.durationMinutes}分钟',
                              ),
                              _divider(),
                              _miniStat(Icons.mic_none_rounded, '方言', record.language),
                              _divider(),
                              _miniStat(Icons.calendar_month_outlined, '日期', _detailDate(record.timestamp)),
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
                              _sectionTitle(Icons.bar_chart_rounded, '情绪概览'),
                              const SizedBox(height: 16),
                              ...record.emotions.asMap().entries.map((entry) {
                                final percent = _emotionPercent(entry.key, record.emotions.length);
                                return _bar(
                                  entry.value,
                                  percent,
                                  _emotionColor(entry.key),
                                );
                              }),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        _circleRate(record.releaseRate),
                      ],
                    ),
                  ),
                  if (record.keywords.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    EmoSectionCard(
                      radius: 30,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionTitle(Icons.sell_outlined, '高频关键词'),
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
                  ],
                  const SizedBox(height: 16),
                  EmoSectionCard(
                    radius: 30,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionTitle(Icons.chat_bubble_outline_rounded, '会话片段'),
                        const SizedBox(height: 14),
                        if (_messages.isEmpty)
                          const Text(
                            '这次会话还没有可展示的消息内容。',
                            style: TextStyle(fontSize: 16, color: Color(0xFF6A625D)),
                          )
                        else
                          ..._messages.take(6).map(
                                (message) => _MessageBubble(message: message),
                              ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  EmoSectionCard(
                    radius: 30,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionTitle(Icons.image_outlined, '关联海报'),
                        const SizedBox(height: 14),
                        if (_posterDetail != null) ...[
                          _PosterPreview(detail: _posterDetail!),
                          const SizedBox(height: 12),
                          EmoGradientOutlineButton(
                            text: '查看海报详情',
                            icon: Icons.open_in_new_rounded,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => MyPostersScreen(
                                  posterId: _poster?['id'] as String?,
                                ),
                              ),
                            ),
                          ),
                        ] else
                          const Text(
                            '这次会话还没有生成海报。',
                            style: TextStyle(fontSize: 16, color: Color(0xFF6A625D)),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _miniStat(IconData icon, String title, String value) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: const Color(0xFFFF7D67), size: 20),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF8A807A),
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
                fontSize: 15,
                color: Color(0xFF3C312D),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() {
    return Container(
      width: 1,
      height: 34,
      color: const Color(0xFFF0E2DA),
    );
  }

  Widget _sectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFFF7B61)),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2C2522),
          ),
        ),
      ],
    );
  }

  Widget _bar(String label, double percent, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4E4742),
              ),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: percent,
                minHeight: 14,
                color: color,
                backgroundColor: color.withValues(alpha: 0.14),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '${(percent * 100).round()}%',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF71665F),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleRate(int rate) {
    return Container(
      width: 104,
      height: 104,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF1E9), Color(0xFFFFDDD0)],
        ),
        border: Border.all(color: Colors.white, width: 3),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$rate%',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Color(0xFFFF6E57),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              '释放强度',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF8B7A71),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _emotionPercent(int index, int total) {
    if (total <= 0) return 0.0;
    final raw = (total - index) / (total + 1);
    return raw.clamp(0.18, 0.9);
  }

  Color _emotionColor(int index) {
    const colors = [
      Color(0xFFFF705D),
      Color(0xFFFFA25C),
      Color(0xFFFFC55A),
      Color(0xFF77C7F7),
    ];
    return colors[index % colors.length];
  }

  String _detailDate(DateTime timestamp) {
    final local = timestamp.toLocal();
    return '${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
  }
}

class _HistoryAvatar extends StatelessWidget {
  const _HistoryAvatar({
    required this.name,
    this.size = 120,
  });

  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.24),
        gradient: const LinearGradient(
          colors: [Color(0xFFFFEEE6), Color(0xFFFFDCCE)],
        ),
      ),
      child: Center(
        child: Text(
          name.isEmpty ? '?' : name.characters.first,
          style: TextStyle(
            fontSize: size * 0.38,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF6F5044),
          ),
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final MessageModel message;

  @override
  Widget build(BuildContext context) {
    final left = message.isAi;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: left ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (left) ...[
            const CircleAvatar(
              radius: 16,
              backgroundColor: Color(0xFFFFD7D7),
              child: Icon(Icons.favorite_rounded, size: 16, color: Color(0xFFFF7A89)),
            ),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: left ? Colors.white : const Color(0x14FF8D77),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                message.content,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.55,
                  color: Color(0xFF3E3631),
                ),
              ),
            ),
          ),
          if (!left) ...[
            const SizedBox(width: 10),
            const CircleAvatar(
              radius: 16,
              backgroundColor: Color(0xFFFFE6D8),
              child: Icon(Icons.person_rounded, size: 16, color: Color(0xFFB17A55)),
            ),
          ],
        ],
      ),
    );
  }
}

class _PosterPreview extends StatelessWidget {
  const _PosterPreview({required this.detail});

  final Map<String, dynamic> detail;

  @override
  Widget build(BuildContext context) {
    final image = _decode(detail['poster_data'] as String?);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: image != null
              ? Image.memory(
                  image,
                  width: double.infinity,
                  height: 220,
                  fit: BoxFit.cover,
                )
              : Container(
                  width: double.infinity,
                  height: 220,
                  color: const Color(0xFFFFEFE7),
                ),
        ),
        const SizedBox(height: 12),
        Text(
          detail['title'] as String? ?? '',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2C2522),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          detail['summary'] as String? ?? '',
          style: const TextStyle(
            fontSize: 15,
            height: 1.6,
            color: Color(0xFF6E655F),
          ),
        ),
      ],
    );
  }

  Uint8List? _decode(String? value) {
    if (value == null || value.isEmpty) return null;
    final content = value.contains(',') ? value.split(',').last : value;
    try {
      return base64Decode(content);
    } catch (_) {
      return null;
    }
  }
}
