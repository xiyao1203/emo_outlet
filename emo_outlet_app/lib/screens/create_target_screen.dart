import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/app_providers.dart';
import '../models/target_model.dart';
import '../widgets/common/avatar_circle.dart';
import 'generate_avatar_screen.dart';
import 'target_list_screen.dart';

class CreateTargetScreen extends StatefulWidget {
  const CreateTargetScreen({super.key});

  @override
  State<CreateTargetScreen> createState() => _CreateTargetScreenState();
}

class _CreateTargetScreenState extends State<CreateTargetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _appearanceController = TextEditingController();
  final _personalityController = TextEditingController();
  final _relationshipController = TextEditingController();

  String _selectedType = 'boss';
  String _selectedStyle = '漫画';

  @override
  void dispose() {
    _nameController.dispose();
    _appearanceController.dispose();
    _personalityController.dispose();
    _relationshipController.dispose();
    super.dispose();
  }

  void _handleCreate() {
    if (!_formKey.currentState!.validate()) return;

    final targetData = {
      'name': _nameController.text,
      'type': _selectedType,
      'appearance': _appearanceController.text,
      'personality': _personalityController.text,
      'relationship': _relationshipController.text,
      'style': _selectedStyle,
    };

    final provider = context.read<TargetProvider>();
    final target = TargetModel.fromJson(targetData);
    provider.setCurrentTarget(target);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const GenerateAvatarScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('创建泄愤对象'),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 名称
              const Text('对象名称 *', style: AppTextStyles.bodyMedium),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: '例如：讨厌的老板',
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? '请输入对象名称' : null,
              ),
              const SizedBox(height: 20),

              // 对象类型
              const Text('对象类型', style: AppTextStyles.bodyMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  'boss',
                  'colleague',
                  'partner',
                  'family',
                  'friend',
                  'other'
                ].map((type) {
                  final isSelected = _selectedType == type;
                  final label = TargetModel(
                    name: '',
                    type: type,
                  ).typeLabel;
                  return ChoiceChip(
                    label: Text(label),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _selectedType = type),
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // 外貌描述
              const Text('外貌描述', style: AppTextStyles.bodyMedium),
              const SizedBox(height: 8),
              TextFormField(
                controller: _appearanceController,
                decoration: const InputDecoration(
                  hintText: '例如：中年男性，西装',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 20),

              // 性格特征
              const Text('性格特征', style: AppTextStyles.bodyMedium),
              const SizedBox(height: 8),
              TextFormField(
                controller: _personalityController,
                decoration: const InputDecoration(
                  hintText: '例如：爱甩锅、小气',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 20),

              // 关系
              const Text('与你的关系', style: AppTextStyles.bodyMedium),
              const SizedBox(height: 8),
              TextFormField(
                controller: _relationshipController,
                decoration: const InputDecoration(
                  hintText: '例如：直属领导',
                ),
              ),
              const SizedBox(height: 20),

              // 风格
              const Text('形象风格', style: AppTextStyles.bodyMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['漫画', '写实', 'Q版', '简约'].map((style) {
                  final isSelected = _selectedStyle == style;
                  return ChoiceChip(
                    label: Text(style),
                    selected: isSelected,
                    onSelected: (_) =>
                        setState(() => _selectedStyle = style),
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 40),

              // 生成按钮
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _handleCreate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                  ),
                  child: const Text(
                    '生成形象',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
