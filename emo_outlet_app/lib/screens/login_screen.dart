import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  bool _showForm = false;

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

  void _showTip(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F5),
      body: SafeArea(
        child: _showForm ? _buildFormView() : _buildWelcomeView(),
      ),
    );
  }

  Widget _buildWelcomeView() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
          // 顶部区域：头像 + 欢迎语（左右布局）
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                // 左侧欢迎文字
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20),
                      Text(
                        'Hi, 小木阳 🌟',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF333333),
                        ),
                      ),
                    ],
                  ),
                ),
                // 右侧小人头像
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Positioned(
                        bottom: 4,
                        child: Text('🧣', style: TextStyle(fontSize: 20)),
                      ),
                      const Positioned(
                        top: 6,
                        child: Text('😠', style: TextStyle(fontSize: 36)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // 情绪提示语
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "今天你的…\n没好好？！",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF333333),
                  height: 1.6,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          // 主按钮
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () => setState(() => _showForm = true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF7A56),
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text('开始释放情绪'),
              ),
            ),
          ),
          const SizedBox(height: 32),
          // 第三方登录（4个，2行×2列）
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _socialIcon(Icons.wechat, '微信'),
                    _socialIcon(Icons.apple, 'Apple'),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _socialIcon(Icons.music_note, '抖音'),
                    _socialIcon(Icons.more_horiz, '其他'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // 已有账号链接
          TextButton(
            onPressed: () => setState(() => _showForm = true),
            child: const Text(
              '已有账号？登录 / 注册',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF6B5CE7),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _socialIcon(IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFEEEEEE)),
          ),
          child: IconButton(
            onPressed: _handleVisitorLogin,
            icon: Icon(icon, color: const Color(0xFF666666), size: 24),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF999999),
          ),
        ),
      ],
    );
  }

  Widget _buildFormView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // 返回按钮
          Row(
            children: [
              IconButton(
                onPressed: () => setState(() => _showForm = false),
                icon: const Icon(Icons.arrow_back_ios, size: 20),
              ),
              const Spacer(),
              const Text('9:41', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 8),
            ],
          ),
          const SizedBox(height: 32),
          // Logo 区域
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: Color(0xFFFF7A56),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('😤', style: TextStyle(fontSize: 40)),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            '情绪出口',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '安全释放你的情绪',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF999999),
            ),
          ),
          const SizedBox(height: 40),

          // 手机号/邮箱输入
          TextField(
            controller: _accountController,
            keyboardType: TextInputType.text,
            decoration: const InputDecoration(
              hintText: '手机号 / 邮箱',
              prefixIcon: Icon(Icons.person_outline),
              filled: true,
              fillColor: Color(0xFFF8F8F8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide(color: Color(0xFFEEEEEE)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide(color: Color(0xFFEEEEEE)),
              ),
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
                filled: true,
                fillColor: Color(0xFFF8F8F8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide(color: Color(0xFFEEEEEE)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide(color: Color(0xFFEEEEEE)),
                ),
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
                  color: const Color(0xFF999999),
                ),
              ),
              filled: true,
              fillColor: const Color(0xFFF8F8F8),
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide(color: Color(0xFFEEEEEE)),
              ),
              enabledBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide(color: Color(0xFFEEEEEE)),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 同意协议 + 年龄验证（注册模式）
          if (!_isLogin) ...[
            Row(
              children: [
                Checkbox(
                  value: _hasAgreed,
                  activeColor: const Color(0xFFFF7A56),
                  onChanged: (v) => setState(() => _hasAgreed = v ?? false),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _hasAgreed = !_hasAgreed),
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(fontSize: 13, color: Color(0xFF666666)),
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
                                  color: Color(0xFFFF7A56),
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
                                  color: Color(0xFFFF7A56),
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
            ),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF7A56),
                foregroundColor: Colors.white,
                textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 0,
              ),
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
                color: Color(0xFFFF7A56),
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
                color: Color(0xFF666666),
                fontSize: 15,
              ),
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
