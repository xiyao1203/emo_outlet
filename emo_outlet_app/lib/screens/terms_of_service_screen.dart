import 'package:flutter/material.dart';
import '../config/theme.dart';

/// 用户协议页面（中英文双语）
class TermsOfServiceScreen extends StatelessWidget {
  final bool showAgreeButton;

  const TermsOfServiceScreen({super.key, this.showAgreeButton = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('用户协议 / Terms of Service'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: AppSpacing.screenPadding,
              children: const [
                _SectionTitle('服务说明 / Service Description'),
                _BodyText(
                  '情绪出口（Emo Outlet）是一款情绪释放辅助工具，通过 AI 对话帮助用户宣泄情绪。\n'
                  'Emo Outlet is an emotional outlet tool that uses AI conversation to help users '
                  'express and release their emotions.',
                ),
                _SectionTitle('AI 服务声明 / AI Service Disclaimer'),
                _BodyText(
                  '重要：AI 服务为非专业辅助工具，请注意以下限制：\n'
                  'IMPORTANT: AI service is a non-professional tool:\n'
                  '• AI 回复基于机器学习生成，不构成任何心理、医疗或法律建议\n'
                  '  AI responses are machine-generated and do NOT constitute any '
                  'psychological, medical, or legal advice\n'
                  '• 本应用不提供心理咨询或治疗服务，AI 不能替代专业心理医生\n'
                  '  This app does NOT provide psychological counseling or therapy\n'
                  '• 如果您有心理困扰或危机，请拨打专业心理援助热线（全国24小时心理援助热线：010-82951332）\n'
                  '  If you are in distress or crisis, please call professional helplines\n'
                  '• AI 可能产生不准确或不适当的回复，平台已采取内容审核措施但不能保证百分百准确\n'
                  '  AI may produce inaccurate or inappropriate responses despite content moderation\n'
                  '• 请勿将 AI 建议作为专业诊断或治疗的替代\n'
                  '  Do NOT substitute AI advice for professional diagnosis or treatment\n'
                  '• 如发现 AI 回复存在违规内容，请通过举报功能告知我们\n'
                  '  Report any inappropriate AI responses via the report feature',
                ),
                _SectionTitle('用户行为准则 / User Conduct'),
                _BodyText(
                  '使用本服务时，您同意遵守以下规则：\n'
                  'By using this service, you agree to:\n'
                  '• 不发布违法、暴力、色情、赌博、毒品等内容\n'
                  '  NOT post illegal, violent, pornographic, gambling, or drug-related content\n'
                  '• 不利用AI生成危害国家安全、社会稳定的内容\n'
                  '  NOT use AI to generate content harmful to national security or social stability\n'
                  '• 不骚扰、威胁、侮辱其他用户\n'
                  '  NOT harass, threaten, or insult other users\n'
                  '• 不尝试绕过内容安全过滤系统\n'
                  '  NOT attempt to bypass content safety filters\n'
                  '• 不将本服务用于任何非法目的\n'
                  '  NOT use this service for any illegal purpose\n'
                  '• 14岁以下未成年人需在监护人陪同下使用\n'
                  '  Users under 14 must use with parental supervision',
                ),
                _SectionTitle('知识产权 / Intellectual Property'),
                _BodyText(
                  '• 本应用的代码、设计、品牌标识归开发者所有\n'
                  '  App code, design, and brand belong to the developer\n'
                  '• 用户与AI的对话内容用于生成情绪分析，不会对外公开\n'
                  '  Chat content is used for emotion analysis only, not publicly shared\n'
                  '• AI生成的海报可以分享，但不得用于商业用途\n'
                  '  AI-generated posters may be shared but not used commercially',
                ),
                _SectionTitle('免责条款 / Limitation of Liability'),
                _BodyText(
                  '• 本应用为情绪释放辅助工具，不替代专业心理咨询或医疗服务\n'
                  '  This is an emotional outlet tool, NOT a substitute for professional '
                  'psychological or medical services\n'
                  '• AI 回复内容不代表开发者立场，开发者不对 AI 生成内容的准确性、完整性作保证\n'
                  '  AI responses do NOT represent the developer\'s views; no guarantee of accuracy or completeness\n'
                  '• 开发者已采取合理的內容安全措施，但不对用户行为造成的后果承担责任\n'
                  '  Developer has implemented reasonable content safety measures but assumes no liability\n'
                  '• 如发现内容问题，请通过举报功能联系我们\n'
                  '  Report content issues via the report feature',
                ),
                _SectionTitle('协议更新 / Updates to Terms'),
                _BodyText(
                  '我们可能会不时更新本协议。重大变更将通过 App 内通知告知。'
                  '继续使用即表示您接受更新后的协议。\n'
                  'We may update these terms. Significant changes will be notified '
                  'in-app. Continued use constitutes acceptance.',
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          if (showAgreeButton) ...[
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                border: Border(
                  top: BorderSide(color: AppColors.divider.withOpacity(0.5)),
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

  const _SectionTitle({required this.text});

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

  const _BodyText({required this.text});

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
