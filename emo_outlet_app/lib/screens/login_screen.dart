import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/theme.dart';
import '../config/constants.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';
import 'privacy_policy_screen.dart';
import 'terms_of_service_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _accountController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _authService = AuthService();
  bool _isLogin = true;
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _hasAgreed = false;
  String? _ageRange;

  @override
  void initState() {
    super.initState();
    _loadConsentState();
  }

  Future<void> _loadConsentState() async {
    final prefs = await SharedPreferences.getInstance();
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
    _accountController.dispose();
    _passwordController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_accountController.text.isEmpty) {
      _showTip('请输入手机号或邮箱');
      return;
    }
    if (_passwordController.text.isEmpty) {
      _showTip('请输入密码');
      return;
    }

    setState(() => _isLoading = true);
    try {
      if (_isLogin) {
        await _authService.login(
          _accountController.text,
          _passwordController.text,
        );
      } else {
        // 注册模式（手机号/邮箱均可）
        await _authService.register(
          _accountController.text,
          _passwordController.text,
          _nicknameController.text.isNotEmpty ? _nicknameController.text : null,
          consentVersion: AppConstants.complianceVersion,
          ageRange: _ageRange,
        );
      }
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        _showTip('登录失败，请检查账号密码');
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
      setState(() => _hasAgreed = true);
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
      await _authService.visitorLogin('访客用户');
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleRegisterWithConsent() async {
    if (!_hasAgreed) {
      _showTip('请先阅读并同意用户协议和隐私政策');
      return;
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

    await _handleLogin();
  }

  Future<bool> _showComplianceDialog() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('服务协议确认'),
        content: const Text(
          '继续使用前，请阅读并同意我们的《用户协议》和《隐私政策》。',
        ),
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
        content: const Text('请确认您的年龄段：'),
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

  bool rangeUnder14() => _ageRange == '<14';

  Future<bool> _showParentalConsentDialog() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('监护人同意'),
        content: const Text(
          '根据《未成年人保护法》和《个人信息保护法》，'
          '14岁以下用户需获得监护人同意后方可使用本服务。\n\n'
          '请确认你的监护人已同意你使用本应用。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('尚未获得同意'),
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

  Widget _buildConsentCheckbox() {
    return Row(
      children: [
        Checkbox(
          value: _hasAgreed,
          activeColor: AppColors.primary,
          onChanged: (v) => setState(() => _hasAgreed = v ?? false),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _hasAgreed = !_hasAgreed),
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                children: [
                  const TextSpan(text: '我已阅读并同意 '),
                  WidgetSpan(
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const TermsOfServiceScreen(),
                        ),
                      ),
                      child: const Text(
                        '《用户协议》',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.primary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                  const TextSpan(text: ' 和 '),
                  WidgetSpan(
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const PrivacyPolicyScreen(),
                        ),
                      ),
                      child: const Text(
                        '《隐私政策》',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.primary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showTip(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 60),
              // Logo 区域
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: AppColors.primaryGradient,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [AppColors.buttonShadow],
                ),
                child: const Center(
                  child: Text('😤', style: TextStyle(fontSize: 40)),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '情绪出口',
                style: AppTextStyles.displayMedium,
              ),
              const SizedBox(height: 8),
              const Text(
                '安全释放你的情绪',
                style: AppTextStyles.bodySmall,
              ),
              const SizedBox(height: 48),

              // 手机号/邮箱输入
              TextField(
                controller: _accountController,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  hintText: '手机号 / 邮箱',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 16),

              // 昵称（注册模式）
              if (!_isLogin) ...[
                TextField(
                  controller: _nicknameController,
                  decoration: const InputDecoration(
                    hintText: '昵称（可选）',
                    prefixIcon: Icon(Icons.face_outlined),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // 密码输入
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: '密码',
                  prefixIcon: const Icon(Icons.lock_outlined),
                  suffixIcon: IconButton(
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.textHint,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 同意协议 + 年龄验证
              if (!_isLogin) ...[                
                _buildConsentCheckbox(),
                const SizedBox(height: 8),
              ],

              // 登录/注册按钮
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          if (_isLogin) {
                            _handleLogin();
                          } else {
                            _handleRegisterWithConsent();
                          }
                        },
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(_isLogin ? '登录' : '注册'),
                ),
              ),
              const SizedBox(height: 12),

              // 切换登录/注册
              TextButton(
                onPressed: () => setState(() => _isLogin = !_isLogin),
                child: Text(
                  _isLogin ? '没有账号？点击注册' : '已有账号？去登录',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // 游客登录
              TextButton(
                onPressed: _isLoading ? null : _handleVisitorLogin,
                child: const Text(
                  '游客模式',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 15,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // 社交登录分割线
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      '社交账号登录',
                      style: TextStyle(
                        color: AppColors.textHint,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 24),

              // 社交登录按钮
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _socialButton(Icons.wechat_outlined, '微信'),
                  const SizedBox(width: 32),
                  _socialButton(Icons.apple, 'Apple'),
                  const SizedBox(width: 32),
                  _socialButton(Icons.alternate_email, '微博'),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _socialButton(IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.background,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border),
          ),
          child: IconButton(
            onPressed: () {},
            icon: Icon(icon, color: AppColors.textSecondary),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textHint)),
      ],
    );
  }
}
