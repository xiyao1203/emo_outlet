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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('历史记录', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF333333))),
        centerTitle: true,
        backgroundColor: const Color(0xFFF8F8F8),
        elevation: 0,
      ),
      body: sessions.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100, height: 100,
                    decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
                    child: const Icon(Icons.history_outlined, size: 48, color: AppColors.primary),
                  ),
                  const SizedBox(height: 24),
                  const Text('还没有历史记录', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF333333))),
                  const SizedBox(height: 8),
                  const Text('开始一次情绪释放，记录会出现在这里', style: TextStyle(fontSize: 14, color: Color(0xFF999999))),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _showSessionActions(context),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                AvatarCircle(
                  imageUrl: session.targetAvatarUrl,
                  name: session.targetName,
                  size: 50,
                  isGenerating: false,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(session.targetName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF333333))),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          _infoChip(session.modeLabel),
                          const SizedBox(width: 6),
                          _infoChip('${session.durationMinutes}分钟'),
                          if (session.dialect != '普通话') ...[const SizedBox(width: 6), _infoChip(session.dialect)],
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Color(0xFFCCCCCC), size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSessionActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4,
                decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.article_outlined, color: Color(0xFF666666)),
                title: const Text('查看详情', style: TextStyle(fontSize: 15, color: Color(0xFF333333))),
                onTap: () => Navigator.of(ctx).pop(),
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Color(0xFF666666)),
                title: const Text('删除记录', style: TextStyle(fontSize: 15, color: Color(0xFF333333))),
                onTap: () {
                  Navigator.of(ctx).pop();
                  context.read<SessionProvider>().sessions.removeWhere((s) => s.id == session.id);
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(text, style: const TextStyle(fontSize: 11, color: Color(0xFF999999))),
    );
  }
}
