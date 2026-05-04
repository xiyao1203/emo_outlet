import 'dart:math' as math;

import 'package:flutter/material.dart';

class AuthPalette {
  static const background = Color(0xFFFFF7F2);
  static const textPrimary = Color(0xFF1F1A17);
  static const textSecondary = Color(0xFF766B66);
  static const coral = Color(0xFFFF6A5F);
  static const orange = Color(0xFFFF8A3D);
  static const softBorder = Color(0xFFF3DDD4);
  static const cardBorder = Color(0xFFF8E8E1);
}

class AuthBackground extends StatelessWidget {
  const AuthBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AuthPalette.background,
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.92),
                    const Color(0xFFFFF2E9),
                    const Color(0xFFFFE7E3),
                  ],
                ),
              ),
            ),
          ),
          const Positioned(
            top: -90,
            left: -80,
            child: _BlurBlob(
              width: 240,
              height: 240,
              colors: [Color(0x33FFD3B8), Color(0x00FFD3B8)],
            ),
          ),
          const Positioned(
            top: 120,
            right: -120,
            child: _BlurBlob(
              width: 320,
              height: 500,
              colors: [Color(0x2EFFC5CF), Color(0x00FFC5CF)],
            ),
          ),
          const Positioned(
            bottom: -40,
            left: -70,
            child: _BlurBlob(
              width: 220,
              height: 220,
              colors: [Color(0x30FFCEC0), Color(0x00FFCEC0)],
            ),
          ),
          Positioned.fill(
            child: CustomPaint(
              painter: _LightStreakPainter(),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class AppBrand extends StatelessWidget {
  const AppBrand({
    super.key,
    this.fontSize = 28,
    this.logoSize = 48,
    this.spacing = 14,
  });

  final double fontSize;
  final double logoSize;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        BrandCloudLogo(size: logoSize),
        SizedBox(width: spacing),
        Text(
          '情绪释放',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
            color: AuthPalette.textPrimary,
            height: 1,
          ),
        ),
      ],
    );
  }
}

class BrandCloudLogo extends StatelessWidget {
  const BrandCloudLogo({super.key, this.size = 48});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _BrandCloudPainter(),
      ),
    );
  }
}

class SupportExpressionRow extends StatelessWidget {
  const SupportExpressionRow({super.key, this.fontSize = 16});

  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final iconSize = fontSize + 12;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: iconSize + 14,
          height: iconSize + 14,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.72),
            border: Border.all(color: Colors.white.withValues(alpha: 0.8)),
            boxShadow: [
              BoxShadow(
                color: const Color(0x14D18D7A),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Icon(Icons.mic_none_rounded,
              color: const Color(0xFF8B6B5B), size: iconSize),
        ),
        const SizedBox(width: 10),
        Text(
          '支持文字、语音、方言表达',
          style: TextStyle(
            fontSize: fontSize,
            color: const Color(0xFF705F56),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class HeroCloudIllustration extends StatelessWidget {
  const HeroCloudIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.05,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 0,
                right: 0,
                bottom: h * 0.06,
                child: SizedBox(
                  height: h * 0.32,
                  child: CustomPaint(painter: _StagePainter()),
                ),
              ),
              Positioned(
                left: w * 0.05,
                top: h * 0.2,
                child: _ChatBubble(
                  size: w * 0.19,
                  child: Icon(
                    Icons.gesture_rounded,
                    color: const Color(0xFFE57B5E),
                    size: w * 0.08,
                  ),
                ),
              ),
              Positioned(
                right: w * 0.06,
                top: h * 0.15,
                child: _ChatBubble(
                  size: w * 0.18,
                  child: Icon(
                    Icons.favorite_rounded,
                    color: const Color(0xFFFF866D),
                    size: w * 0.08,
                  ),
                ),
              ),
              Positioned(
                left: w * 0.75,
                top: h * 0.18,
                child: _FloatingHeart(size: w * 0.07),
              ),
              Positioned(
                right: w * 0.04,
                top: h * 0.55,
                child: _FloatingHeart(size: w * 0.06),
              ),
              Positioned(
                left: w * 0.12,
                bottom: h * 0.2,
                child: _GlowOrb(size: w * 0.04),
              ),
              Positioned(
                right: w * 0.11,
                bottom: h * 0.38,
                child: _GlowOrb(size: w * 0.025),
              ),
              Positioned(
                left: w * 0.16,
                right: w * 0.16,
                top: h * 0.22,
                bottom: h * 0.14,
                child: CustomPaint(
                  painter: _HeroCloudPainter(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class LoginCloudIllustration extends StatelessWidget {
  const LoginCloudIllustration({super.key, this.size = 220});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 0.88,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _MiniCloudPainter(),
            ),
          ),
          Positioned(
            top: size * 0.03,
            left: size * 0.08,
            child: _FloatingHeart(size: size * 0.12),
          ),
          Positioned(
            top: size * 0.12,
            right: size * 0.02,
            child: _FloatingHeart(size: size * 0.14),
          ),
          Positioned(
            left: size * 0.78,
            bottom: size * 0.12,
            child: _LeafDecoration(size: size * 0.18),
          ),
        ],
      ),
    );
  }
}

