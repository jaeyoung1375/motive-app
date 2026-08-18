import 'package:flutter/material.dart';

/// 로그인 화면 전용 색상값.
///
/// motive-ui `app/login/LoginPage.tsx`가 쓰는 구버전 블루 팔레트(`#2F80FF`)를 그대로
/// 옮겼다 — `lib/features/onboarding/widget/onboarding_colors.dart`와 값이 동일하다
/// (motive-ui 원본 화면들이 공통으로 쓰던 팔레트라 우연이 아니다). 도메인 간 결합을
/// 피하려고 온보딩 쪽 클래스를 가져다 쓰지 않고 이 화면에도 동일하게 선언해뒀다
/// — 두 도메인 모두 "motive-ui 원본 그대로 포팅" 목적이므로 값이 바뀌면 양쪽 다 갱신할 것.
class LoginColors {
  LoginColors._();

  static const background = Color(0xFFF4F8FF);
  static const point = Color(0xFF2F80FF);
  static const textPrimary = Color(0xFF0B1220);
  static const textSecondary = Color(0xFF64748B);
  static const textPlaceholder = Color(0xFF94A3B8);
  static const border = Color(0xFFE2E8F0);
  static const kakaoYellow = Color(0xFFFEE500);
  static const kakaoText = Color(0xFF191919);
  static const githubBlack = Color(0xFF181717);
}
