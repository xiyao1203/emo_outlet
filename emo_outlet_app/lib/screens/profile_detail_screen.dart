import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../widgets/common/soft_ui.dart';

class ProfileDetailScreen extends StatefulWidget {
  const ProfileDetailScreen({super.key});

  @override
  State<ProfileDetailScreen> createState() => _ProfileDetailScreenState();
}

class _ProfileDetailScreenState extends State<ProfileDetailScreen> {
  static const List<String> _genderOptions = ['女', '男', '不展示'];
  static const List<String> _regionOptions = [
    '中国·上海',
    '中国·北京',
    '中国·广州',
    '中国·深圳',
    '中国·杭州',
    '中国·成都',
    '中国·武汉',
    '中国·西安',
    '中国·南京',
    '中国·重庆',
  ];

  final ApiService _api = ApiService();
  final ImagePicker _picker = ImagePicker();

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
      setState(() => _profile = detail);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = '加载个人资料失败');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveProfile(Map<String, dynamic> values) async {
    setState(() => _isSaving = true);
    try {
      final result = await _api.updateProfileDetail(values);
      await AuthService().refreshProfile();
      if (!mounted) return;
      setState(() => _profile = result);
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _changeAvatar() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 86,
      maxWidth: 1080,
    );
    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    final lower = picked.name.toLowerCase();
    final mimeType = lower.endsWith('.png')
        ? 'image/png'
        : lower.endsWith('.webp')
            ? 'image/webp'
            : 'image/jpeg';
    final dataUrl = 'data:$mimeType;base64,${base64Encode(bytes)}';
    await _saveProfile({'avatar_url': dataUrl});
  }

  Future<void> _selectGender() async {
    final selected = await _showOptionSheet(
      title: '选择性别',
      options: _genderOptions,
      current: _stringValue('gender'),
    );
    if (selected == null) return;
    await _saveProfile({'gender': selected});
  }

  Future<void> _selectBirthday() async {
    final raw = _stringValue('birthday');
    final initial = DateTime.tryParse(raw) ?? DateTime(1998, 5, 20);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1950, 1, 1),
      lastDate: DateTime.now(),
    );
    if (picked == null) return;
    final text =
        '${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    await _saveProfile({'birthday': text});
  }

  Future<void> _selectRegion() async {
    final selected = await _showOptionSheet(
      title: '选择所在地区',
      options: _regionOptions,
      current: _stringValue('region'),
    );
    if (selected == null) return;
    await _saveProfile({'region': selected});
  }

  Future<String?> _showOptionSheet({
    required String title,
    required List<String> options,
    required String current,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (dialogContext) {
        return SafeArea(
          top: false,
          child: SoftCard(
            radius: 30,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE7D7CF),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: SoftColors.text,
                  ),
                ),
                const SizedBox(height: 10),
                for (final option in options)
                  SoftListTile(
                    leading: SoftIconBadge(
                      icon: option == current
                          ? Icons.check_rounded
                          : Icons.circle_outlined,
                      colors: option == current
                          ? const [Color(0xFFFFD8CA), Color(0xFFFF8F66)]
                          : const [Color(0xFFE9EDF4), Color(0xFFBBC2CD)],
                      size: 44,
                    ),
                    title: option,
                    showDivider: option != options.last,
                    onTap: () => Navigator.of(context).pop(option),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _stringValue(String key) {
    final value = _profile[key];
    if (value == null) return '-';
    final text = '$value'.trim();
    return text.isEmpty ? '-' : text;
  }

  ImageProvider<Object>? _avatarProvider(String? value) {
    if (value == null || value.isEmpty) return null;
    if (value.startsWith('data:image')) {
      return MemoryImage(base64Decode(value.split(',').last));
    }
    return NetworkImage(value);
  }

  Widget _trailingValue(String value, {bool withArrow = true}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 150),
          child: Text(
            value,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14, color: SoftColors.subtext),
          ),
        ),
        if (withArrow) ...[
          const SizedBox(width: 10),
          const Icon(
            Icons.chevron_right_rounded,
            color: Color(0xFFA3A6AE),
            size: 22,
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
        if (value.length < 2 || value.length > 12) return;
        await _saveProfile({'nickname': value});
      },
    );
  }

  Future<void> _showSignatureDialog() async {
    final controller = TextEditingController(text: _stringValue('signature'));
    await _showEditorDialog(
      title: '个性签名',
      hintText: '写一句想让别人认识你的话',
      helperText: '最多 120 个字',
      controller: controller,
      onConfirm: () => _saveProfile({'signature': controller.text.trim()}),
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
      builder: (dialogContext) {
        final navigator = Navigator.of(dialogContext);
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 28),
          child: SoftCard(
            radius: 30,
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: SoftColors.text,
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: const Color(0xFFFFD2C2)),
                    color: Colors.white.withValues(alpha: 0.86),
                  ),
                  child: TextField(
                    controller: controller,
                    maxLines: title == '个性签名' ? 3 : 1,
                    decoration: InputDecoration(
                      hintText: hintText,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    helperText,
                    style: const TextStyle(
                      fontSize: 13,
                      color: SoftColors.subtext,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: SoftOutlineButton(
                        text: '取消',
                        onTap: () => navigator.pop(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SoftGradientButton(
                        text: '保存',
                        onTap: () async {
                          await onConfirm();
                          if (!mounted) return;
                          navigator.pop();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
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
                      Text(
                        _error!,
                        style: const TextStyle(color: SoftColors.text),
                      ),
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
                      const SizedBox(height: 22),
                      SoftCard(
                        padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                        child: Row(
                          children: [
                            InkWell(
                              onTap: _isSaving ? null : _changeAvatar,
                              borderRadius: BorderRadius.circular(999),
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Container(
                                    width: 96,
                                    height: 96,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 3,
                                      ),
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFFF9D9CB),
                                          Color(0xFFFFF2E9),
                                        ],
                                      ),
                                      image: _avatarProvider(
                                                _profile['avatar_url']
                                                    as String?,
                                              ) !=
                                              null
                                          ? DecorationImage(
                                              image: _avatarProvider(
                                                _profile['avatar_url']
                                                    as String?,
                                              )!,
                                              fit: BoxFit.cover,
                                            )
                                          : null,
                                    ),
                                    child: (_profile['avatar_url'] as String?)
                                                ?.isNotEmpty ==
                                            true
                                        ? null
                                        : const Center(
                                            child: Icon(
                                              Icons.person_rounded,
                                              size: 46,
                                              color: Color(0xFFB77A55),
                                            ),
                                          ),
                                  ),
                                  Positioned(
                                    right: -2,
                                    bottom: 4,
                                    child: Container(
                                      width: 38,
                                      height: 38,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white,
                                      ),
                                      child: const Icon(
                                        Icons.camera_alt_rounded,
                                        color: Color(0xFFFF946A),
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 14),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '头像',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: SoftColors.text,
                                    ),
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    '点击更换头像',
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      color: SoftColors.subtext,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (_isSaving)
                              const SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
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
                                icon: Icons.person_rounded,
                                colors: [Color(0xFFFFC7B3), Color(0xFFFF8E66)],
                              ),
                              title: '昵称',
                              trailing:
                                  _trailingValue(_stringValue('nickname')),
                              onTap: _showNicknameDialog,
                            ),
                            SoftListTile(
                              leading: const SoftIconBadge(
                                icon: Icons.badge_rounded,
                                colors: [Color(0xFFD9EEFF), Color(0xFF69B6FF)],
                              ),
                              title: '用户ID',
                              trailing: _trailingValue(
                                _stringValue('user_id'),
                                withArrow: false,
                              ),
                            ),
                            SoftListTile(
                              leading: const SoftIconBadge(
                                icon: Icons.favorite_rounded,
                                colors: [Color(0xFFFFDCE7), Color(0xFFFF638E)],
                              ),
                              title: '个性签名',
                              trailing:
                                  _trailingValue(_stringValue('signature')),
                              onTap: _showSignatureDialog,
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
                              onTap: _selectGender,
                            ),
                            SoftListTile(
                              leading: const SoftIconBadge(
                                icon: Icons.cake_rounded,
                                colors: [Color(0xFFFFE5B8), Color(0xFFFFB548)],
                              ),
                              title: '生日',
                              trailing:
                                  _trailingValue(_stringValue('birthday')),
                              onTap: _selectBirthday,
                            ),
                            SoftListTile(
                              leading: const SoftIconBadge(
                                icon: Icons.place_rounded,
                                colors: [Color(0xFFD8F7E6), Color(0xFF38D57B)],
                              ),
                              title: '所在地区',
                              trailing: _trailingValue(_stringValue('region')),
                              onTap: _selectRegion,
                              showDivider: false,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