class GradientPrimaryButton extends StatelessWidget {
  const GradientPrimaryButton({
    super.key,
    required this.text,
    required this.onTap,
    this.height = 64,
    this.fontSize = 18,
    this.loading = false,
  });

  final String text;
  final VoidCallback? onTap;
  final double height;
  final double fontSize;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null && !loading;
    return Opacity(
      opacity: enabled || loading ? 1 : 0.7,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(height / 2),
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              AuthPalette.coral,
              Color(0xFFFF6B54),
              AuthPalette.orange,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0x40FF8D64),
              blurRadius: 30,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(height / 2),
            onTap: enabled ? onTap : null,
            child: Container(
              height: height,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(height / 2),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.9),
                  width: 2,
                ),
              ),
              child: loading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      text,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: fontSize,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class OutlineSoftButton extends StatelessWidget {
  const OutlineSoftButton({
    super.key,
    required this.text,
    required this.onTap,
    this.height = 56,
    this.trailing,
  });

  final String text;
  final VoidCallback onTap;
  final double height;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(height / 2),
        onTap: onTap,
        child: Ink(
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(height / 2),
            border: Border.all(color: const Color(0xFFDDBEB2)),
            color: Colors.white.withValues(alpha: 0.22),
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFDD655B),
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: 8),
                  trailing!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SocialLoginBadge extends StatelessWidget {
  const SocialLoginBadge({
    super.key,
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
      borderRadius: BorderRadius.circular(40),
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.65),
              border: Border.all(color: Colors.white, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: const Color(0x18E0B7A7),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Center(child: icon),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF645A56),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class SocialIconWeChat extends StatelessWidget {
  const SocialIconWeChat({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 42,
      height: 42,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            bottom: 6,
            child: _BubbleCircle(
              size: 24,
              color: const Color(0xFF21C45A),
            ),
          ),
          Positioned(
            right: 0,
            top: 4,
            child: _BubbleCircle(
              size: 22,
              color: const Color(0xFF39D26A),
            ),
          ),
        ],
      ),
    );
  }
}

