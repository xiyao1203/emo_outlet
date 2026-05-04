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
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(34),
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1CE6B9AA),
            blurRadius: 24,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
          child: Row(
            children: [
              _navItem(
                index: AppConstants.navIndexHome,
                activeIcon: Icons.home_rounded,
                icon: Icons.home_outlined,
                label: '首页',
              ),
              _navItem(
                index: AppConstants.navIndexTarget,
                activeIcon: Icons.groups_rounded,
                icon: Icons.groups_outlined,
                label: '对象',
              ),
              _navItem(
                index: AppConstants.navIndexHistory,
                activeIcon: Icons.assignment_rounded,
                icon: Icons.assignment_outlined,
                label: '记录',
              ),
              _navItem(
                index: AppConstants.navIndexProfile,
                activeIcon: Icons.sentiment_satisfied_rounded,
                icon: Icons.sentiment_satisfied_alt_outlined,
                label: '我的',
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
        borderRadius: BorderRadius.circular(20),
        onTap: () => onTap(index),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                active ? activeIcon : icon,
                size: 29,
                color: active ? AuthPalette.coral : const Color(0xFF8D8D8D),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  color: active ? AuthPalette.coral : const Color(0xFF8D8D8D),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
