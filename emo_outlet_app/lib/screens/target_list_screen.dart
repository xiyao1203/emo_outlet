import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/app_providers.dart';
import '../models/target_model.dart';
import '../widgets/common/avatar_circle.dart';
import 'create_target_screen.dart';
import 'session_mode_screen.dart';

class TargetListScreen extends StatelessWidget {
  final bool isSelectMode;

  const TargetListScreen({super.key, this.isSelectMode = false});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TargetProvider>();
    final targets = provider.targets;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          isSelectMode ? '选择泄愤对象' : '我的对象',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF333333)),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFF8F8F8),
        elevation: 0,
      ),
      body: targets.isEmpty
          ? _buildEmptyState(context)
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              itemCount: targets.length,
              itemBuilder: (context, index) {
                final target = targets[index];
                return _TargetCardItem(
                  target: target,
                  onTap: () {
                    if (isSelectMode) {
                      provider.setCurrentTarget(target);
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SessionModeScreen()),
                      );
                    }
                  },
                  onMenu: () => _showTargetActions(context, target, provider),
                );
              },
            ),
      floatingActionButton: Container(
        height: 52,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        width: double.infinity,
        child: FloatingActionButton.extended(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const CreateTargetScreen()),
          ),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          icon: const Icon(Icons.add, size: 22),
          label: const Text('创建新对象', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person_off_outlined, size: 48, color: AppColors.primary),
          ),
          const SizedBox(height: 24),
          const Text(
            '还没有创建对象',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF333333)),
          ),
          const SizedBox(height: 8),
          const Text(
            '点击下方按钮创建你的第一个泄愤对象',
            style: TextStyle(fontSize: 14, color: Color(0xFF999999)),
          ),
        ],
      ),
    );
  }

  void _showTargetActions(
      BuildContext context, TargetModel target, TargetProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4,
                decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 16),
              _buildSheetItem(Icons.send_outlined, '释放到情绪', AppColors.primary, () {
                provider.setCurrentTarget(target);
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SessionModeScreen()),
                );
              }),
              _buildSheetItem(Icons.share_outlined, '分享给情绪好友', AppColors.textSecondary, () => Navigator.of(context).pop()),
              _buildSheetItem(Icons.more_horiz, '更多分享', AppColors.textSecondary, () => Navigator.of(context).pop()),
              _buildSheetItem(Icons.visibility_off_outlined, '隐藏', AppColors.textSecondary, () {
                if (target.id != null) provider.updateTarget(target.id!, {'is_hidden': true});
                Navigator.of(context).pop();
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSheetItem(IconData icon, String label, Color color, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: color, size: 24),
      title: Text(label, style: TextStyle(fontSize: 15, color: color)),
      onTap: onTap,
    );
  }
}

class _TargetCardItem extends StatelessWidget {
  final TargetModel target;
  final VoidCallback? onTap;
  final VoidCallback? onMenu;

  const _TargetCardItem({required this.target, this.onTap, this.onMenu});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                AvatarCircle(imageUrl: target.avatarUrl, name: target.name, size: 56, isGenerating: false),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(target.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF333333))),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          _buildTag(target.typeLabel),
                          if (target.relationship != null) ...[const SizedBox(width: 6), _buildTag(target.relationship!)],
                        ],
                      ),
                    ],
                  ),
                ),
                if (onMenu != null)
                  IconButton(
                    onPressed: onMenu,
                    icon: const Icon(Icons.more_horiz, color: Color(0xFF999999), size: 22),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(text, style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w500)),
    );
  }
}
