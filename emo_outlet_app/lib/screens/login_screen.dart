import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';

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
        // 注册模式：检测是否为邮箱
        final account = _accountController.text;
        final isEmail = account.contains('@');
        if (isEmail) {
          // 邮箱注册：调用 register 时 phone 传空，但实际上后端 register 需要 phone
          // 这里使用 login 方式处理邮箱注册，或通过 visitor + update
          _showTip('邮箱注册功能暂未开放，请使用手机号注册或登录');
          setState(() => _isLoading = false);
          return;
        }
        await _authService.register(
          account,
          _passwordController.text,
          _nicknameController.text.isNotEmpty ? _nicknameController.text : null,
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

              // 登录/注册按钮
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
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
