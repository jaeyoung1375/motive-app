import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 메인 화면 하단 탭바(토스 메인 화면의 홈/혜택/쇼핑/증권/전체 바에 대응).
/// 지금은 "홈"·"프로필"·"전체" 탭만 실제로 동작한다 — 분석/커뮤니티 화면은 아직 없다.
class MainBottomNav extends StatelessWidget {
  const MainBottomNav({super.key});

  static const _point = Color(0xFF2F80FF);
  static const _inactive = Color(0xFF94A3B8);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: 0,
      selectedItemColor: _point,
      unselectedItemColor: _inactive,
      onTap: (index) {
        if (index == 0) context.go('/');
        if (index == 2) context.go('/profile');
        if (index == 4) context.push('/settings');
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
        BottomNavigationBarItem(icon: Icon(Icons.bar_chart_rounded), label: '분석'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: '프로필'),
        BottomNavigationBarItem(icon: Icon(Icons.groups_outlined), label: '커뮤니티'),
        BottomNavigationBarItem(icon: Icon(Icons.menu), label: '전체'),
      ],
    );
  }
}
