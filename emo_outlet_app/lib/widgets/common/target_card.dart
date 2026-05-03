import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/target_model.dart';
import 'avatar_circle.dart';

class TargetCard extends StatelessWidget {
  final TargetModel target;
  final VoidCallback? onTap;
  final VoidCallback? onMenu;
  final bool isSelected;

  const TargetCard({
    super.key,
    required this.target,
    this.onTap,
    this.onMenu,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: [AppColors.cardShadow],
        ),
        child: Row(
          children: [
            AvatarCircle(
              imageUrl: target.avatarUrl,
              name: target.name,
              size: 56,
              isGenerating: false,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    target.name,
                    style: AppTextStyles.heading3,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _buildTag(target.typeLabel),
                      const SizedBox(width: 8),
                      if (target.relationship != null)
                        _buildTag(target.relationship!),
                    ],
                  ),
                ],
              ),
            ),
            if (onMenu != null)
              IconButton(
                onPressed: onMenu,
                icon: const Icon(
                  Icons.more_horiz,
                  color: AppColors.textHint,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
