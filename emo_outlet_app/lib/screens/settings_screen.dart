import 'package:flutter/material.dart';

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
                    icon: Icons.info_rounded,
                    colors: const [Color(0xFFDDF8EA), Color(0xFF61CC8D)],
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
      builder: (context) {
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
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: SoftColors.text,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  '退出后会返回登录页，但你的历史数据仍会保留。',
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
                        onTap: () => Navigator.of(context).pop(),
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
                              builder: (_) => const LoginScreen(),
                            ),
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
  bool _confirmed = false;

  @override
  Widget build(BuildContext context) {
    return SoftPage(
      child: SingleChildScrollView(
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
                children: const [
                  SoftIconBadge(
                    icon: Icons.shield_rounded,
                    colors: [Color(0xFFFFE2D2), Color(0xFFFF8E60)],
                    size: 72,
                  ),
                  SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '账号安全等级：高',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: SoftColors.text,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '你的账号安全状况良好，请继续保持',
                          style: TextStyle(
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
                children: const [
                  _LineEntry(
                    icon: Icons.phone_android_rounded,
                    colors: [Color(0xFFFFE4D5), Color(0xFFFF9A62)],
                    title: '手机号',
                    value: '138****5678',
                  ),
                  _LineEntry(
                    icon: Icons.wechat_outlined,
                    colors: [Color(0xFFDDF8E4), Color(0xFF59CE7A)],
                    title: '微信绑定',
                    value: '已绑定',
                  ),
                  _LineEntry(
                    icon: Icons.notifications_rounded,
                    colors: [Color(0xFFDDEBFF), Color(0xFF66A3FF)],
                    title: '消息提醒',
                    value: '已开启',
                  ),
                  _LineEntry(
                    icon: Icons.lock_rounded,
                    colors: [Color(0xFFEADFFF), Color(0xFFA673FF)],
                    title: '修改密码',
                    value: '已设置',
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '注销账号',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFFF6551),
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              '永久注销账号，所有数据将被清除且无法恢复',
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

  Future<void> _showDeleteDialog() async {
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.24),
      builder: (context) {
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
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: SoftColors.text,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  '注销后将删除账号信息、历史记录与海报，且无法恢复',
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
                        onTap: () => Navigator.of(context).pop(),
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
}

class PrivacySettingsScreen extends StatelessWidget {
  const PrivacySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _SimpleSubPage(
      title: '隐私设置',
      children: [
        const _HintHero(
          title: '你的隐私，我们用心守护',
          subtitle: '历史记录、海报与会话都只服务于你自己的情绪整理。',
        ),
        const SizedBox(height: 18),
        const _StaticSwitchEntry(title: '允许保存历史记录', value: true),
        const _StaticSwitchEntry(title: '允许生成海报', value: true),
        const _StaticSwitchEntry(title: '仅自己可见', value: false),
        const _StaticSwitchEntry(title: '会话结束自动清除', value: true),
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

class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _SimpleSubPage(
      title: '通知设置',
      children: const [
        _HintHero(
          title: '按你的节奏提醒你',
          subtitle: '重要信息会准时到达，不打扰也不缺席。',
        ),
        SizedBox(height: 18),
        _StaticSwitchEntry(title: '会话提醒', value: true),
        _StaticSwitchEntry(title: '情绪总结提醒', value: true),
        _StaticSwitchEntry(title: '海报生成提醒', value: true),
        _StaticSwitchEntry(title: '活动通知', value: false),
        _StaticSwitchEntry(title: '系统通知', value: true),
      ],
    );
  }
}

class DialectSettingsScreen extends StatelessWidget {
  const DialectSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const options = ['普通话', '四川话', '粤语', '东北话', '上海话'];
    return _SimpleSubPage(
      title: '方言设置',
      children: [
        const _HintHero(
          title: '选择更像你的说话方式',
          subtitle: '熟悉一点，表达就会更自然。',
        ),
        const SizedBox(height: 18),
        SoftCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: List.generate(options.length, (index) {
              final item = options[index];
              return SoftListTile(
                leading: SoftIconBadge(
                  icon: Icons.record_voice_over_rounded,
                  colors: item == '普通话'
                      ? const [Color(0xFFFFE3D6), Color(0xFFFF9367)]
                      : const [Color(0xFFF4EFFF), Color(0xFFC0ACFF)],
                ),
                title: item,
                trailing: item == '普通话'
                    ? const Icon(Icons.check_rounded, color: SoftColors.coral)
                    : const SizedBox.shrink(),
                showDivider: index != options.length - 1,
              );
            }),
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
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SoftPage(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
        child: Column(
          children: [
            SoftHeader(
              title: '帮助反馈',
              onBack: () => Navigator.of(context).pop(),
            ),
            const SizedBox(height: 22),
            SoftCard(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: Row(
                children: const [
                  Icon(Icons.search_rounded, color: Color(0xFF9AA0A8), size: 28),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '搜索帮助内容',
                      style: TextStyle(
                        fontSize: 16,
                        color: SoftColors.subtext,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.favorite_rounded,
                    color: Color(0xFFFF9AA6),
                    size: 34,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            SoftCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _SettingsEntry(
                    icon: Icons.help_rounded,
                    colors: const [Color(0xFFFFE4D5), Color(0xFFFF9A61)],
                    title: '常见问题',
                    subtitle: '解答你最关心的问题',
                    onTap: () {},
                  ),
                  _SettingsEntry(
                    icon: Icons.menu_book_rounded,
                    colors: const [Color(0xFFE7DFFF), Color(0xFF9D80FF)],
                    title: '使用教程',
                    subtitle: '快速上手，轻松使用',
                    onTap: () {},
                  ),
                  _SettingsEntry(
                    icon: Icons.edit_note_rounded,
                    colors: const [Color(0xFFDDF6E5), Color(0xFF53C878)],
                    title: '问题反馈',
                    subtitle: '告诉我们你遇到的问题',
                    onTap: () {},
                  ),
                  _SettingsEntry(
                    icon: Icons.headset_mic_rounded,
                    colors: const [Color(0xFFDCEBFF), Color(0xFF65A4FF)],
                    title: '联系客服',
                    subtitle: '专业客服为你服务',
                    showDivider: false,
                    onTap: () =>
                        Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const ContactCustomerServiceScreen(),
                    )),
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
                    '填写你的问题',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: SoftColors.text,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '请尽可能详细描述问题，方便我们更快帮助你。',
                    style: TextStyle(
                      fontSize: 14,
                      color: SoftColors.subtext,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 180,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.74),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: const Color(0xFFF6E0D7)),
                    ),
                    child: TextField(
                      controller: _controller,
                      maxLength: 500,
                      maxLines: null,
                      expands: true,
                      decoration: const InputDecoration(
                        hintText: '请输入你的问题描述...',
                        hintStyle: TextStyle(color: Color(0xFFC1C5CC)),
                        border: InputBorder.none,
                        counterText: '',
                        contentPadding: EdgeInsets.all(18),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: const Color(0xFFF2DED6)),
                      color: Colors.white.withValues(alpha: 0.72),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.photo_camera_outlined,
                          size: 34,
                          color: SoftColors.text,
                        ),
                        SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '上传截图（选填）',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: SoftColors.text,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                '最多上传 3 张图片，支持 JPG、PNG 格式',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: SoftColors.subtext,
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
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: SoftGradientButton(
                text: '提交反馈',
                height: 60,
                onTap: _showSubmitSuccess,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showSubmitSuccess() async {
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.32),
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 34),
          child: Stack(
            children: [
              SoftCard(
                radius: 30,
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 34,
                          color: Color(0xFF7F8590),
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.favorite_rounded,
                      color: Color(0xFFFF9AA1),
                      size: 120,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '反馈已提交',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: SoftColors.text,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      '我们已收到你的问题，会尽快与你联系',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.6,
                        color: SoftColors.subtext,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: SoftOutlineButton(
                        text: '继续浏览',
                        onTap: () => Navigator.of(context).pop(),
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: SoftGradientButton(
                        text: '完成',
                        onTap: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ContactCustomerServiceScreen extends StatelessWidget {
  const ContactCustomerServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SoftPage(
      child: SingleChildScrollView(
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
                children: const [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '我们会尽快帮助你',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: SoftColors.text,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          '你的每一次倾诉，我们都认真对待',
                          style: TextStyle(
                            fontSize: 16,
                            color: SoftColors.subtext,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
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
                children: const [
                  _LineEntry(
                    icon: Icons.chat_bubble_rounded,
                    colors: [Color(0xFFFFE4D5), Color(0xFFFF9860)],
                    title: '在线客服',
                    subtitle: '实时对话，快速解决你的问题',
                    valueWidget: SoftTag(
                      text: '● 在线',
                      color: SoftColors.green,
                      background: Color(0x1426C66F),
                    ),
                  ),
                  _LineEntry(
                    icon: Icons.mail_rounded,
                    colors: [Color(0xFFE7DFFF), Color(0xFF947BFF)],
                    title: '邮件联系',
                    subtitle: '详细描述问题，我们会尽快回复',
                  ),
                  _LineEntry(
                    icon: Icons.groups_rounded,
                    colors: [Color(0xFFDDF7E6), Color(0xFF54C978)],
                    title: '用户社群',
                    subtitle: '加入社群，分享与互助',
                  ),
                  _LineEntry(
                    icon: Icons.schedule_rounded,
                    colors: [Color(0xFFDCEBFF), Color(0xFF5EA8FF)],
                    title: '服务时间',
                    subtitle: '周一至周日 09:00 - 21:00',
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
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: SoftColors.text,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  const _ChatBubbleRow(
                    left: true,
                    text: '你好呀，我是小心管家，很高兴为你服务！',
                  ),
                  const _ChatBubbleRow(
                    left: false,
                    text: '我想咨询一下情绪记录的问题。',
                  ),
                  const _ChatBubbleRow(
                    left: true,
                    text: '没问题呢，请告诉我你遇到的具体情况，我会尽力帮助你～',
                  ),
                  Container(
                    margin: const EdgeInsets.fromLTRB(18, 10, 18, 18),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.84),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFF2E1D8)),
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            '请输入问题...',
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
                              colors: [SoftColors.coral, SoftColors.orange],
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
      children: [
        const _HintHero(
          title: 'Emo Outlet',
          subtitle: '一个更温柔地安放情绪、整理关系与记录自己的地方。',
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
                    builder: (_) => const TermsOfServiceScreen(),
                  ),
                ),
              ),
              _SettingsEntry(
                icon: Icons.privacy_tip_rounded,
                colors: const [Color(0xFFE6DFFF), Color(0xFF9D80FF)],
                title: '隐私政策',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const PrivacyPolicyScreen(),
                  ),
                ),
              ),
              const _SettingsEntry(
                icon: Icons.chat_rounded,
                colors: [Color(0xFFDDF7E5), Color(0xFF5ACA7A)],
                title: '联系我们',
              ),
              const _SettingsEntry(
                icon: Icons.system_update_rounded,
                colors: [Color(0xFFDDEBFF), Color(0xFF67A9FF)],
                title: '检查更新',
                subtitle: '当前版本 1.0.0',
                showDivider: false,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SimpleSubPage extends StatelessWidget {
  const _SimpleSubPage({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

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
            ...children,
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
                    fontSize: 22,
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
    this.valueWidget,
    this.showDivider = true,
  });

  final IconData icon;
  final List<Color> colors;
  final String title;
  final String? subtitle;
  final String? value;
  final Widget? valueWidget;
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
          if (valueWidget != null)
            valueWidget!
          else if (value != null)
            Text(
              value!,
              style: const TextStyle(
                fontSize: 16,
                color: SoftColors.subtext,
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

class _StaticSwitchEntry extends StatelessWidget {
  const _StaticSwitchEntry({
    required this.title,
    required this.value,
  });

  final String title;
  final bool value;

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
              onChanged: (_) {},
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
