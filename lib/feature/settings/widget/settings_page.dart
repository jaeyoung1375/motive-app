import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/provider/auth_provider.dart';

const _background = Color(0xFFF4F8FF);
const _textPrimary = Color(0xFF0B1220);
const _placeholder = Color(0xFF94A3B8);
const _border = Color(0xFFE2E8F0);
const _danger = Color(0xFFE5484D);

/// motive-app `features/settings/widget/settings_page.dart`에 대응 — 설정 화면.
/// 메뉴는 아직 하드코딩(내 계정/로그아웃/탈퇴하기)이고, "내 계정"은 연결할 화면이
/// 없어 탭해도 반응하지 않는 자리 표시 항목이다.
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key, required this.onBack});

  final VoidCallback onBack;

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('정말 로그아웃 하시겠어요?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('취소')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('로그아웃')),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(authProvider.notifier).clear();
  }

  // 회원 탈퇴 API가 motive-server에 아직 없다 — 연동 전까지는 확인만 받고 끝낸다.
  Future<void> _confirmWithdraw(BuildContext context) async {
    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('탈퇴하기'),
        content: const Text('정말 탈퇴하시겠어요? 이 작업은 되돌릴 수 없어요.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('취소')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('탈퇴', style: TextStyle(color: _danger)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 402),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 8, 20, 0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: onBack,
                        icon: const Icon(Icons.chevron_left, size: 22, color: _textPrimary),
                      ),
                      const Expanded(
                        child: Text(
                          '설정',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: _textPrimary),
                        ),
                      ),
                      const SizedBox(width: 36),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _border),
                    ),
                    child: Column(
                      children: [
                        const _SettingsRow(label: '내 계정', enabled: false),
                        const Divider(height: 1, color: _border),
                        _SettingsRow(label: '로그아웃', onTap: () => _confirmLogout(context, ref)),
                        const Divider(height: 1, color: _border),
                        _SettingsRow(label: '탈퇴하기', onTap: () => _confirmWithdraw(context)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({required this.label, this.onTap, this.enabled = true});

  final String label;
  final VoidCallback? onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(fontSize: 15, color: enabled ? _textPrimary : _placeholder)),
            const Icon(Icons.chevron_right, size: 18, color: _placeholder),
          ],
        ),
      ),
    );
  }
}
