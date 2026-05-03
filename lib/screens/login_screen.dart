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
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLogin = true;
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);
    try {
      await _authService.login(
        _phoneController.text,
        _passwordController.text,
      );
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('登录失败：$e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleVisitorLogin() async {
    setState(() => _isLoading = true);
    try {
      await _authService.visitorLogin();
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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

              // 手机号输入
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  hintText: '手机号',
                  prefixIcon: Icon(Icons.phone_android_outlined),
                ),
              ),
              const SizedBox(height: 16),

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

              // 登录按钮
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
                      : const Text('登录 / 注册'),
                ),
              ),
              const SizedBox(height: 16),

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
