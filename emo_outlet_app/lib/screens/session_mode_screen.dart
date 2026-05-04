import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/constants.dart';
import '../models/session_model.dart';
import '../providers/app_providers.dart';
import '../widgets/auth/auth_visuals.dart';
import '../widgets/common/emo_ui.dart';
import 'chat_screen.dart';

class SessionModeScreen extends StatefulWidget {
  const SessionModeScreen({super.key});

  @override
  State<SessionModeScreen> createState() => _SessionModeScreenState();
}

class _SessionModeScreenState extends State<SessionModeScreen> {
  SessionMode _mode = SessionMode.single;
  String _language = '普通话';
  String _dialect = '四川话';
  int _duration = 5;
  bool _textInput = true;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TargetProvider>();
    final target = provider.currentTarget ??
        (provider.targets.isNotEmpty ? provider.targets.first : null);

    return EmoPageScaffold(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
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
                  '开始释放情绪',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                ),
                const Spacer(),
                const EmoDecorationCloud(size: 104),
              ],
            ),
            Transform.translate(
              offset: const Offset(0, -8),
              child: Column(
                children: [
                  _section(
                    '选择对象',
                    child: target == null
                        ? const SizedBox.shrink()
                        : _targetTile(target),
                  ),
                  const SizedBox(height: 14),
                  _section(
                    '释放模式',
                    child: Row(
                      children: [
                        Expanded(
                          child: _modeCard(
                            title: '单向模式',
                            subtitle: 'Ta只倾听，不会反驳',
                            icon: Icons.headphones_rounded,
                            active: _mode == SessionMode.single,
                            iconColor: const Color(0xFFFF9657),
                            onTap: () =>
                                setState(() => _mode = SessionMode.single),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _modeCard(
                            title: '双向模式',
                            subtitle: 'Ta会回应，也会适度反驳',
                            icon: Icons.forum_rounded,
                            active: _mode == SessionMode.dual,
                            iconColor: const Color(0xFF8C72FF),
                            onTap: () =>
                                setState(() => _mode = SessionMode.dual),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  _section(
                    '选择语言',
                    child: Column(
                      children: [
                        _simpleSelectRow(
                          icon: Icons.chat_bubble_outline_rounded,
                          iconColor: const Color(0xFFFF9B58),
                          title: '选择语言',
                          value: _language,
                        ),
                        const SizedBox(height: 12),
                        _simpleSelectRow(
                          icon: Icons.location_on_outlined,
                          iconColor: const Color(0xFF8E74FF),
                          title: '选择方言（可选）',
                          value: _dialect,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  _section(
                    '设置时长',
                    child: Row(
                      children: AppConstants.sessionDurations.map((value) {
                        final active = value == _duration;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _selectCapsule(
                              text: '$value分钟',
                              active: active,
                              onTap: () => setState(() => _duration = value),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _section(
                    '输入方式',
                    child: Row(
                      children: [
                        Expanded(
                          child: _selectCapsule(
                            text: '文字输入',
                            icon: Icons.edit_outlined,
                            active: _textInput,
                            onTap: () => setState(() => _textInput = true),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _selectCapsule(
                            text: '语音输入',
                            icon: Icons.mic_none_rounded,
                            active: !_textInput,
                            onTap: () => setState(() => _textInput = false),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  GradientPrimaryButton(
                    text: '开始释放',
                    height: 72,
                    fontSize: 20,
                    onTap: target == null
                        ? null
                        : () async {
                            context
                                .read<TargetProvider>()
                                .setCurrentTarget(target);
                            await context.read<SessionProvider>().createSession(
                                  targetId: target.id ?? 'local_target',
                                  targetName: target.name,
                                  targetAvatarUrl: target.avatarUrl,
                                  mode: _mode,
                                  dialect: _dialect,
                                  durationMinutes: _duration,
                                );
                            if (!mounted) return;
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) => const ChatScreen()),
                            );
                          },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(String title, {required Widget child}) {
    return EmoSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 5,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B57),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _targetTile(dynamic target) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.56),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          EmoAvatar(
            label: avatarEmojiByType(target.type),
            background: avatarBgByType(target.type),
            size: 72,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      target.name,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(width: 10),
                    EmoTypePill(
                      text: target.typeLabel,
                      color: typeColor(target.type),
                      background:
                          typeColor(target.type).withValues(alpha: 0.12),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  target.relationship ?? '总是临时加需求，周末还要开会…',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF706760),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded,
              color: Color(0xFF9E9E9E), size: 22),
        ],
      ),
    );
  }

  Widget _modeCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool active,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.52),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: active ? const Color(0xFFFF6F54) : const Color(0xFFF1E5DF),
            width: active ? 2 : 1.2,
          ),
        ),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Icon(
                active
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color:
                    active ? const Color(0xFFFF6F54) : const Color(0xFFD8D0CB),
                size: 22,
              ),
            ),
            Icon(icon, color: iconColor, size: 42),
            const SizedBox(height: 12),
            Text(title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF7B726C),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _simpleSelectRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
  }) {
    return Container(
      height: 66,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.56),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Text(title,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
          Text(value,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right_rounded,
              color: Color(0xFF9A9A9A), size: 22),
        ],
      ),
    );
  }

  Widget _selectCapsule({
    required String text,
    required bool active,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        height: 58,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.54),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: active ? const Color(0xFFFF6F54) : const Color(0xFFF2E5DE),
            width: active ? 2 : 1.2,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      color: active
                          ? const Color(0xFFFF6F54)
                          : const Color(0xFF8E8E8E),
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: active
                          ? const Color(0xFFFF6F54)
                          : const Color(0xFF666666),
                    ),
                  ),
                ],
              ),
            ),
            if (active)
              const Positioned(
                top: -1,
                right: -1,
                child: Icon(Icons.check_circle_rounded,
                    color: Color(0xFFFF6F54), size: 22),
              ),
          ],
        ),
      ),
    );
  }
}
