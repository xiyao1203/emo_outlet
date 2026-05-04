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
                    title: '帮助反馈',
                    onTap: () => _push(context, const HelpFeedbackScreen()),
                  ),
                  _SettingsEntry(
                    icon: Icons.headset_mic_rounded,
                    colors: const [Color(0xFFDDF8EA), Color(0xFF61CC8D)],
                    title: '联系客服',
                    onTap: () =>
                        _push(context, const ContactCustomerServiceScreen()),
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
                  '退出后会回到登录页，但你的历史记录和已保存内容仍会保留在账号中。',
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
                        text: '确认退出',
                        onTap: () async {
                          await AuthService().logout();
                          if (!context.mounted) return;
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (_) => const LoginScreen()),
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
                                '账号安全等级：${_securityLevel}',
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
                                  fontSize: 15,
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
                        ),
                        _LineEntry(
                          icon: Icons.email_rounded,
                          colors: const [Color(0xFFE6DFFF), Color(0xFF947CFF)],
                          title: '邮箱',
                          value: _value('email'),
                        ),
                        _LineEntry(
                          icon: Icons.forum_rounded,
                          colors: const [Color(0xFFDDF8E4), Color(0xFF59CE7A)],
                          title: '微信绑定',
                          value:
                              (_preferences?['wechat_bound'] as bool? ?? false)
                                  ? '已绑定'
                                  : '未绑定',
                        ),
                        _LineEntry(
                          icon: Icons.notifications_rounded,
                          colors: const [Color(0xFFDDEBFF), Color(0xFF66A3FF)],
                          title: '系统通知',
                          value:
                              (_preferences?['system_notification'] as bool? ??
                                      false)
                                  ? '已开启'
                                  : '已关闭',
                        ),
                        _LineEntry(
                          icon: Icons.lock_rounded,
                          colors: const [Color(0xFFEADFFF), Color(0xFFA673FF)],
                          title: '登录方式',
                          value: AuthService().currentUser?.isVisitor == true
                              ? '游客模式'
                              : '账号登录',
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
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        child: Row(
                          children: [
                            SoftIconBadge(
                              icon: Icons.delete_forever_rounded,
                              colors: [Color(0xFFFFDDD8), Color(0xFFFF735E)],
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '注销账号',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFFFF6551),
                                    ),
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    '注销后将删除账号信息、历史记录和海报内容，且无法恢复。',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: SoftColors.subtext,
                                    ),
                                  ),
                                ],
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

  String get _securityLevel {
    var score = 0;
    if (_hasValue('phone')) score++;
    if (_hasValue('email')) score++;
    if (_preferences?['wechat_bound'] == true) score++;
    if (AuthService().currentUser?.isVisitor == false) score++;
    if (score >= 3) return '高';
    if (score >= 2) return '中';
    return '低';
  }

  String get _securityHint {
    if (_securityLevel == '高') {
      return '当前账号资料、通知设置和登录状态都已和服务端同步。';
    }
    if (_securityLevel == '中') {
      return '基础安全项已经齐全，再补充一个绑定方式会更稳妥。';
    }
    return '建议补充手机号、邮箱或绑定方式，方便后续找回和同步数据。';
  }

  bool _hasValue(String key) {
    final text = _profile?[key]?.toString().trim();
    return text != null && text.isNotEmpty;
  }

  String _value(String key) {
    final text = _profile?[key]?.toString().trim();
    return (text == null || text.isEmpty) ? '-' : text;
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
                                      builder: (_) => const LoginScreen()),
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
        const _HintHero(
          title: '你的隐私，我们认真对待',
          subtitle: '这些偏好会直接写回账号，换设备登录后也会保持一致。',
        ),
        const SizedBox(height: 18),
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
                        fontSize: 18,
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
        const _HintHero(
          title: '按你的节奏提醒你',
          subtitle: '通知开关全部走服务端配置，不再是本地展示状态。',
        ),
        const SizedBox(height: 18),
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
          onChanged: (value) =>
              updatePreference('activity_notification', value),
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
    return Column(
      children: [
        const _HintHero(
          title: '选个更像你的说话方式',
          subtitle: '保存后会直接影响后端生成的对话语气。',
        ),
        const SizedBox(height: 18),
        SoftCard(
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
  bool _loading = true;
  bool _submitting = false;
  Map<String, dynamic>? _overview;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final overview = await _api.getSupportOverview();
      if (!mounted) return;
      setState(() => _overview = overview);
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _submit() async {
    final content = _controller.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('先写下你遇到的问题，我们再帮你提交。')),
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      final result = await _api.submitFeedback(content: content);
      if (!mounted) return;
      await _showSubmitSuccess(result['message'] as String?);
      _controller.clear();
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final entries =
        _overview?['common_entries'] as List<dynamic>? ?? <dynamic>[];
    return SoftPage(
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
              child: Column(
                children: [
                  SoftHeader(
                    title: '帮助反馈',
                    onBack: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(height: 22),
                  const _HintHero(
                    title: '把问题告诉我们',
                    subtitle: '你的反馈会直接提交到服务端，我们会尽快跟进处理。',
                  ),
                  const SizedBox(height: 18),
                  SoftCard(
                    child: TextField(
                      controller: _controller,
                      maxLines: 6,
                      maxLength: 500,
                      decoration: const InputDecoration(
                        hintText: '尽量写清问题出现的位置、复现方式，以及你期待的结果。',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  SoftCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: entries
                          .map((item) => Map<String, dynamic>.from(item as Map))
                          .map(
                            (entry) => _SettingsEntry(
                              icon: _entryIcon(entry['title'] as String? ?? ''),
                              colors:
                                  _entryColors(entry['title'] as String? ?? ''),
                              title: entry['title'] as String? ?? '',
                              subtitle: entry['subtitle'] as String?,
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: SoftGradientButton(
                      text: _submitting ? '提交中...' : '提交反馈',
                      height: 60,
                      onTap: _submitting ? null : _submit,
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  IconData _entryIcon(String title) {
    if (title.contains('常见')) return Icons.help_outline_rounded;
    if (title.contains('教程')) return Icons.menu_book_rounded;
    if (title.contains('反馈')) return Icons.edit_note_rounded;
    if (title.contains('客服')) return Icons.support_agent_rounded;
    return Icons.help_center_rounded;
  }

  List<Color> _entryColors(String title) {
    if (title.contains('常见')) {
      return const [Color(0xFFFFE2D7), Color(0xFFFF9666)];
    }
    if (title.contains('教程')) {
      return const [Color(0xFFE6DFFF), Color(0xFF9D80FF)];
    }
    if (title.contains('反馈')) {
      return const [Color(0xFFDDF7E5), Color(0xFF5ACA7A)];
    }
    return const [Color(0xFFDDEBFF), Color(0xFF67A9FF)];
  }

  Future<void> _showSubmitSuccess(String? message) async {
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.32),
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 34),
          child: SoftCard(
            radius: 30,
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.favorite_rounded,
                  color: Color(0xFFFF9AA1),
                  size: 120,
                ),
                const SizedBox(height: 8),
                const Text(
                  '反馈已提交',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: SoftColors.text,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  message ?? '我们已经收到你的问题，会尽快与你联系。',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.6,
                    color: SoftColors.subtext,
                  ),
                ),
                const SizedBox(height: 24),
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
  }
}

class ContactCustomerServiceScreen extends StatefulWidget {
  const ContactCustomerServiceScreen({super.key});

  @override
  State<ContactCustomerServiceScreen> createState() =>
      _ContactCustomerServiceScreenState();
}

class _ContactCustomerServiceScreenState
    extends State<ContactCustomerServiceScreen> {
  final ApiService _api = ApiService();
  bool _loading = true;
  Map<String, dynamic>? _overview;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final overview = await _api.getSupportOverview();
      if (!mounted) return;
      setState(() => _overview = overview);
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final preview =
        _overview?['preview_messages'] as List<dynamic>? ?? <dynamic>[];
    final online = (_overview?['online_status'] as String?) == 'online';
    return SoftPage(
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
              child: Column(
                children: [
                  SoftHeader(
                    title: '联系客服',
                    onBack: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(height: 20),
                  SoftCard(
                    child: Row(
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '我们会尽快帮助你',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: SoftColors.text,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                '你的每一次倾诉，我们都会认真对待。',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: SoftColors.subtext,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.headset_mic_rounded,
                          size: 88,
                          color: Color(0xFFFFA17C),
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
                          icon: Icons.chat_bubble_rounded,
                          colors: const [Color(0xFFFFE4D5), Color(0xFFFF9860)],
                          title: '在线客服',
                          subtitle: '实时对话，快速处理你的问题',
                          value: online ? '在线' : '离线',
                        ),
                        _LineEntry(
                          icon: Icons.mail_rounded,
                          colors: const [Color(0xFFE7DFFF), Color(0xFF947BFF)],
                          title: '邮件联系',
                          subtitle: _overview?['email'] as String?,
                        ),
                        _LineEntry(
                          icon: Icons.groups_rounded,
                          colors: const [Color(0xFFDDF7E6), Color(0xFF54C978)],
                          title: '用户社群',
                          subtitle: _overview?['community_name'] as String?,
                        ),
                        _LineEntry(
                          icon: Icons.schedule_rounded,
                          colors: const [Color(0xFFDCEBFF), Color(0xFF5EA8FF)],
                          title: '服务时间',
                          subtitle: _overview?['service_hours'] as String?,
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
                        const Padding(
                          padding: EdgeInsets.fromLTRB(22, 18, 22, 0),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 4,
                                height: 18,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: SoftColors.coral,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(999)),
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(
                                '对话预览',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: SoftColors.text,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        ...preview.map((item) {
                          final map = Map<String, dynamic>.from(item as Map);
                          return _ChatBubbleRow(
                            left: (map['role'] as String?) != 'user',
                            text: map['content'] as String? ?? '',
                          );
                        }),
                        Container(
                          margin: const EdgeInsets.fromLTRB(18, 10, 18, 18),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.84),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: const Color(0xFFF2E1D8)),
                          ),
                          child: Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  '输入问题后，客服会尽快接入...',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFFBCC1C9),
                                  ),
                                ),
                              ),
                              Container(
                                width: 48,
                                height: 48,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      SoftColors.coral,
                                      SoftColors.orange
                                    ],
                                  ),
                                ),
                                child: const Icon(
                                  Icons.send_rounded,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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
      child: Column(
        children: [
          const _HintHero(
            title: 'Emo Outlet',
            subtitle: '一个更温柔地安放情绪、整理关系和记录自己的地方。',
          ),
          const SizedBox(height: 18),
          SoftCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _SettingsEntry(
                  icon: Icons.description_rounded,
                  colors: const [Color(0xFFFFE2D7), Color(0xFFFF9666)],
                  title: '用户协议',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const TermsOfServiceScreen()),
                  ),
                ),
                _SettingsEntry(
                  icon: Icons.privacy_tip_rounded,
                  colors: const [Color(0xFFE6DFFF), Color(0xFF9D80FF)],
                  title: '隐私政策',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const PrivacyPolicyScreen()),
                  ),
                ),
                const _SettingsEntry(
                  icon: Icons.favorite_rounded,
                  colors: [Color(0xFFDDF7E5), Color(0xFF5ACA7A)],
                  title: '产品理念',
                  subtitle: '我们希望每一次表达，都能被温柔接住。',
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
        ],
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
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : buildContent(),
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

class _HintHero extends StatelessWidget {
  const _HintHero({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: SoftColors.text,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 15,
                    color: SoftColors.subtext,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Icon(
            Icons.favorite_rounded,
            size: 76,
            color: Color(0xFFFFA1A3),
          ),
        ],
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
    this.showDivider = true,
  });

  final IconData icon;
  final List<Color> colors;
  final String title;
  final String? subtitle;
  final String? value;
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
                style: const TextStyle(fontSize: 16, color: SoftColors.subtext),
              ),
            ),
          const SizedBox(width: 8),
          const Icon(
            Icons.chevron_right_rounded,
            color: Color(0xFFA4A9B1),
          ),
        ],
      ),
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
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: SoftColors.text,
                ),
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: Colors.white,
              activeTrackColor: SoftColors.coral,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatBubbleRow extends StatelessWidget {
  const _ChatBubbleRow({
    required this.left,
    required this.text,
  });

  final bool left;
  final String text;

  @override
  Widget build(BuildContext context) {
    final bubble = Container(
      constraints: const BoxConstraints(maxWidth: 260),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: left
            ? Colors.white.withValues(alpha: 0.92)
            : const Color(0x1AFFA17D),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          height: 1.55,
          color: SoftColors.text,
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
      child: Row(
        mainAxisAlignment:
            left ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: left
            ? [
                const CircleAvatar(
                  radius: 18,
                  backgroundColor: Color(0xFFFFD2D4),
                  child: Icon(
                    Icons.favorite_rounded,
                    color: Color(0xFFFF7E8E),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                bubble,
              ]
            : [
                bubble,
                const SizedBox(width: 10),
                const CircleAvatar(
                  radius: 18,
                  backgroundColor: Color(0xFFF9DFD1),
                  child: Icon(
                    Icons.person_rounded,
                    color: Color(0xFFB17A55),
                    size: 18,
                  ),
                ),
              ],
      ),
    );
  }
}
