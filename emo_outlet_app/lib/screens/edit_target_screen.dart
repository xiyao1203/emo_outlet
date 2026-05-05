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
  late final TextEditingController _typeController;
  late final TextEditingController _appearanceController;
  late final TextEditingController _personalityController;
  late final TextEditingController _relationshipController;
  late final TextEditingController _triggerController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.target.name);
    _typeController = TextEditingController(text: widget.target.typeLabel);
    _appearanceController = TextEditingController(
      text: widget.target.appearance ?? '30多岁，戴眼镜，西装笔挺，表情严肃',
    );
    _personalityController = TextEditingController(
      text: widget.target.personality ?? '要求高，细节控，容易焦虑，追求完美',
    );
    _relationshipController = TextEditingController(
      text: widget.target.relationship ?? '直属上级，经常指出问题，给我压力',
    );
    _triggerController = TextEditingController(
      text: widget.target.triggers ?? '临时加需求、周末开会、否定我的方案',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    _appearanceController.dispose();
    _personalityController.dispose();
    _relationshipController.dispose();
    _triggerController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final updated = {
      'name': _nameController.text,
      'appearance': _appearanceController.text,
      'personality': _personalityController.text,
      'relationship': _relationshipController.text,
      'triggers': _triggerController.text,
    };
    if (widget.target.id != null) {
      await context
          .read<TargetProvider>()
          .updateTarget(widget.target.id!, updated);
    }
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final color = typeColor(widget.target.type);
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
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
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
                  style: TextStyle(fontSize: 23, fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                const SizedBox(width: 56),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Spacer(),
                const EmoDecorationCloud(size: 126),
              ],
            ),
            Transform.translate(
              offset: const Offset(0, -10),
              child: EmoSectionCard(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Stack(
                          children: [
                            EmoAvatar(
                              label: avatarEmojiByType(widget.target.type),
                              background: avatarBgByType(widget.target.type),
                              size: 96,
                            ),
                            Positioned(
                              right: -4,
                              bottom: -4,
                              child: Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  border:
                                      Border.all(color: Colors.white, width: 2),
                                ),
                                child: const Icon(Icons.photo_camera_outlined,
                                    size: 22, color: Color(0xFF6F6F6F)),
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
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  EmoTypePill(
                                    text: widget.target.typeLabel,
                                    color: color,
                                    background: color.withValues(alpha: 0.12),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                widget.target.relationship ?? '总是临时加需求，周末还要开会…',
                                style: const TextStyle(
                                  fontSize: 14,
                                  height: 1.5,
                                  color: Color(0xFF706660),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '最近更新：${formatFriendlyTime(widget.target.createdAt)}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF9A948F),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            _editableRow(Icons.person_rounded, const Color(0xFFFF6D9C), '名称',
                _nameController),
            _editableRow(Icons.work_rounded, const Color(0xFFFFA558), '类型',
                _typeController),
            _editableRow(Icons.face_rounded, const Color(0xFFAE8BFF), '外貌描述',
                _appearanceController),
            _editableRow(Icons.star_rounded, const Color(0xFFFFBE57), '性格描述',
                _personalityController),
            _editableRow(Icons.favorite_rounded, const Color(0xFFFF88A8),
                '关系描述', _relationshipController),
            _editableRow(Icons.bolt_rounded, const Color(0xFFFF8A54), '触发事件',
                _triggerController),
            const SizedBox(height: 16),
            EmoSectionCard(
              child: SizedBox(
                height: 56,
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.refresh_rounded,
                          color: Color(0xFF606060), size: 30),
                      SizedBox(width: 12),
                      Text(
                        '重新生成形象',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF3A3A3A),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            GradientPrimaryButton(
              text: '保存修改',
              height: 60,
              fontSize: 18,
              onTap: _save,
            ),
          ],
        ),
      ),
    );
  }

  Widget _editableRow(
    IconData icon,
    Color color,
    String label,
    TextEditingController controller,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: EmoSectionCard(
        padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 14),
            SizedBox(
              width: 86,
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Expanded(
              child: TextField(
                controller: controller,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.4,
                  color: Color(0xFF3A3A3A),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.edit_outlined, color: Color(0xFF9A9A9A), size: 20),
          ],
        ),
      ),
    );
  }
}
