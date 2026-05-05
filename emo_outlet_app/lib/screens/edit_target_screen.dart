import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/target_model.dart';
import '../providers/app_providers.dart';
import '../widgets/auth/auth_visuals.dart';
import '../widgets/common/app_bottom_nav.dart';
import '../widgets/common/emo_ui.dart';
import 'home_screen.dart';

class EditTargetScreen extends StatefulWidget {
  const EditTargetScreen({super.key, required this.target});

  final TargetModel target;

  @override
  State<EditTargetScreen> createState() => _EditTargetScreenState();
}

class _EditTargetScreenState extends State<EditTargetScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _appearanceController;
  late final TextEditingController _personalityController;
  late final TextEditingController _relationshipController;
  late final TextEditingController _triggerController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.target.name);
    _appearanceController =
        TextEditingController(text: widget.target.appearance ?? '');
    _personalityController =
        TextEditingController(text: widget.target.personality ?? '');
    _relationshipController =
        TextEditingController(text: widget.target.relationship ?? '');
    _triggerController = TextEditingController(text: widget.target.triggers ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _appearanceController.dispose();
    _personalityController.dispose();
    _relationshipController.dispose();
    _triggerController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final updated = {
      'name': _nameController.text.trim(),
      'appearance': _appearanceController.text.trim(),
      'personality': _personalityController.text.trim(),
      'relationship': _relationshipController.text.trim(),
      'triggers': _triggerController.text.trim(),
    };
    if (widget.target.id != null) {
      await context.read<TargetProvider>().updateTarget(widget.target.id!, updated);
    }
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final color = typeColor(widget.target.type);

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
            padding: EdgeInsets.fromLTRB(horizontal, 16, horizontal, 14),
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
                      const Text(
                        '编辑对象',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AuthPalette.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 48),
                    ],
                  ),
                  const SizedBox(height: 14),
                  EmoSectionCard(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            EmoAvatar(
                              label: avatarEmojiByType(widget.target.type),
                              background: avatarBgByType(widget.target.type),
                              size: 88,
                            ),
                            Positioned(
                              right: -2,
                              bottom: -2,
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: const Icon(
                                  Icons.photo_camera_outlined,
                                  size: 18,
                                  color: Color(0xFF7C726D),
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
                              Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 10,
                                runSpacing: 8,
                                children: [
                                  Text(
                                    widget.target.name,
                                    style: const TextStyle(
                                      fontSize: 21,
                                      fontWeight: FontWeight.w700,
                                      color: AuthPalette.textPrimary,
                                    ),
                                  ),
                                  EmoTypePill(
                                    text: widget.target.typeLabel,
                                    color: color,
                                    background: color.withValues(alpha: 0.12),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                widget.target.relationship?.trim().isNotEmpty == true
                                    ? widget.target.relationship!
                                    : '补充这个对象的关系和触发点，会让聊天更贴近你的真实感受。',
                                style: const TextStyle(
                                  fontSize: 13,
                                  height: 1.45,
                                  color: Color(0xFF766B66),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                '最近更新：${formatFriendlyTime(widget.target.createdAt)}',
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  color: Color(0xFF9B948F),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  _EditFieldCard(label: '名称', controller: _nameController),
                  const SizedBox(height: 14),
                  _StaticInfoCard(label: '类型', value: widget.target.typeLabel),
                  const SizedBox(height: 14),
                  _EditFieldCard(label: '外貌描述', controller: _appearanceController),
                  const SizedBox(height: 14),
                  _EditFieldCard(label: '性格描述', controller: _personalityController),
                  const SizedBox(height: 14),
                  _EditFieldCard(label: '关系描述', controller: _relationshipController),
                  const SizedBox(height: 14),
                  _EditFieldCard(label: '触发事件', controller: _triggerController),
                  const SizedBox(height: 18),
                  GradientPrimaryButton(
                    text: '保存修改',
                    height: 56,
                    fontSize: 16.5,
                    onTap: _save,
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

class _EditFieldCard extends StatelessWidget {
  const _EditFieldCard({
    required this.label,
    required this.controller,
  });

  final String label;
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
              fontSize: 15.5,
              fontWeight: FontWeight.w700,
              color: AuthPalette.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            constraints: const BoxConstraints(minHeight: 54),
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
                fontSize: 15,
                height: 1.35,
                color: AuthPalette.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StaticInfoCard extends StatelessWidget {
  const _StaticInfoCard({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

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
              fontSize: 15.5,
              fontWeight: FontWeight.w700,
              color: AuthPalette.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 54,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F8F8).withValues(alpha: 0.84),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFEDE5E0)),
            ),
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF766B66),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
