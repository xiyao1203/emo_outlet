import 'dart:async';
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
  String? _tipMessage;
  Timer? _tipTimer;

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
    _tipTimer?.cancel();
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_phoneController.text.trim().isEmpty) {
      _showTip('\u8bf7\u8f93\u5165\u624b\u673a\u53f7');
      return;
    }
    if (_codeController.text.trim().isEmpty) {
      _showTip('\u8bf7\u8f93\u5165\u9a8c\u8bc1\u7801');
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
        _showTip(
            '\u767b\u5f55\u5931\u8d25\uff0c\u8bf7\u68c0\u67e5\u624b\u673a\u53f7\u548c\u9a8c\u8bc1\u7801');
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
      await _authService.visitorLogin('\u6e38\u5ba2\u7528\u6237');
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
      _showTip('\u8bf7\u5148\u8f93\u5165\u624b\u673a\u53f7');
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Text('\u670d\u52a1\u534f\u8bae\u786e\u8ba4'),
        content: const Text(
          '\u7ee7\u7eed\u4f7f\u7528\u524d\uff0c\u8bf7\u9605\u8bfb\u5e76\u540c\u610f\u300a\u7528\u6237\u534f\u8bae\u300b\u548c\u300a\u9690\u79c1\u653f\u7b56\u300b\u3002',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('\u53d6\u6d88'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('\u540c\u610f'),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Text('\u5e74\u9f84\u786e\u8ba4'),
        content: const Text(
            '\u8bf7\u786e\u8ba4\u60a8\u7684\u5e74\u9f84\u6bb5\u3002'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop('<14'),
            child: const Text('14\u5c81\u4ee5\u4e0b'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop('14-18'),
            child: const Text('14-18\u5c81'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop('>18'),
            child: const Text('18\u5c81\u4ee5\u4e0a'),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Text('\u76d1\u62a4\u4eba\u540c\u610f'),
        content: const Text(
          '\u6839\u636e\u672a\u6210\u5e74\u4eba\u4fdd\u62a4\u76f8\u5173\u8981\u6c42\uff0c14\u5c81\u4ee5\u4e0b\u7528\u6237\u9700\u5728\u76d1\u62a4\u4eba\u540c\u610f\u540e\u65b9\u53ef\u7ee7\u7eed\u4f7f\u7528\u3002\n\n\u8bf7\u786e\u8ba4\u4f60\u7684\u76d1\u62a4\u4eba\u5df2\u540c\u610f\u4f60\u4f7f\u7528\u672c\u5e94\u7528\u3002',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('\u6682\u672a\u83b7\u5f97\u540c\u610f'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('\u76d1\u62a4\u4eba\u5df2\u540c\u610f'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _showTip(String msg) {
    _tipTimer?.cancel();
    setState(() => _tipMessage = msg);
    _tipTimer = Timer(const Duration(milliseconds: 2400), () {
      if (!mounted) return;
      setState(() => _tipMessage = null);
    });
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
              final horizontal = math.min(width * 0.06, 26.0);
              final compact = height < 820;

              return Stack(
                children: [
                  SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      horizontal,
                      6,
                      horizontal,
                      math.max(22, height * 0.024),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _LoginNavBar(
                          width: width,
                          onBack: _goBack,
                        ),
                        SizedBox(height: compact ? 12 : 18),
                        _LoginHero(
                          width: width,
                          compact: compact,
                        ),
                        SizedBox(height: compact ? 8 : 12),
                        _LoginCard(
                          phoneController: _phoneController,
                          codeController: _codeController,
                          isLoading: _isLoading,
                          countdown: _countdown,
                          tipMessage: _tipMessage,
                          onLogin: _handleLogin,
                          onRequestCode: _startCountdown,
                          hasAgreed: _hasAgreed,
                          onToggleAgreement: () {
                            setState(() => _hasAgreed = !_hasAgreed);
                          },
                          onVisitorLogin: _handleVisitorLogin,
                        ),
                        SizedBox(height: compact ? 16 : 20),
                        SupportExpressionRow(fontSize: width < 380 ? 13 : 14),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _LoginNavBar extends StatelessWidget {
  const _LoginNavBar({
    required this.width,
    required this.onBack,
  });

  final double width;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: width < 380 ? 38 : 42,
          height: width < 380 ? 38 : 42,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.58),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.white.withValues(alpha: 0.72)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x12D9A695),
                blurRadius: 18,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: IconButton(
            onPressed: onBack,
            padding: EdgeInsets.zero,
            splashRadius: 20,
            icon: const Icon(
              Icons.chevron_left_rounded,
              size: 27,
              color: AuthPalette.textPrimary,
            ),
          ),
        ),
        const SizedBox(width: 12),
        AppBrand(
          fontSize: width < 380 ? 21 : 24,
          logoSize: width < 380 ? 36 : 40,
          spacing: 8,
        ),
      ],
    );
  }
}

class _LoginHero extends StatelessWidget {
  const _LoginHero({
    required this.width,
    required this.compact,
  });

  final double width;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: width < 380 ? 154 : 170,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -width * 0.14,
            top: 14,
            child: _DecorativeGlow(
              width: width * 0.56,
              height: width * 0.62,
              colors: const [Color(0x22FFC6BE), Color(0x00FFC6BE)],
            ),
          ),
          Positioned(
            left: -28,
            bottom: 8,
            child: _DecorativeGlow(
              width: width * 0.34,
              height: width * 0.24,
              colors: const [Color(0x18FFBBB2), Color(0x00FFBBB2)],
            ),
          ),
          Positioned.fill(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 11,
                  child: Padding(
                    padding: EdgeInsets.only(top: compact ? 34 : 40),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '\u6b22\u8fce\u56de\u6765',
                              style: TextStyle(
                                fontSize: 27,
                                fontWeight: FontWeight.w800,
                                height: 1.02,
                                color: AuthPalette.textPrimary,
                                letterSpacing: -0.8,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 4, top: 6),
                              child: _HeroAccentSpark(),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          '\u7528\u66f4\u8f7b\u677e\u7684\u65b9\u5f0f\uff0c\u628a\u60c5\u7eea\u8bf4\u51fa\u6765',
                          maxLines: 1,
                          overflow: TextOverflow.visible,
                          style: TextStyle(
                            fontSize: 13.5,
                            color: AuthPalette.textSecondary,
                            height: 1.2,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(flex: 5),
              ],
            ),
          ),
          Positioned(
            right: 2,
            top: compact ? 8 : 8,
            child: SizedBox(
              width: width < 380 ? 132 : 148,
              child: LoginCloudIllustration(
                size: width < 380 ? 132 : 148,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DecorativeGlow extends StatelessWidget {
  const _DecorativeGlow({
    required this.width,
    required this.height,
    required this.colors,
  });

  final double width;
  final double height;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(width),
          gradient: RadialGradient(colors: colors),
        ),
      ),
    );
  }
}

class _HeroAccentSpark extends StatelessWidget {
  const _HeroAccentSpark();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 24,
      height: 24,
      child: CustomPaint(
        painter: _HeroAccentSparkPainter(),
      ),
    );
  }
}

class _HeroAccentSparkPainter extends CustomPainter {
  const _HeroAccentSparkPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFF8E7D)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(size.width * 0.26, size.height * 0.2),
      Offset(size.width * 0.12, size.height * 0.5),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.76, size.height * 0.08),
      Offset(size.width * 0.56, size.height * 0.32),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.88, size.height * 0.54),
      Offset(size.width * 0.58, size.height * 0.52),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LoginCard extends StatelessWidget {
  const _LoginCard({
    required this.phoneController,
    required this.codeController,
    required this.isLoading,
    required this.countdown,
    required this.tipMessage,
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
  final String? tipMessage;
  final VoidCallback onLogin;
  final VoidCallback onRequestCode;
  final bool hasAgreed;
  final VoidCallback onToggleAgreement;
  final VoidCallback onVisitorLogin;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 22),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.44),
        borderRadius: BorderRadius.circular(34),
        border: Border.all(color: Colors.white.withValues(alpha: 0.82)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12DFAE9D),
            blurRadius: 34,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '\u624b\u673a\u53f7\u767b\u5f55 / \u6ce8\u518c',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF756964),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _InputShell(
            child: TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              style: const TextStyle(
                fontSize: 17,
                color: AuthPalette.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              decoration: _fieldDecoration(
                icon: Icons.smartphone_rounded,
                hint: '\u624b\u673a\u53f7',
              ),
            ),
          ),
          const SizedBox(height: 12),
          _InputShell(
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: codeController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    style: const TextStyle(
                      fontSize: 17,
                      color: AuthPalette.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: _fieldDecoration(
                      icon: Icons.verified_user_outlined,
                      hint: '\u9a8c\u8bc1\u7801',
                      counterText: '',
                    ),
                  ),
                ),
                Container(
                  width: 1,
                  height: 28,
                  margin: const EdgeInsets.only(right: 12),
                  color: const Color(0xFFEDE0DB),
                ),
                _CodeActionChip(
                  text: countdown > 0
                      ? '${countdown}s'
                      : '\u83b7\u53d6\u9a8c\u8bc1\u7801',
                  disabled: countdown > 0,
                  onTap: onRequestCode,
                ),
                const SizedBox(width: 6),
              ],
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            child: tipMessage == null
                ? const SizedBox(height: 10)
                : Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 2),
                    child: _InlineTip(message: tipMessage!),
                  ),
          ),
          const SizedBox(height: 14),
          _CupertinoPrimaryButton(
            text: '\u7acb\u5373\u767b\u5f55',
            loading: isLoading,
            onTap: isLoading ? null : onLogin,
          ),
          const SizedBox(height: 26),
          const Row(
            children: [
              Expanded(child: Divider(color: Color(0xFFE8DCD6), thickness: 1)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '\u5feb\u6377\u767b\u5f55',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF8A7E79),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(child: Divider(color: Color(0xFFE8DCD6), thickness: 1)),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _IosLoginOption(
                label: '\u5fae\u4fe1',
                icon: const SocialIconWeChat(),
                onTap: onVisitorLogin,
              ),
              _IosLoginOption(
                label: 'QQ',
                icon: const SocialIconQQ(),
                onTap: onVisitorLogin,
              ),
              _IosLoginOption(
                label: '\u6e38\u5ba2\u4f53\u9a8c',
                icon: const SocialIconGuest(),
                onTap: onVisitorLogin,
              ),
            ],
          ),
          const SizedBox(height: 20),
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
                  size: 21,
                  color: hasAgreed
                      ? const Color(0xFFFF876D)
                      : const Color(0xFFD6C6BE),
                ),
              ),
              const Text(
                '\u767b\u5f55\u5373\u8868\u793a\u540c\u610f',
                style: TextStyle(
                  fontSize: 13.5,
                  color: Color(0xFF7C706C),
                  height: 1.35,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const TermsOfServiceScreen(),
                  ),
                ),
                child: const Text(
                  '\u300a\u7528\u6237\u534f\u8bae\u300b',
                  style: TextStyle(
                    fontSize: 13.5,
                    color: Color(0xFFFF6F5E),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Text(
                '\u4e0e',
                style: TextStyle(
                  fontSize: 13.5,
                  color: Color(0xFF7C706C),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const PrivacyPolicyScreen(),
                  ),
                ),
                child: const Text(
                  '\u300a\u9690\u79c1\u653f\u7b56\u300b',
                  style: TextStyle(
                    fontSize: 13.5,
                    color: Color(0xFFFF6F5E),
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
        color: Color(0xFFB2A6A0),
        fontWeight: FontWeight.w500,
      ),
      prefixIcon: Icon(
        icon,
        color: const Color(0xFFFF7A66),
        size: 22,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 19),
    );
  }
}

