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

  @override
  void dispose() {
    _nameController.dispose();
    _appearanceController.dispose();
    _personalityController.dispose();
    _relationshipController.dispose();
    _triggersController.dispose();
    super.dispose();
  }

  Future<void> _handleCreate() async {
    final provider = context.read<TargetProvider>();
    await provider.createTarget({
      'name': _nameController.text.isEmpty ? '王总' : _nameController.text,
      'type': _selectedType,
      'appearance': _appearanceController.text,
      'personality': _personalityController.text,
      'relationship': _relationshipController.text,
      'triggers': _triggersController.text,
      'style': _selectedStyle,
    });
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const GenerateAvatarScreen()),
    );
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
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                    ),
                    SizedBox(height: 6),
                    Text(
                      '创建一个对象，把情绪说给Ta听',
                      style: TextStyle(
                        fontSize: 13.5,
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
                          size: 96,
                        ),
                        Positioned(
                          right: -2,
                          bottom: -2,
                          child: Container(
                            width: 42,
                            height: 42,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0x806A5D58),
                            ),
                            child: const Icon(Icons.photo_camera_outlined,
                                color: Colors.white, size: 22),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '上传头像或AI生成形象',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AuthPalette.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            '让Ta更真实，陪伴你更久',
                            style: TextStyle(
                              fontSize: 13.5,
                              color: Color(0xFF7A706B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 14),
                          EmoGradientOutlineButton(
                            text: 'AI生成形象',
                            icon: Icons.auto_awesome_outlined,
                            onTap: _handleCreate,
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
            _fieldRow('外貌描述', '描述Ta的外貌特征，比如发型、气质等', _appearanceController,
                trailingArrow: true),
            _fieldRow('性格描述', '描述Ta的性格特点，比如严厉、温和等', _personalityController,
                trailingArrow: true),
            _fieldRow('关系描述', '你们之间的关系状况', _relationshipController,
                trailingArrow: true),
            _fieldRow('触发事件', '是什么事件让你产生了情绪', _triggersController,
                trailingArrow: true),
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
              text: '生成并保存对象',
              height: 60,
              fontSize: 18,
              onTap: _handleCreate,
            ),
          ],
        ),
      ),
    );
  }

  Widget _fieldRow(
    String title,
    String hint,
    TextEditingController controller, {
    bool trailingArrow = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: EmoSectionCard(
        child: Row(
          children: [
            SizedBox(
              width: 92,
              child: Text(
                title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
            Expanded(
              child: TextField(
                controller: controller,
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: hint,
                  hintStyle: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFFBEB8B4),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF4A4340),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (trailingArrow)
              const Icon(Icons.chevron_right_rounded,
                  color: Color(0xFF9E9E9E), size: 22),
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 92,
              child: Text(
                title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
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
                          horizontal: 14, vertical: 9),
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
                          fontSize: 15,
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
