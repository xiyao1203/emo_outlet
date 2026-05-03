import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../models/message_model.dart';
import '../providers/app_providers.dart';
import '../services/api_service.dart';
import '../utils/helpers.dart';
import 'session_end_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  late Timer _timer;
  bool _isComposing = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final sessionProvider = context.read<SessionProvider>();
      if (sessionProvider.isRunning) {
        sessionProvider.tick();
        if (sessionProvider.remainingSeconds <= 0) {
          _navigateToEnd();
        }
      }
    });
  }

  void _navigateToEnd() {
    _timer.cancel();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const SessionEndScreen(),
          ),
        );
      }
    });
  }

  /// AI 使用确认（首次发送消息前弹窗）
  bool _aiConfirmed = false;

  Future<void> _confirmAiDisclaimer() async {
    if (_aiConfirmed) return;
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('AI 服务确认'),
        content: const Text(
          '本对话由 AI 生成，回复不构成任何心理或医疗建议。\n'
          '如果您有严重心理困扰，请拨打专业援助热线。\n\n'
          '全国24小时心理援助热线：010-82951332',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('我知道了'),
          ),
        ],
      ),
    );
    _aiConfirmed = result ?? false;
    if (!_aiConfirmed) return;
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    if (!_aiConfirmed) {
      _confirmAiDisclaimer().then((_) {
        if (_aiConfirmed && text.isNotEmpty) {
          _doSendMessage(text);
        }
      });
      return;
    }

    _doSendMessage(text);
  }

  void _doSendMessage(String text) {
    if (text.isEmpty) return;

    // 前端内容过滤
    final filterResult = ContentFilter.checkInput(text);
    if (filterResult != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(filterResult),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    final sessionProvider = context.read<SessionProvider>();
    sessionProvider.sendMessage(text);

    _messageController.clear();
    setState(() => _isComposing = false);
  }

  void _addTime() {
    context.read<SessionProvider>().addTime(1);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('已延长 1 分钟'),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sessionProvider = context.watch<SessionProvider>();
    final messages = sessionProvider.messages;
    final session = sessionProvider.currentSession;
    final targetName = session?.targetName ?? 'AI';

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(targetName),
            Text(
              '${session?.modeLabel} · ${session?.dialect ?? "普通话"}',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textHint,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        actions: [
          // 倒计时
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: sessionProvider.remainingSeconds < 30
                    ? AppColors.emotionAnger.withOpacity(0.1)
                    : AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                sessionProvider.formattedTime,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: sessionProvider.remainingSeconds < 30
                      ? AppColors.emotionAnger
                      : AppColors.primary,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // 消息列表
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                return _buildMessageBubble(msg);
              },
            ),
          ),

          // 底部操作栏
          if (sessionProvider.isRunning)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Row(
                children: [
                  // 延长
                  _ActionChip(
                    icon: Icons.timer_outlined,
                    label: '延长1分钟',
                    onTap: _addTime,
                  ),
                  const Spacer(),
                  // 结束
                  _ActionChip(
                    icon: Icons.stop_outlined,
                    label: '结束并查看',
                    color: AppColors.emotionAnger,
                    onTap: () {
                      sessionProvider.endSession();
                      _navigateToEnd();
                    },
                  ),
                ],
              ),
            ),

          // 输入区域
          Container(
            padding: EdgeInsets.only(
              left: 12,
              right: 8,
              bottom: MediaQuery.of(context).padding.bottom + 4,
              top: 8,
            ),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              border: Border(
                top: BorderSide(color: AppColors.divider.withOpacity(0.5)),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('语音输入即将上线'),
                        duration: Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.keyboard_voice_outlined,
                    color: AppColors.textHint,
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    maxLines: 4,
                    minLines: 1,
                    textInputAction: TextInputAction.send,
                    onChanged: (v) =>
                        setState(() => _isComposing = v.trim().isNotEmpty),
                    onSubmitted: (_) => _sendMessage(),
                    decoration: InputDecoration(
                      hintText: '说出你的情绪...',
                      filled: true,
                      fillColor: AppColors.background,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _isComposing ? _sendMessage : null,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _isComposing
                          ? AppColors.primary
                          : AppColors.divider,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showReportDialog(MessageModel msg) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('举报内容'),
        content: const Text('确认要举报这条消息吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                await ApiService().createReport(
                  sessionId: msg.sessionId,
                  messageId: msg.id,
                  reportType: 'inappropriate',
                  description: '用户举报该消息内容不当',
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('举报已提交，感谢你的反馈'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } catch (_) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('举报提交失败，请稍后重试'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text('确认举报'),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(MessageModel msg) {
    final isUser = msg.isUser;
    return GestureDetector(
      onLongPress: () => _showReportDialog(msg),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF7A56), Color(0xFFFF9A76)],
                ),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(Icons.smart_toy_outlined,
                    size: 18, color: Colors.white),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser
                    ? AppColors.primary
                    : AppColors.cardBackground,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(AppRadius.md),
                  topRight: const Radius.circular(AppRadius.md),
                  bottomLeft: Radius.circular(
                      isUser ? AppRadius.md : AppRadius.xs),
                  bottomRight: Radius.circular(
                      isUser ? AppRadius.xs : AppRadius.md),
                ),
                boxShadow: [AppColors.cardShadow],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    msg.content,
                    style: TextStyle(
                      fontSize: 15,
                      color: isUser
                          ? Colors.white
                          : AppColors.textPrimary,
                      height: 1.5,
                    ),
                  ),
                  if (msg.dialect != null && msg.dialect != '普通话')
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '（${msg.dialect}）',
                        style: TextStyle(
                          fontSize: 12,
                          color: isUser
                              ? Colors.white.withOpacity(0.7)
                              : AppColors.textHint,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.secondary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: c.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: c),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: c,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
