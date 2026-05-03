import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/app_providers.dart';
import '../models/target_model.dart';
import '../widgets/common/avatar_circle.dart';
import 'avatar_result_screen.dart';

class GenerateAvatarScreen extends StatefulWidget {
  const GenerateAvatarScreen({super.key});

  @override
  State<GenerateAvatarScreen> createState() => _GenerateAvatarScreenState();
}

class _GenerateAvatarScreenState extends State<GenerateAvatarScreen> {
  double _progress = 0;
  late Timer _timer;
  bool _isComplete = false;

  @override
  void initState() {
    super.initState();
    _startGeneration();
  }

  void _startGeneration() {
    const totalSteps = 50;
    int currentStep = 0;
    _timer = Timer.periodic(const Duration(milliseconds: 80), (timer) {
      currentStep++;
      setState(() => _progress = currentStep / totalSteps);

      if (currentStep >= totalSteps) {
        timer.cancel();
        setState(() => _isComplete = true);

        // 模拟AI生成完成
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => const AvatarResultScreen(),
              ),
            );
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final target = context.watch<TargetProvider>().currentTarget;
    final name = target?.name ?? '未知对象';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('生成形象'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: AppSpacing.screenPadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 生成中头像
              AvatarCircle(
                name: name,
                size: 160,
                isGenerating: !_isComplete,
                progress: _isComplete ? 1 : _progress,
              ),
              const SizedBox(height: 32),

              // 进度文字
              Text(
                _isComplete ? '生成完成！' : '正在生成 ${name} 的形象...',
                style: AppTextStyles.heading2,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              Text(
                _isComplete ? '看起来就很欠骂！' : 'AI 正在根据你的描述创作...',
                style: AppTextStyles.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // 进度条
              if (!_isComplete)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: _progress,
                      backgroundColor: AppColors.divider,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primary),
                      minHeight: 6,
                    ),
                  ),
                ),

              const SizedBox(height: 40),

              // 取消按钮
              if (!_isComplete)
                TextButton(
                  onPressed: () {
                    _timer.cancel();
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    '取消生成',
                    style: TextStyle(
                      color: AppColors.textHint,
                      fontSize: 15,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
