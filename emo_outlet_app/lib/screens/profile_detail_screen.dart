import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../widgets/common/soft_ui.dart';

class ProfileDetailScreen extends StatefulWidget {
  const ProfileDetailScreen({super.key});

  @override
  State<ProfileDetailScreen> createState() => _ProfileDetailScreenState();
}

class _ProfileDetailScreenState extends State<ProfileDetailScreen> {
  final ApiService _api = ApiService();
  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;
  Map<String, dynamic> _profile = <String, dynamic>{};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final detail = await _api.getProfileDetail();
      if (!mounted) return;
      setState(() {
        _profile = detail;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '加载个人资料失败';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveProfile(Map<String, dynamic> values) async {
    setState(() => _isSaving = true);
    try {
      final result = await _api.updateProfileDetail(values);
      if (result['nickname'] != null) {
        await AuthService().refreshProfile();
      }
      if (!mounted) return;
      setState(() {
        _profile = result;
      });
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SoftPage(
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_error!, style: const TextStyle(color: SoftColors.text)),
                      const SizedBox(height: 12),
                      SoftOutlineButton(text: '重试', onTap: _load),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                  child: Column(
                    children: [
                      SoftHeader(
                        title: '个人资料',
                        onBack: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(height: 26),
                      SoftCard(
                        padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                        child: SizedBox(
                          height: 172,
                          child: Row(
                            children: [
                              Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Container(
                                    width: 116,
                                    height: 116,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 3),
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFFF9D9CB), Color(0xFFFFF2E9)],
                                      ),
                                      image: (_profile['avatar_url'] as String?)?.isNotEmpty == true
                                          ? DecorationImage(
                                              image: NetworkImage(_profile['avatar_url'] as String),
                                              fit: BoxFit.cover,
                                            )
                                          : null,
                                    ),
                                    child: (_profile['avatar_url'] as String?)?.isNotEmpty == true
                                        ? null
                                        : const Center(
                                            child: Icon(
                                              Icons.person_rounded,
                                              size: 56,
                                              color: Color(0xFFB77A55),
                                            ),
                                          ),
                                  ),
                                  Positioned(
                                    right: -2,
                                    bottom: 4,
                                    child: Container(
                                      width: 42,
                                      height: 42,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Color(0x20F0D1C5),
                                            blurRadius: 12,
                                            offset: Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.camera_alt_rounded,
                                        color: Color(0xFFFF946A),
                                        size: 21,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 18),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '头像',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w700,
                                        color: SoftColors.text,
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      '当前头像来自你的账户资料',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: SoftColors.subtext,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                width: 140,
                                height: 120,
                                child: Center(
                                  child: Icon(
                                    Icons.favorite_rounded,
                                    color: Color(0xFFFF8F86),
                                    size: 86,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      SoftCard(
                        padding: EdgeInsets.zero,
                        child: Column(
                          children: [
                            SoftListTile(
                              leading: const SoftIconBadge(
                                icon: Icons.person_rounded,
                                colors: [Color(0xFFFFC7B3), Color(0xFFFF8E66)],
                              ),
                              title: '昵称',
                              trailing: _trailingValue(_stringValue('nickname'), withArrow: true),
                              onTap: _showNicknameDialog,
                            ),
                            SoftListTile(
                              leading: const SoftIconBadge(
                                icon: Icons.badge_rounded,
                                colors: [Color(0xFFD9EEFF), Color(0xFF69B6FF)],
                              ),
                              title: '用户ID',
                              trailing: _trailingValue(_stringValue('user_id'), withArrow: false),
                            ),
                            SoftListTile(
                              leading: const SoftIconBadge(
                                icon: Icons.favorite_rounded,
                                colors: [Color(0xFFFFDCE7), Color(0xFFFF638E)],
                              ),
                              title: '个性签名',
                              trailing: _trailingValue(_stringValue('signature')),
                              onTap: () => _showFieldDialog('个性签名', 'signature', maxLength: 120),
                              showDivider: false,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      SoftCard(
                        padding: EdgeInsets.zero,
                        child: Column(
                          children: [
                            SoftListTile(
                              leading: const SoftIconBadge(
                                icon: Icons.transgender_rounded,
                                colors: [Color(0xFFF0DFFF), Color(0xFFB170FF)],
                              ),
                              title: '性别',
                              trailing: _trailingValue(_stringValue('gender')),
                              onTap: () => _showFieldDialog('性别', 'gender', maxLength: 20),
                            ),
                            SoftListTile(
                              leading: const SoftIconBadge(
                                icon: Icons.cake_rounded,
                                colors: [Color(0xFFFFE5B8), Color(0xFFFFB548)],
                              ),
                              title: '生日',
                              trailing: _trailingValue(_stringValue('birthday')),
                              onTap: () => _showFieldDialog('生日', 'birthday', maxLength: 20),
                            ),
                            SoftListTile(
                              leading: const SoftIconBadge(
                                icon: Icons.place_rounded,
                                colors: [Color(0xFFD8F7E6), Color(0xFF38D57B)],
                              ),
                              title: '所在地区',
                              trailing: _trailingValue(_stringValue('region')),
                              onTap: () => _showFieldDialog('所在地区', 'region', maxLength: 60),
                            ),
                            SoftListTile(
                              leading: const SoftIconBadge(
                                icon: Icons.phone_iphone_rounded,
                                colors: [Color(0xFFDFF0FF), Color(0xFF58AFFF)],
                              ),
                              title: '绑定手机',
                              trailing: _trailingValue(_stringValue('phone'), withArrow: false),
                              showDivider: false,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 26),
                      SizedBox(
                        width: double.infinity,
                        child: SoftGradientButton(
                          text: _isSaving ? '保存中...' : '保存',
                          height: 60,
                          fontSize: 18,
                          onTap: _isSaving ? null : () => Navigator.of(context).pop(),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  String _stringValue(String key) {
    final value = _profile[key];
    if (value == null) {
      return '-';
    }
    final text = '$value'.trim();
    return text.isEmpty ? '-' : text;
  }

  Widget _trailingValue(String value, {bool withArrow = true}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 180),
          child: Text(
            value,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 16, color: SoftColors.subtext),
          ),
        ),
        if (withArrow) ...[
          const SizedBox(width: 10),
          const Icon(
            Icons.chevron_right_rounded,
            color: Color(0xFFA3A6AE),
            size: 24,
          ),
        ],
      ],
    );
  }

  Future<void> _showNicknameDialog() async {
    final controller = TextEditingController(text: _stringValue('nickname'));
    await _showEditorDialog(
      title: '修改昵称',
      hintText: '请输入昵称',
      helperText: '昵称 2-12 个字',
      controller: controller,
      onConfirm: () async {
        final value = controller.text.trim();
        if (value.length < 2 || value.length > 12) {
          return;
        }
        await _saveProfile({'nickname': value});
      },
    );
  }

  Future<void> _showFieldDialog(
    String title,
    String field, {
    required int maxLength,
  }) async {
    final controller = TextEditingController(
      text: _profile[field] as String? ?? '',
    );
    await _showEditorDialog(
      title: title,
      hintText: '请输入$title',
      helperText: '$title 最多 $maxLength 个字',
      controller: controller,
      onConfirm: () => _saveProfile({field: controller.text.trim()}),
    );
  }

  Future<void> _showEditorDialog({
    required String title,
    required String hintText,
    required String helperText,
    required TextEditingController controller,
    required Future<void> Function() onConfirm,
  }) async {
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.2),
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 28),
          child: Stack(
            alignment: Alignment.topCenter,
            clipBehavior: Clip.none,
            children: [
              SoftCard(
                radius: 30,
                padding: const EdgeInsets.fromLTRB(22, 72, 22, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: SoftColors.text,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: const Color(0xFFFFD2C2)),
                        color: Colors.white.withValues(alpha: 0.86),
                      ),
                      child: TextField(
                        controller: controller,
                        decoration: InputDecoration(
                          hintText: hintText,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 18,
                          ),
                          suffixIcon: IconButton(
                            onPressed: controller.clear,
                            icon: const Icon(
                              Icons.cancel_rounded,
                              color: Color(0xFFB4B6BC),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        helperText,
                        style: const TextStyle(
                          fontSize: 14,
                          color: SoftColors.subtext,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: SoftOutlineButton(
                            text: '取消',
                            onTap: () => Navigator.of(context).pop(),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: SoftGradientButton(
                            text: '确认保存',
                            onTap: () async {
                              await onConfirm();
                              if (!mounted) return;
                              Navigator.of(context).pop();
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Positioned(
                top: -42,
                child: Icon(
                  Icons.favorite_rounded,
                  size: 86,
                  color: Color(0xFFFF9AA1),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
