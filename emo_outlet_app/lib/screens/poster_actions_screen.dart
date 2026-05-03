import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../config/theme.dart';
import '../providers/app_providers.dart';

class PosterActionsScreen extends StatelessWidget {
  const PosterActionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final emotionProvider = context.watch<EmotionProvider>();
    final sessionProvider = context.watch<SessionProvider>();
    final posterData = emotionProvider.posterData;
    final report = emotionProvider.currentReport;
    final targetName = sessionProvider.currentSession?.targetName ?? '未知对象';
    final dominantEmotion = report?.dominantEmotion ?? '平静';
    final dominantValue = (report?.dominantEmotionValue ?? 0).toStringAsFixed(0);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('泄愤操作', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF333333))),
        centerTitle: true,
        backgroundColor: const Color(0xFFF8F8F8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF666666)),
          onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Spacer(),
            // 海报预览（缩小版）
            Container(
              width: 240,
              height: 340,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    _emotionGradientColor(dominantEmotion),
                    _emotionGradientColor(dominantEmotion).withOpacity(0.8),
                    const Color(0xFFFFD4B0),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8)),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (posterData != null && posterData.startsWith('data:'))
                      ClipOval(
                        child: Image.memory(
                          Base64Decoder().convert(posterData.split(',')[1]),
                          width: 60, height: 60, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _defaultAvatar(targetName, 24),
                        ),
                      )
                    else
                      _defaultAvatar(targetName, 24),
                    const SizedBox(height: 16),
                    Text(report?.title ?? '说出来好多了！', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 1)),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.25), borderRadius: BorderRadius.circular(14)),
                      child: Text('$dominantEmotion $dominantValue%', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white)),
                    ),
                    const SizedBox(height: 10),
                    const Text('😤', style: TextStyle(fontSize: 28)),
                  ],
                ),
              ),
            ),
            const Spacer(),
            // 操作按钮
            _buildActionCard(
              icon: Icons.download_outlined,
              title: '保存到相册',
              subtitle: '将海报保存到本地相册',
              onTap: () {
                HapticFeedback.mediumImpact();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('海报已保存到相册'), behavior: SnackBarBehavior.floating),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildActionCard(
              icon: Icons.share_outlined,
              title: '分享到社交平台',
              subtitle: '分享你的情绪海报给好友',
              onTap: () async {
                try {
                  await Share.share(
                    '我刚在「情绪出口」释放了情绪！\n'
                    '今天的主要情绪是 $dominantEmotion，强度 $dominantValue%\n'
                    '说出来好多了！😤',
                  );
                } catch (e) {
                  await Clipboard.setData(
                    ClipboardData(text: '我刚在「情绪出口」释放了情绪！\n主要情绪：$dominantEmotion $dominantValue%\n说出来好多了！😤'),
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('分享内容已复制到剪贴板'), behavior: SnackBarBehavior.floating),
                    );
                  }
                }
              },
            ),
            const SizedBox(height: 12),
            _buildActionCard(
              icon: Icons.home_outlined,
              title: '回到首页',
              subtitle: '返回主页继续使用',
              onTap: () => Navigator.of(context).popUntil((route) => route.isFirst),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return Container(
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
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF333333))),
                    const SizedBox(height: 2),
                    Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF999999))),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Color(0xFFCCCCCC), size: 20),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _defaultAvatar(String name, double fontSize) {
    return Container(
      width: 60, height: 60,
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.3), shape: BoxShape.circle),
      child: Center(
        child: Text(
          name.length >= 2 ? name.substring(0, 2) : name[0],
          style: TextStyle(fontSize: fontSize, color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Color _emotionGradientColor(String emotion) {
    switch (emotion) {
      case '愤怒': return const Color(0xFFE57373);
      case '悲伤': return const Color(0xFF64B5F6);
      case '焦虑': return const Color(0xFFFFB74D);
      case '疲惫': return const Color(0xFFA1887F);
      case '无奈': return const Color(0xFF90A4AE);
      default: return const Color(0xFFFF7A56);
    }
  }
}
