import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/constants.dart';
import '../providers/app_providers.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../widgets/common/emo_ui.dart';
import '../widgets/common/soft_ui.dart';
import 'posters_screen.dart';
import 'profile_detail_screen.dart';
import 'settings_screen.dart';

class ProfileHomeScreen extends StatefulWidget {
  const ProfileHomeScreen({
    super.key,
    this.onSwitchTab,
  });

  final ValueChanged<int>? onSwitchTab;

  @override
  State<ProfileHomeScreen> createState() => _ProfileHomeScreenState();
}

class _ProfileHomeScreenState extends State<ProfileHomeScreen> {
  final ApiService _api = ApiService();
  bool _loading = true;
  int _targetCount = 0;
  int _sessionCount = 0;
  String? _latestPosterId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<TargetProvider>().loadTargets();
      await _loadSummary();
    });
  }

  Future<void> _loadSummary() async {
    setState(() => _loading = true);
    try {
      final targets = await _api.getTargets();
      final report = await _api.getEmotionReport(period: 'all');
      final posters = await _api.listPosters();
      if (!mounted) return;
      setState(() {
        _targetCount = targets.length;
        _sessionCount = report['total_sessions'] as int? ?? 0;
        _latestPosterId = posters.isEmpty
            ? null
            : (posters.first as Map<String, dynamic>)['id'] as String?;
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  ImageProvider<Object>? _avatarProvider(String? value) {
    if (value == null || value.isEmpty) return null;
    if (value.startsWith('data:image')) {
      return MemoryImage(base64Decode(value.split(',').last));
    }
    return NetworkImage(value);
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
    final nickname = user?.nickname?.trim().isNotEmpty == true
        ? user!.nickname!.trim()
        : '游客用户';

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final horizontal = EmoResponsive.edgePadding(width);

        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(horizontal, 16, horizontal, 24),
          child: EmoResponsiveContent(
            width: width,
            maxWidth: 760,
            child: Column(
              children: [
                const SizedBox(height: 4),
                const Text(
                  '我的',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: SoftColors.text,
                  ),
                ),
                const SizedBox(height: 22),
                SoftCard(
                  padding: EdgeInsets.zero,
                  child: InkWell(
                    onTap: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ProfileDetailScreen()),
                      );
                      await AuthService().refreshProfile();
                      if (mounted) setState(() {});
                    },
                    borderRadius: BorderRadius.circular(26),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Row(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                              gradient: const LinearGradient(
                                colors: [Color(0xFFF8D8C8), Color(0xFFFFF1E8)],
                              ),
                              image: _avatarProvider(user?.avatarUrl) != null
                                  ? DecorationImage(
                                      image: _avatarProvider(user?.avatarUrl)!,
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: user?.avatarUrl?.isNotEmpty == true
                                ? null
                                : const Icon(
                                    Icons.person_rounded,
                                    size: 38,
                                    color: Color(0xFFB57A55),
                                  ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  nickname,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: SoftColors.text,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  '点击进入个人资料与头像设置',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: SoftColors.subtext,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: Color(0xFFA7ABB3),
                            size: 24,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: '我的对象',
                        value: _loading ? '--' : '$_targetCount',
                        hint: '管理你在意的人',
                        actionText: '去查看',
                        onTap: () => widget.onSwitchTab?.call(AppConstants.navIndexTarget),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        title: '累计释放',
                        value: _loading ? '--' : '$_sessionCount',
                        hint: '真实对话次数累计',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SoftCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _ProfileMenuEntry(
                        icon: Icons.image_rounded,
                        colors: const [Color(0xFFFFE1D6), Color(0xFFFF9164)],
                        title: '我的海报',
                        subtitle: _latestPosterId == null
                            ? '完成一次会话后，这里会出现你的情绪海报'
                            : '查看与管理最近生成的海报',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => MyPostersScreen(posterId: _latestPosterId),
                            ),
                          );
                        },
                      ),
                      _ProfileMenuEntry(
                        icon: Icons.settings_rounded,
                        colors: const [Color(0xFFE2DFFF), Color(0xFF9B82FF)],
                        title: '设置中心',
                        subtitle: '账号安全、通知偏好和隐私设置',
                        showDivider: false,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const SettingsScreen()),
                          );
                        },
                      ),
                    ],
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

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.hint,
    this.actionText,
    this.onTap,
  });

  final String title;
  final String value;
  final String hint;
  final String? actionText;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: SoftColors.text,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: SoftColors.text,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            hint,
            style: const TextStyle(fontSize: 12.5, color: SoftColors.subtext),
          ),
          if (actionText != null && onTap != null) ...[
            const SizedBox(height: 10),
            GestureDetector(
              onTap: onTap,
              child: Text(
                actionText!,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: SoftColors.coral,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ProfileMenuEntry extends StatelessWidget {
  const _ProfileMenuEntry({
    required this.icon,
    required this.colors,
    required this.title,
    required this.subtitle,
    this.showDivider = true,
    this.onTap,
  });

  final IconData icon;
  final List<Color> colors;
  final String title;
  final String subtitle;
  final bool showDivider;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SoftListTile(
      leading: SoftIconBadge(icon: icon, colors: colors),
      title: title,
      subtitle: subtitle,
      showDivider: showDivider,
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: Color(0xFFA4A9B1),
      ),
      onTap: onTap,
    );
  }
}
