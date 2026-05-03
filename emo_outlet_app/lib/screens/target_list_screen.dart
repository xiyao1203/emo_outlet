import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/constants.dart';
import '../config/theme.dart';
import '../providers/app_providers.dart';
import '../models/target_model.dart';
import '../widgets/common/target_card.dart';
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
      appBar: AppBar(
        title: Text(isSelectMode ? '选择泄愤对象' : '我的对象'),
        actions: [
          if (targets.length < AppConstants.maxTargetsPerUser)
            IconButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const CreateTargetScreen(),
                ),
              ),
              icon: const Icon(Icons.add_circle_outline),
            ),
        ],
      ),
      body: targets.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 80,
                    color: AppColors.textHint.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '还没有创建对象',
                    style: AppTextStyles.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '点击下方按钮创建你的第一个泄愤对象',
                    style: AppTextStyles.label,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const CreateTargetScreen(),
                      ),
                    ),
                    child: const Text('创建对象'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: AppSpacing.screenPadding,
              itemCount: targets.length,
              itemBuilder: (context, index) {
                final target = targets[index];
                return TargetCard(
                  target: target,
                  onTap: () {
                    if (isSelectMode) {
                      provider.setCurrentTarget(target);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const SessionModeScreen(),
                        ),
                      );
                    }
                  },
                  onMenu: () => _showTargetActions(context, target, provider),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const CreateTargetScreen(),
          ),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('创建对象'),
      ),
    );
  }

  void _showTargetActions(
      BuildContext context, TargetModel target, TargetProvider provider) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              _actionItem(context, '释放到情绪', Icons.send_outlined, () {
                provider.setCurrentTarget(target);
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const SessionModeScreen(),
                  ),
                );
              }),
              _actionItem(context, '分享给情绪好友', Icons.share_outlined, () {
                Navigator.of(context).pop();
              }),
              _actionItem(context, '更多分享', Icons.more_horiz, () {
                Navigator.of(context).pop();
              }),
              _actionItem(context, '隐藏', Icons.visibility_off_outlined, () {
                provider.updateTarget(target.id!, {'is_hidden': true});
                Navigator.of(context).pop();
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionItem(
      BuildContext context, String label, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(label, style: AppTextStyles.bodyMedium),
      onTap: onTap,
    );
  }
}
