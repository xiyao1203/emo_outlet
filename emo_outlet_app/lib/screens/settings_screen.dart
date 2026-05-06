import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../widgets/common/emo_ui.dart';
import '../widgets/common/soft_ui.dart';
import 'login_screen.dart';
import 'privacy_policy_screen.dart';
import 'terms_of_service_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final horizontal = EmoResponsive.edgePadding(width);

        return SoftPage(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(horizontal, 18, horizontal, 28),
            child: EmoResponsiveContent(
              width: width,
              maxWidth: 720,
              child: Column(
                children: [
                  SoftHeader(
                    title: '设置',
                    onBack: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(height: 20),
                  SoftCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        _SettingsEntry(
                          icon: Icons.verified_user_rounded,
                          colors: const [Color(0xFFFFE5D8), Color(0xFFFF9B63)],
                          title: '账号与安全',
                          subtitle: '管理手机号、邮箱和微信绑定',
                          onTap: () => _push(context, const AccountSecurityScreen()),
                        ),
                        _SettingsEntry(
                          icon: Icons.privacy_tip_rounded,
                          colors: const [Color(0xFFEDE2FF), Color(0xFFAB8EFF)],
                          title: '隐私设置',
                          subtitle: '控制资料展示与协议入口',
                          onTap: () => _push(context, const PrivacySettingsScreen()),
                        ),
                        _SettingsEntry(
                          icon: Icons.notifications_active_rounded,
                          colors: const [Color(0xFFDFF4FF), Color(0xFF76B8FF)],
                          title: '通知设置',
                          subtitle: '活动提醒与系统通知',
                          onTap: () => _push(context, const NotificationSettingsScreen()),
                        ),
                        _SettingsEntry(
                          icon: Icons.record_voice_over_rounded,
                          colors: const [Color(0xFFFFF0D7), Color(0xFFFFBE64)],
                          title: '表达偏好',
                          subtitle: '选择更适合你的方言与表达方式',
                          onTap: () => _push(context, const DialectSettingsScreen()),
                        ),
                        _SettingsEntry(
                          icon: Icons.feedback_rounded,
                          colors: const [Color(0xFFFFE3DB), Color(0xFFFF886A)],
                          title: '帮助与反馈',
                          subtitle: '提交问题和体验建议',
                          onTap: () => _push(context, const HelpFeedbackScreen()),
                        ),
                        _SettingsEntry(
                          icon: Icons.info_rounded,
                          colors: const [Color(0xFFDDEFFF), Color(0xFF74AEFF)],
                          title: '关于我们',
                          subtitle: '查看版本信息与产品说明',
                          onTap: () => _push(context, const AboutUsScreen()),
                          showDivider: false,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: SoftGradientButton(
                      text: '退出登录',
                      height: 54,
                      onTap: () => _showLogoutDialog(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _push(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    final navigator = Navigator.of(context);
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 28),
          child: SoftCard(
            radius: 28,
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.logout_rounded,
                  size: 62,
                  color: SoftColors.coral,
                ),
                const SizedBox(height: 14),
                const Text(
                  '确认退出登录？',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: SoftColors.text,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  '退出后会返回登录页，你的历史记录和资料仍会保留在当前账号中。',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.55,
                    color: SoftColors.subtext,
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
                          Navigator.of(dialogContext).pop();
                          await AuthService().logout();
                          if (!context.mounted) return;
                          navigator.pushAndRemoveUntil(
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

  bool _loading = true;
  bool _deleting = false;
  bool _wechatBound = false;
  Map<String, dynamic>? _profile;

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
        _wechatBound = preferences['wechat_bound'] == true;
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _fieldValue(String key, String fallback) {
    final raw = _profile?[key]?.toString().trim();
    if (raw == null || raw.isEmpty) return fallback;
    return raw;
  }

  String get _safetyLevel {
    var count = 0;
    if (_fieldValue('phone', '').isNotEmpty) count++;
    if (_fieldValue('email', '').isNotEmpty) count++;
    if (_wechatBound) count++;
    if (count >= 3) return '高';
    if (count == 2) return '中';
    return '低';
  }

  String get _safetyHint {
    switch (_safetyLevel) {
      case '高':
        return '手机号、邮箱和微信都已完善，账号更安全。';
      case '中':
        return '再补充一种找回方式，账号保护会更稳。';
      default:
        return '建议至少绑定两种方式，方便找回账号。';
    }
  }

  Future<void> _editPhone() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _AccountFieldScreen(
          title: '修改手机号',
          description: '手机号可用于登录、找回账号和重要安全提醒。',
          hintText: '请输入 11 位手机号',
          initialValue: _fieldValue('phone', ''),
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
    if (mounted) await _load();
  }

  Future<void> _editEmail() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _AccountFieldScreen(
          title: '修改邮箱',
          description: '绑定邮箱后，可以用于接收通知和账号找回。',
          hintText: '请输入邮箱地址',
          initialValue: _fieldValue('email', ''),
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            final email = value.trim();
            if (email.isEmpty) return '请输入邮箱地址';
            final valid = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
            if (!valid) return '请输入正确的邮箱地址';
            return null;
          },
          onSave: (value) => _api.updateProfileDetail({'email': value}),
        ),
      ),
    );
    if (mounted) await _load();
  }

  Future<void> _editWechatBinding() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _WechatBindingScreen(
          initialBound: _wechatBound,
          onSave: (bound) => _api.updatePreferences({'wechat_bound': bound}),
        ),
      ),
    );
    if (mounted) await _load();
  }

  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        var checked = false;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(horizontal: 24),
              child: SoftCard(
                radius: 28,
                padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '申请注销账号',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: SoftColors.text,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      '注销后将退出登录，且当前账号下的记录与资料将无法恢复。请确认你已完成数据备份。',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.6,
                        color: SoftColors.subtext,
                      ),
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => setDialogState(() => checked = !checked),
                      child: Row(
                        children: [
                          Icon(
                            checked
                                ? Icons.check_circle_rounded
                                : Icons.radio_button_unchecked_rounded,
                            size: 22,
                            color: checked
                                ? SoftColors.coral
                                : SoftColors.subtext,
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              '我已了解注销后不可恢复',
                              style: TextStyle(
                                fontSize: 14,
                                color: SoftColors.text,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: SoftOutlineButton(
                            text: '取消',
                            onTap: () => Navigator.of(dialogContext).pop(false),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SoftGradientButton(
                            text: '确认注销',
                            onTap: checked
                                ? () => Navigator.of(dialogContext).pop(true)
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
      },
    );

    if (confirmed != true) return;
    setState(() => _deleting = true);
    try {
      await AuthService().deleteAccount();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SoftPage(
      child: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final horizontal = EmoResponsive.edgePadding(width);
                  return SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(horizontal, 18, horizontal, 28),
                    child: EmoResponsiveContent(
                      width: width,
                      maxWidth: 720,
                      child: Column(
                        children: [
                          SoftHeader(
                            title: '账号与安全',
                            onBack: () => Navigator.of(context).pop(),
                          ),
                          const SizedBox(height: 20),
                          SoftCard(
                            child: Row(
                              children: [
                                Container(
                                  width: 52,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFFFFC9A7), SoftColors.coral],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: SoftColors.coral.withValues(alpha: 0.18),
                                        blurRadius: 16,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.shield_rounded,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '安全等级：$_safetyLevel',
                                        style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w700,
                                          color: SoftColors.text,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        _safetyHint,
                                        style: const TextStyle(
                                          fontSize: 13.5,
                                          height: 1.5,
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
                                _EditableSettingTile(
                                  label: '手机号',
                                  value: _fieldValue('phone', '未绑定'),
                                  onTap: _editPhone,
                                ),
                                _EditableSettingTile(
                                  label: '邮箱',
                                  value: _fieldValue('email', '未绑定'),
                                  onTap: _editEmail,
                                ),
                                _EditableSettingTile(
                                  label: '微信绑定',
                                  value: _wechatBound ? '已绑定' : '未绑定',
                                  onTap: _editWechatBinding,
                                  showDivider: false,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          SoftCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '账号管理',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    color: SoftColors.text,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  '如需停用当前账号，可以申请注销。注销后将无法恢复。',
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    height: 1.55,
                                    color: SoftColors.subtext,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  child: SoftOutlineButton(
                                    text: _deleting ? '处理中...' : '申请注销账号',
                                    onTap: _deleting ? null : _deleteAccount,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  final ApiService _api = ApiService();

  bool _loading = true;
  bool _profileVisible = true;
  bool _emotionReportVisible = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final preferences = await _api.getPreferences();
      if (!mounted) return;
      setState(() {
        _profileVisible = preferences['profile_visible'] != false;
        _emotionReportVisible = preferences['report_visible'] != false;
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save(String key, bool value) async {
    setState(() {
      if (key == 'profile_visible') _profileVisible = value;
      if (key == 'report_visible') _emotionReportVisible = value;
    });
    await _api.updatePreferences({key: value});
  }

  @override
  Widget build(BuildContext context) {
    return _PreferencePage(
      title: '隐私设置',
      loading: _loading,
      children: [
        SoftCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _SwitchSettingTile(
                title: '允许展示个人资料',
                subtitle: '关闭后，昵称和头像将减少在部分互动场景中的曝光。',
                value: _profileVisible,
                onChanged: (value) => _save('profile_visible', value),
              ),
              _SwitchSettingTile(
                title: '允许展示情绪报告',
                subtitle: '关闭后，报告页中的部分个性化摘要将默认隐藏。',
                value: _emotionReportVisible,
                onChanged: (value) => _save('report_visible', value),
                showDivider: false,
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        SoftCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _NavSettingTile(
                title: '隐私政策',
                subtitle: '查看数据使用和保护说明',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
                ),
              ),
              _NavSettingTile(
                title: '用户协议',
                subtitle: '查看产品使用条款',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const TermsOfServiceScreen()),
                ),
                showDivider: false,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  final ApiService _api = ApiService();

  bool _loading = true;
  bool _activityNotification = true;
  bool _systemNotification = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final preferences = await _api.getPreferences();
      if (!mounted) return;
      setState(() {
        _activityNotification = preferences['activity_notification'] != false;
        _systemNotification = preferences['system_notification'] != false;
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save(String key, bool value) async {
    setState(() {
      if (key == 'activity_notification') _activityNotification = value;
      if (key == 'system_notification') _systemNotification = value;
    });
    await _api.updatePreferences({key: value});
  }

  @override
  Widget build(BuildContext context) {
    return _PreferencePage(
      title: '通知设置',
      loading: _loading,
      children: [
        SoftCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _SwitchSettingTile(
                title: '活动提醒',
                subtitle: '接收与情绪释放、对象互动相关的提醒。',
                value: _activityNotification,
                onChanged: (value) => _save('activity_notification', value),
              ),
              _SwitchSettingTile(
                title: '系统通知',
                subtitle: '接收版本更新、账号安全等系统消息。',
                value: _systemNotification,
                onChanged: (value) => _save('system_notification', value),
                showDivider: false,
              ),
            ],
          ),
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

class _DialectSettingsScreenState extends State<DialectSettingsScreen> {
  final ApiService _api = ApiService();

  static const List<String> _dialects = ['普通话', '粤语', '四川话', '东北话', '上海话'];

  bool _loading = true;
  String _selectedDialect = '普通话';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final preferences = await _api.getPreferences();
      final dialect = preferences['dialect']?.toString().trim();
      if (!mounted) return;
      setState(() {
        _selectedDialect = _dialects.contains(dialect) ? dialect! : '普通话';
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save(String dialect) async {
    setState(() => _selectedDialect = dialect);
    await _api.updatePreferences({'dialect': dialect});
  }

  @override
  Widget build(BuildContext context) {
    return _PreferencePage(
      title: '表达偏好',
      loading: _loading,
      children: [
        SoftCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '选择你更舒服的表达方式',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: SoftColors.text,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '聊天页会优先使用你偏好的表达口吻，让对话更自然。',
                style: TextStyle(
                  fontSize: 13.5,
                  height: 1.55,
                  color: SoftColors.subtext,
                ),
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _dialects.map((dialect) {
                  final selected = dialect == _selectedDialect;
                  return ChoiceChip(
                    label: Text(
                      dialect,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                        color: selected ? SoftColors.coral : SoftColors.text,
                      ),
                    ),
                    selected: selected,
                    onSelected: (_) => _save(dialect),
                    showCheckmark: false,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                      side: BorderSide(
                        color: selected
                            ? SoftColors.coral
                            : const Color(0xFFE9DDD6),
                      ),
                    ),
                    backgroundColor: Colors.white.withValues(alpha: 0.72),
                    selectedColor: const Color(0xFFFFF1EB),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
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
    if (content.isEmpty) {
      _showInlineNotice(context, '请先输入反馈内容');
      return;
    }

    setState(() => _submitting = true);
    try {
      await _api.submitFeedback(content: content);
      if (!mounted) return;
      _controller.clear();
      _showInlineNotice(context, '反馈已提交，我们会尽快查看');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SoftPage(
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final horizontal = EmoResponsive.edgePadding(width);
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(horizontal, 18, horizontal, 28),
              child: EmoResponsiveContent(
                width: width,
                maxWidth: 720,
                child: Column(
                  children: [
                    SoftHeader(
                      title: '帮助与反馈',
                      onBack: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(height: 20),
                    SoftCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '告诉我们你遇到的问题',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: SoftColors.text,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '例如功能异常、建议优化或希望新增的体验，我们都会认真看。',
                            style: TextStyle(
                              fontSize: 13.5,
                              height: 1.55,
                              color: SoftColors.subtext,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _FeedbackInput(
                            controller: _controller,
                            hintText: '尽量详细描述问题，便于我们更快定位和优化。',
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: SoftGradientButton(
                              text: _submitting ? '提交中...' : '提交反馈',
                              onTap: _submitting ? null : _submit,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SoftPage(
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final horizontal = EmoResponsive.edgePadding(width);
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(horizontal, 18, horizontal, 28),
              child: EmoResponsiveContent(
                width: width,
                maxWidth: 720,
                child: Column(
                  children: [
                    SoftHeader(
                      title: '关于我们',
                      onBack: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(height: 20),
                    SoftCard(
                      child: Column(
                        children: [
                          Container(
                            width: 76,
                            height: 76,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFFC7B8), Color(0xFFFF8A66)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: SoftColors.coral.withValues(alpha: 0.18),
                                  blurRadius: 18,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.favorite_rounded,
                              color: Colors.white,
                              size: 36,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            '情绪释放',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: SoftColors.text,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '一个更轻、更安全的情绪表达空间。',
                            style: TextStyle(
                              fontSize: 14,
                              color: SoftColors.subtext,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    const SoftCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          _InfoRow(label: '当前版本', value: 'v1.0.0'),
                          _DividerLine(),
                          _InfoRow(label: '产品定位', value: '情绪表达与陪伴'),
                          _DividerLine(),
                          _InfoRow(
                            label: '说明',
                            value: '我们希望用更温和的方式，帮你把情绪说出来。',
                            showDivider: false,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    const SoftCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '温馨提示',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: SoftColors.text,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '如果你正处在紧急危险或持续性心理危机中，请优先联系身边可信赖的人，或尽快寻求专业帮助。',
                            style: TextStyle(
                              fontSize: 13.5,
                              height: 1.6,
                              color: SoftColors.subtext,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PreferencePage extends StatelessWidget {
  const _PreferencePage({
    required this.title,
    required this.loading,
    required this.children,
  });

  final String title;
  final bool loading;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SoftPage(
      child: SafeArea(
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final horizontal = EmoResponsive.edgePadding(width);
                  return SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(horizontal, 18, horizontal, 28),
                    child: EmoResponsiveContent(
                      width: width,
                      maxWidth: 720,
                      child: Column(
                        children: [
                          SoftHeader(
                            title: title,
                            onBack: () => Navigator.of(context).pop(),
                          ),
                          const SizedBox(height: 20),
                          ...children,
                        ],
                      ),
                    ),
                  );
                },
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
    required this.subtitle,
    required this.onTap,
    this.showDivider = true,
  });

  final IconData icon;
  final List<Color> colors;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(26),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: colors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Icon(icon, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w700,
                          color: SoftColors.text,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 13,
                          color: SoftColors.subtext,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: SoftColors.subtext,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
        if (showDivider) const _DividerLine(indent: 76),
      ],
    );
  }
}

class _EditableSettingTile extends StatelessWidget {
  const _EditableSettingTile({
    required this.label,
    required this.value,
    required this.onTap,
    this.showDivider = true,
  });

  final String label;
  final String value;
  final VoidCallback onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
            child: Row(
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: SoftColors.text,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 14,
                      color: SoftColors.subtext,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: SoftColors.subtext,
                  size: 21,
                ),
              ],
            ),
          ),
        ),
        if (showDivider) const _DividerLine(indent: 18),
      ],
    );
  }
}

class _SwitchSettingTile extends StatelessWidget {
  const _SwitchSettingTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.showDivider = true,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: SoftColors.text,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.55,
                        color: SoftColors.subtext,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Switch.adaptive(
                value: value,
                activeThumbColor: SoftColors.coral,
                onChanged: onChanged,
              ),
            ],
          ),
        ),
        if (showDivider) const _DividerLine(indent: 18),
      ],
    );
  }
}

class _NavSettingTile extends StatelessWidget {
  const _NavSettingTile({
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.showDivider = true,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: SoftColors.text,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.5,
                          color: SoftColors.subtext,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: SoftColors.subtext,
                  size: 21,
                ),
              ],
            ),
          ),
        ),
        if (showDivider) const _DividerLine(indent: 18),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.showDivider = true,
  });

  final String label;
  final String value;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 80,
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: SoftColors.text,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.55,
                    color: SoftColors.subtext,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showDivider) const _DividerLine(indent: 18),
      ],
    );
  }
}

class _AccountFieldScreen extends StatefulWidget {
  const _AccountFieldScreen({
    required this.title,
    required this.description,
    required this.hintText,
    required this.initialValue,
    required this.onSave,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  final String title;
  final String description;
  final String hintText;
  final String initialValue;
  final TextInputType keyboardType;
  final String? Function(String value)? validator;
  final Future<void> Function(String value) onSave;

  @override
  State<_AccountFieldScreen> createState() => _AccountFieldScreenState();
}

class _AccountFieldScreenState extends State<_AccountFieldScreen> {
  late final TextEditingController _controller;
  bool _saving = false;
  String? _errorText;

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

  Future<void> _save() async {
    final value = _controller.text.trim();
    final error = widget.validator?.call(value);
    if (error != null) {
      setState(() => _errorText = error);
      return;
    }

    setState(() {
      _saving = true;
      _errorText = null;
    });
    try {
      await widget.onSave(value);
      if (!mounted) return;
      Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SoftPage(
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final horizontal = EmoResponsive.edgePadding(width);
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(horizontal, 18, horizontal, 28),
              child: EmoResponsiveContent(
                width: width,
                maxWidth: 720,
                child: Column(
                  children: [
                    SoftHeader(
                      title: widget.title,
                      onBack: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(height: 20),
                    SoftCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.description,
                            style: const TextStyle(
                              fontSize: 13.5,
                              height: 1.55,
                              color: SoftColors.subtext,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _MainstreamTextField(
                            controller: _controller,
                            keyboardType: widget.keyboardType,
                            hintText: widget.hintText,
                            errorText: _errorText,
                          ),
                          const SizedBox(height: 18),
                          SizedBox(
                            width: double.infinity,
                            child: SoftGradientButton(
                              text: _saving ? '保存中...' : '保存',
                              onTap: _saving ? null : _save,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _WechatBindingScreen extends StatefulWidget {
  const _WechatBindingScreen({
    required this.initialBound,
    required this.onSave,
  });

  final bool initialBound;
  final Future<void> Function(bool bound) onSave;

  @override
  State<_WechatBindingScreen> createState() => _WechatBindingScreenState();
}

class _WechatBindingScreenState extends State<_WechatBindingScreen> {
  late bool _bound;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _bound = widget.initialBound;
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await widget.onSave(_bound);
      if (!mounted) return;
      Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SoftPage(
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final horizontal = EmoResponsive.edgePadding(width);
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(horizontal, 18, horizontal, 28),
              child: EmoResponsiveContent(
                width: width,
                maxWidth: 720,
                child: Column(
                  children: [
                    SoftHeader(
                      title: '微信绑定',
                      onBack: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(height: 20),
                    SoftCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '快捷登录与身份找回',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: SoftColors.text,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '当前版本先提供绑定状态管理。后续接入微信开放平台后，可升级为真实授权绑定流程。',
                            style: TextStyle(
                              fontSize: 13.5,
                              height: 1.55,
                              color: SoftColors.subtext,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.72),
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.86),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '绑定微信账号',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: SoftColors.text,
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        '开启后，在支持的场景中可作为账号找回与快捷登录方式。',
                                        style: TextStyle(
                                          fontSize: 13,
                                          height: 1.5,
                                          color: SoftColors.subtext,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Switch.adaptive(
                                  value: _bound,
                                  activeThumbColor: SoftColors.coral,
                                  onChanged: (value) => setState(() => _bound = value),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          SizedBox(
                            width: double.infinity,
                            child: SoftGradientButton(
                              text: _saving ? '保存中...' : '保存设置',
                              onTap: _saving ? null : _save,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _FeedbackInput extends StatelessWidget {
  const _FeedbackInput({
    required this.controller,
    required this.hintText,
  });

  final TextEditingController controller;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.76),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.88)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextField(
        controller: controller,
        minLines: 6,
        maxLines: 10,
        textAlignVertical: TextAlignVertical.top,
        style: const TextStyle(
          fontSize: 15.5,
          height: 1.45,
          color: SoftColors.text,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: const TextStyle(
            fontSize: 14.5,
            height: 1.45,
            color: Color(0xFFBAADA4),
          ),
        ),
      ),
    );
  }
}

class _MainstreamTextField extends StatelessWidget {
  const _MainstreamTextField({
    required this.controller,
    required this.hintText,
    this.keyboardType = TextInputType.text,
    this.errorText,
  });

  final TextEditingController controller;
  final String hintText;
  final TextInputType keyboardType;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.78),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: errorText == null
                  ? Colors.white.withValues(alpha: 0.9)
                  : const Color(0xFFFF8A66),
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            textAlign: TextAlign.left,
            style: const TextStyle(
              fontSize: 16,
              color: SoftColors.text,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hintText,
              hintStyle: const TextStyle(
                fontSize: 15,
                color: Color(0xFFB8ACA3),
                fontWeight: FontWeight.w500,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 18,
              ),
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 8),
          Text(
            errorText!,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFFE35E43),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}

class _DividerLine extends StatelessWidget {
  const _DividerLine({this.indent = 0});

  final double indent;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: indent),
      height: 1,
      color: const Color(0xFFF1E7E1),
    );
  }
}

void _showInlineNotice(BuildContext context, String message) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  messenger?.hideCurrentSnackBar();
  messenger?.showSnackBar(
    SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.fromLTRB(18, 0, 18, 18),
    ),
  );
}
