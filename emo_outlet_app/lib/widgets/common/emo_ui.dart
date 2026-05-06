import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../auth/auth_visuals.dart';

class EmoPageScaffold extends StatelessWidget {
  const EmoPageScaffold({
    super.key,
    required this.child,
    this.bottomNavigationBar,
  });

  final Widget child;
  final Widget? bottomNavigationBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthBackground(
        child: SafeArea(child: child),
      ),
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}

class EmoResponsive {
  EmoResponsive._();

  static bool isTabletWidth(double width) => width >= 700;

  static double edgePadding(
    double width, {
    double phoneFactor = 0.045,
    double phoneMax = 20,
    double tabletPadding = 24,
  }) {
    if (width >= 700) return tabletPadding;
    return math.min(width * phoneFactor, phoneMax);
  }

  static double contentMaxWidth(
    double width, {
    double tabletMax = 620,
    double desktopMax = 880,
  }) {
    if (width >= 980) return desktopMax;
    if (width >= 700) return tabletMax;
    return width;
  }

  static int featureGridCount(double width) {
    if (width >= 1080) return 4;
    if (width >= 760) return 3;
    return 2;
  }
}

class EmoResponsiveContent extends StatelessWidget {
  const EmoResponsiveContent({
    super.key,
    required this.width,
    required this.child,
    this.alignment = Alignment.topCenter,
    this.maxWidth,
  });

  final double width;
  final Widget child;
  final Alignment alignment;
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? EmoResponsive.contentMaxWidth(width),
        ),
        child: child,
      ),
    );
  }
}

class EmoTopBrandBar extends StatelessWidget {
  const EmoTopBrandBar({
    super.key,
    this.trailing,
    this.showSubtitle = true,
  });

  final Widget? trailing;
  final bool showSubtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppBrand(fontSize: 21, logoSize: 38, spacing: 9),
            if (showSubtitle) ...[
              const SizedBox(height: 5),
              const Text(
                '把不舒服的情绪，轻轻放出来',
                style: TextStyle(
                  fontSize: 12.5,
                  color: Color(0xFF7C6C63),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
        const Spacer(),
        trailing ?? const SizedBox.shrink(),
      ],
    );
  }
}

class EmoSectionCard extends StatelessWidget {
  const EmoSectionCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(15),
    this.radius = 26,
  });

  final Widget child;
  final EdgeInsets padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.36),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: Colors.white.withValues(alpha: 0.82)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14E7B9AB),
            blurRadius: 22,
            offset: Offset(0, 10),
          ),
        ],
      ),
      padding: padding,
      child: child,
    );
  }
}

class EmoRoundIconButton extends StatelessWidget {
  const EmoRoundIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.size = 46,
  });

  final IconData icon;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.82),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(icon, size: size * 0.5, color: AuthPalette.textPrimary),
        ),
      ),
    );
  }
}

class EmoGradientOutlineButton extends StatelessWidget {
  const EmoGradientOutlineButton({
    super.key,
    required this.text,
    required this.onTap,
    this.icon,
  });

  final String text;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: Ink(
          height: 52,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: const Color(0xFFFF7A5A), width: 1.6),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, color: const Color(0xFFFF7A5A), size: 24),
                const SizedBox(width: 10),
              ],
              Text(
                text,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFFF7A5A),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EmoTypePill extends StatelessWidget {
  const EmoTypePill({
    super.key,
    required this.text,
    this.color = const Color(0xFFFF7D5D),
    this.background = const Color(0x14FF7D5D),
  });

  final String text;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class EmoAvatar extends StatelessWidget {
  const EmoAvatar({
    super.key,
    required this.label,
    required this.background,
    this.size = 88,
  });

  final String label;
  final Color background;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            background.withValues(alpha: 0.15),
            background.withValues(alpha: 0.35),
          ],
        ),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontSize: size * 0.38,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF4F3E38),
          ),
        ),
      ),
    );
  }
}

class EmoProfileBubble extends StatelessWidget {
  const EmoProfileBubble({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        gradient: const LinearGradient(
          colors: [Color(0xFFF9C8B5), Color(0xFFFFE8DA)],
        ),
      ),
      child: const Center(
        child: Text('👩🏻', style: TextStyle(fontSize: 38)),
      ),
    );
  }
}

