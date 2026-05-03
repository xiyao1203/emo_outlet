import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/app_providers.dart';
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
    final target = context.read<TargetProvider>().currentTarget;
    final targetId = target?.id;

    const totalSteps = 50;
    int currentStep = 0;
    _timer = Timer.periodic(const Duration(milliseconds: 80), (timer) {
      currentStep++;
      setState(() => _progress = currentStep / totalSteps);

      if (currentStep >= totalSteps) {
        timer.cancel();
        setState(() => _isComplete = true);

        if (targetId != null) {
          context.read<TargetProvider>().generateAvatar(targetId);
        }

        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const AvatarResultScreen()),
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
        title: const Text('生成形象', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF333333))),
        centerTitle: true,
        backgroundColor: const Color(0xFFF8F8F8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF666666)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 动画头像
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: _isComplete ? 180 : 140,
                height: _isComplete ? 180 : 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF7A56), Color(0xFFFF9A76)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 24, offset: const Offset(0, 8)),
                  ],
                ),
                child: Center(
                  child: Text(
                    name.length >= 2 ? name.substring(0, 2) : name[0],
                    style: TextStyle(fontSize: _isComplete ? 64 : 48, color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // 标题
              Text(
                _isComplete ? '生成完成！' : '正在创造形象...',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Color(0xFF333333)),
              ),
              const SizedBox(height: 8),
              Text(
                _isComplete ? '看起来就很欠骂！' : 'AI 正在根据你的描述为你创作 $name 的形象',
                style: const TextStyle(fontSize: 14, color: Color(0xFF999999)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // 进度条
              if (!_isComplete)
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: _progress,
                          backgroundColor: const Color(0xFFE0E0E0),
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                          minHeight: 6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${(_progress * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(fontSize: 14, color: AppColors.primary, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              const SizedBox(height: 40),

              // 取消按钮
              if (!_isComplete)
                TextButton(
                  onPressed: () {
                    _timer.cancel();
                    Navigator.of(context).pop();
                  },
                  child: const Text('取消生成', style: TextStyle(fontSize: 15, color: Color(0xFF999999))),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
