import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_providers.dart';
import '../widgets/auth/auth_visuals.dart';
import '../widgets/common/app_bottom_nav.dart';
import '../widgets/common/emo_ui.dart';
import 'avatar_result_screen.dart';
import 'home_screen.dart';

enum _AvatarGenerationState { loading, success, failure }

class GenerateAvatarScreen extends StatefulWidget {
  const GenerateAvatarScreen({super.key});

  @override
  State<GenerateAvatarScreen> createState() => _GenerateAvatarScreenState();
}

class _GenerateAvatarScreenState extends State<GenerateAvatarScreen> {
  Timer? _timer;
  double _progress = 0.08;
  _AvatarGenerationState _state = _AvatarGenerationState.loading;
  String _status = '正在分析外貌与性格描述...';
  String _error = '';

  @override
  void initState() {
    super.initState();
    _startGeneration();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startProgressTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 300), (timer) {
      if (!mounted || _state != _AvatarGenerationState.loading) {
        timer.cancel();
        return;
      }
      setState(() {
        _progress += 0.06;
        if (_progress > 0.9) {
          _progress = 0.9;
        }
        if (_progress < 0.36) {
          _status = '正在分析外貌与性格描述...';
        } else if (_progress < 0.72) {
          _status = '正在根据风格生成漫画头像...';
        } else {
          _status = '正在优化光影、表情和细节...';
        }
      });
    });
  }

  Future<void> _startGeneration() async {
    final provider = context.read<TargetProvider>();
    final current = provider.currentTarget;
    final targetId = current?.id;
    if (targetId == null) {
      setState(() {
        _state = _AvatarGenerationState.failure;
        _error = '还没有可生成的对象信息，请先完成创建。';
      });
      return;
    }

    setState(() {
      _state = _AvatarGenerationState.loading;
      _progress = 0.08;
      _status = '正在分析外貌与性格描述...';
      _error = '';
    });
    _startProgressTimer();

    try {
      await provider.generateAvatar(targetId);
      if (!mounted) return;
      _timer?.cancel();
      setState(() {
        _progress = 1;
        _state = _AvatarGenerationState.success;
        _status = '生成完成，已经为你准备好预览。';
      });
    } catch (error) {
      if (!mounted) return;
      _timer?.cancel();
      setState(() {
        _state = _AvatarGenerationState.failure;
        _error = '形象生成失败了，请检查服务配置后重试。';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final target = context.watch<TargetProvider>().currentTarget;
    final current = target;

    return EmoPageScaffold(
      bottomNavigationBar: AppBottomNav(
        currentIndex: 1,
        onTap: (index) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => HomeScreen(initialIndex: index)),
          );
        },
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
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
                  '生成形象中',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                const EmoDecorationCloud(size: 116),
              ],
            ),
            const SizedBox(height: 10),
            EmoSectionCard(
              radius: 36,
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
              child: Column(
                children: [
                  Container(
                    width: 196,
                    height: 196,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFFFFB28A), Color(0xFFFF7A7F)],
                      ),
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: EmoAvatar(
                          label: avatarEmojiByType(current?.type ?? 'boss'),
                          background: avatarBgByType(current?.type ?? 'boss'),
                          imageUrl: _state == _AvatarGenerationState.success
                              ? current?.avatarUrl
                              : null,
                          size: 152,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _state == _AvatarGenerationState.failure
                        ? '生成失败'
                        : _state == _AvatarGenerationState.success
                            ? '形象生成完成'
                            : '正在为你生成专属形象',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _state == _AvatarGenerationState.failure
                        ? _error
                        : _status,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.8,
                      color: _state == _AvatarGenerationState.failure
                          ? const Color(0xFFCC5C54)
                          : const Color(0xFFC8A79A),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.68),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: Colors.white),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: LinearProgressIndicator(
                              value: _state == _AvatarGenerationState.failure
                                  ? null
                                  : _progress,
                              minHeight: 20,
                              backgroundColor: const Color(0xFFF7E8E0),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFFFF7B7A),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Text(
                          _state == _AvatarGenerationState.failure
                              ? '--'
                              : '${(_progress * 100).round()}%',
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFFF7E73),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: _StepChip(
                          title: '分析描述',
                          active: _progress < 0.36,
                          done: _progress >= 0.36,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _StepChip(
                          title: '生成图像',
                          active: _progress >= 0.36 && _progress < 0.9,
                          done: _progress >= 0.9,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _StepChip(
                          title: '优化细节',
                          active: _progress >= 0.9 &&
                              _state == _AvatarGenerationState.loading,
                          done: _state == _AvatarGenerationState.success,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  const EmoSectionCard(
                    radius: 24,
                    child: Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline_rounded,
                          color: Color(0xFFFFB356),
                          size: 28,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '会结合外貌、性格和风格标签生成更贴近记忆的漫画头像。',
                            style: TextStyle(
                              fontSize: 12.5,
                              height: 1.45,
                              color: Color(0xFF8A6255),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            if (_state == _AvatarGenerationState.loading)
              const GradientPrimaryButton(
                text: '生成中，请稍候',
                height: 54,
                fontSize: 15.5,
                onTap: null,
              )
            else if (_state == _AvatarGenerationState.success)
              GradientPrimaryButton(
                text: '查看生成结果',
                height: 54,
                fontSize: 15.5,
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => const AvatarResultScreen(),
                    ),
                  );
                },
              )
            else
              GradientPrimaryButton(
                text: '重新生成',
                height: 54,
                fontSize: 15.5,
                onTap: _startGeneration,
              ),
          ],
        ),
      ),
    );
  }
}

class _StepChip extends StatelessWidget {
  const _StepChip({
    required this.title,
    required this.active,
    this.done = false,
  });

  final String title;
  final bool active;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final color = active
        ? const Color(0xFFFF7B7A)
        : done
            ? const Color(0xFF8E5A4E)
            : const Color(0xFF9A9A9A);
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: active ? const Color(0xFFFFD3C7) : const Color(0xFFF2E8E3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            done ? Icons.check_circle_rounded : Icons.trip_origin_rounded,
            size: 20,
            color: color,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
