import 'dart:async';

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
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;
  String _debouncedQuery = '';

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
      setState(() => _debouncedQuery = _normalize(value));
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TargetProvider>();
    final targets = provider.targets;
    final query = _debouncedQuery;
    final filtered = targets.where((target) {
      if (query.isEmpty) return true;
      return _normalize(target.name).contains(query) ||
          _normalize(target.relationship ?? '').contains(query) ||
          _normalize(target.typeLabel).contains(query);
    }).toList();

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 104),
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
                      '\u6211\u7684\u5bf9\u8c61',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AuthPalette.textPrimary,
                      ),
                    ),
                    const Align(
                      alignment: Alignment.centerRight,
                      child: SizedBox(
                        width: 88,
                        height: 72,
                        child: EmoDecorationCloud(size: 80),
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
                    const Icon(
                      Icons.search_rounded,
                      size: 22,
                      color: Color(0xFFABABAB),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: _handleSearchChanged,
                        decoration: const InputDecoration(
                          hintText:
                              '\u641c\u7d22\u5bf9\u8c61\u540d\u79f0\u6216\u5173\u952e\u8bcd',
                          hintStyle: TextStyle(
                            color: Color(0xFFB3B3B3),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                          border: InputBorder.none,
                        ),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: AuthPalette.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              EmoSectionCard(
                radius: 30,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Row(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Center(
                        child: Text(
                          '\uD83D\uDC65',
                          style: TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text.rich(
                            TextSpan(
                              children: [
                                const TextSpan(
                                  text: '\u5171 ',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                    color: AuthPalette.textPrimary,
                                  ),
                                ),
                                TextSpan(
                                  text: '${targets.length}',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFFF754C),
                                  ),
                                ),
                                const TextSpan(
                                  text: ' \u4e2a\u5bf9\u8c61',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                    color: AuthPalette.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            query.isEmpty
                                ? '\u9009\u62e9\u5bf9\u8c61\uff0c\u5411 TA \u503e\u8bc9\u4f60\u7684\u60c5\u7eea\u5427'
                                : '\u5df2\u627e\u5230 ${filtered.length} \u4e2a\u76f8\u5173\u5bf9\u8c61',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF8A7D77),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 92,
                      height: 72,
                      child: EmoDecorationCloud(size: 84),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (filtered.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 18),
                  child: Text(
                    '\u6ca1\u6709\u627e\u5230\u5339\u914d\u7684\u5bf9\u8c61',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF8A7D77),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              else
                for (final target in filtered) ...[
                  _TargetCard(target: target),
                  const SizedBox(height: 12),
                ],
            ],
          ),
        ),
        Positioned(
          left: 18,
          right: 18,
          bottom: 18,
          child: GradientPrimaryButton(
            text: '\u002b \u65b0\u5efa\u5bf9\u8c61',
            height: 60,
            fontSize: 18,
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
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: () {
          context.read<TargetProvider>().setCurrentTarget(target);
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => TargetDetailScreen(target: target),
            ),
          );
        },
        child: Row(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: LinearGradient(
                  colors: [
                    _typeBg(target.type),
                    _typeBg(target.type).withValues(alpha: 0.72),
                  ],
                ),
              ),
              child: Center(
                child: Text(
                  _avatarByType(target.type),
                  style: const TextStyle(fontSize: 26),
                ),
              ),
            ),
            const SizedBox(width: 14),
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
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AuthPalette.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          target.typeLabel,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: color,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    target.relationship ?? _sampleDesc(target.type),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF837772),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 24,
              color: Color(0xFF8C8580),
            ),
          ],
        ),
      ),
    );
  }

  String _avatarByType(String type) {
    switch (type) {
      case 'boss':
        return '\uD83D\uDC68\u200D\uDCBC';
      case 'colleague':
        return '\uD83D\uDC6D';
      case 'friend':
        return '\uD83E\uDD1D';
      case 'family':
        return '\uD83C\uDFE0';
      case 'other':
        return '\u2728';
      default:
        return '\uD83D\uDE42';
    }
  }

  String _sampleDesc(String type) {
    switch (type) {
      case 'boss':
        return '\u5de5\u4f5c\u8981\u6c42\u4e25\u683c\uff0c\u4f46\u5f88\u6709\u80fd\u529b';
      case 'colleague':
        return '\u56e2\u961f\u91cc\u7684\u5f00\u5fc3\u679c\uff0c\u4e50\u4e8e\u5e2e\u52a9\u4eba';
      case 'friend':
        return '\u65e0\u8bdd\u4e0d\u8c08\u7684\u597d\u670b\u53cb\uff0c\u5f88\u61c2\u6211';
      case 'family':
        return '\u4e00\u8d77\u5954\u8dd1\u8fc7\u751f\u6d3b\u7684\u5bb6\u4eba';
      case 'other':
        return '\u6211\u6700\u53ef\u7231\u7684\u5c0f\u751f\u547d';
      default:
        return '\u603b\u80fd\u63a5\u4f4f\u6211\u60c5\u7eea\u7684\u5bf9\u8c61';
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
