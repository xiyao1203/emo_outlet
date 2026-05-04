import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
  Timer? _timer;
  bool _timeoutShown = false;

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
      if (mounted) setState(() {});
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
          content: '我真的受够了！每次我加班到很晚，结果还被说效率低，凭什么啊！',
          sender: MessageSender.user,
          createdAt: now.subtract(const Duration(minutes: 4)),
        ),
        MessageModel(
          sessionId: id,
          content: '我在听，你可以继续说。',
          sender: MessageSender.ai,
          createdAt: now.subtract(const Duration(minutes: 4)),
        ),
        MessageModel(
          sessionId: id,
          content: '明明是工作太多了，根本不是我的能力问题，凭什么都怪我！',
          sender: MessageSender.user,
          createdAt: now.subtract(const Duration(minutes: 3)),
        ),
        MessageModel(
          sessionId: id,
          content: '这件事确实让你很委屈。',
          sender: MessageSender.ai,
          createdAt: now.subtract(const Duration(minutes: 3)),
        ),
        MessageModel(
          sessionId: id,
          content: '而且其他人也没做多少，领导却只盯着我，太不公平了！',
          sender: MessageSender.user,
          createdAt: now.subtract(const Duration(minutes: 2)),
        ),
        MessageModel(
          sessionId: id,
          content: '我理解你的感受，你可以继续说。',
          sender: MessageSender.ai,
          createdAt: now.subtract(const Duration(minutes: 2)),
        ),
      ]);
    } else {
      provider.seedMessages([
        MessageModel(
          sessionId: id,
          content: '我注意到最近你情绪比较大，是不是工作压力太大了？',
          sender: MessageSender.ai,
          createdAt: now.subtract(const Duration(minutes: 4)),
        ),
        MessageModel(
          sessionId: id,
          content: '是啊，你总是临时加需求，完全不考虑我们现在的进度。',
          sender: MessageSender.user,
          createdAt: now.subtract(const Duration(minutes: 4)),
        ),
        MessageModel(
          sessionId: id,
          content: '我只是希望你把事情做好。客户的期望很高，我也有压力。',
          sender: MessageSender.ai,
          createdAt: now.subtract(const Duration(minutes: 3)),
        ),
        MessageModel(
          sessionId: id,
          content: '我理解你有压力，但频繁改需求真的让我们很被动。',
          sender: MessageSender.user,
          createdAt: now.subtract(const Duration(minutes: 3)),
        ),
        MessageModel(
          sessionId: id,
          content: '你说得有道理，频繁调整确实会影响效率。我可能在沟通上考虑得不够。',
          sender: MessageSender.ai,
          createdAt: now.subtract(const Duration(minutes: 2)),
        ),
      ]);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
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
              const Text('⏰', style: TextStyle(fontSize: 70)),
              const SizedBox(height: 16),
              const Text(
                '时间到了',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              const Text(
                '本次释放时间已结束，要不要再说一句？',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 18,
                    color: Color(0xFF6D6662),
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 24),
              OutlineSoftButton(
                text: '延长1分钟',
                onTap: () {
                  context.read<SessionProvider>().addTime(1);
                  _timeoutShown = false;
                  Navigator.of(ctx).pop();
                },
              ),
              const SizedBox(height: 14),
              GradientPrimaryButton(
                text: '结束释放',
                height: 58,
                fontSize: 20,
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
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 14),
              const Text(
                '结束后将停止本次对话，\n并进入情绪总结与海报生成。',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 18,
                    height: 1.5,
                    color: Color(0xFF6D6662),
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 22),
              EmoGradientOutlineButton(
                text: '继续释放',
                onTap: () => Navigator.of(ctx).pop(),
              ),
              const SizedBox(height: 14),
              GradientPrimaryButton(
                text: '结束并生成总结',
                height: 62,
                fontSize: 22,
                onTap: () {
                  provider.endSession();
                  provider.clearCurrentSession();
                  Navigator.of(ctx).pop();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (_) => const HomeScreen(initialIndex: 2)),
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

    return EmoPageScaffold(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
            child: Row(
              children: [
                EmoRoundIconButton(
                  icon: Icons.chevron_left_rounded,
                  onTap: () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: 18),
                EmoAvatar(
                  label: avatarEmojiByType(target?.type ?? 'boss'),
                  background: avatarBgByType(target?.type ?? 'boss'),
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
                            session?.targetName ?? '王总',
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.w800),
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
                        dual ? '正在双向交流，彼此理解中…' : '本次倾诉剩余时间',
                        style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF86807B),
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.64),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0x30FF7D5D)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time_rounded,
                          color: Color(0xFFFF6E53)),
                      const SizedBox(width: 8),
                      Text(
                        provider.formattedTime,
                        style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFFF6E53)),
                      ),
                    ],
                  ),
                ),
                if (dual) ...[
                  const SizedBox(width: 12),
                  TextButton.icon(
                    onPressed: _showEndConfirmDialog,
                    icon: const Icon(Icons.power_settings_new_rounded,
                        color: Color(0xFFFF6E53)),
                    label: const Text(
                      '结束',
                      style: TextStyle(
                          fontSize: 18,
                          color: Color(0xFFFF6E53),
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: EmoSectionCard(
              child: Row(
                children: [
                  Icon(
                    dual ? Icons.forum_rounded : Icons.volume_up_rounded,
                    color: dual
                        ? const Color(0xFF8D73FF)
                        : const Color(0xFFFF8D73),
                    size: 30,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      dual
                          ? '双向模式进行中，Ta会回应，你也会被理解'
                          : '单向倾诉中，TA不会反驳，只会倾听和理解你 ❤️',
                      style: const TextStyle(
                          fontSize: 18,
                          color: Color(0xFF726964),
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  const EmoDecorationCloud(size: 120),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 0),
              itemCount: messages.length,
              itemBuilder: (context, index) {
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
              padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: '把想说的话说出来…',
                        hintStyle: TextStyle(
                          fontSize: 18,
                          color: Color(0xFFBCB8B5),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                  ),
                  Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0x0FF2F2F2),
                    ),
                    child: const Icon(Icons.mic_none_rounded,
                        color: Color(0xFF8F8F8F), size: 28),
                  ),
                  const SizedBox(width: 12),
                  InkWell(
                    onTap: _send,
                    borderRadius: BorderRadius.circular(999),
                    child: Ink(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Color(0xFFFF9863), Color(0xFFFF5A6A)],
                        ),
                      ),
                      child: const Icon(Icons.send_rounded,
                          color: Colors.white, size: 30),
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
                left: user ? 0 : 78, right: user ? 16 : 0, bottom: 8),
            child: Text(
              '$hh:$mm',
              style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFFA7A2A0),
                  fontWeight: FontWeight.w500),
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
                  size: 56,
                ),
                const SizedBox(width: 10),
              ],
              Flexible(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                  decoration: BoxDecoration(
                    color: user ? null : Colors.white.withValues(alpha: 0.82),
                    gradient: user
                        ? const LinearGradient(
                            colors: [Color(0xFFFFA15B), Color(0xFFFF5D63)],
                          )
                        : null,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(26),
                      topRight: const Radius.circular(26),
                      bottomLeft: Radius.circular(user ? 26 : 8),
                      bottomRight: Radius.circular(user ? 8 : 26),
                    ),
                  ),
                  child: Text(
                    message.content,
                    style: TextStyle(
                      fontSize: 19,
                      height: 1.45,
                      color: user ? Colors.white : const Color(0xFF4F4845),
                      fontWeight: FontWeight.w600,
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
