import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/constants.dart';
import '../services/auth_service.dart';
import '../widgets/auth/auth_visuals.dart';
import 'home_screen.dart';
import 'privacy_policy_screen.dart';
import 'splash_screen.dart';
import 'terms_of_service_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;
  bool _hasAgreed = true;
  String? _ageRange;
  int _countdown = 0;

  @override
  void initState() {
    super.initState();
    _loadConsentState();
  }

  Future<void> _loadConsentState() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _hasAgreed = prefs.getBool(AppConstants.complianceAgreedKey) ?? false;
      _ageRange = prefs.getString(AppConstants.ageRangeKey);
    });
  }

  Future<void> _saveConsentState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.complianceAgreedKey, true);
  }

  Future<void> _saveAgeRange(String range) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.ageRangeKey, range);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_phoneController.text.trim().isEmpty) {
      _showTip('请输入手机号');
      return;
    }
    if (_codeController.text.trim().isEmpty) {
      _showTip('请输入验证码');
      return;
    }

    if (!_hasAgreed) {
      final agreed = await _showComplianceDialog();
      if (!agreed) return;
      await _saveConsentState();
      if (mounted) setState(() => _hasAgreed = true);
    }

    if (_ageRange == null) {
      final range = await _showAgeVerificationDialog();
      if (range == null) return;
      _ageRange = range;
      await _saveAgeRange(range);
    }

    if (rangeUnder14()) {
      final parentalConfirm = await _showParentalConsentDialog();
      if (!parentalConfirm) return;
    }

    setState(() => _isLoading = true);
    try {
      await _authService.login(
        _phoneController.text.trim(),
        _codeController.text.trim(),
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (_) {
      if (mounted) {
        _showTip('登录失败，请检查手机号和验证码');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleVisitorLogin() async {
    if (!_hasAgreed) {
      final agreed = await _showComplianceDialog();
      if (!agreed) return;
      await _saveConsentState();
      if (mounted) setState(() => _hasAgreed = true);
    }

    if (_ageRange == null) {
      final range = await _showAgeVerificationDialog();
      if (range == null) return;
      _ageRange = range;
      await _saveAgeRange(range);
    }

    if (rangeUnder14()) {
      final parentalConfirm = await _showParentalConsentDialog();
      if (!parentalConfirm) return;
    }

    setState(() => _isLoading = true);
    try {
      await _authService.visitorLogin('游客用户');
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _startCountdown() {
    if (_countdown > 0) return;
    if (_phoneController.text.trim().isEmpty) {
      _showTip('请先输入手机号');
      return;
    }

    setState(() => _countdown = 60);
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() {
        if (_countdown > 0) _countdown--;
      });
      return _countdown > 0;
    });
  }

  bool rangeUnder14() => _ageRange == '<14';

  Future<bool> _showComplianceDialog() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('服务协议确认'),
        content: const Text('继续使用前，请阅读并同意《用户协议》和《隐私政策》。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('同意'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<String?> _showAgeVerificationDialog() async {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('年龄确认'),
        content: const Text('请确认您的年龄段。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop('<14'),
            child: const Text('14岁以下'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop('14-18'),
            child: const Text('14-18岁'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop('>18'),
            child: const Text('18岁以上'),
          ),
        ],
      ),
    );
  }

  Future<bool> _showParentalConsentDialog() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('监护人同意'),
        content: const Text(
          '根据未成年人保护相关要求，14岁以下用户需在监护人同意后方可继续使用。'
          '\n\n请确认你的监护人已同意你使用本应用。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('暂未获得同意'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('监护人已同意'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _showTip(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _goBack() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const SplashScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final height = constraints.maxHeight;
              final horizontal = math.min(width * 0.07, 34.0);
              final compact = height < 820;

              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  horizontal,
                  10,
                  horizontal,
                  math.max(22, height * 0.02),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: _goBack,
                          iconSize: 38,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          style: IconButton.styleFrom(
                            foregroundColor: AuthPalette.textPrimary,
                          ),
                          icon: const Icon(Icons.chevron_left_rounded),
                        ),
                        const SizedBox(width: 12),
                        AppBrand(
                          fontSize: width < 380 ? 24 : 28,
                          logoSize: width < 380 ? 42 : 48,
                          spacing: 12,
                        ),
                      ],
                    ),
                    SizedBox(height: compact ? 22 : 34),
                    SizedBox(
                      height: width < 380 ? 190 : 220,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 30),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '欢迎回来',
                                    style: TextStyle(
                                      fontSize: width < 380 ? 34 : 40,
                                      fontWeight: FontWeight.w800,
                                      height: 1.12,
                                      color: AuthPalette.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    '用更轻松的方式，把情绪说出来',
                                    style: TextStyle(
                                      fontSize: width < 380 ? 18 : 20,
                                      color: AuthPalette.textSecondary,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          LoginCloudIllustration(
                            size:
                                width < 380 ? 170 : math.min(width * 0.43, 230),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: compact ? 12 : 20),
                    _LoginCard(
                      phoneController: _phoneController,
                      codeController: _codeController,
                      isLoading: _isLoading,
                      countdown: _countdown,
                      onLogin: _handleLogin,
                      onRequestCode: _startCountdown,
                      hasAgreed: _hasAgreed,
                      onToggleAgreement: () {
                        setState(() => _hasAgreed = !_hasAgreed);
                      },
                      onVisitorLogin: _handleVisitorLogin,
                    ),
                    SizedBox(height: compact ? 22 : 28),
                    SupportExpressionRow(fontSize: width < 380 ? 14 : 16),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _LoginCard extends StatelessWidget {
  const _LoginCard({
    required this.phoneController,
    required this.codeController,
    required this.isLoading,
    required this.countdown,
    required this.onLogin,
    required this.onRequestCode,
    required this.hasAgreed,
    required this.onToggleAgreement,
    required this.onVisitorLogin,
  });

  final TextEditingController phoneController;
  final TextEditingController codeController;
  final bool isLoading;
  final int countdown;
  final VoidCallback onLogin;
  final VoidCallback onRequestCode;
  final bool hasAgreed;
  final VoidCallback onToggleAgreement;
  final VoidCallback onVisitorLogin;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.26),
        borderRadius: BorderRadius.circular(36),
        border: Border.all(color: AuthPalette.cardBorder, width: 1.4),
        boxShadow: [
          BoxShadow(
            color: const Color(0x1CF0B8A5),
            blurRadius: 30,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        children: [
          _InputShell(
            child: TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              style: const TextStyle(
                fontSize: 16,
                color: AuthPalette.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              decoration: _fieldDecoration(
                icon: Icons.smartphone_rounded,
                hint: '手机号',
              ),
            ),
          ),
          const SizedBox(height: 14),
          _InputShell(
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: codeController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AuthPalette.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: _fieldDecoration(
                      icon: Icons.verified_user_outlined,
                      hint: '验证码',
                      counterText: '',
                    ),
                  ),
                ),
                Container(
                  width: 1,
                  height: 30,
                  margin: const EdgeInsets.only(right: 14),
                  color: const Color(0xFFE8D6CF),
                ),
                InkWell(
                  onTap: countdown > 0 ? null : onRequestCode,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Text(
                      countdown > 0 ? '${countdown}s' : '获取验证码',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: countdown > 0
                            ? const Color(0xFFBBABA4)
                            : const Color(0xFFFF6C5B),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          GradientPrimaryButton(
            text: '手机号登录 / 注册',
            height: 68,
            fontSize: 20,
            loading: isLoading,
            onTap: isLoading ? null : onLogin,
          ),
          const SizedBox(height: 30),
          Row(
            children: [
              Expanded(
                  child: Container(height: 1, color: const Color(0xFFE5D5CE))),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 18),
                child: Text(
                  '快捷登录',
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF807470),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                  child: Container(height: 1, color: const Color(0xFFE5D5CE))),
            ],
          ),
          const SizedBox(height: 26),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SocialLoginBadge(
                label: '微信',
                icon: const SocialIconWeChat(),
                onTap: onVisitorLogin,
              ),
              SocialLoginBadge(
                label: 'QQ',
                icon: const SocialIconQQ(),
                onTap: onVisitorLogin,
              ),
              SocialLoginBadge(
                label: '游客体验',
                icon: const SocialIconGuest(),
                onTap: onVisitorLogin,
              ),
            ],
          ),
          const SizedBox(height: 28),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 4,
            runSpacing: 4,
            children: [
              GestureDetector(
                onTap: onToggleAgreement,
                child: Icon(
                  hasAgreed
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  size: 22,
                  color: hasAgreed
                      ? const Color(0xFFFF8C70)
                      : const Color(0xFFD7C4BC),
                ),
              ),
              const Text(
                '登录即表示同意',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF7A6E69),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => const TermsOfServiceScreen()),
                ),
                child: const Text(
                  '《用户协议》',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFFFF6C5B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Text(
                '与',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF7A6E69),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => const PrivacyPolicyScreen()),
                ),
                child: const Text(
                  '《隐私政策》',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFFFF6C5B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  InputDecoration _fieldDecoration({
    required IconData icon,
    required String hint,
    String? counterText,
  }) {
    return InputDecoration(
      border: InputBorder.none,
      isDense: true,
      counterText: counterText,
      hintText: hint,
      hintStyle: const TextStyle(
        fontSize: 16,
        color: Color(0xFFB5AAA4),
        fontWeight: FontWeight.w500,
      ),
      prefixIcon: Icon(icon, color: const Color(0xFFFF7565), size: 25),
      contentPadding: const EdgeInsets.symmetric(vertical: 22),
    );
  }
}

class _InputShell extends StatelessWidget {
  const _InputShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white, width: 1.4),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12EAB7A7),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}