class EmoDecorationCloud extends StatelessWidget {
  const EmoDecorationCloud({
    super.key,
    this.size = 180,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 0.92,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _SimpleCloudPainter(),
            ),
          ),
          Positioned(
            top: size * 0.1,
            left: size * 0.02,
            child: Icon(Icons.favorite_rounded,
                color: const Color(0xFFFF8E80), size: size * 0.1),
          ),
          Positioned(
            top: size * 0.18,
            right: size * 0.02,
            child: Icon(Icons.favorite_rounded,
                color: const Color(0xFFFF8E80), size: size * 0.08),
          ),
        ],
      ),
    );
  }
}

class EmoHeaderTitle extends StatelessWidget {
  const EmoHeaderTitle({
    super.key,
    required this.title,
    required this.subtitle,
    this.trailingCloud,
  });

  final String title;
  final String subtitle;
  final Widget? trailingCloud;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                  color: AuthPalette.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF7A6D67),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        if (trailingCloud != null) trailingCloud!,
      ],
    );
  }
}

class EmoMenuSheet extends StatelessWidget {
  const EmoMenuSheet({
    super.key,
    required this.title,
    required this.avatar,
    required this.items,
  });

  final String title;
  final Widget avatar;
  final List<EmoMenuSheetItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFDF8F4),
        borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
      ),
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 26),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0x22000000),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                avatar,
                const SizedBox(width: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AuthPalette.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            EmoSectionCard(
              radius: 24,
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  for (var i = 0; i < items.length; i++) ...[
                    _sheetRow(items[i]),
                    if (i != items.length - 1)
                      const Divider(height: 1, color: Color(0xFFF2E5DE)),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
            EmoSectionCard(
              radius: 24,
              padding: EdgeInsets.zero,
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () => Navigator.of(context).pop(),
                child: const SizedBox(
                  height: 66,
                  child: Center(
                    child: Text(
                      '取消',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AuthPalette.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sheetRow(EmoMenuSheetItem item) {
    return Builder(
      builder: (context) => InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: item.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(item.icon, color: item.color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w600,
                    color: item.color,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: Color(0xFF9A9A9A), size: 26),
            ],
          ),
        ),
      ),
    );
  }
}

class EmoMenuSheetItem {
  EmoMenuSheetItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.background,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Color background;
  final VoidCallback onTap;
}

Color typeColor(String type) {
  switch (type) {
    case 'boss':
      return const Color(0xFFFF7A5A);
    case 'colleague':
      return const Color(0xFF8F79E8);
    case 'partner':
      return const Color(0xFF76A6FF);
    case 'client':
      return const Color(0xFFFFA648);
    case 'family':
      return const Color(0xFF6CC48F);
    default:
      return const Color(0xFFAAAAAA);
  }
}

Color avatarBgByType(String type) {
  switch (type) {
    case 'boss':
      return const Color(0xFFF8BBB2);
    case 'colleague':
      return const Color(0xFFD8C9FF);
    case 'partner':
      return const Color(0xFFC7E2FF);
    case 'client':
      return const Color(0xFFFFD8A9);
    case 'family':
      return const Color(0xFFD3F0D8);
    default:
      return const Color(0xFFE8D9D2);
  }
}

String avatarEmojiByType(String type) {
  switch (type) {
    case 'boss':
      return '👨‍💼';
    case 'colleague':
      return '🙍🏻‍♀️';
    case 'partner':
      return '🙍🏻‍♂️';
    case 'client':
      return '🧑🏻‍💼';
    case 'family':
      return '👨‍👩‍👧';
    default:
      return '🙂';
  }
}

String formatFriendlyTime(DateTime? value) {
  if (value == null) return '今天 10:30';
  final now = DateTime.now();
  final sameDay = now.year == value.year &&
      now.month == value.month &&
      now.day == value.day;
  final yesterday = now.subtract(const Duration(days: 1));
  final isYesterday = yesterday.year == value.year &&
      yesterday.month == value.month &&
      yesterday.day == value.day;
  final hh = value.hour.toString().padLeft(2, '0');
  final mm = value.minute.toString().padLeft(2, '0');
  if (sameDay) return '今天 $hh:$mm';
  if (isYesterday) return '昨天 $hh:$mm';
  return '${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')} $hh:$mm';
}

