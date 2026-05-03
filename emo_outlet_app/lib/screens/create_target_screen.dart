import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/app_providers.dart';
import '../models/target_model.dart';
import 'generate_avatar_screen.dart';

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

  void _handleCreate() async {
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
    await provider.createTarget(targetData);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const GenerateAvatarScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('创建泄愤对象', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF333333))),
        centerTitle: true,
        backgroundColor: const Color(0xFFF8F8F8),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('基本信息'),
              const SizedBox(height: 12),
              // 对象名称
              _buildLabel('对象名称 *'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _nameController,
                hint: '例如：讨厌的老板',
                validator: (v) => v == null || v.isEmpty ? '请输入对象名称' : null,
              ),
              const SizedBox(height: 20),
              // 对象类型
              _buildLabel('对象类型'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: ['boss','colleague','partner','family','friend','other'].map((type) {
                  final isSelected = _selectedType == type;
                  final label = TargetModel(name: '', type: type).typeLabel;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedType = type),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
                      ),
                      child: Text(label, style: TextStyle(fontSize: 14, color: isSelected ? Colors.white : AppColors.textPrimary, fontWeight: FontWeight.w500)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 28),
              _buildSectionHeader('详细描述'),
              const SizedBox(height: 12),
              // 外貌描述
              _buildLabel('外貌描述'),
              const SizedBox(height: 8),
              _buildTextField(controller: _appearanceController, hint: '例如：中年男性，西装革履', maxLines: 2),
              const SizedBox(height: 16),
              // 性格特征
              _buildLabel('性格特征'),
              const SizedBox(height: 8),
              _buildTextField(controller: _personalityController, hint: '例如：爱甩锅、小气、爱拍马屁', maxLines: 2),
              const SizedBox(height: 16),
              // 与你的关系
              _buildLabel('与你的关系'),
              const SizedBox(height: 8),
              _buildTextField(controller: _relationshipController, hint: '例如：直属领导'),
              const SizedBox(height: 12),
              // AI 补全
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _handleAiComplete,
                  icon: const Icon(Icons.auto_fix_high, size: 18),
                  label: const Text('AI 自动补全', style: TextStyle(fontSize: 14)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(color: AppColors.primary.withOpacity(0.3)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              _buildSectionHeader('形象风格'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: ['漫画','写实','Q版','简约'].map((style) {
                  final isSelected = _selectedStyle == style;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedStyle = style),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
                      ),
                      child: Text(style, style: TextStyle(fontSize: 14, color: isSelected ? Colors.white : AppColors.textPrimary, fontWeight: FontWeight.w500)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 40),
              // 生成按钮
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _handleCreate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 4,
                    shadowColor: AppColors.primary.withOpacity(0.3),
                  ),
                  child: const Text('生成形象', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _handleAiComplete() async {
    if (_nameController.text.isEmpty || _relationshipController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先填写对象名称和关系'), behavior: SnackBarBehavior.floating),
      );
      return;
    }
    final provider = context.read<TargetProvider>();
    final result = await provider.aiComplete(_nameController.text, _relationshipController.text);
    if (result != null && mounted) {
      if (result['appearance'] != null) _appearanceController.text = result['appearance'] as String;
      if (result['personality'] != null) _personalityController.text = result['personality'] as String;
      if (result['type'] != null) setState(() => _selectedType = result['type'] as String);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('AI 已自动补全！'), behavior: SnackBarBehavior.floating),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('AI 补全暂不可用，请手动填写'), behavior: SnackBarBehavior.floating),
      );
    }
  }

  Widget _buildSectionHeader(String text) {
    return Row(
      children: [
        Container(width: 4, height: 18, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF333333))),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF666666)));
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFCCCCCC)),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}