class SocialIconQQ extends StatelessWidget {
  const SocialIconQQ({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Q',
      style: TextStyle(
        fontSize: 40,
        height: 1,
        color: Color(0xFF3D95FF),
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class SocialIconGuest extends StatelessWidget {
  const SocialIconGuest({super.key});

  @override
  Widget build(BuildContext context) {
    return const Icon(
      Icons.person_rounded,
      size: 38,
      color: Color(0xFFF2A43D),
    );
  }
}

class _BubbleCircle extends StatelessWidget {
  const _BubbleCircle({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Stack(
        children: [
          Positioned(
            left: size * 0.24,
            top: size * 0.3,
            child: _Dot(size: size * 0.12),
          ),
          Positioned(
            right: size * 0.24,
            top: size * 0.3,
            child: _Dot(size: size * 0.12),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFFFD497),
        boxShadow: [
          BoxShadow(
            color: const Color(0x90FFE9B9),
            blurRadius: size * 2.4,
            spreadRadius: size * 0.4,
          ),
        ],
      ),
    );
  }
}

class _FloatingHeart extends StatelessWidget {
  const _FloatingHeart({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.favorite_rounded,
      size: size,
      color: const Color(0xFFFF8A7C),
      shadows: const [
        Shadow(
          color: Color(0x40FFFFFF),
          blurRadius: 18,
        ),
      ],
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.size, required this.child});

  final double size;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.42),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.9),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0x20FFD5C7),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Center(child: child),
          ),
          Positioned(
            bottom: -size * 0.08,
            left: size * 0.16,
            child: Transform.rotate(
              angle: 0.35,
              child: Container(
                width: size * 0.22,
                height: size * 0.16,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.42),
                  borderRadius: BorderRadius.circular(size * 0.08),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LeafDecoration extends StatelessWidget {
  const _LeafDecoration({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 1.2,
      child: CustomPaint(
        painter: _LeafPainter(),
      ),
    );
  }
}

class _BlurBlob extends StatelessWidget {
  const _BlurBlob({
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
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: colors),
        ),
      ),
    );
  }
}

class _LightStreakPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0x00FFFFFF), Color(0x42FFEBD5), Color(0x00FFFFFF)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path()
      ..moveTo(size.width * 0.15, 0)
      ..quadraticBezierTo(
        size.width * 0.35,
        size.height * 0.22,
        size.width * 0.44,
        size.height * 0.48,
      )
      ..quadraticBezierTo(
        size.width * 0.52,
        size.height * 0.7,
        size.width * 0.67,
        size.height,
      );

    canvas.drawPath(
      path.shift(const Offset(14, 0)),
      paint
        ..style = PaintingStyle.stroke
        ..strokeWidth = 56
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 48),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BrandCloudPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final outlinePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
        colors: [Color(0xFFFF4F62), Color(0xFFFF8C4C)],
      ).createShader(Offset.zero & size)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.14
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    path.moveTo(size.width * 0.18, size.height * 0.64);
    path.cubicTo(
      size.width * 0.1,
      size.height * 0.64,
      size.width * 0.05,
      size.height * 0.57,
      size.width * 0.05,
      size.height * 0.48,
    );
    path.cubicTo(
      size.width * 0.05,
      size.height * 0.37,
      size.width * 0.14,
      size.height * 0.28,
      size.width * 0.26,
      size.height * 0.28,
    );
    path.cubicTo(
      size.width * 0.28,
      size.height * 0.15,
      size.width * 0.39,
      size.height * 0.06,
      size.width * 0.52,
      size.height * 0.06,
    );
    path.cubicTo(
      size.width * 0.67,
      size.height * 0.06,
      size.width * 0.79,
      size.height * 0.17,
      size.width * 0.81,
      size.height * 0.32,
    );
    path.cubicTo(
      size.width * 0.92,
      size.height * 0.35,
      size.width * 0.98,
      size.height * 0.44,
      size.width * 0.98,
      size.height * 0.55,
    );
    path.cubicTo(
      size.width * 0.98,
      size.height * 0.68,
      size.width * 0.87,
      size.height * 0.78,
      size.width * 0.73,
      size.height * 0.78,
    );
    path.lineTo(size.width * 0.38, size.height * 0.78);
    path.cubicTo(
      size.width * 0.33,
      size.height * 0.86,
      size.width * 0.24,
      size.height * 0.89,
      size.width * 0.15,
      size.height * 0.85,
    );
    path.cubicTo(
      size.width * 0.2,
      size.height * 0.83,
      size.width * 0.25,
      size.height * 0.78,
      size.width * 0.29,
      size.height * 0.71,
    );

    canvas.drawPath(path, outlinePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _StagePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final basePaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFFFFF6EF), Color(0xFFFFD6CD)],
      ).createShader(Offset.zero & size);

    final topRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height * 0.77),
      width: size.width * 0.72,
      height: size.height * 0.16,
    );
    canvas.drawOval(topRect, basePaint);

    final ringRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height * 0.77),
      width: size.width * 0.8,
      height: size.height * 0.24,
    );
    canvas.drawOval(
      ringRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..shader = const LinearGradient(
          colors: [Color(0x40FFFFFF), Color(0xB0FFF5EE), Color(0x10FFFFFF)],
        ).createShader(ringRect),
    );

    final outerGlow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..shader = const SweepGradient(
        colors: [
          Color(0x00FFFFFF),
          Color(0xCCFFF7ED),
          Color(0x50FFD9B1),
          Color(0x00FFFFFF),
        ],
      ).createShader(ringRect)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    final loopPath = Path()
      ..addArc(
        Rect.fromCenter(
          center: Offset(size.width / 2, size.height * 0.57),
          width: size.width * 0.84,
          height: size.height * 0.5,
        ),
        math.pi * 0.82,
        math.pi * 1.46,
      );
    canvas.drawPath(loopPath, outerGlow);

    final lowerBase = Rect.fromCenter(
      center: Offset(size.width / 2, size.height * 0.92),
      width: size.width * 0.42,
      height: size.height * 0.08,
    );
    canvas.drawOval(
      lowerBase,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFFFFE7E0), Color(0xFFFED0C4)],
        ).createShader(lowerBase),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _HeroCloudPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cloudPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.18, -0.22),
        radius: 0.95,
        colors: [
          Colors.white.withValues(alpha: 0.98),
          const Color(0xFFFFD6CC),
          const Color(0xFFFFC4B8),
        ],
      ).createShader(Offset.zero & size);

    final shadowPaint = Paint()
      ..color = const Color(0x24FF9F8B)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28);
    canvas.drawOval(
      Rect.fromLTWH(
        size.width * 0.12,
        size.height * 0.68,
        size.width * 0.76,
        size.height * 0.17,
      ),
      shadowPaint,
    );

    final path = Path()
      ..moveTo(size.width * 0.18, size.height * 0.58)
      ..cubicTo(
        size.width * 0.08,
        size.height * 0.6,
        size.width * 0.03,
        size.height * 0.52,
        size.width * 0.03,
        size.height * 0.42,
      )
      ..cubicTo(
        size.width * 0.03,
        size.height * 0.3,
        size.width * 0.11,
        size.height * 0.22,
        size.width * 0.22,
        size.height * 0.22,
      )
      ..cubicTo(
        size.width * 0.26,
        size.height * 0.08,
        size.width * 0.38,
        size.height * 0.01,
        size.width * 0.5,
        size.height * 0.03,
      )
      ..cubicTo(
        size.width * 0.63,
        size.height * 0.02,
        size.width * 0.74,
        size.height * 0.12,
        size.width * 0.77,
        size.height * 0.24,
      )
      ..cubicTo(
        size.width * 0.89,
        size.height * 0.24,
        size.width * 0.97,
        size.height * 0.33,
        size.width * 0.97,
        size.height * 0.45,
      )
      ..cubicTo(
        size.width * 0.97,
        size.height * 0.57,
        size.width * 0.87,
        size.height * 0.66,
        size.width * 0.74,
        size.height * 0.66,
      )
      ..cubicTo(
        size.width * 0.72,
        size.height * 0.76,
        size.width * 0.64,
        size.height * 0.85,
        size.width * 0.54,
        size.height * 0.88,
      )
      ..cubicTo(
        size.width * 0.44,
        size.height * 0.93,
        size.width * 0.33,
        size.height * 0.9,
        size.width * 0.25,
        size.height * 0.83,
      )
      ..cubicTo(
        size.width * 0.16,
        size.height * 0.79,
        size.width * 0.11,
        size.height * 0.71,
        size.width * 0.12,
        size.height * 0.61,
      )
      ..close();

    canvas.drawPath(path, cloudPaint);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.white.withValues(alpha: 0.54),
    );

    final blushPaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0x99FF8E8B), Color(0x00FF8E8B)],
      ).createShader(Rect.fromCircle(
        center: Offset(size.width * 0.3, size.height * 0.5),
        radius: size.width * 0.13,
      ));
    canvas.drawCircle(
      Offset(size.width * 0.3, size.height * 0.5),
      size.width * 0.11,
      blushPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.69, size.height * 0.5),
      size.width * 0.11,
      blushPaint,
    );

    final eyePaint = Paint()
      ..color = const Color(0xFF8D4B39)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.012
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(size.width * 0.42, size.height * 0.43),
        width: size.width * 0.11,
        height: size.height * 0.09,
      ),
      0.1,
      math.pi * 0.8,
      false,
      eyePaint,
    );
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(size.width * 0.58, size.height * 0.43),
        width: size.width * 0.11,
        height: size.height * 0.09,
      ),
      0.1,
      math.pi * 0.8,
      false,
      eyePaint,
    );

    final mouthRect = Rect.fromCenter(
      center: Offset(size.width * 0.5, size.height * 0.57),
      width: size.width * 0.1,
      height: size.height * 0.09,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(mouthRect, Radius.circular(size.width * 0.04)),
      Paint()..color = const Color(0xFFAF3B2A),
    );
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.57),
        width: size.width * 0.08,
        height: size.height * 0.05,
      ),
      0,
      math.pi,
      false,
      Paint()
        ..color = const Color(0xFFFFC7BA)
        ..style = PaintingStyle.fill,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.61),
        width: size.width * 0.046,
        height: size.height * 0.025,
      ),
      Paint()..color = const Color(0xFFFF7B8A),
    );

    final handPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFD8CC), Color(0xFFFFB8A8)],
      ).createShader(Offset.zero & size);
    final leftArm = Path()
      ..moveTo(size.width * 0.1, size.height * 0.63)
      ..cubicTo(
        size.width * 0.0,
        size.height * 0.66,
        size.width * -0.02,
        size.height * 0.74,
        size.width * 0.03,
        size.height * 0.79,
      )
      ..cubicTo(
        size.width * 0.08,
        size.height * 0.83,
        size.width * 0.18,
        size.height * 0.82,
        size.width * 0.25,
        size.height * 0.75,
      );
    canvas.drawPath(
      leftArm,
      handPaint
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.04
        ..strokeCap = StrokeCap.round,
    );
    final rightArm = Path()
      ..moveTo(size.width * 0.88, size.height * 0.63)
      ..cubicTo(
        size.width * 0.98,
        size.height * 0.66,
        size.width * 1.0,
        size.height * 0.74,
        size.width * 0.95,
        size.height * 0.79,
      )
      ..cubicTo(
        size.width * 0.9,
        size.height * 0.83,
        size.width * 0.8,
        size.height * 0.82,
        size.width * 0.73,
        size.height * 0.75,
      );
    canvas.drawPath(rightArm, handPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MiniCloudPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cloudRect = Offset.zero & size;
    final cloudPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.12, -0.25),
        radius: 0.95,
        colors: [
          Color(0xFFFFFBF7),
          Color(0xFFFFE1D7),
          Color(0xFFFFCFBF),
        ],
      ).createShader(cloudRect);

    final path = Path()
      ..moveTo(size.width * 0.14, size.height * 0.57)
      ..cubicTo(
        size.width * 0.05,
        size.height * 0.57,
        0,
        size.height * 0.49,
        0,
        size.height * 0.39,
      )
      ..cubicTo(
        0,
        size.height * 0.28,
        size.width * 0.08,
        size.height * 0.21,
        size.width * 0.18,
        size.height * 0.21,
      )
      ..cubicTo(
        size.width * 0.23,
        size.height * 0.08,
        size.width * 0.34,
        0,
        size.width * 0.48,
        size.height * 0.04,
      )
      ..cubicTo(
        size.width * 0.62,
        0,
        size.width * 0.75,
        size.height * 0.1,
        size.width * 0.79,
        size.height * 0.24,
      )
      ..cubicTo(
        size.width * 0.92,
        size.height * 0.24,
        size.width,
        size.height * 0.35,
        size.width,
        size.height * 0.48,
      )
      ..cubicTo(
        size.width,
        size.height * 0.61,
        size.width * 0.89,
        size.height * 0.7,
        size.width * 0.76,
        size.height * 0.7,
      )
      ..cubicTo(
        size.width * 0.72,
        size.height * 0.84,
        size.width * 0.6,
        size.height * 0.93,
        size.width * 0.47,
        size.height * 0.94,
      )
      ..cubicTo(
        size.width * 0.33,
        size.height * 0.96,
        size.width * 0.19,
        size.height * 0.88,
        size.width * 0.14,
        size.height * 0.76,
      )
      ..close();

    canvas.drawShadow(path, const Color(0x22FFAEA3), 24, false);
    canvas.drawPath(path, cloudPaint);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.white.withValues(alpha: 0.6),
    );

    final eyeFill = Paint()..color = const Color(0xFF6D3C2E);
    final eyeStroke = Paint()
      ..color = const Color(0xFF6D3C2E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.013
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(
      Offset(size.width * 0.52, size.height * 0.37),
      size.width * 0.04,
      eyeFill,
    );
    canvas.drawCircle(
      Offset(size.width * 0.534, size.height * 0.35),
      size.width * 0.012,
      Paint()..color = Colors.white,
    );
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(size.width * 0.35, size.height * 0.37),
        width: size.width * 0.09,
        height: size.height * 0.05,
      ),
      0.2,
      math.pi * 0.72,
      false,
      eyeStroke,
    );
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(size.width * 0.44, size.height * 0.35),
        width: size.width * 0.06,
        height: size.height * 0.03,
      ),
      1.2,
      0.6,
      false,
      eyeStroke,
    );

    final cheekPaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xAAFF8F90), Color(0x00FF8F90)],
      ).createShader(cloudRect);
    canvas.drawCircle(
      Offset(size.width * 0.28, size.height * 0.47),
      size.width * 0.08,
      cheekPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.62, size.height * 0.47),
      size.width * 0.08,
      cheekPaint,
    );

    final mouth = Rect.fromCenter(
      center: Offset(size.width * 0.45, size.height * 0.52),
      width: size.width * 0.1,
      height: size.height * 0.08,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(mouth, Radius.circular(size.width * 0.03)),
      Paint()..color = const Color(0xFFB84334),
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.45, size.height * 0.55),
        width: size.width * 0.05,
        height: size.height * 0.024,
      ),
      Paint()..color = const Color(0xFFFF8DA2),
    );

    final armPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFE2D8), Color(0xFFFFC5B8)],
      ).createShader(cloudRect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.05
      ..strokeCap = StrokeCap.round;
    final leftArm = Path()
      ..moveTo(size.width * 0.24, size.height * 0.57)
      ..quadraticBezierTo(
        size.width * 0.18,
        size.height * 0.52,
        size.width * 0.2,
        size.height * 0.45,
      );
    final rightArm = Path()
      ..moveTo(size.width * 0.67, size.height * 0.57)
      ..quadraticBezierTo(
        size.width * 0.73,
        size.height * 0.52,
        size.width * 0.71,
        size.height * 0.45,
      );
    canvas.drawPath(leftArm, armPaint);
    canvas.drawPath(rightArm, armPaint);

    final heartPath = Path()
      ..moveTo(size.width * 0.45, size.height * 0.71)
      ..cubicTo(
        size.width * 0.39,
        size.height * 0.63,
        size.width * 0.28,
        size.height * 0.63,
        size.width * 0.28,
        size.height * 0.73,
      )
      ..cubicTo(
        size.width * 0.28,
        size.height * 0.81,
        size.width * 0.37,
        size.height * 0.87,
        size.width * 0.45,
        size.height * 0.92,
      )
      ..cubicTo(
        size.width * 0.53,
        size.height * 0.87,
        size.width * 0.62,
        size.height * 0.81,
        size.width * 0.62,
        size.height * 0.73,
      )
      ..cubicTo(
        size.width * 0.62,
        size.height * 0.63,
        size.width * 0.51,
        size.height * 0.63,
        size.width * 0.45,
        size.height * 0.71,
      );
    canvas.drawPath(
      heartPath,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFC4AF), Color(0xFFFF7B6B)],
        ).createShader(cloudRect),
    );
    canvas.drawPath(
      heartPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.white.withValues(alpha: 0.72),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LeafPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stem = Paint()
      ..color = const Color(0x40F4A08B)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(size.width * 0.12, size.height)
      ..quadraticBezierTo(
        size.width * 0.42,
        size.height * 0.58,
        size.width * 0.4,
        0,
      );
    canvas.drawPath(path, stem);

    final leafPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0x30FFB6A4), Color(0x80FFC0B0)],
      ).createShader(Offset.zero & size);

    canvas.drawOval(
      Rect.fromLTWH(size.width * 0.04, size.height * 0.44, size.width * 0.34,
          size.height * 0.28),
      leafPaint,
    );
    canvas.drawOval(
      Rect.fromLTWH(size.width * 0.34, size.height * 0.22, size.width * 0.38,
          size.height * 0.24),
      leafPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
