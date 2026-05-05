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
            _nameController.text.trim().isEmpty
                ? 'Ta'
                : _nameController.text.trim(),
            _relationshipController.text.trim(),
          );
      if (!mounted || result == null) return;
      _appearanceController.text = result['appearance'] as String? ?? '';
      _personalityController.text = result['personality'] as String? ?? '';
      final style = result['style'] as String? ?? _selectedStyle;
      if (<String>['Q版', '手绘', '温和', '夸张'].contains(style)) {
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
        'name': _nameController.text.trim().isEmpty
            ? '未命名对象'
            : _nameController.text.trim(),
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
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 10),
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
                        fontSize: 21,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      '创建一个对象，把情绪说给 Ta 听',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF79706C),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                const EmoDecorationCloud(size: 92),
              ],
            ),
            Transform.translate(
              offset: const Offset(0, -10),
              child: EmoSectionCard(
                child: Row(
                  children: [
                    Stack(
                      children: [
                        EmoAvatar(
                          label: avatarEmojiByType(_selectedType),
                          background: avatarBgByType(_selectedType),
                          size: 88,
                        ),
                        Positioned(
                          right: -2,
                          bottom: -2,
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0x806A5D58),
                            ),
                            child: const Icon(
                              Icons.auto_awesome_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '上传头像或 AI 生成形象',
                            style: TextStyle(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w700,
                              color: AuthPalette.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            '先补全外貌和性格，再生成更贴近记忆的对象形象',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF7A706B),
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 12),
                          EmoGradientOutlineButton(
                            text: _isAiCompleting ? 'AI 补全中...' : 'AI 智能补全',
                            icon: Icons.auto_awesome_outlined,
                            onTap: _isAiCompleting ? () {} : _handleAiComplete,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _fieldRow('对象名称', '请输入对象名称', _nameController),
            _choiceRow(
              title: '对象类型',
              values: const [
                ['boss', '老板'],
                ['colleague', '同事'],
                ['partner', '前任'],
                ['client', '客户'],
                ['family', '家人'],
                ['other', '其他'],
              ],
              selected: _selectedType,
              onSelected: (value) => setState(() => _selectedType = value),
            ),
            _fieldRow(
              '外貌描述',
              '描述 Ta 的外貌特征，比如发型、气质等',
              _appearanceController,
            ),
            _fieldRow(
              '性格描述',
              '描述 Ta 的性格特点，比如直接、温和、强势等',
              _personalityController,
            ),
            _fieldRow(
              '关系描述',
              '你们之间的关系状态，比如上司、前任、家人',
              _relationshipController,
            ),
            _fieldRow(
              '触发事件',
              '是什么事情让你在意或有情绪',
              _triggersController,
            ),
            _choiceRow(
              title: '形象风格',
              values: const [
                ['Q版', 'Q版'],
                ['手绘', '手绘'],
                ['温和', '温和'],
                ['夸张', '夸张'],
              ],
              selected: _selectedStyle,
              onSelected: (value) => setState(() => _selectedStyle = value),
            ),
            const SizedBox(height: 16),
            GradientPrimaryButton(
              text: _isSubmitting ? '生成中...' : '生成并保存对象',
              height: 58,
              fontSize: 17,
              onTap: _isSubmitting ? null : _handleCreate,
            ),
          ],
        ),
      ),
    );
  }

  Widget _fieldRow(
    String title,
    String hint,
    TextEditingController controller,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: EmoSectionCard(
        padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
        child: Row(
          children: [
            SizedBox(
              width: 84,
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Expanded(
              child: TextField(
                controller: controller,
                textAlign: TextAlign.left,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: hint,
                  hintStyle: const TextStyle(
                    fontSize: 14.5,
                    color: Color(0xFFBEB8B4),
                    fontWeight: FontWeight.w500,
                  ),
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                style: const TextStyle(
                  fontSize: 14.5,
                  height: 1.35,
                  color: Color(0xFF4A4340),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _choiceRow({
    required String title,
    required List<List<String>> values,
    required String selected,
    required ValueChanged<String> onSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: EmoSectionCard(
        padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 84,
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Expanded(
              child: Wrap(
                alignment: WrapAlignment.end,
                spacing: 8,
                runSpacing: 8,
                children: values.map((item) {
                  final active = selected == item.first;
                  return InkWell(
                    onTap: () => onSelected(item.first),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 13,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: active
                            ? const Color(0x14FF7D5D)
                            : Colors.white.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: active
                              ? const Color(0xFFFF7D5D)
                              : const Color(0xFFF1E6DF),
                        ),
                      ),
                      child: Text(
                        item.last,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: active
                              ? const Color(0xFFFF7D5D)
                              : const Color(0xFF53504D),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
