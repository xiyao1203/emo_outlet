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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('向 $targetName 释放情绪', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF333333))),
        centerTitle: true,
        backgroundColor: const Color(0xFFF8F8F8),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 目标信息
            Center(
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFFFF7A56), Color(0xFFFF9A76)]),
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 4))],
                    ),
                    child: Center(
                      child: Text(
                        targetName.length >= 2 ? targetName.substring(0, 2) : targetName[0],
                        style: const TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(targetName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF333333))),
                  if (target?.typeLabel != null) ...[const SizedBox(height: 4), Text(target!.typeLabel, style: const TextStyle(fontSize: 13, color: Color(0xFF999999)))],
                ],
              ),
            ),
            const SizedBox(height: 32),

            _buildSectionTitle('模式选择'),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _ModeCard(
                icon: Icons.volume_up_outlined, title: '单向模式', desc: 'AI 只承接，不反驳',
                isSelected: _mode == SessionMode.single,
                onTap: () => setState(() => _mode = SessionMode.single),
              )),
              const SizedBox(width: 12),
              Expanded(child: _ModeCard(
                icon: Icons.forum_outlined, title: '双向模式', desc: 'AI 可反驳',
                isSelected: _mode == SessionMode.dual,
                onTap: () => setState(() => _mode = SessionMode.dual),
              )),
            ]),
            const SizedBox(height: 24),

            if (_mode == SessionMode.dual) ...[
              _buildSectionTitle('AI 风格'),
              const SizedBox(height: 12),
              Wrap(spacing: 8, runSpacing: 8, children: AppConstants.chatStyles.entries.map((entry) {
                final isSelected = _chatStyle == _parseChatStyle(entry.key);
                return GestureDetector(
                  onTap: () => setState(() => _chatStyle = isSelected ? null : _parseChatStyle(entry.key)),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Text(entry.key, style: TextStyle(fontSize: 14, color: isSelected ? Colors.white : AppColors.textPrimary, fontWeight: FontWeight.w500)),
                      const SizedBox(width: 4),
                      Text(entry.value, style: TextStyle(fontSize: 11, color: isSelected ? Colors.white70 : AppColors.textHint)),
                    ]),
                  ),
                );
              }).toList()),
              const SizedBox(height: 24),
            ],

            _buildSectionTitle('方言选择'),
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8, children: AppConstants.dialects.map((dialect) {
              final isSelected = _dialect == dialect;
              return GestureDetector(
                onTap: () => setState(() => _dialect = dialect),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
                  ),
                  child: Text(dialect, style: TextStyle(fontSize: 14, color: isSelected ? Colors.white : AppColors.textPrimary, fontWeight: FontWeight.w500)),
                ),
              );
            }).toList()),
            const SizedBox(height: 24),

            _buildSectionTitle('持续时间'),
            const SizedBox(height: 12),
            Row(children: AppConstants.sessionDurations.map((min) {
              final isSelected = _duration == min;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: GestureDetector(
                    onTap: () => setState(() => _duration = min),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
                        boxShadow: isSelected ? [BoxShadow(color: AppColors.primary.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 2))] : null,
                      ),
                      child: Column(children: [
                        Text('$min', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : AppColors.textPrimary)),
                        Text('分钟', style: TextStyle(fontSize: 12, color: isSelected ? Colors.white.withOpacity(0.8) : AppColors.textHint)),
                      ]),
                    ),
                  ),
                ),
              );
            }).toList()),
            const SizedBox(height: 40),

            // 开始按钮
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  final sessionProvider = context.read<SessionProvider>();
                  sessionProvider.createSession(
                    targetId: target?.id ?? '', targetName: targetName,
                    targetAvatarUrl: target?.avatarUrl, mode: _mode,
                    chatStyle: _chatStyle, dialect: _dialect, durationMinutes: _duration,
                  );
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ChatScreen()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 4,
                  shadowColor: AppColors.primary.withOpacity(0.3),
                ),
                child: const Text('开始释放', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Row(children: [
      Container(width: 4, height: 18, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 8),
      Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF333333))),
    ]);
  }

  ChatStyle? _parseChatStyle(String label) {
    switch (label) {
      case '嘴硬型': return ChatStyle.stubborn;
      case '道歉型': return ChatStyle.apologetic;
      case '冷漠型': return ChatStyle.cold;
      case '阴阳型': return ChatStyle.sarcastic;
      case '理性型': return ChatStyle.rational;
      default: return null;
    }
  }
}

class _ModeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeCard({required this.icon, required this.title, required this.desc, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.border, width: 1.5),
          boxShadow: isSelected ? [BoxShadow(color: AppColors.primary.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 2))] : null,
        ),
        child: Column(children: [
          Icon(icon, size: 36, color: isSelected ? Colors.white : AppColors.primary),
          const SizedBox(height: 8),
          Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : AppColors.textPrimary)),
          const SizedBox(height: 4),
          Text(desc, style: TextStyle(fontSize: 12, color: isSelected ? Colors.white.withOpacity(0.8) : AppColors.textHint)),
        ]),
      ),
    );
  }
}
