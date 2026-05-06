import 'package:flutter/material.dart';

import '../auth/auth_visuals.dart';

class SoftColors {
  static const background = Color(0xFFFFFAF7);
  static const text = Color(0xFF20242B);
  static const subtext = Color(0xFF8D929D);
  static const divider = Color(0xFFF4E7DF);
  static const coral = Color(0xFFFF615E);
  static const orange = Color(0xFFFFB06E);
  static const green = Color(0xFF26C66F);
}

class SoftPage extends StatelessWidget {
  const SoftPage({
    super.key,
    required this.child,
    this.bottomNavigationBar,
  });

  final Widget child;
  final Widget? bottomNavigationBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SoftColors.background,
      body: AuthBackground(
        child: SafeArea(child: child),
      ),
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}

class SoftHeader extends StatelessWidget {
  const SoftHeader({
    super.key,
    required this.title,
    this.onBack,
    this.trailing,
  });

  final String title;
  final VoidCallback? onBack;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: onBack,
              behavior: HitTestBehavior.opaque,
              child: const SizedBox(
                width: 48,
                height: 48,
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 24,
                  color: SoftColors.text,
                ),
              ),
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: SoftColors.text,
            ),
          ),
          if (trailing != null)
            Align(alignment: Alignment.centerRight, child: trailing!),
        ],
      ),
    );
  }
}

class SoftCard extends StatelessWidget {
  const SoftCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.radius = 24,
  });

  final Widget child;
  final EdgeInsets padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: Colors.white, width: 1.4),
        boxShadow: const [
          BoxShadow(
            color: Color(0x16E9C8BC),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      padding: padding,
      child: child,
    );
  }
}

class SoftGradientButton extends StatelessWidget {
  const SoftGradientButton({
    super.key,
    required this.text,
    required this.onTap,
    this.height = 52,
    this.fontSize = 15,
  });

  final String text;
  final VoidCallback? onTap;
  final double height;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(height / 2),
        gradient: LinearGradient(
          colors: enabled
              ? const [SoftColors.coral, SoftColors.orange]
              : const [Color(0xFFFFC4B6), Color(0xFFFFD4B7)],
        ),
        boxShadow: enabled
            ? const [
                BoxShadow(
                  color: Color(0x35FF9B78),
                  blurRadius: 24,
                  offset: Offset(0, 10),
                ),
              ]
            : const [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(height / 2),
          onTap: onTap,
          child: Container(
            height: height,
            alignment: Alignment.center,
            child: Text(
              text,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w700,
                color: enabled
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.88),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SoftOutlineButton extends StatelessWidget {
  const SoftOutlineButton({
    super.key,
    required this.text,
    required this.onTap,
    this.height = 50,
    this.textColor = SoftColors.text,
  });

  final String text;
  final VoidCallback? onTap;
  final double height;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(height / 2),
        onTap: onTap,
        child: Ink(
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(height / 2),
            color: enabled
                ? Colors.white.withValues(alpha: 0.78)
                : Colors.white.withValues(alpha: 0.56),
            border: Border.all(
              color: enabled
                  ? const Color(0xFFFFD5C8)
                  : const Color(0xFFF1DDD6),
            ),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                color: enabled
                    ? textColor
                    : textColor.withValues(alpha: 0.5),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SoftIconBadge extends StatelessWidget {
  const SoftIconBadge({
    super.key,
    required this.icon,
    required this.colors,
    this.size = 48,
    this.iconColor = Colors.white,
  });

  final IconData icon;
  final List<Color> colors;
  final double size;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(colors: colors),
      ),
      child: Icon(icon, color: iconColor, size: size * 0.5),
    );
  }
}

class SoftListTile extends StatelessWidget {
  const SoftListTile({
    super.key,
    required this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.showDivider = true,
  });

  final Widget leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      child: Row(
        children: [
          leading,
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: SoftColors.text,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      color: SoftColors.subtext,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 12),
            trailing!,
          ],
        ],
      ),
    );

    final tile = showDivider
        ? Column(
            children: [
              content,
              const Divider(height: 1, color: SoftColors.divider),
            ],
          )
        : content;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: tile,
    );
  }
}

class SoftTag extends StatelessWidget {
  const SoftTag({
    super.key,
    required this.text,
    required this.color,
    this.background,
  });

  final String text;
  final Color color;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: background ?? color.withValues(alpha: 0.1),
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
