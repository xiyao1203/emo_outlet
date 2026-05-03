import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/app_providers.dart';
import '../models/session_model.dart';
import '../widgets/common/avatar_circle.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sessionProvider = context.watch<SessionProvider>();
    final sessions = sessionProvider.sessions;

    return Scaffold(
      appBar: AppBar(
        title: const Text('历史记录'),
      ),
      body: sessions.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history_outlined,
                    size: 80,
                    color: AppColors.textHint.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '还没有历史记录',
                    style: AppTextStyles.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '开始一次情绪释放，记录会出现在这里',
                    style: AppTextStyles.label,
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: AppSpacing.screenPadding,
              itemCount: sessions.length,
              itemBuilder: (context, index) {
                final session = sessions[index];
                return _HistoryItem(session: session);
              },
            ),
    );
  }
}

class _HistoryItem extends StatelessWidget {
  final SessionModel session;

  const _HistoryItem({required this.session});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: [AppColors.cardShadow],
      ),
      child: Row(
        children: [
          AvatarCircle(
            name: session.targetName,
            size: 48,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.targetName,
                  style: AppTextStyles.heading3,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _infoChip(session.modeLabel),
                    const SizedBox(width: 8),
                    _infoChip('${session.durationMinutes}分钟'),
                    if (session.dialect != '普通话') ...[
                      const SizedBox(width: 8),
                      _infoChip(session.dialect),
                    ],
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _showSessionActions(context),
            icon: const Icon(Icons.more_horiz, color: AppColors.textHint),
          ),
        ],
      ),
    );
  }

  void _showSessionActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
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
              ListTile(
                leading: const Icon(Icons.article_outlined,
                    color: AppColors.textSecondary),
                title: const Text('查看详情', style: AppTextStyles.bodyMedium),
                onTap: () => Navigator.of(ctx).pop(),
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline,
                    color: AppColors.textSecondary),
                title: const Text('删除记录', style: AppTextStyles.bodyMedium),
                onTap: () {
                  Navigator.of(ctx).pop();
                  context.read<SessionProvider>().sessions
                      .removeWhere((s) => s.id == session.id);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          color: AppColors.textHint,
        ),
      ),
    );
  }
}
