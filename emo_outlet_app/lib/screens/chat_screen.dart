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
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final stt.SpeechToText _speech = stt.SpeechToText();
  Timer? _timer;
  bool _timeoutShown = false;
  bool _isListening = false;
  int _lastMessageCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<SessionProvider>();
      if (provider.messages.isEmpty) {
        _seedMessages(provider);
      }
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final provider = context.read<SessionProvider>();
      if (!provider.isRunning) return;
      provider.tick();
      if (provider.remainingSeconds <= 0 && !_timeoutShown) {
        _timeoutShown = true;
        _showTimeoutDialog();
      }
      if (mounted) {
        setState(() {});
      }
    });
  }

  void _seedMessages(SessionProvider provider) {
    final session = provider.currentSession;
    if (session == null) return;
    final id = session.id ?? 'session_local';
    final now = DateTime.now();
    if (session.mode == SessionMode.single) {
      provider.seedMessages([
        MessageModel(
          sessionId: id,
          content: '我真的受够了，明明我已经很努力了，还是一直被否定。',
          sender: MessageSender.user,
          createdAt: now.subtract(const Duration(minutes: 4)),
        ),
        MessageModel(
          sessionId: id,
          content: '我在听，你可以把最想说的那句话先说出来。',
          sender: MessageSender.ai,
          createdAt: now.subtract(const Duration(minutes: 4)),
        ),
        MessageModel(
          sessionId: id,
          content: '他们总把问题丢给我，出了事又像全是我的责任。',
          sender: MessageSender.user,
          createdAt: now.subtract(const Duration(minutes: 3)),
        ),
        MessageModel(
          sessionId: id,
          content: '这份委屈我接住了，你继续说，我陪你把它讲完整。',
          sender: MessageSender.ai,
          createdAt: now.subtract(const Duration(minutes: 3)),
        ),
      ]);
    } else {
      provider.seedMessages([
        MessageModel(
          sessionId: id,
          content: '最近你对我的不满，好像已经积了很久。',
          sender: MessageSender.ai,
          createdAt: now.subtract(const Duration(minutes: 4)),
        ),
        MessageModel(
          sessionId: id,
          content: '是，你总是临时改需求，根本不考虑我这边的节奏。',
          sender: MessageSender.user,
          createdAt: now.subtract(const Duration(minutes: 4)),
        ),
        MessageModel(
          sessionId: id,
          content: '我听见了，你生气不是没理由的，我们可以把最刺的点讲清楚。',
          sender: MessageSender.ai,
          createdAt: now.subtract(const Duration(minutes: 3)),
        ),
      ]);
    }
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
      if (mounted) {
        setState(() => _isListening = false);
      }
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
          _controller.selection = TextSelection.fromPosition(
            TextPosition(offset: _controller.text.length),
          );
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
              const Text('⏰', style: TextStyle(fontSize: 62)),
              const SizedBox(height: 16),
              const Text(
                '时间到了',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              const Text(
                '这次释放时间已经结束，要不要再给自己一分钟，把最后想说的话说完？',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF6D6662),
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              OutlineSoftButton(
                text: '延长 1 分钟',
                onTap: () {
                  context.read<SessionProvider>().addTime(1);
                  _timeoutShown = false;
                  Navigator.of(ctx).pop();
                },
              ),
              const SizedBox(height: 14),
              GradientPrimaryButton(
                text: '结束释放',
                height: 54,
                fontSize: 17,
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
              const EmoDecorationCloud(size: 120),
              const Text(
                '确认结束释放？',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 14),
              const Text(
                '结束后会停止本次对话，并进入情绪总结与海报生成。',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: Color(0xFF6D6662),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 22),
              EmoGradientOutlineButton(
                text: '继续释放',
                onTap: () => Navigator.of(ctx).pop(),
              ),
              const SizedBox(height: 14),
              GradientPrimaryButton(
                text: '结束并生成总结',
                height: 58,
                fontSize: 18,
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
          _scrollController.position.maxScrollExtent + 120,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
        );
      });
    }

    return EmoPageScaffold(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 10),
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
                  size: 60,
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
                                fontSize: 19,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          EmoTypePill(
                            text: dual ? '双向模式' : '单向模式',
                            color: const Color(0xFFFF7D5D),
                            background: const Color(0x14FF7D5D),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        dual ? '正在双向交流，慢慢说清楚你的感受' : '本次倾诉剩余时间',
                        style: const TextStyle(
                          fontSize: 13.5,
                          color: Color(0xFF86807B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                      ),
                      const SizedBox(width: 8),
                      Text(
                        provider.formattedTime,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFFF6E53),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: EmoSectionCard(
              padding: const EdgeInsets.fromLTRB(18, 16, 14, 16),
              child: Row(
                children: [
                  Icon(
                    dual ? Icons.forum_rounded : Icons.favorite_border_rounded,
                    color: dual
                        ? const Color(0xFF8D73FF)
                        : const Color(0xFFFF8D73),
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      dual
                          ? '双向模式进行中，Ta 会回应你，你也能听见自己的情绪被接住。'
                          : '单向倾诉中，AI 会先倾听和接纳，不会和你争辩。',
                      style: const TextStyle(
                        fontSize: 13.5,
                        height: 1.45,
                        color: Color(0xFF726964),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const EmoDecorationCloud(size: 82),
                ],
              ),
            ),
          ),
          if (provider.sendError != null) ...[
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                decoration: BoxDecoration(
                  color: const Color(0x14FF6B5D),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0x33FF6B5D)),
                ),
                child: Text(
                  provider.sendError!,
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: Color(0xFFCC5C54),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              itemCount: totalCount,
              itemBuilder: (context, index) {
                if (index >= messages.length) {
                  return _TypingBubble(targetType: target?.type ?? 'boss');
                }
                final msg = messages[index];
                return _MessageBubble(
                  message: msg,
                  targetType: target?.type ?? 'boss',
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              18,
              10,
              18,
              MediaQuery.of(context).padding.bottom + 10,
            ),
            child: EmoSectionCard(
              radius: 28,
              padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 4,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: _isListening ? '正在听你说话...' : '把想说的话说出来',
                        hintStyle: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFFBCB8B5),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: _toggleVoiceInput,
                    borderRadius: BorderRadius.circular(999),
                    child: Ink(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isListening
                            ? const Color(0x14FF6D5E)
                            : const Color(0x0FF2F2F2),
                        border: Border.all(
                          color: _isListening
                              ? const Color(0x44FF6D5E)
                              : Colors.transparent,
                        ),
                      ),
                      child: Icon(
                        _isListening
                            ? Icons.graphic_eq_rounded
                            : Icons.mic_none_rounded,
                        color: _isListening
                            ? const Color(0xFFFF6D5E)
                            : const Color(0xFF8F8F8F),
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: provider.isSending ? null : _send,
                    borderRadius: BorderRadius.circular(999),
                    child: Ink(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: provider.isSending
                            ? const LinearGradient(
                                colors: [Color(0xFFFFC0A6), Color(0xFFFF9CAA)],
                              )
                            : const LinearGradient(
                                colors: [Color(0xFFFF9863), Color(0xFFFF5A6A)],
                              ),
                      ),
                      child: const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
        crossAxisAlignment:
            user ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: user ? 0 : 56,
              right: user ? 12 : 0,
              bottom: 8,
            ),
            child: Text(
              '$hh:$mm',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFFA7A2A0),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Row(
            mainAxisAlignment:
                user ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!user) ...[
                EmoAvatar(
                  label: avatarEmojiByType(targetType),
                  background: avatarBgByType(targetType),
                  size: 42,
                ),
                const SizedBox(width: 10),
              ],
              Flexible(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                  decoration: BoxDecoration(
                    color: user ? null : Colors.white.withValues(alpha: 0.82),
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
                  ),
                  child: Text(
                    message.content,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.55,
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

class _TypingBubble extends StatelessWidget {
  const _TypingBubble({required this.targetType});

  final String targetType;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          EmoAvatar(
            label: avatarEmojiByType(targetType),
            background: avatarBgByType(targetType),
            size: 42,
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.82),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
                bottomRight: Radius.circular(24),
                bottomLeft: Radius.circular(8),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _Dot(),
                SizedBox(width: 6),
                _Dot(),
                SizedBox(width: 6),
                _Dot(),
                SizedBox(width: 10),
                Text(
                  '正在输入...',
                  style: TextStyle(
                    fontSize: 14,
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

class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 6,
      decoration: const BoxDecoration(
        color: Color(0xFFFF8C78),
        shape: BoxShape.circle,
      ),
    );
  }
}
