import 'dart:convert';

import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../widgets/common/soft_ui.dart';

class MyPostersScreen extends StatefulWidget {
  const MyPostersScreen({super.key, this.posterId});

  final String? posterId;

  @override
  State<MyPostersScreen> createState() => _MyPostersScreenState();
}

class _MyPostersScreenState extends State<MyPostersScreen> {
  final ApiService _api = ApiService();
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _poster;

  bool get _favorite => _poster?['is_favorite'] as bool? ?? false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      String? posterId = widget.posterId;
      if (posterId == null) {
        final posters = await _api.listPosters();
        if (posters.isEmpty) {
          if (!mounted) return;
          setState(() => _poster = null);
          return;
        }
        posterId = (posters.first as Map<String, dynamic>)['id'] as String?;
      }

      if (posterId == null) {
        throw Exception('missing poster id');
      }

      final detail = await _api.getPosterDetail(posterId);
      if (!mounted) return;
      setState(() {
        _poster = detail;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = '加载海报失败';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _toggleFavorite() async {
    final posterId = _poster?['id'] as String?;
    if (posterId == null) return;
    final updated = await _api.updatePosterFavorite(posterId, !_favorite);
    if (!mounted) return;
    setState(() {
      _poster = {
        ...?_poster,
        'is_favorite': updated['is_favorite'],
      };
    });
  }

  Future<void> _deletePoster() async {
    final posterId = _poster?['id'] as String?;
    if (posterId == null) return;
    await _api.deletePoster(posterId);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return SoftPage(
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_error!,
                          style: const TextStyle(color: SoftColors.text)),
                      const SizedBox(height: 12),
                      SoftOutlineButton(text: '重试', onTap: _load),
                    ],
                  ),
                )
              : _poster == null
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.image_not_supported_outlined,
                              size: 52, color: SoftColors.subtext),
                          SizedBox(height: 12),
                          Text('还没有生成海报',
                              style: TextStyle(color: SoftColors.text)),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                      child: Column(
                        children: [
                          SoftHeader(
                            title: '海报详情',
                            onBack: () => Navigator.of(context).pop(),
                            trailing: IconButton(
                              onPressed: _showMoreSheet,
                              icon: const Icon(
                                Icons.more_horiz_rounded,
                                color: SoftColors.text,
                                size: 28,
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          SoftCard(
                            padding: EdgeInsets.zero,
                            radius: 30,
                            child: Column(
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(30)),
                                  child: Container(
                                    width: double.infinity,
                                    color: const Color(0xFFFFF3ED),
                                    child: (_poster!['poster_data'] as String?)
                                                ?.startsWith('data:image') ==
                                            true
                                        ? Image.memory(
                                            base64Decode(
                                              (_poster!['poster_data']
                                                      as String)
                                                  .split(',')
                                                  .last,
                                            ),
                                            fit: BoxFit.cover,
                                          )
                                        : SizedBox(
                                            height: 420,
                                            child: Center(
                                              child: Text(
                                                _stringValue('title'),
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  color: SoftColors.text,
                                                ),
                                              ),
                                            ),
                                          ),
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(20, 18, 20, 18),
                                  child: Row(
                                    children: [
                                      Text(
                                        _stringValue('date'),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: SoftColors.text,
                                        ),
                                      ),
                                      const Spacer(),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(20, 0, 20, 20),
                                  child: Row(
                                    children: [
                                      SoftTag(
                                        text: _stringValue('tag'),
                                        color: SoftColors.coral,
                                        background: const Color(0x14FF6C61),
                                      ),
                                      const Spacer(),
                                      Flexible(
                                        child: Text(
                                          _stringValue('title'),
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: SoftColors.text,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: _ActionButton(
                                  icon: Icons.reply_rounded,
                                  iconColors: const [
                                    Color(0xFFE1D8FF),
                                    Color(0xFF9B7BFF)
                                  ],
                                  label: '分享海报',
                                  onTap: _showMoreSheet,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: _ActionButton(
                                  icon: Icons.download_rounded,
                                  iconColors: const [
                                    Color(0xFFD5F9D6),
                                    Color(0xFF73D977)
                                  ],
                                  label: '保存图片',
                                  onTap: () {},
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: _ActionButton(
                                  icon: _favorite
                                      ? Icons.star_rounded
                                      : Icons.star_border_rounded,
                                  iconColors: const [
                                    Color(0xFFFFE8B7),
                                    Color(0xFFFFBE3D)
                                  ],
                                  label: _favorite ? '已收藏' : '收藏',
                                  onTap: _toggleFavorite,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: _ActionButton(
                                  icon: Icons.delete_rounded,
                                  iconColors: const [
                                    Color(0xFFFFD6D1),
                                    Color(0xFFFF715C)
                                  ],
                                  label: '删除',
                                  onTap: _deletePoster,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          SoftCard(
                            padding: EdgeInsets.zero,
                            child: Column(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.fromLTRB(22, 22, 22, 8),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 4,
                                        height: 22,
                                        child: DecoratedBox(
                                          decoration: BoxDecoration(
                                            color: SoftColors.coral,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(999)),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Text(
                                        '海报信息',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                          color: SoftColors.text,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SoftListTile(
                                  leading: const SoftIconBadge(
                                    icon: Icons.schedule_rounded,
                                    colors: [
                                      Color(0xFFFFD8C2),
                                      Color(0xFFFF8A52)
                                    ],
                                  ),
                                  title: '创建时间',
                                  subtitle: _stringValue('created_at_label'),
                                  trailing: const SizedBox.shrink(),
                                ),
                                SoftListTile(
                                  leading: const SoftIconBadge(
                                    icon: Icons.description_rounded,
                                    colors: [
                                      Color(0xFFE2D8FF),
                                      Color(0xFF967CFF)
                                    ],
                                  ),
                                  title: '来源会话',
                                  subtitle:
                                      _stringValue('source_session_title'),
                                  trailing: const Icon(
                                    Icons.chevron_right_rounded,
                                    color: Color(0xFFA5A9B0),
                                    size: 24,
                                  ),
                                  showDivider: false,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              _stringValue('summary'),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFFC8A89A),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
    );
  }

  String _stringValue(String key) {
    final value = _poster?[key];
    if (value == null) return '-';
    final text = '$value'.trim();
    return text.isEmpty ? '-' : text;
  }

  Future<void> _showMoreSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.32),
      builder: (sheetContext) {
        final navigator = Navigator.of(sheetContext);
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: SoftCard(
            radius: 28,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 6,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6DED9),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  '更多操作',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: SoftColors.text,
                  ),
                ),
                const SizedBox(height: 18),
                _SheetItem(
                  icon: Icons.share_rounded,
                  iconColor: const Color(0xFF1EC95B),
                  label: '分享给好友',
                  onTap: () => navigator.pop(),
                ),
                _SheetItem(
                  icon: Icons.photo_library_outlined,
                  iconColor: const Color(0xFF7EA8FF),
                  label: '分享到朋友圈',
                  onTap: () => navigator.pop(),
                ),
                _SheetItem(
                  icon: Icons.download_rounded,
                  iconColor: const Color(0xFF9680FF),
                  label: '保存到本地',
                  onTap: () => navigator.pop(),
                ),
                _SheetItem(
                  icon: _favorite
                      ? Icons.star_rounded
                      : Icons.star_border_rounded,
                  iconColor: const Color(0xFFFFB936),
                  label: _favorite ? '取消收藏' : '设为收藏',
                  onTap: () async {
                    await _toggleFavorite();
                    if (!mounted) return;
                    navigator.pop();
                  },
                ),
                _SheetItem(
                  icon: Icons.delete_rounded,
                  iconColor: const Color(0xFFFF634F),
                  label: '删除海报',
                  onTap: () async {
                    await _deletePoster();
                    if (!mounted) return;
                    navigator.pop();
                  },
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: SoftOutlineButton(
                    text: '取消',
                    textColor: SoftColors.coral,
                    onTap: () => navigator.pop(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.iconColors,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final List<Color> iconColors;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      radius: 24,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            SoftIconBadge(icon: icon, colors: iconColors, size: 50),
            const SizedBox(height: 14),
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF6B707A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetItem extends StatelessWidget {
  const _SheetItem({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SoftCard(
        radius: 22,
        padding: EdgeInsets.zero,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            child: Row(
              children: [
                Icon(icon, size: 30, color: iconColor),
                const SizedBox(width: 18),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 18,
                    color: SoftColors.text,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
