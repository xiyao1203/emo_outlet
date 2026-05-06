import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../models/message_model.dart';
import '../models/session_model.dart';
import '../providers/app_providers.dart';
import '../widgets/auth/auth_visuals.dart';
import '../widgets/common/emo_ui.dart';
import 'home_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final stt.SpeechToText _speech = stt.SpeechToText();

  Timer? _timer;
  bool _timeoutShown = false;
  bool _isListening = false;
  int _lastMessageCount = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final provider = context.read<SessionProvider>();
      if (!provider.isRunning) return;
      provider.tick();
      if (provider.remainingSeconds <= 0 && !_timeoutShown) {
        _timeoutShown = true;
        _showTimeoutDialog();
      }
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _speech.stop();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _toggleVoiceInput() async {
    if (_isListening) {
      await _speech.stop();
      if (mounted) setState(() => _isListening = false);
      return;
    }

    final available = await _speech.initialize(
      onStatus: (status) {
        if (!mounted) return;
        if (status == 'done' || status == 'notListening') {
          setState(() => _isListening = false);
        }
      },
      onError: (_) {
        if (!mounted) return;
        setState(() => _isListening = false);
      },
    );

    if (!available) {
      if (!mounted) return;
      _showTopMessage('当前设备暂不支持语音输入');
      return;
    }

    setState(() => _isListening = true);
    await _speech.listen(
      onResult: (result) {
        if (!mounted) return;
        setState(() {
          _controller.text = result.recognizedWords;
          _controller.selection =
              TextSelection.collapsed(offset: _controller.text.length);
          _isListening = !result.finalResult;
        });
      },
      listenOptions: stt.SpeechListenOptions(
        listenMode: stt.ListenMode.confirmation,
        partialResults: true,
      ),
    );
  }

  void _showTopMessage(String text) {
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 10,
        left: 18,
        right: 18,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xE6221D1B),
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x26000000),
                  blurRadius: 24,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
    overlay.insert(entry);
    Future<void>.delayed(const Duration(seconds: 2), entry.remove);
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    context.read<SessionProvider>().sendMessage(text);
    _controller.clear();
    setState(() {});
  }

  Future<void> _showTimeoutDialog() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: EmoSectionCard(
          radius: 34,
          padding: const EdgeInsets.fromLTRB(28, 24, 28, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('⏰', style: TextStyle(fontSize: 52)),
              const SizedBox(height: 16),
              const Text(
                '时间到了',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AuthPalette.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '这次释放时间已经结束。要不要再给自己 1 分钟，把最后想说的话说完？',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.5,
                  color: Color(0xFF6D6662),
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 22),
              OutlineSoftButton(
                text: '延长 1 分钟',
                onTap: () {
                  context.read<SessionProvider>().addTime(1);
                  _timeoutShown = false;
                  Navigator.of(ctx).pop();
                },
              ),
              const SizedBox(height: 12),
              GradientPrimaryButton(
                text: '结束释放',
                height: 54,
                fontSize: 16.5,
                onTap: () {
                  Navigator.of(ctx).pop();
                  _showEndConfirmDialog();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showEndConfirmDialog() async {
    final provider = context.read<SessionProvider>();
    await showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: EmoSectionCard(
          radius: 34,
          padding: const EdgeInsets.fromLTRB(28, 12, 28, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const EmoDecorationCloud(size: 108),
              const Text(
                '确认结束释放？',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AuthPalette.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '结束后会停止本次对话，并进入历史记录与情绪报告。',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.5,
                  height: 1.5,
                  color: Color(0xFF6D6662),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              EmoGradientOutlineButton(
                text: '继续释放',
                onTap: () => Navigator.of(ctx).pop(),
              ),
              const SizedBox(height: 12),
              GradientPrimaryButton(
                text: '结束并查看记录',
                height: 56,
                fontSize: 16.5,
                onTap: () {
                  provider.endSession();
                  provider.clearCurrentSession();
                  Navigator.of(ctx).pop();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (_) => const HomeScreen(initialIndex: 2),
                    ),
                    (route) => route.isFirst,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SessionProvider>();
    final session = provider.currentSession;
    final target = context.watch<TargetProvider>().currentTarget;
    final dual = session?.mode == SessionMode.dual;
    final messages = provider.messages;
    final totalCount = messages.length + (provider.isSending ? 1 : 0);

    if (totalCount != _lastMessageCount) {
      _lastMessageCount = totalCount;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_scrollController.hasClients) return;
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 140,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
        );
      });
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final horizontal = EmoResponsive.edgePadding(width);
        final canSend = !provider.isSending && _controller.text.trim().isNotEmpty;

        return EmoPageScaffold(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(horizontal, 16, horizontal, 10),
                child: EmoResponsiveContent(
                  width: width,
                  maxWidth: 760,
                  child: Row(
                    children: [
                      EmoRoundIconButton(
                        icon: Icons.chevron_left_rounded,
                        onTap: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 12),
                      EmoAvatar(
                        label: avatarEmojiByType(target?.type ?? 'boss'),
                        background: avatarBgByType(target?.type ?? 'boss'),
                        size: 52,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    session?.targetName ?? '未命名对象',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: AuthPalette.textPrimary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                EmoTypePill(
                                  text: dual ? '双向聊天' : '单向倾诉',
                                  color: const Color(0xFFFF7D5D),
                                  background: const Color(0x14FF7D5D),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              dual
                                  ? '让对话慢慢变清晰，也让感受被接住'
                                  : '先把情绪说出来，不着急解决问题',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF86807B),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      _TimerChip(timeText: provider.formattedTime),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontal),
                child: EmoResponsiveContent(
                  width: width,
                  maxWidth: 760,
                  child: EmoSectionCard(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                    child: Row(
                      children: [
                        Icon(
                          dual ? Icons.forum_rounded : Icons.favorite_border_rounded,
                          color: dual ? const Color(0xFF8D73FF) : const Color(0xFFFF8D73),
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            dual
                                ? '双向模式进行中，AI 会带着你选择的人格来回应你。'
                                : '单向模式进行中，AI 会先倾听并接住你的情绪。',
                            style: const TextStyle(
                              fontSize: 13,
                              height: 1.45,
                              color: Color(0xFF726964),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const EmoDecorationCloud(size: 72),
                      ],
                    ),
                  ),
                ),
              ),
              if (provider.sendError != null) ...[
                const SizedBox(height: 10),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontal),
                  child: EmoResponsiveContent(
                    width: width,
                    maxWidth: 760,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                      decoration: BoxDecoration(
                        color: const Color(0x14FF6B5D),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0x33FF6B5D)),
                      ),
                      child: Text(
                        provider.sendError!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFFCC5C54),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Expanded(
                child: messages.isEmpty && !provider.isSending
                    ? Padding(
                        padding: EdgeInsets.symmetric(horizontal: horizontal),
                        child: EmoResponsiveContent(
                          width: width,
                          maxWidth: 760,
                          child: const _ChatEmptyState(),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: EdgeInsets.symmetric(horizontal: horizontal),
                        itemCount: totalCount,
                        itemBuilder: (context, index) {
                          if (index >= messages.length) {
                            return _TypingBubble(
                              targetType: target?.type ?? 'boss',
                              dual: dual,
                            );
                          }
                          final msg = messages[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 2),
                            child: EmoResponsiveContent(
                              width: width,
                              maxWidth: 760,
                              child: _MessageBubble(
                                message: msg,
                                targetType: target?.type ?? 'boss',
                              ),
                            ),
                          );
                        },
                      ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  horizontal,
                  10,
                  horizontal,
                  MediaQuery.of(context).padding.bottom + 10,
                ),
                child: EmoResponsiveContent(
                  width: width,
                  maxWidth: 760,
                  child: EmoSectionCard(
                    radius: 24,
                    padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Container(
                            constraints: const BoxConstraints(minHeight: 52),
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.82),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: const Color(0xFFEDE5E0)),
                            ),
                            child: TextField(
                              controller: _controller,
                              minLines: 1,
                              maxLines: 4,
                              onChanged: (_) => setState(() {}),
                              onSubmitted: (_) {
                                if (canSend) _send();
                              },
                              textAlignVertical: TextAlignVertical.center,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: _isListening
                                    ? '正在听你说话...'
                                    : '把想说的话慢慢说出来',
                                hintStyle: const TextStyle(
                                  fontSize: 14.5,
                                  color: Color(0xFFBCB8B5),
                                  fontWeight: FontWeight.w500,
                                ),
                                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              style: const TextStyle(
                                fontSize: 15,
                                height: 1.4,
                                fontWeight: FontWeight.w500,
                                color: AuthPalette.textPrimary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        _ActionCircle(
                          active: _isListening,
                          icon: _isListening
                              ? Icons.graphic_eq_rounded
                              : Icons.mic_none_rounded,
                          onTap: _toggleVoiceInput,
                        ),
                        const SizedBox(width: 10),
                        _SendCircle(
                          sending: provider.isSending,
                          onTap: canSend ? _send : null,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TimerChip extends StatelessWidget {
  const _TimerChip({required this.timeText});

  final String timeText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.64),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0x30FF7D5D)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.access_time_rounded,
            color: Color(0xFFFF6E53),
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            timeText,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFFFF6E53),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatEmptyState extends StatelessWidget {
  const _ChatEmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: EmoSectionCard(
        padding: EdgeInsets.fromLTRB(22, 26, 22, 26),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            EmoDecorationCloud(size: 112),
            SizedBox(height: 12),
            Text(
              '从一句真实感受开始',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AuthPalette.textPrimary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '不用组织得很完整。想到什么，就先说什么。',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                height: 1.5,
                color: Color(0xFF7A706A),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.targetType,
  });

  final MessageModel message;
  final String targetType;

  @override
  Widget build(BuildContext context) {
    final user = message.isUser;
    final time = message.createdAt ?? DateTime.now();
    final hh = time.hour.toString().padLeft(2, '0');
    final mm = time.minute.toString().padLeft(2, '0');

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: user ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: user ? 0 : 54,
              right: user ? 8 : 0,
              bottom: 8,
            ),
            child: Text(
              '$hh:$mm',
              style: const TextStyle(
                fontSize: 12.5,
                color: Color(0xFFA7A2A0),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: user ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!user) ...[
                EmoAvatar(
                  label: avatarEmojiByType(targetType),
                  background: avatarBgByType(targetType),
                  size: 40,
                ),
                const SizedBox(width: 10),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                  decoration: BoxDecoration(
                    color: user ? null : Colors.white.withValues(alpha: 0.86),
                    gradient: user
                        ? const LinearGradient(
                            colors: [Color(0xFFFFA15B), Color(0xFFFF5D63)],
                          )
                        : null,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(24),
                      topRight: const Radius.circular(24),
                      bottomLeft: Radius.circular(user ? 24 : 8),
                      bottomRight: Radius.circular(user ? 8 : 24),
                    ),
                    boxShadow: user
                        ? const [
                            BoxShadow(
                              color: Color(0x18FF8B73),
                              blurRadius: 18,
                              offset: Offset(0, 8),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    message.content,
                    style: TextStyle(
                      fontSize: 14.5,
                      height: 1.58,
                      color: user ? Colors.white : const Color(0xFF4F4845),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TypingBubble extends StatefulWidget {
  const _TypingBubble({
    required this.targetType,
    required this.dual,
  });

  final String targetType;
  final bool dual;

  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          EmoAvatar(
            label: avatarEmojiByType(widget.targetType),
            background: avatarBgByType(widget.targetType),
            size: 40,
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.86),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
                bottomRight: Radius.circular(24),
                bottomLeft: Radius.circular(8),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) => Row(
                    children: List.generate(3, (index) {
                      final t = ((_controller.value + index * 0.18) % 1.0);
                      final opacity = 0.35 + (1 - (t - 0.5).abs() * 2) * 0.65;
                      return Container(
                        margin: EdgeInsets.only(right: index == 2 ? 0 : 6),
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF8C78).withValues(alpha: opacity),
                          shape: BoxShape.circle,
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  widget.dual ? '模型思考中...' : '正在输入...',
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: Color(0xFF8A817C),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCircle extends StatelessWidget {
  const _ActionCircle({
    required this.active,
    required this.icon,
    required this.onTap,
  });

  final bool active;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Ink(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: active ? const Color(0x14FF6D5E) : const Color(0xFFF4F2F0),
          border: Border.all(
            color: active ? const Color(0x44FF6D5E) : const Color(0xFFEAE3DE),
          ),
        ),
        child: Icon(
          icon,
          color: active ? const Color(0xFFFF6D5E) : const Color(0xFF8F8F8F),
          size: 22,
        ),
      ),
    );
  }
}

class _SendCircle extends StatelessWidget {
  const _SendCircle({
    required this.sending,
    required this.onTap,
  });

  final bool sending;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null || sending;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 160),
        opacity: enabled ? 1 : 0.58,
        child: Ink(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: sending
                ? const LinearGradient(
                    colors: [Color(0xFFFFC0A6), Color(0xFFFF9CAA)],
                  )
                : const LinearGradient(
                    colors: [Color(0xFFFF9863), Color(0xFFFF5A6A)],
                  ),
            boxShadow: enabled
                ? const [
                    BoxShadow(
                      color: Color(0x24FF8D75),
                      blurRadius: 14,
                      offset: Offset(0, 8),
                    ),
                  ]
                : const [],
          ),
          child: sending
              ? const Padding(
                  padding: EdgeInsets.all(13),
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 22,
                ),
        ),
      ),
    );
  }
}
