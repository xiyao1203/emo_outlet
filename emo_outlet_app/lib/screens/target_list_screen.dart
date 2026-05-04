import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/target_model.dart';
import '../providers/app_providers.dart';
import '../widgets/auth/auth_visuals.dart';
import '../widgets/common/emo_ui.dart';
import 'create_target_screen.dart';
import 'target_detail_screen.dart';

class TargetListScreen extends StatefulWidget {
  const TargetListScreen({super.key, this.isSelectMode = false});

  final bool isSelectMode;

  @override
  State<TargetListScreen> createState() => _TargetListScreenState();
}

class _TargetListScreenState extends State<TargetListScreen> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TargetProvider>();
    final targets = provider.targets;
    final filtered = targets
        .where(
          (target) =>
              target.name.contains(query) ||
              (target.relationship ?? '').contains(query) ||
              target.typeLabel.contains(query),
        )
        .toList();

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 110),
          child: Column(
            children: [
              SizedBox(
                height: 58,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: EmoRoundIconButton(
                        icon: Icons.arrow_back_ios_new_rounded,
                        size: 52,
                        onTap: () {
                          if (Navigator.of(context).canPop()) {
                            Navigator.of(context).pop();
                          }
                        },
                      ),
                    ),
                    const Text(
                      '我的对象',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: AuthPalette.textPrimary,
                      ),
                    ),
                    const Align(
                      alignment: Alignment.centerRight,
                      child: SizedBox(
                        width: 110,
                        height: 86,
                        child: EmoDecorationCloud(size: 98),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.66),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: Colors.white),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search_rounded,
                        size: 30, color: Color(0xFFABABAB)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        onChanged: (value) => setState(() => query = value),
                        decoration: const InputDecoration(
                          hintText: '搜索对象名称或关键词',
                          hintStyle: TextStyle(
                            color: Color(0xFFB3B3B3),
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              EmoSectionCard(
                radius: 30,
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                child: Row(
                  children: [
                    Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Center(
                        child: Text('👥', style: TextStyle(fontSize: 38)),
                      ),
                    ),
                    const SizedBox(width: 18),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: '共 ',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    color: AuthPalette.textPrimary,
                                  ),
                                ),
                                TextSpan(
                                  text: '12',
                                  style: TextStyle(
                                    fontSize: 38,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFFFF754C),
                                  ),
                                ),
                                TextSpan(
                                  text: ' 个对象',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    color: AuthPalette.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            '选择对象，向 TA 倾诉你的情绪吧',
                            style: TextStyle(
                              fontSize: 17,
                              color: Color(0xFF8A7D77),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 118,
                      height: 90,
                      child: EmoDecorationCloud(size: 102),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              for (final target in filtered) ...[
                _TargetCard(target: target),
                const SizedBox(height: 14),
              ],
            ],
          ),
        ),
        Positioned(
          left: 18,
          right: 18,
          bottom: 18,
          child: GradientPrimaryButton(
            text: '＋ 新建对象',
            height: 74,
            fontSize: 22,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CreateTargetScreen()),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _TargetCard extends StatelessWidget {
  const _TargetCard({required this.target});

  final TargetModel target;

  @override
  Widget build(BuildContext context) {
    final color = _typeColor(target.type);
    return EmoSectionCard(
      radius: 30,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: () {
          context.read<TargetProvider>().setCurrentTarget(target);
          Navigator.of(context).push(
            MaterialPageRoute(
                builder: (_) => TargetDetailScreen(target: target)),
          );
        },
        child: Row(
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),
                gradient: LinearGradient(
                  colors: [
                    _typeBg(target.type),
                    _typeBg(target.type).withValues(alpha: 0.72),
                  ],
                ),
              ),
              child: Center(
                child: Text(_avatarByType(target.type),
                    style: const TextStyle(fontSize: 42)),
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          target.name,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: AuthPalette.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          target.typeLabel,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: color,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    target.relationship ?? _sampleDesc(target.type),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 17,
                      color: Color(0xFF837772),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                size: 32, color: Color(0xFF8C8580)),
          ],
        ),
      ),
    );
  }

  String _avatarByType(String type) {
    switch (type) {
      case 'boss':
        return '👨‍💼';
      case 'colleague':
        return '👩';
      case 'friend':
        return '🧑';
      case 'family':
        return '👒';
      case 'other':
        return '🐱';
      default:
        return '🙂';
    }
  }

  String _sampleDesc(String type) {
    switch (type) {
      case 'boss':
        return '工作要求严格，但很有能力';
      case 'colleague':
        return '团队中的开心果，乐于助人';
      case 'friend':
        return '无话不谈的好朋友，超懂我';
      case 'family':
        return '一起奋斗过的兄弟';
      case 'other':
        return '我最可爱的猫咪';
      default:
        return '总能接住我情绪的人';
    }
  }
}

Color _typeColor(String type) {
  switch (type) {
    case 'boss':
      return const Color(0xFFFF8A57);
    case 'colleague':
      return const Color(0xFF9A85F0);
    case 'friend':
      return const Color(0xFFFF8F99);
    case 'family':
      return const Color(0xFFFF8F99);
    case 'other':
      return const Color(0xFFFF9B9B);
    default:
      return const Color(0xFF8D8D8D);
  }
}

Color _typeBg(String type) {
  switch (type) {
    case 'boss':
      return const Color(0xFFE7E3DF);
    case 'colleague':
      return const Color(0xFFE4DDFD);
    case 'friend':
      return const Color(0xFFFFE0E2);
    case 'family':
      return const Color(0xFFF7E2D6);
    case 'other':
      return const Color(0xFFFFE6D8);
    default:
      return const Color(0xFFF1E7E2);
  }
}
