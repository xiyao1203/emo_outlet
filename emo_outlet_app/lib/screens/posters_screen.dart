import 'package:flutter/material.dart';

import '../widgets/common/soft_ui.dart';

class MyPostersScreen extends StatefulWidget {
  const MyPostersScreen({super.key});

  @override
  State<MyPostersScreen> createState() => _MyPostersScreenState();
}

class _MyPostersScreenState extends State<MyPostersScreen> {
  bool _favorite = true;

  @override
  Widget build(BuildContext context) {
    return SoftPage(
      child: SingleChildScrollView(
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
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(30)),
                    child: Container(
                      height: 452,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFFFFD4C5), Color(0xFFF8BA92)],
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            left: 26,
                            top: 40,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  '把情绪\n装进瓶子里',
                                  style: TextStyle(
                                    height: 1.35,
                                    fontSize: 34,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF6F4B40),
                                  ),
                                ),
                                SizedBox(height: 18),
                                Text(
                                  '然后，轻轻放下',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Color(0xFF8A685D),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Positioned(
                            left: 18,
                            bottom: 24,
                            child: Icon(
                              Icons.favorite_rounded,
                              color: Color(0xFFFF94A0),
                              size: 86,
                            ),
                          ),
                          Positioned(
                            right: 48,
                            bottom: 74,
                            child: Container(
                              width: 172,
                              height: 224,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.68),
                                  width: 3,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x40FFC79A),
                                    blurRadius: 34,
                                    offset: Offset(0, 14),
                                  ),
                                ],
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.white.withValues(alpha: 0.2),
                                    Colors.white.withValues(alpha: 0.05),
                                  ],
                                ),
                              ),
                              child: Center(
                                child: Container(
                                  width: 94,
                                  height: 94,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFFFB5A9),
                                        Color(0xFFFF8E85),
                                      ],
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x50FFD9B0),
                                        blurRadius: 30,
                                        offset: Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.favorite_rounded,
                                    color: Colors.white,
                                    size: 50,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                    child: Row(
                      children: const [
                        Text(
                          '2024.05.18',
                          style: TextStyle(
                            fontSize: 16,
                            color: SoftColors.text,
                          ),
                        ),
                        Spacer(),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Row(
                      children: const [
                        SoftTag(
                          text: '释放 · 释放心情',
                          color: SoftColors.coral,
                          background: Color(0x14FF6C61),
                        ),
                        Spacer(),
                        Text(
                          '把情绪装进瓶子里',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: SoftColors.text,
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
                    iconColors: const [Color(0xFFE1D8FF), Color(0xFF9B7BFF)],
                    label: '分享海报',
                    onTap: _showMoreSheet,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _ActionButton(
                    icon: Icons.download_rounded,
                    iconColors: const [Color(0xFFD5F9D6), Color(0xFF73D977)],
                    label: '保存图片',
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _ActionButton(
                    icon: Icons.star_rounded,
                    iconColors: const [Color(0xFFFFE8B7), Color(0xFFFFBE3D)],
                    label: '收藏',
                    onTap: () => setState(() => _favorite = !_favorite),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _ActionButton(
                    icon: Icons.delete_rounded,
                    iconColors: const [Color(0xFFFFD6D1), Color(0xFFFF715C)],
                    label: '删除',
                    onTap: () {},
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
                              borderRadius:
                                  BorderRadius.all(Radius.circular(999)),
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
                      colors: [Color(0xFFFFD8C2), Color(0xFFFF8A52)],
                    ),
                    title: '创建时间',
                    subtitle: '2024年5月18日 20:30',
                    trailing: const SizedBox.shrink(),
                  ),
                  SoftListTile(
                    leading: const SoftIconBadge(
                      icon: Icons.description_rounded,
                      colors: [Color(0xFFE2D8FF), Color(0xFF967CFF)],
                    ),
                    title: '来源会话',
                    subtitle: '把情绪装进瓶子里 · 情绪释放练习',
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
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                '每一次释放，都是向内在温柔的靠近',
                style: TextStyle(
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

  Future<void> _showMoreSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.32),
      builder: (context) {
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
                  icon: Icons.wechat,
                  iconColor: const Color(0xFF1EC95B),
                  label: '分享给微信好友',
                  onTap: () => Navigator.of(context).pop(),
                ),
                _SheetItem(
                  icon: Icons.camera,
                  iconColor: const Color(0xFF7EA8FF),
                  label: '分享到朋友圈',
                  onTap: () => Navigator.of(context).pop(),
                ),
                _SheetItem(
                  icon: Icons.download_rounded,
                  iconColor: const Color(0xFF9680FF),
                  label: '保存到本地',
                  onTap: () => Navigator.of(context).pop(),
                ),
                _SheetItem(
                  icon: Icons.star_rounded,
                  iconColor: const Color(0xFFFFB936),
                  label: _favorite ? '取消收藏' : '设为收藏',
                  onTap: () {
                    setState(() => _favorite = !_favorite);
                    Navigator.of(context).pop();
                  },
                ),
                _SheetItem(
                  icon: Icons.delete_rounded,
                  iconColor: const Color(0xFFFF634F),
                  label: '删除海报',
                  onTap: () => Navigator.of(context).pop(),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: SoftOutlineButton(
                    text: '取消',
                    textColor: SoftColors.coral,
                    onTap: () => Navigator.of(context).pop(),
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
