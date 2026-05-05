import 'dart:async';

import 'package:flutter/material.dart';

import '../models/history_record_model.dart';
import '../models/session_model.dart';
import '../services/api_service.dart';
import '../widgets/auth/auth_visuals.dart';
import '../widgets/common/emo_ui.dart';
import 'history_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final ApiService _api = ApiService();
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;

  bool _loading = true;
  String _range = 'all';
  String _query = '';
  String _modeFilter = 'all';
  String? _emotionFilter;
  String _sort = 'recent';
  List<HistoryRecordModel> _records = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  String _normalize(String value) => value.trim().toLowerCase();

  void _handleSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 220), () {
      if (!mounted) return;
      setState(() => _query = _normalize(value));
    });
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final sessions = await _api.getSessions(pageSize: 100);
      final records = sessions
          .map((item) =>
              SessionModel.fromJson(Map<String, dynamic>.from(item as Map)))
          .map(HistoryRecordModel.fromSession)
          .toList();
      if (!mounted) return;
      setState(() => _records = records);
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  List<HistoryRecordModel> get _filtered {
    final now = DateTime.now();
    final items = _records.where((item) {
      final matchQuery = _query.isEmpty ||
          _normalize(item.name).contains(_query) ||
          item.keywords.any((tag) => _normalize(tag).contains(_query)) ||
          item.emotions.any((emotion) => _normalize(emotion).contains(_query));

      var matchRange = true;
      if (_range == 'week') {
        matchRange = now.difference(item.timestamp).inDays < 7;
      } else if (_range == 'month') {
        matchRange = now.year == item.timestamp.year &&
            now.month == item.timestamp.month;
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

  List<String> get _emotionOptions {
    final values = <String>{};
    for (final record in _records) {
      values.addAll(record.emotions);
    }
    final list = values.toList()..sort();
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Column(
          children: [
            const SizedBox(height: 8),
            const Text(
              '历史记录',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 14),
            _rangeTabs(),
            const SizedBox(height: 14),
            GestureDetector(
              onLongPress: _showFilterSheet,
              child: _searchBar(),
            ),
            const SizedBox(height: 14),
            if (_loading)
              const Padding(
                padding: EdgeInsets.only(top: 80),
                child: CircularProgressIndicator(),
              )
            else if (_filtered.isEmpty)
              _emptyState()
            else
              ..._filtered.map(
                (record) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
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
              ),
            const SizedBox(height: 10),
            const EmoDecorationCloud(size: 118),
            const SizedBox(height: 10),
            const Text(
              '记录每一次情绪释放，见证内心慢慢松开。',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF79716B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    return const EmoSectionCard(
      radius: 28,
      child: Column(
        children: [
          SizedBox(height: 8),
          EmoDecorationCloud(size: 120),
          SizedBox(height: 8),
          Text(
            '还没有历史记录',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AuthPalette.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '完成一次会话后，这里会自动展示真实的记录和情绪总结。',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.8,
              height: 1.55,
              color: Color(0xFF857972),
            ),
          ),
        ],
      ),
    );
  }

  Widget _rangeTabs() {
    return EmoSectionCard(
      radius: 999,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
          height: 40,
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
                fontSize: 14,
                fontWeight: FontWeight.w600,
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
      radius: 24,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: Color(0xFF8C8C8C), size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: _handleSearchChanged,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: '搜索对象、情绪或关键词',
                hintStyle: TextStyle(
                  fontSize: 13.5,
                  color: Color(0xFF9C9C9C),
                  fontWeight: FontWeight.w500,
                ),
              ),
              style:
                  const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(HistoryRecordModel record) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('删除海报提醒'),
          content: const Text('历史会话本身仍会保留，当前版本只支持删除对应海报。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('我知道了'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showFilterSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        String mode = _modeFilter;
        String sort = _sort;
        String? emotion = _emotionFilter;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
              decoration: const BoxDecoration(
                color: Color(0xFFFFFBF8),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
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
                          color: const Color(0xFFE8DAD1),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '筛选记录',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 18),
                    const Text('会话模式',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _sheetChip('all', '全部', mode, (value) {
                          setModalState(() => mode = value);
                        }),
                        _sheetChip('single', '单向', mode, (value) {
                          setModalState(() => mode = value);
                        }),
                        _sheetChip('dual', '双向', mode, (value) {
                          setModalState(() => mode = value);
                        }),
                      ],
                    ),
                    const SizedBox(height: 18),
                    const Text('排序方式',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _sheetChip('recent', '按时间', sort, (value) {
                          setModalState(() => sort = value);
                        }),
                        _sheetChip('duration', '按时长', sort, (value) {
                          setModalState(() => sort = value);
                        }),
                      ],
                    ),
                    const SizedBox(height: 18),
                    const Text('情绪标签',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _optionChip(
                          label: '全部',
                          selected: emotion == null,
                          onTap: () => setModalState(() => emotion = null),
                        ),
                        ..._emotionOptions.map(
                          (item) => _optionChip(
                            label: item,
                            selected: emotion == item,
                            onTap: () => setModalState(() => emotion = item),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _modeFilter = 'all';
                                _sort = 'recent';
                                _emotionFilter = null;
                              });
                              Navigator.of(context).pop();
                            },
                            child: const Text('重置'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _modeFilter = mode;
                                _sort = sort;
                                _emotionFilter = emotion;
                              });
                              Navigator.of(context).pop();
                            },
                            child: const Text('应用'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _sheetChip(
    String value,
    String label,
    String current,
    ValueChanged<String> onChanged,
  ) {
    return _optionChip(
      label: label,
      selected: value == current,
      onTap: () => onChanged(value),
    );
  }

  Widget _optionChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: selected ? const Color(0x1AFF7E68) : Colors.white,
          border: Border.all(
            color: selected ? const Color(0xFFFF7E68) : const Color(0xFFE7DCD5),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: selected ? const Color(0xFFFF6C55) : const Color(0xFF6C635D),
          ),
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
    return EmoSectionCard(
      radius: 26,
      padding: const EdgeInsets.all(15),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        onLongPress: onDelete,
        child: Column(
          children: [
            Row(
              children: [
                _AvatarBox(name: record.name),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AuthPalette.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(record.timestamp),
                        style: const TextStyle(
                          fontSize: 12.8,
                          color: Color(0xFF8B8079),
                        ),
                      ),
                    ],
                  ),
                ),
                EmoTypePill(text: record.modeLabel),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _MiniInfo(
                  icon: Icons.schedule_rounded,
                  label: '${record.durationMinutes}分钟',
                ),
                const SizedBox(width: 10),
                _MiniInfo(
                  icon: Icons.auto_awesome_rounded,
                  label: '${record.releaseRate}%',
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.end,
                    children: record.emotions
                        .map((item) => EmoTypePill(text: item))
                        .toList(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                record.summary,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.55,
                  color: Color(0xFF5A504A),
                ),
              ),
            ),
            if (record.keywords.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: record.keywords
                    .take(4)
                    .map(
                      (item) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0x14FF7C68),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          item,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: Color(0xFFFF6E57),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static String _formatDate(DateTime time) {
    final local = time.toLocal();
    return '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')} '
        '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }
}

class _AvatarBox extends StatelessWidget {
  const _AvatarBox({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFFFFE1D8), Color(0xFFFFF0E9)],
        ),
      ),
      child: Center(
        child: Text(
          name.isEmpty ? '?' : name.characters.first,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Color(0xFF7E5745),
          ),
        ),
      ),
    );
  }
}

class _MiniInfo extends StatelessWidget {
  const _MiniInfo({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: const Color(0xFFFF7B62)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12.5,
              color: Color(0xFF6B625C),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
