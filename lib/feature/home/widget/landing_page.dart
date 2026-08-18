import 'package:flutter/material.dart';

/// motive-ui `app/LandingPage.tsx`에 대응 — 로그인은 됐지만 온보딩(운동 프로필)을
/// 아직 완료하지 않은 사용자에게 보여주는 히어로 화면.
///
/// ⚠️ motive-ui 원본은 비로그인 사용자도 이 화면을 봤지만(마케팅 랜딩), motive-app은
/// 세션이 없으면 `/login`으로 보내도록 라우터에서 이미 가드해뒀다 — 이 화면은 "로그인은
/// 했지만 온보딩 미완료" 케이스로 도달 범위가 좁아졌다(`docs/ai/06_domain_playbooks/auth.md` 참고).
class LandingPage extends StatelessWidget {
  const LandingPage({super.key, required this.onGetStarted});

  final VoidCallback onGetStarted;

  static const _background = Color(0xFFF4F8FF);
  static const _hero = Color(0xFFE4EEFF);
  static const _point = Color(0xFF2F80FF);
  static const _textPrimary = Color(0xFF0B1220);
  static const _textSecondary = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 402),
          child: Column(
            children: [
              Expanded(
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    color: _hero,
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
                  ),
                  child: Center(
                    child: Container(
                      width: 170,
                      height: 170,
                      decoration: const BoxDecoration(color: _point, shape: BoxShape.circle),
                      child: const Icon(Icons.favorite, size: 64, color: Colors.white),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(26, 28, 26, 34),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Motive',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: _textPrimary),
                    ),
                    const SizedBox(height: 6),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 24),
                      child: Text(
                        '오늘의 동기부여, 모티브와 함께 시작해요',
                        style: TextStyle(fontSize: 14, color: _textSecondary),
                      ),
                    ),
                    SizedBox(
                      height: 53,
                      child: ElevatedButton(
                        onPressed: onGetStarted,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _point,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                        ),
                        child: const Text('시작하기', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
