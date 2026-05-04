import 'package:flutter/material.dart';

import '../../config/constants.dart';
import '../auth/auth_visuals.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(18, 0, 18, 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1CE6B9AA),
            blurRadius: 28,
            offset: Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 14, 10, 12),
          child: Row(
            children: [
              _navItem(
                index: AppConstants.navIndexHome,
                activeIcon: Icons.home_rounded,
                icon: Icons.home_outlined,
                label: '\u9996\u9875',
              ),
              _navItem(
                index: AppConstants.navIndexTarget,
                activeIcon: Icons.people_alt_rounded,
                icon: Icons.people_alt_outlined,
                label: '\u5bf9\u8c61',
              ),
              _navItem(
                index: AppConstants.navIndexHistory,
                activeIcon: Icons.menu_book_rounded,
                icon: Icons.menu_book_outlined,
                label: '\u8bb0\u5f55',
              ),
              _navItem(
                index: AppConstants.navIndexProfile,
                activeIcon: Icons.person_rounded,
                icon: Icons.person_outline_rounded,
                label: '\u6211\u7684',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem({
    required int index,
    required IconData activeIcon,
    required IconData icon,
    required String label,
  }) {
    final active = currentIndex == index;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => onTap(index),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                active ? activeIcon : icon,
                size: 25,
                color: active ? AuthPalette.coral : const Color(0xFFA7A3A3),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.8,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  color: active ? AuthPalette.coral : const Color(0xFF8F8B8B),
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
