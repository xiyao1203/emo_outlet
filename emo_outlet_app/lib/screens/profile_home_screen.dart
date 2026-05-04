import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/constants.dart';
import '../providers/app_providers.dart';
import '../services/auth_service.dart';
import '../widgets/common/soft_ui.dart';
import 'posters_screen.dart';
import 'profile_detail_screen.dart';
import 'settings_screen.dart';

class ProfileHomeScreen extends StatelessWidget {
  const ProfileHomeScreen({
    super.key,
    this.onSwitchTab,
  });

  final ValueChanged<int>? onSwitchTab;

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
    final nickname = user?.nickname ?? '小太阳';
    final targets = context.watch<TargetProvider>().targets;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      child: Column(
        children: [
          const SizedBox(height: 4),
          const Text(
            '我的',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: SoftColors.text,
            ),
          ),
          const SizedBox(height: 24),
          SoftCard(
            padding: EdgeInsets.zero,
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ProfileDetailScreen()),
                );
              },
              borderRadius: BorderRadius.circular(28),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    Container(
                      width: 86,
                      height: 86,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFF8D8C8), Color(0xFFFFF1E8)],
                        ),
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        size: 42,
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
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: SoftColors.text,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '点击进入个人资料编辑',
                            style: TextStyle(
                              fontSize: 15,
                              color: SoftColors.subtext,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0xFFA7ABB3),
                      size: 26,
                    ),
                  ],
                ),
              ),
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
                        '我的对象',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: SoftColors.text,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${targets.isEmpty ? 12 : targets.length}',
                        style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w700,
                          color: SoftColors.text,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () =>
                            onSwitchTab?.call(AppConstants.navIndexTarget),
                        child: const Text('去查看'),
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
                        '累计释放',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: SoftColors.text,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        '48',
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w700,
                          color: SoftColors.text,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '持续表达，慢慢会轻一点',
                        style: TextStyle(fontSize: 13, color: SoftColors.subtext),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SoftCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _ProfileMenuEntry(
                  icon: Icons.image_rounded,
                  colors: const [Color(0xFFFFE1D6), Color(0xFFFF9164)],
                  title: '我的海报',
                  subtitle: '查看与管理我的专属海报',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const MyPostersScreen()),
                    );
                  },
                ),
                _ProfileMenuEntry(
                  icon: Icons.settings_rounded,
                  colors: const [Color(0xFFE2DFFF), Color(0xFF9B82FF)],
                  title: '设置中心',
                  subtitle: '偏好设置与账户管理',
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
