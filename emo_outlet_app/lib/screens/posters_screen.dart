import 'package:flutter/material.dart';

import '../config/constants.dart';
import '../widgets/auth/auth_visuals.dart';
import '../widgets/common/app_bottom_nav.dart';
import '../widgets/common/emo_ui.dart';
import 'home_screen.dart';

class MyPostersScreen extends StatefulWidget {
  const MyPostersScreen({super.key});

  @override
  State<MyPostersScreen> createState() => _MyPostersScreenState();
}

class _MyPostersScreenState extends State<MyPostersScreen> {
  String _tab = '全部';

  final _posters = const [
    _PosterData(
      date: '2024.05.20',
      titleTop: '允许自己',
      titleBottom: '慢慢来',
      emoji: '☁️',
      colors: [Color(0xFFFCE5DF), Color(0xFFFFF4EE)],
    ),
    _PosterData(
      date: '2024.05.18',
      titleTop: '把情绪',
      titleBottom: '装进瓶子里',
      subtitle: '然后，轻轻放下',
      emoji: '🫙',
      colors: [Color(0xFFFFD8C5), Color(0xFFFFF0DE)],
    ),
    _PosterData(
      date: '2024.05.15',
      titleTop: '深呼吸',
      titleBottom: '一切都会好起来的',
      emoji: '🌿',
      colors: [Color(0xFFF3F6D8), Color(0xFFFCFDF5)],
    ),
    _PosterData(
      date: '2024.05.12',
      titleTop: '今天的你',
      titleBottom: '已经很棒了',
      emoji: '🌙',
      colors: [Color(0xFFD8DBFF), Color(0xFFF0E8FF)],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return EmoPageScaffold(
      bottomNavigationBar: AppBottomNav(
        currentIndex: AppConstants.navIndexProfile,
        onTap: (index) => Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => HomeScreen(initialIndex: index)),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
        child: Column(
          children: [
            SizedBox(
              height: 52,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: EmoRoundIconButton(
                      icon: Icons.arrow_back_ios_new_rounded,
                      size: 52,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                  ),
                  const Text(
                    '我的海报',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: AuthPalette.textPrimary,
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: EmoRoundIconButton(
                      icon: Icons.search_rounded,
                      size: 52,
                      onTap: () {},
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Colors.white),
              ),
              child: Row(
                children: ['全部', '最近', '收藏'].map((tab) {
                  final active = _tab == tab;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _tab = tab),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        height: 58,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          gradient: active
                              ? const LinearGradient(
                                  colors: [
                                    Color(0xFFFFCFC1),
                                    Color(0xFFFFF0DD)
                                  ],
                                )
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          tab,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: active
                                ? const Color(0xFFFF7D57)
                                : AuthPalette.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _posters.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.72,
              ),
              itemBuilder: (context, index) =>
                  _PosterCard(data: _posters[index]),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: EmoGradientOutlineButton(
                text: '批量管理',
                onTap: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PosterCard extends StatelessWidget {
  const _PosterCard({required this.data});

  final _PosterData data;

  @override
  Widget build(BuildContext context) {
    return EmoSectionCard(
      radius: 24,
      padding: const EdgeInsets.all(0),
      child: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: data.colors,
                ),
              ),
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
              child: Stack(
                children: [
                  Positioned(
                    left: 8,
                    top: 4,
                    right: 8,
                    child: Column(
                      children: [
                        Text(
                          data.titleTop,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            height: 1.4,
                            color: Color(0xFF6C4E43),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          data.titleBottom,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 20,
                            height: 1.4,
                            color: Color(0xFF6C4E43),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (data.subtitle != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            data.subtitle!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF6F625E),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 10,
                    child: Center(
                      child: Text(
                        data.emoji,
                        style: const TextStyle(fontSize: 96),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    data.date,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AuthPalette.textPrimary,
                    ),
                  ),
                ),
                const Icon(Icons.more_vert_rounded, size: 22),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PosterData {
  const _PosterData({
    required this.date,
    required this.titleTop,
    required this.titleBottom,
    required this.emoji,
    required this.colors,
    this.subtitle,
  });

  final String date;
  final String titleTop;
  final String titleBottom;
  final String? subtitle;
  final String emoji;
  final List<Color> colors;
}
