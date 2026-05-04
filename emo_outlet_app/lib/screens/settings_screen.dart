import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../widgets/auth/auth_visuals.dart';
import '../widgets/common/emo_ui.dart';
import 'login_screen.dart';
import 'privacy_policy_screen.dart';
import 'terms_of_service_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return EmoPageScaffold(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
        child: Column(
          children: [
            _PageHeader(
                title: '设置中心', onBack: () => Navigator.of(context).pop()),
            const SizedBox(height: 26),
            EmoSectionCard(
              radius: 34,
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  _SettingEntry(
                    emoji: '🛡️',
                    title: '账号与安全',
                    onTap: () => _push(context, const AccountSecurityScreen()),
                  ),
                  _SettingEntry(
                    emoji: '🔒',
                    title: '隐私设置',
                    onTap: () => _push(context, const PrivacySettingsScreen()),
                  ),
                  _SettingEntry(
                    emoji: '🔔',
                    title: '通知设置',
                    onTap: () =>
                        _push(context, const NotificationSettingsScreen()),
                  ),
                  _SettingEntry(
                    emoji: '💬',
                    title: '方言设置',
                    onTap: () => _push(context, const DialectSettingsScreen()),
                  ),
                  _SettingEntry(
                    emoji: '🗨️',
                    title: '帮助反馈',
                    onTap: () => _push(context, const HelpFeedbackScreen()),
                  ),
                  _SettingEntry(
                    emoji: '💗',
                    title: '关于我们',
                    isLast: true,
                    onTap: () => _push(context, const AboutUsScreen()),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 34),
            SizedBox(
              width: double.infinity,
              child: GradientPrimaryButton(
                text: '退出登录',
                height: 78,
                fontSize: 22,
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

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.48),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 42),
        child: EmoSectionCard(
          radius: 34,
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('☁️', style: TextStyle(fontSize: 110)),
              const SizedBox(height: 8),
              const Text(
                '确认退出登录？',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AuthPalette.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '退出后将返回登录页，\n但你的历史记录会保留。',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  height: 1.7,
                  color: Color(0xFF766C67),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlineSoftButton(
                      text: '取消',
                      onTap: () => Navigator.of(ctx).pop(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GradientPrimaryButton(
                      text: '确认退出',
                      height: 56,
                      fontSize: 18,
                      onTap: () async {
                        await AuthService().logout();
                        if (!ctx.mounted) return;
                        Navigator.of(ctx).pushAndRemoveUntil(
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
      ),
    );
  }
}

class AccountSecurityScreen extends StatelessWidget {
  const AccountSecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _SettingsSubScaffold(
      title: '账号与安全',
      child: Column(
        children: [
          EmoSectionCard(
            radius: 32,
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
            child: Row(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFE3D9), Color(0xFFFFF3EE)],
                    ),
                  ),
                  child: const Center(
                    child: Text('🛡️', style: TextStyle(fontSize: 54)),
                  ),
                ),
                const SizedBox(width: 18),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '账号安全等级：高',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AuthPalette.textPrimary,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        '你的账号安全状况良好，请继续保持',
                        style: TextStyle(
                          fontSize: 17,
                          color: Color(0xFF7D716C),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _PanelCard(
            children: const [
              _InfoRow(emoji: '📱', title: '手机号', trailing: '138****5678'),
              _InfoRow(emoji: '💚', title: '微信绑定', trailing: '已绑定'),
              _InfoRow(emoji: '🐧', title: 'QQ绑定', trailing: '已绑定'),
              _InfoRow(emoji: '🔐', title: '修改密码', trailing: '已设置'),
              _InfoRow(
                emoji: '⏻',
                title: '账号注销',
                trailing: '永久注销，无法恢复',
                isLast: true,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.44),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: const Color(0xFFF6CFC9), width: 1.4),
            ),
            child: const Row(
              children: [
                Text('🗑️', style: TextStyle(fontSize: 46)),
                SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '注销账号',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFFF5E54),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '永久注销账号，所有数据将被清除且无法恢复',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF8E817B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded,
                    size: 30, color: Color(0xFF999999)),
              ],
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

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  bool saveHistory = true;
  bool allowPoster = true;
  bool onlyVisibleToMe = false;
  bool clearAfterChat = true;

  @override
  Widget build(BuildContext context) {
    return _SettingsSubScaffold(
      title: '隐私设置',
      child: Column(
        children: [
          _HeroCard(
            emoji: '🔒',
            title: '你的隐私，我们用心守护',
            description: '您可以在这里管理个人隐私与数据的\n使用方式，安心享受每一次陪伴。',
            tint: const [Color(0xFFF0E4FF), Color(0xFFF9F2FF)],
          ),
          const SizedBox(height: 18),
          _SwitchCard(
            emoji: '🕒',
            title: '允许保存历史记录',
            subtitle: '关闭后，将不再保存新的聊天记录',
            value: saveHistory,
            onChanged: (value) => setState(() => saveHistory = value),
          ),
          _SwitchCard(
            emoji: '🖼️',
            title: '允许生成海报',
            subtitle: '关闭后，将无法生成和保存专属海报',
            value: allowPoster,
            onChanged: (value) => setState(() => allowPoster = value),
          ),
          _SwitchCard(
            emoji: '🙈',
            title: '仅自己可见',
            subtitle: '开启后，内容仅对你自己可见',
            value: onlyVisibleToMe,
            onChanged: (value) => setState(() => onlyVisibleToMe = value),
          ),
          _SwitchCard(
            emoji: '🗑️',
            title: '会话结束自动清除',
            subtitle: '关闭后，聊天记录将保留在设备中',
            value: clearAfterChat,
            onChanged: (value) => setState(() => clearAfterChat = value),
          ),
          const SizedBox(height: 8),
          EmoSectionCard(
            radius: 30,
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => const PrivacyPolicyScreen()),
                );
              },
              child: const Row(
                children: [
                  Text('🛡️', style: TextStyle(fontSize: 44)),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '数据与隐私说明',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AuthPalette.textPrimary,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '查看我们的数据使用规则与隐私政策',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF8A7E77),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded,
                      size: 30, color: Color(0xFF999999)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '🔒 你的隐私对我们非常重要，所有数据处理均遵循相关法律法规。\n如有疑问，请随时联系我们的客服团队。',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                height: 1.8,
                color: Color(0xFF978A84),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
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
    extends State<NotificationSettingsScreen> {
  bool chat = true;
  bool summary = true;
  bool poster = true;
  bool activity = false;
  bool system = true;

  @override
  Widget build(BuildContext context) {
    return _SettingsSubScaffold(
      title: '通知设置',
      child: Column(
        children: [
          _HeroCard(
            emoji: '🔔',
            title: '按你的节奏提醒你',
            description: '不错过重要消息，也不打扰你的生活',
            tint: const [Color(0xFFFFF2EE), Color(0xFFFFF9F4)],
          ),
          const SizedBox(height: 18),
          _SwitchCard(
            emoji: '💬',
            title: '会话提醒',
            subtitle: '当有新的消息时，及时提醒你',
            value: chat,
            onChanged: (value) => setState(() => chat = value),
          ),
          _SwitchCard(
            emoji: '🙂',
            title: '情绪总结提醒',
            subtitle: '每日情绪总结生成后提醒你查看',
            value: summary,
            onChanged: (value) => setState(() => summary = value),
          ),
          _SwitchCard(
            emoji: '📘',
            title: '海报生成提醒',
            subtitle: '专属海报生成后提醒你查看',
            value: poster,
            onChanged: (value) => setState(() => poster = value),
          ),
          _SwitchCard(
            emoji: '🗓️',
            title: '活动通知',
            subtitle: '参与活动、福利等消息提醒',
            value: activity,
            onChanged: (value) => setState(() => activity = value),
          ),
          _SwitchCard(
            emoji: '⚙️',
            title: '系统通知',
            subtitle: '系统与账号相关的重要通知',
            value: system,
            onChanged: (value) => setState(() => system = value),
          ),
          const SizedBox(height: 18),
          const Text(
            '你可以随时在这里管理通知偏好 💗',
            style: TextStyle(
              fontSize: 17,
              color: Color(0xFF978B85),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class DialectSettingsScreen extends StatefulWidget {
  const DialectSettingsScreen({super.key});

  @override
  State<DialectSettingsScreen> createState() => _DialectSettingsScreenState();
}

class _DialectSettingsScreenState extends State<DialectSettingsScreen> {
  String selected = '普通话';

  final options = const ['普通话', '四川话', '粤语', '东北话', '上海话', '闽南话', '客家话'];

  @override
  Widget build(BuildContext context) {
    return _SettingsSubScaffold(
      title: '方言设置',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeroCard(
            emoji: '🎧',
            title: '方言设置',
            description: '选择你熟悉的方言\n让陪伴更亲切、更懂你',
            tint: const [Color(0xFFFFF3EE), Color(0xFFFFF8F3)],
          ),
          const SizedBox(height: 18),
          EmoSectionCard(
            radius: 30,
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
            child: const Row(
              children: [
                Expanded(
                  child: Text(
                    '主要语言',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AuthPalette.textPrimary,
                    ),
                  ),
                ),
                Text(
                  '普通话',
                  style: TextStyle(
                    fontSize: 18,
                    color: Color(0xFF857872),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.chevron_right_rounded,
                    size: 28, color: Color(0xFF999999)),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const Padding(
            padding: EdgeInsets.only(left: 6, bottom: 12),
            child: Text(
              '选择方言',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AuthPalette.textPrimary,
              ),
            ),
          ),
          ...options.map(
            (dialect) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: EmoSectionCard(
                radius: 28,
                padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Text(
                            dialect,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AuthPalette.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.75),
                              borderRadius: BorderRadius.circular(18),
                              border:
                                  Border.all(color: const Color(0xFFF6D3C8)),
                            ),
                            child: const Text(
                              '🔊 试听示例',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFFF8258),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => selected = dialect),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selected == dialect
                                ? const Color(0xFFFF7B59)
                                : const Color(0xFFC9C3C0),
                            width: 2.4,
                          ),
                        ),
                        child: selected == dialect
                            ? Center(
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFFFF7B59),
                                  ),
                                ),
                              )
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            '✨ 语言设置后将立即生效',
            style: TextStyle(
              fontSize: 17,
              color: Color(0xFF978B85),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
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
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _SettingsSubScaffold(
      title: '帮助反馈',
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: Colors.white),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.search_rounded,
                        size: 30, color: Color(0xFF9A9A9A)),
                    SizedBox(width: 12),
                    Text(
                      '搜索帮助内容',
                      style: TextStyle(
                        fontSize: 17,
                        color: Color(0xFF9A9A9A),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Positioned(
                right: 8,
                top: 2,
                child: SizedBox(
                    width: 102,
                    height: 82,
                    child: EmoDecorationCloud(size: 100)),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _PanelCard(
            children: const [
              _RichEntry(emoji: '❓', title: '常见问题', subtitle: '解答你最关心的问题'),
              _RichEntry(emoji: '📖', title: '使用教程', subtitle: '快速上手，轻松使用'),
              _RichEntry(emoji: '📝', title: '问题反馈', subtitle: '告诉我们你遇到的问题'),
              _RichEntry(
                  emoji: '🎧',
                  title: '联系客服',
                  subtitle: '专业客服为你服务',
                  isLast: true),
            ],
          ),
          const SizedBox(height: 18),
          EmoSectionCard(
            radius: 30,
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '填写你的问题',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AuthPalette.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  '请尽可能详细地描述问题，以便我们更好地帮助你',
                  style: TextStyle(
                    fontSize: 17,
                    color: Color(0xFF8A7E77),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.48),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: const Color(0xFFF5E3DB)),
                  ),
                  child: TextField(
                    controller: _controller,
                    maxLength: 500,
                    maxLines: 6,
                    decoration: const InputDecoration(
                      hintText: '请输入你的问题描述...',
                      hintStyle: TextStyle(color: Color(0xFFBBBBBB)),
                      contentPadding: EdgeInsets.all(18),
                      border: InputBorder.none,
                      counterText: '',
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: const Color(0xFFF3D8CF),
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: const Row(
                    children: [
                      Text('📷', style: TextStyle(fontSize: 34)),
                      SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '上传截图（选填）',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AuthPalette.textPrimary,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              '最多上传 3 张图片，支持 JPG、PNG 格式',
                              style: TextStyle(
                                fontSize: 15,
                                color: Color(0xFF9A8D86),
                                fontWeight: FontWeight.w500,
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
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: GradientPrimaryButton(
              text: '提交反馈',
              height: 74,
              fontSize: 22,
              onTap: () {},
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
    return _SettingsSubScaffold(
      title: '关于我们',
      child: Column(
        children: [
          const SizedBox(height: 8),
          const Text('☁️', style: TextStyle(fontSize: 140)),
          const SizedBox(height: 8),
          const Text(
            '情绪释放',
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w800,
              color: AuthPalette.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Version 1.0.0',
            style: TextStyle(
              fontSize: 20,
              color: Color(0xFF7C726D),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 22),
          EmoSectionCard(
            radius: 30,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '💗 遇见更好的自己',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AuthPalette.textPrimary,
                  ),
                ),
                SizedBox(height: 14),
                Text(
                  '情绪释放是一款专注于情绪疏导与心理健康的应用。\n\n在这里，你可以安全地记录心情、释放压力、获得陪伴，\n让每一种情绪都被温柔接纳，遇见更从容、更好的自己。',
                  style: TextStyle(
                    fontSize: 17,
                    height: 1.8,
                    color: Color(0xFF695E59),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _PanelCard(
            children: [
              _RichEntry(
                emoji: '🛡️',
                title: '用户协议',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => const TermsOfServiceScreen()),
                ),
              ),
              _RichEntry(
                emoji: '🔒',
                title: '隐私政策',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => const PrivacyPolicyScreen()),
                ),
              ),
              const _RichEntry(emoji: '💬', title: '联系我们'),
              const _RichEntry(
                emoji: '☁️',
                title: '检查更新',
                trailingText: '当前版本 1.0.0',
                isLast: true,
              ),
            ],
          ),
          const SizedBox(height: 18),
          EmoSectionCard(
            radius: 30,
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
            child: const Row(
              children: [
                Text('☁️', style: TextStyle(fontSize: 88)),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '感谢你选择情绪释放 💗',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AuthPalette.textPrimary,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        '愿我们陪你走过每一段情绪时光 🌈',
                        style: TextStyle(
                          fontSize: 18,
                          color: Color(0xFF7B6F6A),
                          fontWeight: FontWeight.w500,
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
    );
  }
}

class _SettingsSubScaffold extends StatelessWidget {
  const _SettingsSubScaffold({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return EmoPageScaffold(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
        child: Column(
          children: [
            _PageHeader(
                title: title, onBack: () => Navigator.of(context).pop()),
            const SizedBox(height: 24),
            child,
          ],
        ),
      ),
    );
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({
    required this.title,
    required this.onBack,
  });

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: EmoRoundIconButton(
              icon: Icons.arrow_back_ios_new_rounded,
              size: 52,
              onTap: onBack,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: AuthPalette.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.emoji,
    required this.title,
    required this.description,
    required this.tint,
  });

  final String emoji;
  final String title;
  final String description;
  final List<Color> tint;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(colors: tint),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 84)),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AuthPalette.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.8,
                    color: Color(0xFF7D726D),
                    fontWeight: FontWeight.w500,
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

class _PanelCard extends StatelessWidget {
  const _PanelCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return EmoSectionCard(
      radius: 34,
      padding: const EdgeInsets.all(14),
      child: Column(children: children),
    );
  }
}

class _SettingEntry extends StatelessWidget {
  const _SettingEntry({
    required this.emoji,
    required this.title,
    required this.onTap,
    this.isLast = false,
  });

  final String emoji;
  final String title;
  final VoidCallback onTap;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(26),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 22),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : const Border(
                  bottom: BorderSide(color: Color(0xFFF4E7E0), width: 1),
                ),
        ),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: Color(0xFFF9F4F2),
                shape: BoxShape.circle,
              ),
              child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 30))),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AuthPalette.textPrimary,
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                size: 30, color: Color(0xFF999999)),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.emoji,
    required this.title,
    required this.trailing,
    this.isLast = false,
  });

  final String emoji;
  final String title;
  final String trailing;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 24),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(bottom: BorderSide(color: Color(0xFFF4E7E0))),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 34)),
          const SizedBox(width: 18),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AuthPalette.textPrimary,
              ),
            ),
          ),
          Flexible(
            child: Text(
              trailing,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 18,
                color: Color(0xFF928681),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right_rounded,
              size: 30, color: Color(0xFF999999)),
        ],
      ),
    );
  }
}

class _RichEntry extends StatelessWidget {
  const _RichEntry({
    required this.emoji,
    required this.title,
    this.subtitle,
    this.trailingText,
    this.isLast = false,
    this.onTap,
  });

  final String emoji;
  final String title;
  final String? subtitle;
  final String? trailingText;
  final bool isLast;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 22),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : const Border(bottom: BorderSide(color: Color(0xFFF4E7E0))),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 34)),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AuthPalette.textPrimary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF8E817B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailingText != null) ...[
              Flexible(
                child: Text(
                  trailingText!,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Color(0xFF8E817B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            const Icon(Icons.chevron_right_rounded,
                size: 30, color: Color(0xFF999999)),
          ],
        ),
      ),
    );
  }
}

class _SwitchCard extends StatelessWidget {
  const _SwitchCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: EmoSectionCard(
        radius: 30,
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 40)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AuthPalette.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF8A7E77),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Transform.scale(
              scale: 1.15,
              child: Switch(
                value: value,
                onChanged: onChanged,
                activeThumbColor: Colors.white,
                activeTrackColor: const Color(0xFFFF6E57),
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: const Color(0xFFE2E2E2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
