import 'package:flutter/material.dart';
import '../config/theme.dart';

/// 隐私政策页面（中英文双语）
class PrivacyPolicyScreen extends StatelessWidget {
  final bool showAgreeButton;

  const PrivacyPolicyScreen({super.key, this.showAgreeButton = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('隐私政策 / Privacy Policy'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: AppSpacing.screenPadding,
              children: const [
                _SectionTitle('信息收集 / Information We Collect'),
                _BodyText(
                  '我们收集以下类型的数据以提供服务：\n'
                  '• 账号信息：手机号/邮箱、密码（加密存储）、昵称\n'
                  '  Account: phone/email, password (hashed), nickname\n'
                  '• 对话内容：您与 AI 之间的聊天记录\n'
                  '  Chat Content: messages between you and AI\n'
                  '• 情绪分析：基于对话生成的情绪分析结果\n'
                  '  Emotion Analysis: analysis results from your chats\n'
                  '• 设备信息：设备唯一标识符（UUID）、操作系统版本\n'
                  '  Device Info: UUID, OS version',
                ),
                _SectionTitle('数据用途 / How We Use Data'),
                _BodyText(
                  '收集的数据用于以下目的：\n'
                  '• 提供 AI 对话与情绪释放服务\n'
                  '  To provide AI chat and emotional outlet services\n'
                  '• 生成情绪分析与海报\n'
                  '  To generate emotion analysis and posters\n'
                  '• 改进服务质量与用户体验\n'
                  '  To improve service quality and user experience\n'
                  '• 不会用于广告投放或用户画像\n'
                  '  NOT used for advertising or user profiling',
                ),
                _SectionTitle('AI 数据处理 / AI Data Processing'),
                _BodyText(
                  '我们的 AI 服务处理以下数据：\n'
                  '• 对话内容将发送至 AI 服务供应商（如 DeepSeek / 通义千问 / OpenAI）用于生成回复\n'
                  '  Chat content is sent to AI providers (DeepSeek / Qwen / OpenAI) for response generation\n'
                  '• AI 回复经过内容安全审核，确保不包含违规内容\n'
                  '  AI responses go through content safety review\n'
                  '• 我们记录违规内容用于改进安全策略，不用于其他目的\n'
                  '  Violation logs are used only for safety improvement',
                ),
                _SectionTitle('第三方共享 / Third-Party Sharing'),
                _BodyText(
                  '您的数据可能在以下场景与第三方共享：\n'
                  '• AI 服务供应商：对话内容将发送至 AI API（如 DeepSeek / 通义千问 / OpenAI）用于生成回复\n'
                  '  AI Providers: chat content is sent to AI APIs for response generation\n'
                  '• 云服务商：数据存储在云端服务器\n'
                  '  Cloud Services: data is stored on cloud servers\n'
                  '• 内容审核服务：必要时提交至第三方内容审核平台\n'
                  '  Content review services when necessary\n'
                  '• 我们不会出售您的个人信息给任何第三方\n'
                  '  We do NOT sell your personal information',
                ),
                _SectionTitle('数据跨境传输 / Cross-Border Transfer'),
                _BodyText(
                  '如使用 OpenAI 等海外 AI 服务，您的对话数据可能传输至境外服务器。'
                  '我们将采取合同条款等措施确保数据安全。\n'
                  'If using overseas AI services (e.g. OpenAI), your chat data may be '
                  'transferred abroad. We implement contractual safeguards.',
                ),
                _SectionTitle('数据保留与删除 / Data Retention & Deletion'),
                _BodyText(
                  '• 账号存续期间：数据持续保留\n'
                  '  Data retained while account is active\n'
                  '• 注销账号后：30 天内彻底删除所有数据\n'
                  '  All data permanently deleted within 30 days after account deletion\n'
                  '• 聊天记录的本地缓存可在设置中手动清除\n'
                  '  Local chat caches can be cleared in settings',
                ),
                _SectionTitle('用户权利 / Your Rights'),
                _BodyText(
                  '根据《个人信息保护法》及 GDPR，您享有以下权利：\n'
                  '• 访问权：查看我们收集的您的个人数据\n'
                  '  Right to access your personal data\n'
                  '• 更正权：修改不准确的个人信息\n'
                  '  Right to correct inaccurate information\n'
                  '• 删除权：注销账号删除所有数据\n'
                  '  Right to delete (account deletion)\n'
                  '• 可携带权：导出您的数据（设置中操作）\n'
                  '  Right to data portability (export in settings)\n'
                  '• 撤回同意：随时撤回数据收集同意\n'
                  '  Right to withdraw consent at any time',
                ),
                _SectionTitle('未成年人保护 / Minor Protection'),
                _BodyText(
                  '• 14 岁以下用户需获得监护人同意方可使用\n'
                  '  Users under 14 need parental consent to use this service\n'
                  '• 14-18 岁用户使用受青少年模式保护（内容降敏、次数限制）\n'
                  '  Users aged 14-18 have youth mode protection (filtered content, usage limits)\n'
                  '• 未成年用户的 AI 对话采用更温和的安全策略\n'
                  '  Minors receive extra gentle AI safety protocols\n'
                  '• 如发现未经监护人同意收集未成年人数据，请联系我们删除\n'
                  '  Contact us to delete minor data collected without consent',
                ),
                _SectionTitle('投诉举报 / Complaints & Reports'),
                _BodyText(
                  '如发现违规内容或需要投诉，请通过以下方式联系我们：\n'
                  'To report violations or file complaints:\n'
                  '• App 内举报功能：在聊天界面长按消息可举报\n'
                  '  In-app report: long-press message in chat to report\n'
                  '• 邮箱 Email: support@emooutlet.app\n'
                  '我们将在 48 小时内处理举报\n'
                  'We will process reports within 48 hours',
                ),
                _SectionTitle('算法备案 / Algorithm Filing'),
                _BodyText(
                  '本应用使用的生成式人工智能服务已依法履行算法备案义务。\n'
                  'The generative AI service used in this app has fulfilled algorithm filing obligations.',
                ),
                _SectionTitle('联系我们 / Contact Us'),
                _BodyText(
                  '如对隐私政策有任何疑问，请联系：\n'
                  'If you have any questions about this policy:\n'
                  '• 邮箱 Email: support@emooutlet.app\n'
                  '• 更新时间 Last updated: 2026-05-03',
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
          if (showAgreeButton) ...[
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                border: Border(
                  top: BorderSide(
                      color: AppColors.divider.withValues(alpha: 0.5)),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                  ),
                  child: const Text(
                    '我已了解 / I Understand',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
          height: 1.4,
        ),
      ),
    );
  }
}

class _BodyText extends StatelessWidget {
  final String text;

  const _BodyText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        color: AppColors.textSecondary,
        height: 1.7,
      ),
    );
  }
}
