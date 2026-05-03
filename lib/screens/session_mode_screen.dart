import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../config/constants.dart';
import '../models/session_model.dart';
import '../providers/app_providers.dart';
import 'chat_screen.dart';

class SessionModeScreen extends StatefulWidget {
  const SessionModeScreen({super.key});

  @override
  State<SessionModeScreen> createState() => _SessionModeScreenState();
}

class _SessionModeScreenState extends State<SessionModeScreen> {
  SessionMode _mode = SessionMode.single;
  ChatStyle? _chatStyle;
  String _dialect = '普通话';
  int _duration = 3;

  @override
  Widget build(BuildContext context) {
    final target = context.watch<TargetProvider>().currentTarget;
    final targetName = target?.name ?? '未知对象';

    return Scaffold(
      appBar: AppBar(
        title: Text('向 $targetName 释放情绪'),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 目标信息
            Center(
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: AppColors.primaryGradient,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [AppColors.buttonShadow],
                    ),
                    child: Center(
                      child: Text(
                        targetName.length >= 2
                            ? targetName.substring(0, 2)
                            : targetName[0],
                        style: const TextStyle(
                          fontSize: 28,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(targetName, style: AppTextStyles.heading2),
                  if (target?.typeLabel != null) ...[
                    const SizedBox(height: 4),
                    Text(target!.typeLabel, style: AppTextStyles.label),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 32),

            // 模式选择
            const Text('模式选择', style: AppTextStyles.bodyMedium),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _ModeCard(
                    icon: Icons.volume_up_outlined,
                    title: '单向模式',
                    desc: 'AI 只承接，不反驳',
                    isSelected: _mode == SessionMode.single,
                    onTap: () => setState(() => _mode = SessionMode.single),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ModeCard(
                    icon: Icons.forum_outlined,
                    title: '双向模式',
                    desc: 'AI 可反驳',
                    isSelected: _mode == SessionMode.dual,
                    onTap: () => setState(() => _mode = SessionMode.dual),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 风格选择（双向模式）
            if (_mode == SessionMode.dual) ...[
              const Text('AI 风格', style: AppTextStyles.bodyMedium),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: AppConstants.chatStyles.entries.map((entry) {
                  final isSelected = _chatStyle == _parseChatStyle(entry.key);
                  return ChoiceChip(
                    label: Text('${entry.key}（${entry.value}）'),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _chatStyle = selected ? _parseChatStyle(entry.key) : null;
                      });
                    },
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      fontSize: 13,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],

            // 方言选择
            const Text('方言选择', style: AppTextStyles.bodyMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AppConstants.dialects.map((dialect) {
                final isSelected = _dialect == dialect;
                return ChoiceChip(
                  label: Text(dialect),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _dialect = dialect),
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // 时间选择
            const Text('持续时间', style: AppTextStyles.bodyMedium),
            const SizedBox(height: 12),
            Row(
              children: AppConstants.sessionDurations.map((min) {
                final isSelected = _duration == min;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: GestureDetector(
                      onTap: () => setState(() => _duration = min),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.cardBackground,
                          borderRadius:
                              BorderRadius.circular(AppRadius.md),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.border,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '$min',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              '分钟',
                              style: TextStyle(
                                fontSize: 12,
                                color: isSelected
                                    ? Colors.white.withOpacity(0.8)
                                    : AppColors.textHint,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 40),

            // 开始按钮
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  final sessionProvider =
                      context.read<SessionProvider>();
                  sessionProvider.createSession(
                    targetId: target?.id ?? '',
                    targetName: targetName,
                    targetAvatarUrl: target?.avatarUrl,
                    mode: _mode,
                    chatStyle: _chatStyle,
                    dialect: _dialect,
                    durationMinutes: _duration,
                  );

                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ChatScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                ),
                child: const Text(
                  '开始释放',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  ChatStyle? _parseChatStyle(String label) {
    switch (label) {
      case '嘴硬型':
        return ChatStyle.stubborn;
      case '道歉型':
        return ChatStyle.apologetic;
      case '冷漠型':
        return ChatStyle.cold;
      case '阴阳型':
        return ChatStyle.sarcastic;
      case '理性型':
        return ChatStyle.rational;
      default:
        return null;
    }
  }
}

class _ModeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeCard({
    required this.icon,
    required this.title,
    required this.desc,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: 1.5,
          ),
          boxShadow: isSelected ? [AppColors.buttonShadow] : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? Colors.white : AppColors.primary,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              desc,
              style: TextStyle(
                fontSize: 12,
                color: isSelected
                    ? Colors.white.withOpacity(0.8)
                    : AppColors.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
