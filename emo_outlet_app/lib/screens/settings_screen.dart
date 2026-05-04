import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../widgets/common/soft_ui.dart';
import 'login_screen.dart';
import 'privacy_policy_screen.dart';
import 'terms_of_service_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SoftPage(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
        child: Column(
          children: [
            SoftHeader(
              title: '设置中心',
              onBack: () => Navigator.of(context).pop(),
            ),
            const SizedBox(height: 24),
            SoftCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _SettingsEntry(
                    icon: Icons.verified_user_rounded,
                    colors: const [Color(0xFFFFDFC8), Color(0xFFFF9B63)],
                    title: '账号与安全',
                    onTap: () => _push(context, const AccountSecurityScreen()),
                  ),
                  _SettingsEntry(
                    icon: Icons.privacy_tip_rounded,
                    colors: const [Color(0xFFE5DAFF), Color(0xFFAA8CFF)],
                    title: '隐私设置',
                    onTap: () => _push(context, const PrivacySettingsScreen()),
                  ),
                  _SettingsEntry(
                    icon: Icons.notifications_active_rounded,
                    colors: const [Color(0xFFDDF3FF), Color(0xFF6CB8FF)],
                    title: '通知设置',
                    onTap: () =>
                        _push(context, const NotificationSettingsScreen()),
                  ),
                  _SettingsEntry(
                    icon: Icons.record_voice_over_rounded,
                    colors: const [Color(0xFFFFECD2), Color(0xFFFFBC65)],
                    title: '方言设置',
                    onTap: () => _push(context, const DialectSettingsScreen()),
                  ),
                  _SettingsEntry(
                    icon: Icons.help_center_rounded,
                    colors: const [Color(0xFFFFE1D9), Color(0xFFFF8767)],
                    title: '帮助与反馈',
                    onTap: () => _push(context, const HelpFeedbackScreen()),
                  ),
                  _SettingsEntry(
                    icon: Icons.info_rounded,
                    colors: const [Color(0xFFDDF0FF), Color(0xFF71AFFF)],
                    title: '关于我们',
                    showDivider: false,
                    onTap: () => _push(context, const AboutUsScreen()),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: SoftGradientButton(
                text: '退出登录',
                height: 60,
                onTap: () => _showLogoutDialog(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _push(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 28),
          child: SoftCard(
            radius: 30,
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.logout_rounded,
                  size: 72,
                  color: SoftColors.coral,
                ),
                const SizedBox(height: 14),
                const Text(
                  '确认退出登录？',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: SoftColors.text,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  '退出后会回到登录页，已保存的数据会保留在账号中。',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: SoftColors.subtext,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: SoftOutlineButton(
                        text: '取消',
                        onTap: () => Navigator.of(dialogContext).pop(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SoftGradientButton(
                        text: '退出登录',
                        onTap: () async {
                          await AuthService().logout();
                          if (!context.mounted) return;
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                            (route) => false,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class AccountSecurityScreen extends StatefulWidget {
  const AccountSecurityScreen({super.key});

  @override
  State<AccountSecurityScreen> createState() => _AccountSecurityScreenState();
}

class _AccountSecurityScreenState extends State<AccountSecurityScreen> {
  final ApiService _api = ApiService();

  bool _confirmed = false;
  bool _loading = true;
  Map<String, dynamic>? _profile;
  Map<String, dynamic>? _preferences;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final profile = await _api.getProfileDetail();
      final preferences = await _api.getPreferences();
      if (!mounted) return;
      setState(() {
        _profile = profile;
        _preferences = preferences;
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  bool _hasValue(String key) {
    final text = _profile?[key]?.toString().trim();
    return text != null && text.isNotEmpty;
  }

  String _value(String key) {
    final text = _profile?[key]?.toString().trim();
    return (text == null || text.isEmpty) ? '未设置' : text;
  }

  String get _securityLevel {
    var score = 0;
    if (_hasValue('phone')) score++;
    if (_hasValue('email')) score++;
    if (_preferences?['wechat_bound'] == true) score++;
    if (score >= 3) return '高';
    if (score >= 2) return '中';
    return '低';
  }

  String get _securityHint {
    switch (_securityLevel) {
      case '高':
        return '手机号、邮箱和微信绑定都已完善。';
      case '中':
        return '再补充一个绑定方式会更稳妥。';
      default:
        return '建议至少绑定两种找回方式。';
    }
  }

  Future<void> _openPhoneEditor() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _AccountFieldScreen(
          title: '手机号',
          hintText: '请输入 11 位手机号',
          initialValue: _profile?['phone']?.toString() ?? '',
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (!RegExp(r'^1\d{10}$').hasMatch(value)) {
              return '请输入正确的手机号';
            }
            return null;
          },
          onSave: (value) => _api.updateProfileDetail({'phone': value}),
        ),
      ),
    );
    await _load();
  }

  Future<void> _openEmailEditor() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _AccountFieldScreen(
          title: '邮箱',
          hintText: '请输入常用邮箱',
          initialValue: _profile?['email']?.toString() ?? '',
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value)) {
              return '请输入正确的邮箱';
            }
            return null;
          },
          onSave: (value) => _api.updateProfileDetail({'email': value}),
        ),
      ),
    );
    await _load();
  }

  Future<void> _openWechatBinding() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _WechatBindingScreen(
          isBound: (_preferences?['wechat_bound'] as bool?) ?? false,
        ),
      ),
    );
    await _load();
  }

  Future<void> _showDeleteDialog() async {
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.24),
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 28),
          child: SoftCard(
            radius: 30,
            padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.sentiment_dissatisfied_rounded,
                  size: 78,
                  color: Color(0xFFFF8A7A),
                ),
                const SizedBox(height: 12),
                const Text(
                  '确认注销账号？',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: SoftColors.text,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  '注销后将删除账号信息、历史记录与海报，且无法恢复。',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.7,
                    color: SoftColors.subtext,
                  ),
                ),
                const SizedBox(height: 18),
                InkWell(
                  onTap: () => setState(() => _confirmed = !_confirmed),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: _confirmed
                                ? SoftColors.coral
                                : const Color(0xFFFFC8BC),
                          ),
                          color: _confirmed
                              ? SoftColors.coral.withValues(alpha: 0.12)
                              : Colors.transparent,
                        ),
                        child: _confirmed
                            ? const Icon(
                                Icons.check_rounded,
                                size: 16,
                                color: SoftColors.coral,
                              )
                            : null,
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        '我已了解注销后果',
                        style: TextStyle(
                          fontSize: 16,
                          color: SoftColors.subtext,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: SoftOutlineButton(
                        text: '取消',
                        onTap: () => Navigator.of(dialogContext).pop(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SoftGradientButton(
                        text: '确认注销',
                        onTap: _confirmed
                            ? () async {
                                await AuthService().deleteAccount();
                                if (!context.mounted) return;
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (_) => const LoginScreen(),
                                  ),
                                  (route) => false,
                                );
                              }
                            : null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SoftPage(
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
              child: Column(
                children: [
                  SoftHeader(
                    title: '账号与安全',
                    onBack: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(height: 24),
                  SoftCard(
                    child: Row(
                      children: [
                        const SoftIconBadge(
                          icon: Icons.shield_rounded,
                          colors: [Color(0xFFFFE2D2), Color(0xFFFF8E60)],
                          size: 72,
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '账号安全等级：$_securityLevel',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: SoftColors.text,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _securityHint,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: SoftColors.subtext,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  SoftCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        _LineEntry(
                          icon: Icons.phone_android_rounded,
                          colors: const [Color(0xFFFFE4D5), Color(0xFFFF9A62)],
                          title: '手机号',
                          value: _value('phone'),
                          onTap: _openPhoneEditor,
                        ),
                        _LineEntry(
                          icon: Icons.email_rounded,
                          colors: const [Color(0xFFE6DFFF), Color(0xFF947CFF)],
                          title: '邮箱',
                          value: _value('email'),
                          onTap: _openEmailEditor,
                        ),
                        _LineEntry(
                          icon: Icons.chat_rounded,
                          colors: const [Color(0xFFDDF8E4), Color(0xFF59CE7A)],
                          title: '微信绑定',
                          value: (_preferences?['wechat_bound'] as bool? ?? false)
                              ? '已绑定'
                              : '未绑定',
                          onTap: _openWechatBinding,
                          showDivider: false,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  SoftCard(
                    padding: EdgeInsets.zero,
                    child: InkWell(
                      onTap: _showDeleteDialog,
                      borderRadius: BorderRadius.circular(28),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        child: Row(
                          children: [
                            SoftIconBadge(
                              icon: Icons.delete_forever_rounded,
                              colors: [Color(0xFFFFDDD8), Color(0xFFFF735E)],
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                '注销账号',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFFF6551),
                                ),
                              ),
                            ),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: Color(0xFFA3A8B0),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _AccountFieldScreen extends StatefulWidget {
  const _AccountFieldScreen({
    required this.title,
    required this.hintText,
    required this.initialValue,
    required this.onSave,
    required this.validator,
    required this.keyboardType,
  });

  final String title;
  final String hintText;
  final String initialValue;
  final Future<Map<String, dynamic>> Function(String value) onSave;
  final String? Function(String value) validator;
  final TextInputType keyboardType;

  @override
  State<_AccountFieldScreen> createState() => _AccountFieldScreenState();
}

class _AccountFieldScreenState extends State<_AccountFieldScreen> {
  late final TextEditingController _controller;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final value = _controller.text.trim();
    final error = widget.validator(value);
    if (error != null) {
      setState(() => _error = error);
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.onSave(value);
      await AuthService().refreshProfile();
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = '保存失败，请稍后再试');
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _SimpleSubPage(
      title: widget.title,
      child: Column(
        children: [
          SoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _controller,
                  keyboardType: widget.keyboardType,
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    border: InputBorder.none,
                    hintStyle: const TextStyle(
                      fontSize: 15,
                      color: SoftColors.subtext,
                    ),
                  ),
                  style: const TextStyle(
                    fontSize: 16,
                    color: SoftColors.text,
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    _error!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFFFF6A59),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: SoftGradientButton(
              text: _saving ? '保存中...' : '保存',
              onTap: _saving ? null : _submit,
            ),
          ),
        ],
      ),
    );
  }
}

class _WechatBindingScreen extends StatefulWidget {
  const _WechatBindingScreen({required this.isBound});

  final bool isBound;

  @override
  State<_WechatBindingScreen> createState() => _WechatBindingScreenState();
}

class _WechatBindingScreenState extends State<_WechatBindingScreen> {
  final ApiService _api = ApiService();
  late bool _isBound = widget.isBound;
  bool _saving = false;

  Future<void> _toggleBinding() async {
    setState(() => _saving = true);
    try {
      await _api.updatePreferences({'wechat_bound': !_isBound});
      if (!mounted) return;
      setState(() => _isBound = !_isBound);
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _SimpleSubPage(
      title: '微信绑定',
      child: Column(
        children: [
          SoftCard(
            child: Row(
              children: [
                const SoftIconBadge(
                  icon: Icons.chat_rounded,
                  colors: [Color(0xFFDDF8E4), Color(0xFF59CE7A)],
                  size: 72,
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isBound ? '当前微信已绑定' : '当前微信未绑定',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: SoftColors.text,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '绑定后可以作为找回方式使用。',
                        style: TextStyle(
                          fontSize: 14,
                          color: SoftColors.subtext,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: SoftGradientButton(
              text: _saving ? '处理中...' : (_isBound ? '解除绑定' : '立即绑定'),
              onTap: _saving ? null : _toggleBinding,
            ),
          ),
        ],
      ),
    );
  }
}

class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState
    extends _PreferenceScreenState<PrivacySettingsScreen> {
  @override
  String get title => '隐私设置';

  @override
  Widget buildContent() {
    return Column(
      children: [
        _PreferenceSwitchEntry(
          title: '保存历史记录',
          value: preference('save_history'),
          onChanged: (value) => updatePreference('save_history', value),
        ),
        _PreferenceSwitchEntry(
          title: '允许生成海报',
          value: preference('allow_posters'),
          onChanged: (value) => updatePreference('allow_posters', value),
        ),
        _PreferenceSwitchEntry(
          title: '内容仅自己可见',
          value: preference('private_only'),
          onChanged: (value) => updatePreference('private_only', value),
        ),
        _PreferenceSwitchEntry(
          title: '会话结束后自动清空当前上下文',
          value: preference('auto_clear_session'),
          onChanged: (value) => updatePreference('auto_clear_session', value),
        ),
        const SizedBox(height: 18),
        SoftCard(
          padding: EdgeInsets.zero,
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
              );
            },
            borderRadius: BorderRadius.circular(28),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                children: [
                  SoftIconBadge(
                    icon: Icons.description_rounded,
                    colors: [Color(0xFFE2D8FF), Color(0xFF967CFF)],
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      '查看隐私政策',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: SoftColors.text,
                      ),
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends _PreferenceScreenState<NotificationSettingsScreen> {
  @override
  String get title => '通知设置';

  @override
  Widget buildContent() {
    return Column(
      children: [
        _PreferenceSwitchEntry(
          title: '会话提醒',
          value: preference('session_reminder'),
          onChanged: (value) => updatePreference('session_reminder', value),
        ),
        _PreferenceSwitchEntry(
          title: '报告提醒',
          value: preference('report_reminder'),
          onChanged: (value) => updatePreference('report_reminder', value),
        ),
        _PreferenceSwitchEntry(
          title: '海报提醒',
          value: preference('poster_reminder'),
          onChanged: (value) => updatePreference('poster_reminder', value),
        ),
        _PreferenceSwitchEntry(
          title: '活动通知',
          value: preference('activity_notification'),
          onChanged: (value) => updatePreference('activity_notification', value),
        ),
        _PreferenceSwitchEntry(
          title: '系统通知',
          value: preference('system_notification'),
          onChanged: (value) => updatePreference('system_notification', value),
        ),
      ],
    );
  }
}

class DialectSettingsScreen extends StatefulWidget {
  const DialectSettingsScreen({super.key});

  @override
  State<DialectSettingsScreen> createState() => _DialectSettingsScreenState();
}

class _DialectSettingsScreenState
    extends _PreferenceScreenState<DialectSettingsScreen> {
  static const Map<String, String> _labels = {
    'mandarin': '普通话',
    'sichuan': '四川话',
    'cantonese': '粤语',
    'northeastern': '东北话',
    'shanghainese': '上海话',
  };

  @override
  String get title => '方言设置';

  @override
  Widget buildContent() {
    final current = (_preferences?['dialect'] as String?) ?? 'mandarin';
    return SoftCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: _labels.entries.map((entry) {
          final selected = entry.key == current;
          return SoftListTile(
            leading: SoftIconBadge(
              icon: Icons.record_voice_over_rounded,
              colors: selected
                  ? const [Color(0xFFFFE3D6), Color(0xFFFF9368)]
                  : const [Color(0xFFE8ECF4), Color(0xFFB4BBC6)],
            ),
            title: entry.value,
            trailing: selected
                ? const Icon(Icons.check_rounded, color: SoftColors.coral)
                : const SizedBox.shrink(),
            onTap: () => updatePreference('dialect', entry.key),
            showDivider: entry.key != _labels.keys.last,
          );
        }).toList(),
      ),
    );
  }
}

class HelpFeedbackScreen extends StatefulWidget {
  const HelpFeedbackScreen({super.key});

  @override
  State<HelpFeedbackScreen> createState() => _HelpFeedbackScreenState();
}

class _HelpFeedbackScreenState extends State<HelpFeedbackScreen> {
  final ApiService _api = ApiService();
  final TextEditingController _controller = TextEditingController();

  bool _submitting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final content = _controller.text.trim();
    if (content.isEmpty) return;
    setState(() => _submitting = true);
    try {
      final result = await _api.submitFeedback(content: content);
      if (!mounted) return;
      _controller.clear();
      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 28),
            child: SoftCard(
              radius: 30,
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 70,
                    color: SoftColors.green,
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    '反馈已提交',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: SoftColors.text,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    (result['message'] as String?) ?? '我们会尽快查看你的反馈。',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: SoftColors.subtext,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: SoftGradientButton(
                      text: '完成',
                      onTap: () => Navigator.of(dialogContext).pop(),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _SimpleSubPage(
      title: '帮助与反馈',
      child: Column(
        children: [
          SoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '问题描述',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: SoftColors.text,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _controller,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    hintText: '请简要描述你遇到的问题',
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                      fontSize: 15,
                      color: SoftColors.subtext,
                    ),
                  ),
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.6,
                    color: SoftColors.text,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '尽量写清出现的位置和你期望的结果。',
                  style: TextStyle(
                    fontSize: 13,
                    color: SoftColors.subtext,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: SoftGradientButton(
              text: _submitting ? '提交中...' : '提交反馈',
              onTap: _submitting ? null : _submit,
            ),
          ),
        ],
      ),
    );
  }
}

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _SimpleSubPage(
      title: '关于我们',
      child: SoftCard(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            _SettingsEntry(
              icon: Icons.description_rounded,
              colors: const [Color(0xFFFFE2D7), Color(0xFFFF9666)],
              title: '用户协议',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TermsOfServiceScreen()),
              ),
            ),
            _SettingsEntry(
              icon: Icons.privacy_tip_rounded,
              colors: const [Color(0xFFE6DFFF), Color(0xFF9D80FF)],
              title: '隐私政策',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
              ),
            ),
            const _SettingsEntry(
              icon: Icons.system_update_rounded,
              colors: [Color(0xFFDDEBFF), Color(0xFF67A9FF)],
              title: '当前版本',
              subtitle: '1.0.0',
              showDivider: false,
            ),
          ],
        ),
      ),
    );
  }
}

abstract class _PreferenceScreenState<T extends StatefulWidget>
    extends State<T> {
  final ApiService _api = ApiService();
  bool _loading = true;
  Map<String, dynamic>? _preferences;

  String get title;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    setState(() => _loading = true);
    try {
      final preferences = await _api.getPreferences();
      if (!mounted) return;
      setState(() => _preferences = preferences);
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  bool preference(String key) => _preferences?[key] as bool? ?? false;

  Future<void> updatePreference(String key, dynamic value) async {
    final updated = await _api.updatePreferences({key: value});
    if (!mounted) return;
    setState(() => _preferences = updated);
  }

  Widget buildContent();

  @override
  Widget build(BuildContext context) {
    return _SimpleSubPage(
      title: title,
      child: _loading ? const Center(child: CircularProgressIndicator()) : buildContent(),
    );
  }
}

class _SimpleSubPage extends StatelessWidget {
  const _SimpleSubPage({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SoftPage(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        child: Column(
          children: [
            SoftHeader(
              title: title,
              onBack: () => Navigator.of(context).pop(),
            ),
            const SizedBox(height: 22),
            child,
          ],
        ),
      ),
    );
  }
}

class _SettingsEntry extends StatelessWidget {
  const _SettingsEntry({
    required this.icon,
    required this.colors,
    required this.title,
    this.subtitle,
    this.onTap,
    this.showDivider = true,
  });

  final IconData icon;
  final List<Color> colors;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return SoftListTile(
      leading: SoftIconBadge(icon: icon, colors: colors),
      title: title,
      subtitle: subtitle,
      showDivider: showDivider,
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: Color(0xFFA4A9B1),
      ),
      onTap: onTap,
    );
  }
}

class _LineEntry extends StatelessWidget {
  const _LineEntry({
    required this.icon,
    required this.colors,
    required this.title,
    this.subtitle,
    this.value,
    this.onTap,
    this.showDivider = true,
  });

  final IconData icon;
  final List<Color> colors;
  final String title;
  final String? subtitle;
  final String? value;
  final VoidCallback? onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return SoftListTile(
      leading: SoftIconBadge(icon: icon, colors: colors),
      title: title,
      subtitle: subtitle,
      showDivider: showDivider,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (value != null)
            Flexible(
              child: Text(
                value!,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14, color: SoftColors.subtext),
              ),
            ),
          const SizedBox(width: 8),
          const Icon(
            Icons.chevron_right_rounded,
            color: Color(0xFFA4A9B1),
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}

class _PreferenceSwitchEntry extends StatelessWidget {
  const _PreferenceSwitchEntry({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: SoftCard(
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: SoftColors.text,
                ),
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: Colors.white,
              activeTrackColor: SoftColors.coral,
            ),
          ],
        ),
      ),
    );
  }
}
