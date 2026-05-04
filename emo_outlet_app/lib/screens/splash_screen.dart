import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../widgets/auth/auth_visuals.dart';
import 'login_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  static const _headlineTop =
      '\u628a\u4e0d\u8212\u670d\u7684\u60c5\u7eea\uff0c';
  static const _headlineAccent = '\u8f7b\u8f7b\u653e\u51fa\u6765';
  static const _subtitle =
      '\u5b89\u5168\u8868\u8fbe\u3001\u5373\u65f6\u758f\u89e3\uff0c\u4e13\u5c5e\u4f60\u7684\u60c5\u7eea\u51fa\u53e3';
  static const _primaryCta = '\u5f00\u59cb\u91ca\u653e';
  static const _secondaryCta =
      '\u5df2\u6709\u8d26\u53f7\uff0c\u53bb\u767b\u5f55';

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
              final compact = height < 820;
              final horizontal = math.min(width * 0.073, 33.0);
              final brandFontSize = width < 380 ? 24.0 : 29.0;
              final brandLogoSize = width < 380 ? 44.0 : 50.0;
              final titleTopSize = width < 380 ? 36.0 : 46.0;
              final titleAccentSize = width < 380 ? 38.0 : 50.0;
              final subtitleSize = width < 380 ? 16.0 : 17.5;
              final primaryButtonHeight = width < 380 ? 60.0 : 68.0;
              final secondaryButtonHeight = width < 380 ? 56.0 : 61.0;
              final primaryButtonFontSize = width < 380 ? 25.0 : 29.0;
              final secondaryButtonFontSize = width < 380 ? 16.0 : 17.0;

              return Stack(
                children: [
                  Positioned(
                    left: -width * 0.34,
                    bottom: height * 0.2,
                    child: _DecorativeOrb(
                      size: width * 0.56,
                      colors: const [Color(0x26FFB7A9), Color(0x00FFB7A9)],
                    ),
                  ),
                  Positioned(
                    right: -width * 0.43,
                    top: height * 0.18,
                    child: _DecorativeOrb(
                      size: width * 0.96,
                      colors: const [Color(0x22FFC9C2), Color(0x00FFC9C2)],
                    ),
                  ),
                  SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      horizontal,
                      compact ? 14 : 16,
                      horizontal,
                      math.max(20, height * 0.026),
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: height - 18),
                      child: IntrinsicHeight(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: compact ? 12 : 18),
                            AppBrand(
                              fontSize: brandFontSize,
                              logoSize: brandLogoSize,
                              spacing: 14,
                            ),
                            SizedBox(height: compact ? 48 : 66),
                            Text(
                              _headlineTop,
                              style: TextStyle(
                                fontSize: titleTopSize,
                                height: 1.08,
                                fontWeight: FontWeight.w800,
                                color: AuthPalette.textPrimary,
                                letterSpacing: -1.2,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: ShaderMask(
                                    shaderCallback: (bounds) =>
                                        const LinearGradient(
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                      colors: [
                                        Color(0xFFFF5A60),
                                        Color(0xFFFF8A47),
                                      ],
                                    ).createShader(bounds),
                                    child: Text(
                                      _headlineAccent,
                                      style: TextStyle(
                                        fontSize: titleAccentSize,
                                        height: 0.98,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                        letterSpacing: -1.5,
                                      ),
                                    ),
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(left: 6, top: 10),
                                  child: _AccentSpark(),
                                ),
                              ],
                            ),
                            SizedBox(height: compact ? 20 : 24),
                            Text(
                              _subtitle,
                              style: TextStyle(
                                fontSize: subtitleSize,
                                height: 1.42,
                                color: AuthPalette.textSecondary,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.1,
                              ),
                            ),
                            SizedBox(height: compact ? 26 : 38),
                            Expanded(
                              child: Center(
                                child: SizedBox(
                                  width: width * 0.92,
                                  child: const _HeroCloudImage(),
                                ),
                              ),
                            ),
                            SizedBox(height: compact ? 14 : 18),
                            GradientPrimaryButton(
                              text: _primaryCta,
                              height: primaryButtonHeight,
                              fontSize: primaryButtonFontSize,
                              onTap: () => _openLogin(context),
                            ),
                            const SizedBox(height: 16),
                            OutlineSoftButton(
                              text: _secondaryCta,
                              height: secondaryButtonHeight,
                              fontSize: secondaryButtonFontSize,
                              trailing: const Icon(
                                Icons.chevron_right_rounded,
                                color: Color(0xFFDD655B),
                                size: 22,
                              ),
                              onTap: () => _openLogin(context),
                            ),
                            SizedBox(height: compact ? 22 : 30),
                            SupportExpressionRow(
                                fontSize: width < 380 ? 14 : 16),
                          ],
                        ),
                      ),
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

class _DecorativeOrb extends StatelessWidget {
  const _DecorativeOrb({
    required this.size,
    required this.colors,
  });

  final double size;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: colors),
        ),
      ),
    );
  }
}

class _AccentSpark extends StatelessWidget {
  const _AccentSpark();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 30,
      height: 30,
      child: CustomPaint(
        painter: _AccentSparkPainter(),
      ),
    );
  }
}

class _AccentSparkPainter extends CustomPainter {
  const _AccentSparkPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFA08F)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(size.width * 0.5, 0),
      Offset(size.width * 0.36, size.height * 0.32),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.8, size.height * 0.28),
      Offset(size.width * 0.54, size.height * 0.4),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.76, size.height * 0.72),
      Offset(size.width * 0.46, size.height * 0.62),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _HeroCloudImage extends StatelessWidget {
  const _HeroCloudImage();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.02,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Positioned(
            left: -8,
            right: -8,
            bottom: -6,
            child: Image.asset(
              'assets/images/splash_base_glow.png',
              fit: BoxFit.contain,
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 54, 22, 106),
              child: Image.asset(
                'assets/images/splash_cloud_hero.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 4, 10),
              child: IgnorePointer(
                child: Image.asset(
                  'assets/images/splash_floating_overlay.png',
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
