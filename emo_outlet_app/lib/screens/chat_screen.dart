import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../config/constants.dart';
import '../models/message_model.dart';
import '../models/session_model.dart';
import '../providers/app_providers.dart';
import '../services/api_service.dart';
import '../widgets/auth/auth_visuals.dart';
import '../widgets/common/emo_ui.dart';
import 'home_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, this.preferVoiceInput = false});

  final bool preferVoiceInput;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ApiService _api = ApiService();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final stt.SpeechToText _speech = stt.SpeechToText();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final FlutterTts _flutterTts = FlutterTts();

  Timer? _timer;
  bool _timeoutShown = false;
  bool _isListening = false;
  bool _voiceAutoplay = true;
  int _lastMessageCount = 0;
  String? _spokenSignature;
  String? _speakingSignature;
  String _voice = 'alloy';

  @override
  void initState() {
    super.initState();
    _bindAudioHandlers();
    _loadVoicePreferences();
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
    if (widget.preferVoiceInput) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _toggleVoiceInput();
        }
      });
    }
  }

  void _bindAudioHandlers() {
    _audioPlayer.onPlayerComplete.listen((_) {
      if (!mounted) return;
      setState(() => _speakingSignature = null);
    });
    _flutterTts.setCompletionHandler(() {
      if (!mounted) return;
      setState(() => _speakingSignature = null);
    });
  }

  Future<void> _loadVoicePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _voiceAutoplay = prefs.getBool(AppConstants.voiceAutoplayKey) ?? true;
      _voice = prefs.getString(AppConstants.voiceOptionKey) ?? 'alloy';
      if (!AppConstants.ttsVoiceLabels.containsKey(_voice)) {
        _voice = 'alloy';
      }
    });
  }

  Future<void> _saveVoicePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.voiceAutoplayKey, _voiceAutoplay);
    await prefs.setString(AppConstants.voiceOptionKey, _voice);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _speech.stop();
    _audioPlayer.dispose();
    _flutterTts.stop();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _messageSignature(MessageModel message) {
    return '${message.id ?? ''}|${message.createdAt?.toIso8601String() ?? ''}|${message.content}';
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

  String _speechLocale(String dialectCode) {
    switch (dialectCode) {
      case 'cantonese':
        return 'zh-HK';
      default:
        return 'zh-CN';
    }
  }

  double _speechRate() {
    switch (_voice) {
      case 'nova':
        return 0.42;
      case 'sage':
        return 0.38;
      case 'shimmer':
        return 0.48;
      case 'echo':
        return 0.34;
      default:
        return 0.4;
    }
  }

  double _speechPitch() {
    switch (_voice) {
      case 'nova':
        return 1.08;
      case 'sage':
        return 0.96;
      case 'shimmer':
        return 1.12;
      case 'echo':
        return 0.90;
      default:
        return 1.0;
    }
  }

  Future<void> _speakLocally(String text, String dialectCode) async {
    await _audioPlayer.stop();
    await _flutterTts.stop();
    await _flutterTts.awaitSpeakCompletion(true);
    await _flutterTts.setLanguage(_speechLocale(dialectCode));
    await _flutterTts.setSpeechRate(_speechRate());
    await _flutterTts.setPitch(_speechPitch());
    await _flutterTts.speak(text);
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
      _showTopMessage('当前设备暂不支持语音输入');
      return;
    }

    setState(() => _isListening = true);
    await _speech.listen(
      localeId: 'zh_CN',
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

  Future<void> _stopSpeaking() async {
    await _audioPlayer.stop();
    await _flutterTts.stop();
    if (!mounted) return;
    setState(() => _speakingSignature = null);
  }

  Future<void> _send() async {
    final provider = context.read<SessionProvider>();
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    await _stopSpeaking();
    await _speech.stop();
    if (mounted) {
      setState(() => _isListening = false);
    }
    _controller.clear();
    setState(() {});
    await provider.sendMessage(text);
  }

  Future<void> _toggleVoiceAutoplay() async {
    setState(() => _voiceAutoplay = !_voiceAutoplay);
    await _saveVoicePreferences();
    _showTopMessage(_voiceAutoplay ? '已开启自动播报' : '已关闭自动播报');
  }

  Future<void> _pickVoice() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => SafeArea(
        top: false,
        child: EmoSectionCard(
          radius: 28,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFE7D8D0),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                '选择播报音色',
                style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              for (final entry in AppConstants.ttsVoiceLabels.entries)
                InkWell(
                  onTap: () => Navigator.of(context).pop(entry.key),
                  borderRadius: BorderRadius.circular(18),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            entry.value,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (_voice == entry.key)
                          const Icon(
                            Icons.check_circle_rounded,
                            color: Color(0xFFFF6F54),
                            size: 20,
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
    if (selected == null) return;
    setState(() => _voice = selected);
    await _saveVoicePreferences();
    _showTopMessage('已切换到 ${AppConstants.ttsVoiceLabels[selected]} 音色');
  }

  Future<void> _playMessage(MessageModel message) async {
    final session = context.read<SessionProvider>().currentSession;
    final signature = _messageSignature(message);
    final dialectCode =
        AppConstants.dialectMap[session?.dialect ?? '普通话'] ?? 'mandarin';
    setState(() => _speakingSignature = signature);

    try {
      final payload = await _api.synthesizeSpeech(
        text: message.content,
        dialect: dialectCode,
        voice: _voice,
      );
      final audioBase64 = payload['audio_base64'] as String? ?? '';
      if (audioBase64.isEmpty) {
        throw Exception('empty-audio');
      }
      final bytes = Uint8List.fromList(base64Decode(audioBase64));
      await _audioPlayer.stop();
      await _flutterTts.stop();
      await _audioPlayer.play(BytesSource(bytes));
    } catch (_) {
      try {
        await _speakLocally(message.content, dialectCode);
      } catch (_) {
        if (!mounted) return;
        setState(() => _speakingSignature = null);
        _showTopMessage('语音播报暂时不可用，请稍后再试');
      }
    }
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
                onTap: () async {
                  await provider.endSession();
                  provider.clearCurrentSession();
                  if (!mounted || !ctx.mounted) return;
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

  void _handleNewAiMessage(List<MessageModel> messages, bool isSending) {
    if (messages.isEmpty || isSending) return;
    final last = messages.last;
    if (!last.isAi) return;
    final signature = _messageSignature(last);
    if (_spokenSignature == signature) return;
    _spokenSignature = signature;
    if (_voiceAutoplay) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _playMessage(last);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SessionProvider>();
    final session = provider.currentSession;
    final target = context.watch<TargetProvider>().currentTarget;
    final messages = provider.messages;
    final dual = session?.mode == SessionMode.dual;
    final totalCount = messages.length + (provider.isSending ? 1 : 0);
    final dialect = session?.dialect ?? '普通话';

    _handleNewAiMessage(messages, provider.isSending);

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
                  child: _ChatHeader(
                    session: session,
                    targetType: target?.type ?? 'boss',
                    targetAvatarUrl: target?.avatarUrl,
                    timeText: provider.formattedTime,
                    onBack: () => Navigator.of(context).maybePop(),
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
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _VoiceTogglePill(
                          icon: _voiceAutoplay
                              ? Icons.volume_up_rounded
                              : Icons.volume_off_rounded,
                          label: _voiceAutoplay ? '自动播报已开启' : '自动播报已关闭',
                          active: _voiceAutoplay,
                          onTap: _toggleVoiceAutoplay,
                        ),
                        _VoiceTogglePill(
                          icon: Icons.record_voice_over_rounded,
                          label:
                              '当前音色：${AppConstants.ttsVoiceLabels[_voice] ?? '晴暖'}',
                          active: true,
                          onTap: _pickVoice,
                        ),
                        _VoiceTogglePill(
                          icon: dual
                              ? Icons.forum_rounded
                              : Icons.favorite_border_rounded,
                          label: dual ? '双向聊天进行中' : '单向倾诉进行中',
                          active: false,
                          onTap: null,
                        ),
                        _VoiceTogglePill(
                          icon: Icons.language_rounded,
                          label: '当前方言：$dialect',
                          active: false,
                          onTap: null,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (provider.sendError != null)
                Padding(
                  padding: EdgeInsets.fromLTRB(horizontal, 10, horizontal, 0),
                  child: EmoResponsiveContent(
                    width: width,
                    maxWidth: 760,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0x14FF6B5F),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0x33FF6B5F)),
                      ),
                      child: Text(
                        provider.sendError!,
                        style: const TextStyle(
                          fontSize: 13.5,
                          color: Color(0xFFBD5548),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              Expanded(
                child: messages.isEmpty && !provider.isSending
                    ? Center(
                        child: EmoResponsiveContent(
                          width: width,
                          maxWidth: 760,
                          child: const _ChatEmptyState(),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: EdgeInsets.fromLTRB(
                          horizontal,
                          18,
                          horizontal,
                          18,
                        ),
                        itemCount: totalCount,
                        itemBuilder: (context, index) {
                          if (index >= messages.length) {
                            return _TypingBubble(dual: dual);
                          }
                          final msg = messages[index];
                          return EmoResponsiveContent(
                            width: width,
                            maxWidth: 760,
                            child: _MessageBubble(
                              message: msg,
                              targetType: target?.type ?? 'boss',
                              targetAvatarUrl: target?.avatarUrl,
                              isSpeaking:
                                  _speakingSignature == _messageSignature(msg),
                              onSpeak: msg.isAi
                                  ? () => _speakingSignature ==
                                          _messageSignature(msg)
                                      ? _stopSpeaking()
                                      : _playMessage(msg)
                                  : null,
                            ),
                          );
                        },
                      ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  horizontal,
                  8,
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
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
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

class _ChatHeader extends StatelessWidget {
  const _ChatHeader({
    required this.session,
    required this.targetType,
    required this.targetAvatarUrl,
    required this.timeText,
    required this.onBack,
  });

  final SessionModel? session;
  final String targetType;
  final String? targetAvatarUrl;
  final String timeText;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final dual = session?.mode == SessionMode.dual;
    return Row(
      children: [
        EmoRoundIconButton(
          icon: Icons.chevron_left_rounded,
          onTap: onBack,
        ),
        const SizedBox(width: 12),
        EmoAvatar(
          label: avatarEmojiByType(targetType),
          background: avatarBgByType(targetType),
          imageUrl: targetAvatarUrl,
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
                  const SizedBox(width: 8),
                  EmoTypePill(
                    text: dual ? '双向聊天' : '单向倾诉',
                    color: const Color(0xFFFF7D5D),
                    background: const Color(0x14FF7D5D),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '剩余时间 $timeText',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF86807B),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _VoiceTogglePill extends StatelessWidget {
  const _VoiceTogglePill({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: active
              ? const Color(0x14FF7A60)
              : Colors.white.withValues(alpha: 0.58),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: active ? const Color(0x33FF7A60) : const Color(0x1FE5D9D4),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: active ? const Color(0xFFFF6E53) : const Color(0xFF8B837D),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color:
                    active ? const Color(0xFFFF6E53) : const Color(0xFF6F6660),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatEmptyState extends StatelessWidget {
  const _ChatEmptyState();

  @override
  Widget build(BuildContext context) {
    return const EmoSectionCard(
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
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.targetType,
    required this.targetAvatarUrl,
    required this.isSpeaking,
    required this.onSpeak,
  });

  final MessageModel message;
  final String targetType;
  final String? targetAvatarUrl;
  final bool isSpeaking;
  final VoidCallback? onSpeak;

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
            mainAxisAlignment:
                user ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!user) ...[
                EmoAvatar(
                  label: avatarEmojiByType(targetType),
                  background: avatarBgByType(targetType),
                  imageUrl: targetAvatarUrl,
                  size: 40,
                ),
                const SizedBox(width: 10),
              ],
              Flexible(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 13,
                      ),
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
                    if (!user && onSpeak != null)
                      Positioned(
                        right: -4,
                        bottom: -8,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: onSpeak,
                            borderRadius: BorderRadius.circular(999),
                            child: Ink(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x14000000),
                                    blurRadius: 10,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                                border: Border.all(
                                  color: isSpeaking
                                      ? const Color(0x33FF7A60)
                                      : const Color(0x1FE5D9D4),
                                ),
                              ),
                              child: Icon(
                                isSpeaking
                                    ? Icons.stop_rounded
                                    : Icons.volume_up_rounded,
                                size: 16,
                                color: isSpeaking
                                    ? const Color(0xFFFF6E53)
                                    : const Color(0xFF8B837D),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
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
  const _TypingBubble({required this.dual});

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
          const EmoDecorationCloud(size: 40),
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
                          color: const Color(0xFFFF8C78)
                              .withValues(alpha: opacity),
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
