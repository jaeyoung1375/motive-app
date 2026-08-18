import 'package:flutter/material.dart';

/// 온보딩 화면 전용 색상값.
///
/// ⚠️ motive-ui `app/onboarding/Step1Page.tsx`는 `@/components/Button`(구 컴포넌트
/// 세트)을 쓰는데, 이 구 세트는 CLAUDE.md에 적힌 원래 디자인 컨셉(포인트 블루 `#2F80FF`)을
/// 그대로 하드코딩하고 있다 — `lib/core/theme/app_theme.dart`에 이미 설정해둔 오렌지
/// 계열(`motive-500`, `components/ui/` 신 세트 기준)과는 다른 팔레트다
/// (motive-ui `12_known_issues` 3번: 두 팔레트가 공존). 이 화면은 **원본 그대로**
/// 포팅하는 것이 목적이라 여기서는 블루 팔레트를 그대로 쓴다 — 앱 전체 색상을
/// 오렌지/블루 중 무엇으로 통일할지는 아직 결정된 사항이 아니다.
class OnboardingColors {
  OnboardingColors._();

  static const background = Color(0xFFF4F8FF);
  static const point = Color(0xFF2F80FF);
  static const textPrimary = Color(0xFF0B1220);
  static const textSecondary = Color(0xFF64748B);
  static const textPlaceholder = Color(0xFF94A3B8);
  static const border = Color(0xFFE2E8F0);
}
