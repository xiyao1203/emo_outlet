import 'package:flutter/material.dart';
import '../../config/theme.dart';

class AvatarCircle extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final double size;
  final bool isGenerating;
  final double progress;

  const AvatarCircle({
    super.key,
    this.imageUrl,
    this.name,
    this.size = 80,
    this.isGenerating = false,
    this.progress = 0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFFFF7A56), Color(0xFFFF9A76)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: imageUrl != null
                ? ClipOval(
                    child: Image.network(
                      imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildDefaultAvatar(),
                    ),
                  )
                : _buildDefaultAvatar(),
          ),
          if (isGenerating)
            Positioned.fill(
              child: Center(
                child: CircularProgressIndicator(
                  value: progress > 0 ? progress : null,
                  strokeWidth: 3,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Center(
      child: Text(
        _getInitial(),
        style: TextStyle(
          fontSize: size * 0.4,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _getInitial() {
    if (name == null || name!.isEmpty) return '?';
    if (name!.length >= 2) return name!.substring(0, 2);
    return name![0];
  }
}
