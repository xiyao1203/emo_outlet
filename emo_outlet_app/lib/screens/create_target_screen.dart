import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_providers.dart';
import '../widgets/auth/auth_visuals.dart';
import '../widgets/common/app_bottom_nav.dart';
import '../widgets/common/emo_ui.dart';
import 'generate_avatar_screen.dart';
import 'home_screen.dart';

class CreateTargetScreen extends StatefulWidget {
  const CreateTargetScreen({super.key});

  @override
  State<CreateTargetScreen> createState() => _CreateTargetScreenState();
}

class _CreateTargetScreenState extends State<CreateTargetScreen> {
  final _nameController = TextEditingController();
  final _appearanceController = TextEditingController();
  final _personalityController = TextEditingController();
  final _relationshipController = TextEditingController();
  final _triggersController = TextEditingController();

  String _selectedType = 'boss';
  String _selectedStyle = 'Q版';
  bool _isSubmitting = false;
  bool _isAiCompleting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _appearanceController.dispose();
    _personalityController.dispose();
    _relationshipController.dispose();
    _triggersController.dispose();
    super.dispose();
  }

  Future<void> _handleAiComplete() async {
    if (_isAiCompleting) return;
    setState(() => _isAiCompleting = true);
    try {
      final result = await context.read<TargetProvider>().aiComplete(
            _nameController.text.trim().isEmpty ? 'Ta' : _nameController.text.trim(),
            _relationshipController.text.trim(),
          );
      if (!mounted || result == null) return;
      _appearanceController.text = result['appearance'] as String? ?? '';
      _personalityController.text = result['personality'] as String? ?? '';
      final style = result['style'] as String? ?? _selectedStyle;
      if (const <String>['Q版', '手绘', '温和', '夸张'].contains(style)) {
        setState(() => _selectedStyle = style);
      }
    } finally {
      if (mounted) {
        setState(() => _isAiCompleting = false);
      }
    }
  }

  Future<void> _handleCreate() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);
    try {
      await context.read<TargetProvider>().createTarget({
        'name': _nameController.text.trim().isEmpty ? '未命名对象' : _nameController.text.trim(),
        'type': _selectedType,
        'appearance': _appearanceController.text.trim(),
        'personality': _personalityController.text.trim(),
        'relationship': _relationshipController.text.trim(),
        'triggers': _triggersController.text.trim(),
        'style': _selectedStyle,
      });
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const GenerateAvatarScreen()),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final horizontal = EmoResponsive.edgePadding(width);

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
            padding: EdgeInsets.fromLTRB(horizontal, 16, horizontal, 12),
            child: EmoResponsiveContent(
              width: width,
              maxWidth: 620,
              child: Column(
                children: [
                  Row(
                    children: [
                      EmoRoundIconButton(
                        icon: Icons.chevron_left_rounded,
                        onTap: () => Navigator.of(context).pop(),
                      ),
                      const Spacer(),
                      const Column(
                        children: [
                          Text(
                            '创建对象',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w700,
                              color: AuthPalette.textPrimary,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            '创建一个对象，把情绪说给 Ta 听',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: Color(0xFF7E746E),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      const EmoDecorationCloud(size: 84),
                    ],
                  ),
                  const SizedBox(height: 14),
                  EmoSectionCard(
                    child: Row(
                      children: [
                        Stack(
                          children: [
                            EmoAvatar(
                              label: avatarEmojiByType(_selectedType),
                              background: avatarBgByType(_selectedType),
                              size: 84,
                            ),
                            Positioned(
                              right: -2,
                              bottom: -2,
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF8F7E77).withValues(alpha: 0.78),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: const Icon(
                                  Icons.auto_awesome_rounded,
                                  size: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '上传头像或 AI 生成形象',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AuthPalette.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                '先补全外貌和性格，再生成更贴近记忆的对象形象',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  height: 1.4,
                                  color: Color(0xFF7B706B),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 12),
                              EmoGradientOutlineButton(
                                text: _isAiCompleting ? 'AI 智能补全中...' : 'AI 智能补全',
                                icon: Icons.auto_awesome_outlined,
                                onTap: _isAiCompleting ? () {} : _handleAiComplete,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  _FormFieldCard(
                    label: '对象名称',
                    hint: '请输入对象名称',
                    controller: _nameController,
                  ),
                  const SizedBox(height: 14),
                  _ChoiceFieldCard(
                    title: '对象类型',
                    selected: _selectedType,
                    values: const [
                      _ChoiceItem('boss', '老板'),
                      _ChoiceItem('colleague', '同事'),
                      _ChoiceItem('partner', '前任'),
                      _ChoiceItem('client', '客户'),
                      _ChoiceItem('family', '家人'),
                      _ChoiceItem('other', '其他'),
                    ],
                    onSelected: (value) => setState(() => _selectedType = value),
                  ),
                  const SizedBox(height: 14),
                  _FormFieldCard(
                    label: '外貌描述',
                    hint: '描述 Ta 的外貌特征，比如发型、气质等',
                    controller: _appearanceController,
                  ),
                  const SizedBox(height: 14),
                  _FormFieldCard(
                    label: '性格描述',
                    hint: '描述 Ta 的性格特点，比如直接、温和、强势等',
                    controller: _personalityController,
                  ),
                  const SizedBox(height: 14),
                  _FormFieldCard(
                    label: '关系描述',
                    hint: '你们之间的关系状态，比如上司、前任、家人',
                    controller: _relationshipController,
                  ),
                  const SizedBox(height: 14),
                  _FormFieldCard(
                    label: '触发事件',
                    hint: '是什么事情让你在意，或者让你有情绪',
                    controller: _triggersController,
                  ),
                  const SizedBox(height: 14),
                  _ChoiceFieldCard(
                    title: '形象风格',
                    selected: _selectedStyle,
                    values: const [
                      _ChoiceItem('Q版', 'Q版'),
                      _ChoiceItem('手绘', '手绘'),
                      _ChoiceItem('温和', '温和'),
                      _ChoiceItem('夸张', '夸张'),
                    ],
                    onSelected: (value) => setState(() => _selectedStyle = value),
                  ),
                  const SizedBox(height: 18),
                  GradientPrimaryButton(
                    text: _isSubmitting ? '生成中...' : '生成并保存对象',
                    height: 56,
                    fontSize: 15.5,
                    onTap: _isSubmitting ? null : _handleCreate,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FormFieldCard extends StatelessWidget {
  const _FormFieldCard({
    required this.label,
    required this.hint,
    required this.controller,
  });

  final String label;
  final String hint;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return EmoSectionCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              color: AuthPalette.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            constraints: const BoxConstraints(minHeight: 52),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F8F8).withValues(alpha: 0.84),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFEDE5E0)),
            ),
            child: TextField(
              controller: controller,
              textAlign: TextAlign.left,
              textAlignVertical: TextAlignVertical.center,
              style: const TextStyle(
                fontSize: 14,
                height: 1.35,
                color: AuthPalette.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFFB4AEA8),
                  fontWeight: FontWeight.w500,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChoiceFieldCard extends StatelessWidget {
  const _ChoiceFieldCard({
    required this.title,
    required this.selected,
    required this.values,
    required this.onSelected,
  });

  final String title;
  final String selected;
  final List<_ChoiceItem> values;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return EmoSectionCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              color: AuthPalette.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: values.map((item) {
              final active = item.value == selected;
              return GestureDetector(
                onTap: () => onSelected(item.value),
                child: Container(
                  constraints: const BoxConstraints(minHeight: 40),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                  decoration: BoxDecoration(
                    color: active
                        ? const Color(0xFFFFF1EC)
                        : Colors.white.withValues(alpha: 0.74),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: active ? const Color(0xFFFF7D5E) : const Color(0xFFE8DFD8),
                    ),
                  ),
                  child: Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: active ? const Color(0xFFFF7D5E) : const Color(0xFF59504B),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _ChoiceItem {
  const _ChoiceItem(this.value, this.label);

  final String value;
  final String label;
}
