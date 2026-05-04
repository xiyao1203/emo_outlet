import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../widgets/auth/auth_visuals.dart';
import 'login_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  void _openLogin(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
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
              final compact = height < 760;
              final horizontal = math.min(width * 0.07, 32.0);

              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  horizontal,
                  12,
                  horizontal,
                  math.max(20, height * 0.02),
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: height - 12),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: compact ? 12 : 28),
                        AppBrand(
                          fontSize: width < 380 ? 24 : 28,
                          logoSize: width < 380 ? 42 : 48,
                          spacing: 12,
                        ),
                        SizedBox(height: compact ? 34 : 56),
                        Text(
                          '把不舒服的情绪，',
                          style: TextStyle(
                            fontSize: width < 380 ? 34 : 42,
                            height: 1.12,
                            fontWeight: FontWeight.w800,
                            color: AuthPalette.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                '轻轻放出来',
                                style: TextStyle(
                                  fontSize: width < 380 ? 34 : 42,
                                  height: 1.1,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFFFF6D4C),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                top: width < 380 ? 2 : 4,
                                left: 6,
                              ),
                              child: Transform.rotate(
                                angle: -0.35,
                                child: const Text(
                                  '⌞',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFFF9E8A),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: compact ? 18 : 22),
                        Text(
                          '安全表达、即时疏解、专属你的情绪出口',
                          style: TextStyle(
                            fontSize: width < 380 ? 16 : 18,
                            height: 1.5,
                            color: AuthPalette.textSecondary,
                          ),
                        ),
                        SizedBox(height: compact ? 18 : 30),
                        const Expanded(
                          child: Center(
                            child: HeroCloudIllustration(),
                          ),
                        ),
                        SizedBox(height: compact ? 14 : 24),
                        GradientPrimaryButton(
                          text: '开始释放',
                          height: width < 380 ? 60 : 66,
                          fontSize: width < 380 ? 24 : 28,
                          onTap: () => _openLogin(context),
                        ),
                        const SizedBox(height: 16),
                        OutlineSoftButton(
                          text: '已有账号，去登录',
                          height: width < 380 ? 56 : 60,
                          trailing: const Icon(
                            Icons.chevron_right_rounded,
                            color: Color(0xFFDD655B),
                            size: 22,
                          ),
                          onTap: () => _openLogin(context),
                        ),
                        SizedBox(height: compact ? 18 : 26),
                        SupportExpressionRow(fontSize: width < 380 ? 14 : 16),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
