import 'package:flutter/material.dart';

import '../models/history_record_model.dart';
import '../widgets/auth/auth_visuals.dart';
import '../widgets/common/emo_ui.dart';
import 'history_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _range = 'all';
  String _query = '';
  String _modeFilter = 'all';
  String? _emotionFilter;
  String _sort = 'recent';

  late final TextEditingController _searchController;
  final List<HistoryRecordModel> _records = [
    HistoryRecordModel(
      id: 'r1',
      name: '王总',
      avatar: '👨‍💼',
      mode: 'dual',
      modeLabel: '双向',
      timestamp: DateTime(2025, 5, 20, 20, 30),
      durationMinutes: 5,
      emotions: ['愤怒', '委屈'],
      releaseRate: 86,
      summary:
          '你已经很努力了，偶尔会感到委屈和愤怒是正常的。\n允许自己表达这些情绪，是在好好照顾自己。\n相信你值得被理解，也值得更轻松地生活。',
      keywords: ['工作压力', '被误解', '想证明自己', '累', '没人理解', '期待认可'],
      language: '中文',
      posterTitle: '说出来，\n好多了！',
      posterSubtitle: '把不舒服的情绪。\n轻轻放出来。',
    ),
    HistoryRecordModel(
      id: 'r2',
      name: '女友小雨',
      avatar: '👩🏻',
      mode: 'single',
      modeLabel: '单向',
      timestamp: DateTime(2025, 5, 19, 22, 15),
      durationMinutes: 8,
      emotions: ['压力', '焦虑'],
      releaseRate: 74,
      summary: '你已经把担心说出来了，这很重要。\n慢一点没有关系，先安稳住自己的节奏。',
      keywords: ['关系压力', '怕失去', '没有回应', '敏感', '胡思乱想'],
      language: '中文',
      posterTitle: '慢一点，\n也没关系',
      posterSubtitle: '情绪被看见，\n心会轻一点。',
    ),
    HistoryRecordModel(
      id: 'r3',
      name: '女儿甜甜',
      avatar: '👧🏻',
      mode: 'dual',
      modeLabel: '双向',
      timestamp: DateTime(2025, 5, 18, 19, 45),
      durationMinutes: 12,
      emotions: ['失望', '焦虑'],
      releaseRate: 68,
      summary: '你很在意家人的感受，也在努力做一个更好的照顾者。\n把失望和不安说出来，本身就是一种勇敢。',
      keywords: ['教育', '担心', '失望', '自责'],
      language: '中文',
      posterTitle: '我也在学习，\n做更好的自己',
      posterSubtitle: '理解情绪，\n也是理解爱。',
    ),
    HistoryRecordModel(
      id: 'r4',
      name: '奶茶',
      avatar: '🐶',
      mode: 'single',
      modeLabel: '单向',
      timestamp: DateTime(2025, 5, 17, 18, 20),
      durationMinutes: 6,
      emotions: ['平静', '开心'],
      releaseRate: 91,
      summary: '平静和开心也是值得被记录的情绪。\n你有在认真感受生活，这是很珍贵的能力。',
      keywords: ['陪伴', '治愈', '放松', '开心'],
      language: '中文',
      posterTitle: '今天也被温柔治愈',
      posterSubtitle: '把开心留下来，\n也是一种照顾自己。',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<HistoryRecordModel> get _filtered {
    final now = DateTime(2025, 5, 20, 23, 59);
    var items = _records.where((item) {
      final matchQuery = _query.isEmpty ||
          item.name.contains(_query) ||
          item.keywords.any((tag) => tag.contains(_query)) ||
          item.emotions.any((emotion) => emotion.contains(_query));

      bool matchRange = true;
      if (_range == 'week') {
        matchRange = now.difference(item.timestamp).inDays < 7;
      } else if (_range == 'month') {
        matchRange = now.month == item.timestamp.month;
      }

      final matchMode = _modeFilter == 'all' ||
          (_modeFilter == 'single' && !item.isDual) ||
          (_modeFilter == 'dual' && item.isDual);

      final matchEmotion =
          _emotionFilter == null || item.emotions.contains(_emotionFilter);

      return matchQuery && matchRange && matchMode && matchEmotion;
    }).toList();

    if (_sort == 'duration') {
      items.sort((a, b) => b.durationMinutes.compareTo(a.durationMinutes));
    } else {
      items.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 4),
      child: Column(
        children: [
          const SizedBox(height: 10),
          const Text(
            '历史记录',
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 18),
          _rangeTabs(),
          const SizedBox(height: 16),
          GestureDetector(
            onLongPress: _showFilterSheet,
            child: _searchBar(),
          ),
          const SizedBox(height: 18),
          for (final record in _filtered)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _HistoryCard(
                record: record,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => HistoryDetailScreen(record: record),
                  ),
                ),
                onDelete: () => _showDeleteDialog(record),
              ),
            ),
          const SizedBox(height: 12),
          const EmoDecorationCloud(size: 170),
          const SizedBox(height: 12),
          const Text(
            '记录每一次情绪释放，见证内心的成长',
            style: TextStyle(
              fontSize: 18,
              color: Color(0xFF79716B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _rangeTabs() {
    return EmoSectionCard(
      radius: 999,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          _tabItem('all', '全部'),
          _tabItem('week', '本周'),
          _tabItem('month', '本月'),
        ],
      ),
    );
  }

  Widget _tabItem(String key, String label) {
    final active = _range == key;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: () => setState(() => _range = key),
        child: Container(
          height: 54,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            gradient: active
                ? const LinearGradient(
                    colors: [Color(0xFFFF4F67), Color(0xFFFF8A47)],
                  )
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: active ? Colors.white : const Color(0xFF2F2825),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _searchBar() {
    return EmoSectionCard(
      radius: 26,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: Color(0xFF8C8C8C), size: 30),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _query = value.trim()),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: '搜索对象或情绪关键词',
                hintStyle: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF9C9C9C),
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(HistoryRecordModel record) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.46),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 36),
        child: EmoSectionCard(
          radius: 34,
          padding: const EdgeInsets.fromLTRB(26, 0, 26, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const EmoDecorationCloud(size: 160),
              const SizedBox(height: 6),
              const Text(
                '删除这条记录？',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),
              const Text(
                '删除后将无法恢复，\n但不会影响你的对象信息。',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  height: 1.6,
                  color: Color(0xFF6D6662),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlineSoftButton(
                      text: '取消',
                      onTap: () => Navigator.of(ctx).pop(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GradientPrimaryButton(
                      text: '确认删除',
                      height: 58,
                      fontSize: 20,
                      onTap: () {
                        setState(() {
                          _records.removeWhere((item) => item.id == record.id);
                        });
                        Navigator.of(ctx).pop();
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.restore_outlined,
                      color: Color(0xFF8E8E8E), size: 20),
                  SizedBox(width: 8),
                  Text(
                    '你也可以稍后在回收记录中查看',
                    style: TextStyle(fontSize: 16, color: Color(0xFF7F7A76)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          return Container(
            decoration: const BoxDecoration(
              color: Color(0xFFFDF8F4),
              borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
            ),
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 82,
                      height: 6,
                      decoration: BoxDecoration(
                        color: const Color(0x18000000),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Center(
                    child: Text(
                      '筛选与排序',
                      style:
                          TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
                    ),
                  ),
                  const SizedBox(height: 22),
                  _sheetTitle('时间范围'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                          child: _sheetChip('全部', _range == 'all',
                              () => setSheetState(() => _range = 'all'))),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _sheetChip('本周', _range == 'week',
                              () => setSheetState(() => _range = 'week'))),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _sheetChip('本月', _range == 'month',
                              () => setSheetState(() => _range = 'month'))),
                    ],
                  ),
                  const SizedBox(height: 22),
                  _sheetTitle('模式'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                          child: _sheetChip('单向', _modeFilter == 'single',
                              () => setSheetState(() => _modeFilter = 'single'),
                              icon: Icons.arrow_right_alt_rounded)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _sheetChip('双向', _modeFilter == 'dual',
                              () => setSheetState(() => _modeFilter = 'dual'),
                              icon: Icons.sync_alt_rounded)),
                    ],
                  ),
                  const SizedBox(height: 22),
                  _sheetTitle('情绪标签'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: ['愤怒', '委屈', '压力', '焦虑'].map((item) {
                      final active = _emotionFilter == item;
                      return _emotionFilterChip(item, active, () {
                        setSheetState(
                            () => _emotionFilter = active ? null : item);
                      });
                    }).toList(),
                  ),
                  const SizedBox(height: 22),
                  _sheetTitle('排序方式'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                          child: _sheetChip('最近优先', _sort == 'recent',
                              () => setSheetState(() => _sort = 'recent'),
                              icon: Icons.access_time_rounded)),
                      const SizedBox(width: 16),
                      Expanded(
                          child: _sheetChip('时长优先', _sort == 'duration',
                              () => setSheetState(() => _sort = 'duration'),
                              icon: Icons.timelapse_rounded)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlineSoftButton(
                          text: '重置',
                          onTap: () {
                            setState(() {
                              _range = 'all';
                              _modeFilter = 'all';
                              _emotionFilter = null;
                              _sort = 'recent';
                            });
                            Navigator.of(ctx).pop();
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: GradientPrimaryButton(
                          text: '应用筛选',
                          height: 58,
                          fontSize: 20,
                          onTap: () {
                            setState(() {});
                            Navigator.of(ctx).pop();
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _sheetTitle(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
    );
  }

  Widget _sheetChip(String text, bool active, VoidCallback onTap,
      {IconData? icon}) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        height: 58,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          gradient: active
              ? const LinearGradient(
                  colors: [Color(0xFFFF4F67), Color(0xFFFF8A47)])
              : null,
          color: active ? null : Colors.white,
          border: Border.all(color: const Color(0xFFF1E6DF)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon,
                  color: active ? Colors.white : const Color(0xFF4F4F4F),
                  size: 24),
              const SizedBox(width: 8),
            ],
            Text(
              text,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: active ? Colors.white : const Color(0xFF303030),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emotionFilterChip(String text, bool active, VoidCallback onTap) {
    final icon = _emotionIcon(text);
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: active ? const Color(0x14FF7C68) : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0xFFF1E6DF)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 10),
            Text(
              text,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color:
                    active ? const Color(0xFFFF6E57) : const Color(0xFF2F2825),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({
    required this.record,
    required this.onTap,
    required this.onDelete,
  });

  final HistoryRecordModel record;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onDelete,
      child: EmoSectionCard(
        radius: 32,
        padding: const EdgeInsets.all(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: onTap,
          child: Row(
            children: [
              _ListAvatar(avatar: record.avatar),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          record.name,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: AuthPalette.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: record.isDual
                                ? const Color(0x14936EFF)
                                : const Color(0x14FF7D5D),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                record.isDual
                                    ? Icons.people_alt_outlined
                                    : Icons.arrow_forward_rounded,
                                size: 18,
                                color: record.isDual
                                    ? const Color(0xFF7A5FFF)
                                    : const Color(0xFFFF7D5D),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                record.modeLabel,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: record.isDual
                                      ? const Color(0xFF7A5FFF)
                                      : const Color(0xFFFF7D5D),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined,
                            size: 22, color: Color(0xFF7E7E7E)),
                        const SizedBox(width: 8),
                        Text(
                          _dateTimeText(record.timestamp),
                          style: const TextStyle(
                              fontSize: 16, color: Color(0xFF6D6662)),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text('·',
                              style: TextStyle(
                                  fontSize: 20, color: Color(0xFF8F8A86))),
                        ),
                        const Icon(Icons.access_time_rounded,
                            size: 22, color: Color(0xFF7E7E7E)),
                        const SizedBox(width: 8),
                        Text(
                          '${record.durationMinutes}分钟',
                          style: const TextStyle(
                              fontSize: 16, color: Color(0xFF6D6662)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 12,
                      runSpacing: 10,
                      children: record.emotions
                          .map(
                            (item) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: _emotionBg(item),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(_emotionIcon(item),
                                      style: const TextStyle(fontSize: 22)),
                                  const SizedBox(width: 8),
                                  Text(
                                    item,
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.chevron_right_rounded,
                  color: Color(0xFF8D8D8D), size: 34),
            ],
          ),
        ),
      ),
    );
  }
}

class _ListAvatar extends StatelessWidget {
  const _ListAvatar({required this.avatar});

  final String avatar;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 4),
        gradient: const LinearGradient(
          colors: [Color(0xFFFFEEE8), Color(0xFFFFD9CC)],
        ),
      ),
      child: Center(
        child: Text(avatar, style: const TextStyle(fontSize: 48)),
      ),
    );
  }
}

String _dateTimeText(DateTime value) {
  final hh = value.hour.toString().padLeft(2, '0');
  final mm = value.minute.toString().padLeft(2, '0');
  return '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')} $hh:$mm';
}

String _emotionIcon(String emotion) {
  switch (emotion) {
    case '愤怒':
      return '😠';
    case '委屈':
      return '😟';
    case '压力':
      return '😥';
    case '焦虑':
      return '😰';
    case '平静':
      return '😌';
    case '开心':
      return '😊';
    case '失望':
      return '😢';
    default:
      return '🙂';
  }
}

Color _emotionBg(String emotion) {
  switch (emotion) {
    case '愤怒':
      return const Color(0x18FF7B62);
    case '委屈':
      return const Color(0x18A17BFF);
    case '压力':
      return const Color(0x18FFBE4D);
    case '焦虑':
      return const Color(0x18B5D95A);
    case '平静':
      return const Color(0x18B9E46A);
    case '开心':
      return const Color(0x18FF9BB0);
    case '失望':
      return const Color(0x1872A8FF);
    default:
      return const Color(0x14CCCCCC);
  }
}
