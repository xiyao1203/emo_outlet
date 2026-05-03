import 'package:flutter/material.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onEnter() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFFE5D9),
              Color(0xFFFFC6A5),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                children: [
                  const Spacer(flex: 3),
                  // 愤怒表情卡通人物
                  Container(
                    width: 160,
                    height: 160,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // 橙色外套
                        Positioned(
                          bottom: 8,
                          child: Container(
                            width: 100,
                            height: 60,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF7A56),
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                        // 愤怒表情
                        const Positioned(
                          top: 20,
                          child: Text(
                            '😤',
                            style: TextStyle(fontSize: 64),
                          ),
                        ),
                        // 紧握的拳头（左侧）
                        Positioned(
                          left: 8,
                          top: 60,
                          child: Transform.rotate(
                            angle: -0.3,
                            child: const Text('✊', style: TextStyle(fontSize: 28)),
                          ),
                        ),
                        // 紧握的拳头（右侧）
                        Positioned(
                          right: 8,
                          top: 60,
                          child: Transform.rotate(
                            angle: 0.3,
                            child: const Text('✊', style: TextStyle(fontSize: 28)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 36),
                  // App 名称
                  const Text(
                    '情绪出口',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF333333),
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // 副标题
                  const Text(
                    '把不舒畅的情绪说出来就好多了',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF999999),
                    ),
                  ),
                  const SizedBox(height: 40),
                  // 立即进入按钮
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _onEnter,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF7A56),
                          foregroundColor: Colors.white,
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text('立即进入'),
                      ),
                    ),
                  ),
                  const Spacer(flex: 3),
                  // 底部版权
                  const Text(
                    '© 2024 情绪释放 App',
                    style: TextStyle(
                      fontSize: 10,
                      color: Color(0xFF999999),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