class _SimpleCloudPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.1, -0.2),
        radius: 0.95,
        colors: [
          Color(0xFFFFFCFA),
          Color(0xFFFFE4DB),
          Color(0xFFFFD0C1),
        ],
      ).createShader(rect);

    final path = Path()
      ..moveTo(size.width * 0.18, size.height * 0.62)
      ..cubicTo(
        size.width * 0.08,
        size.height * 0.62,
        size.width * 0.03,
        size.height * 0.56,
        size.width * 0.03,
        size.height * 0.45,
      )
      ..cubicTo(
        size.width * 0.03,
        size.height * 0.34,
        size.width * 0.12,
        size.height * 0.26,
        size.width * 0.22,
        size.height * 0.26,
      )
      ..cubicTo(
        size.width * 0.26,
        size.height * 0.1,
        size.width * 0.39,
        size.height * 0.02,
        size.width * 0.54,
        size.height * 0.06,
      )
      ..cubicTo(
        size.width * 0.68,
        size.height * 0.04,
        size.width * 0.8,
        size.height * 0.14,
        size.width * 0.83,
        size.height * 0.26,
      )
      ..cubicTo(
        size.width * 0.93,
        size.height * 0.28,
        size.width,
        size.height * 0.36,
        size.width,
        size.height * 0.48,
      )
      ..cubicTo(
        size.width,
        size.height * 0.61,
        size.width * 0.9,
        size.height * 0.71,
        size.width * 0.76,
        size.height * 0.71,
      )
      ..cubicTo(
        size.width * 0.72,
        size.height * 0.84,
        size.width * 0.6,
        size.height * 0.92,
        size.width * 0.46,
        size.height * 0.93,
      )
      ..cubicTo(
        size.width * 0.32,
        size.height * 0.95,
        size.width * 0.18,
        size.height * 0.87,
        size.width * 0.15,
        size.height * 0.75,
      )
      ..close();

    canvas.drawShadow(path, const Color(0x20FFAB9B), 24, false);
    canvas.drawPath(path, paint);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.white.withValues(alpha: 0.6),
    );

    final eye = Paint()..color = const Color(0xFF6F3C31);
    canvas.drawCircle(
      Offset(size.width * 0.38, size.height * 0.42),
      size.width * 0.03,
      eye,
    );
    canvas.drawCircle(
      Offset(size.width * 0.58, size.height * 0.42),
      size.width * 0.03,
      eye,
    );
    canvas.drawCircle(
      Offset(size.width * 0.39, size.height * 0.4),
      size.width * 0.008,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      Offset(size.width * 0.59, size.height * 0.4),
      size.width * 0.008,
      Paint()..color = Colors.white,
    );

    final mouthRect = Rect.fromCenter(
      center: Offset(size.width * 0.48, size.height * 0.56),
      width: size.width * 0.12,
      height: size.height * 0.08,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(mouthRect, Radius.circular(size.width * 0.03)),
      Paint()..color = const Color(0xFFB6493A),
    );

    final heart = Path()
      ..moveTo(size.width * 0.5, size.height * 0.7)
      ..cubicTo(
        size.width * 0.44,
        size.height * 0.61,
        size.width * 0.33,
        size.height * 0.62,
        size.width * 0.33,
        size.height * 0.72,
      )
      ..cubicTo(
        size.width * 0.33,
        size.height * 0.8,
        size.width * 0.43,
        size.height * 0.86,
        size.width * 0.5,
        size.height * 0.9,
      )
      ..cubicTo(
        size.width * 0.57,
        size.height * 0.86,
        size.width * 0.67,
        size.height * 0.8,
        size.width * 0.67,
        size.height * 0.72,
      )
      ..cubicTo(
        size.width * 0.67,
        size.height * 0.62,
        size.width * 0.56,
        size.height * 0.61,
        size.width * 0.5,
        size.height * 0.7,
      );

    canvas.drawPath(
      heart,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFFFFBFAC), Color(0xFFFF7A6C)],
        ).createShader(rect),
    );

    final orbitRect = Rect.fromCenter(
      center: Offset(size.width * 0.52, size.height * 0.7),
      width: size.width * 1.04,
      height: size.height * 0.26,
    );
    canvas.drawArc(
      orbitRect,
      math.pi * 0.9,
      math.pi * 1.3,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..shader = const LinearGradient(
          colors: [Color(0x40FFFFFF), Color(0xAAFFF7EB), Color(0x00FFFFFF)],
        ).createShader(orbitRect),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
