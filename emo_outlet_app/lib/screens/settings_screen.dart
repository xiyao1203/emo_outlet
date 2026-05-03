import 'package:flutter/material.dart';
import 'privacy_policy_screen.dart';
import 'terms_of_service_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '设置中心',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF333333)),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFF8F8F8),
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF8F8F8),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(context, [
            _buildItem(Icons.lock_outline, '账号与安全', () {}),
            _buildItem(Icons.notifications_outlined, '消息通知', () {}),
            _buildItem(Icons.shield_outlined, '隐私设置', () {}),
            _buildItem(Icons.language_outlined, '语言设置', () {}),
          ]),
          const SizedBox(height: 16),
          _buildSection(context, [
            _buildItem(Icons.folder_outlined, '方案管理', () {}),
          ]),
          const SizedBox(height: 16),
          _buildSection(context, [
            _buildItem(Icons.help_outline, '帮助与反馈', () {}),
            _buildItem(Icons.info_outline, '关于我们', () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TermsOfServiceScreen()),
              );
            }),
            _buildItem(Icons.privacy_tip_outlined, '隐私政策', () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
              );
            }),
          ]),
          const SizedBox(height: 32),
          const Center(
            child: Text(
              'v1.0.0',
              style: TextStyle(fontSize: 10, color: Color(0xFF999999)),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, List<Widget> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: items),
    );
  }

  Widget _buildItem(IconData icon, String label, VoidCallback onTap) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF0F0F0), width: 0.5)),
      ),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF666666), size: 22),
        title: Text(label, style: const TextStyle(fontSize: 15, color: Color(0xFF333333))),
        trailing: const Icon(Icons.chevron_right, color: Color(0xFFCCCCCC), size: 20),
        onTap: onTap,
      ),
    );
  }
}