class _InlineTip extends StatelessWidget {
  const _InlineTip({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF2EC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFD7CA)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: 16,
            color: Color(0xFFFF7A66),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 13.5,
                height: 1.35,
                color: Color(0xFFB25E4E),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
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
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white, width: 1.15),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0EE0B3A2),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _CodeActionChip extends StatelessWidget {
  const _CodeActionChip({
    required this.text,
    required this.disabled,
    required this.onTap,
  });

  final String text;
  final bool disabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: disabled ? null : onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: disabled ? const Color(0xFFF7F1EE) : const Color(0xFFFFF1EC),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color:
                  disabled ? const Color(0xFFB8ABA5) : const Color(0xFFFF6A5D),
            ),
          ),
        ),
      ),
    );
  }
}

class _CupertinoPrimaryButton extends StatelessWidget {
  const _CupertinoPrimaryButton({
    required this.text,
    required this.onTap,
    this.loading = false,
  });

  final String text;
  final VoidCallback? onTap;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: loading ? null : onTap,
        child: Ink(
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFF1F1A17),
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Color(0x241F1A17),
                blurRadius: 18,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Center(
            child: loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      height: 1,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _IosLoginOption extends StatelessWidget {
  const _IosLoginOption({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final Widget icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withValues(alpha: 0.9),
                  Colors.white.withValues(alpha: 0.55),
                ],
              ),
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.9), width: 1.4),
              boxShadow: [
                const BoxShadow(
                  color: Color(0x14DDA999),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.46),
                  blurRadius: 0,
                  spreadRadius: -1,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: Center(
              child: Transform.scale(
                scale: 0.96,
                child: icon,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14.5,
              color: Color(0xFF5E5450),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
