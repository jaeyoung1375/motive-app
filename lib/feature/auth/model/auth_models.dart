/// motive-ui `features/auth/auth.type.ts`에 대응.
class RefreshResponse {
  const RefreshResponse({required this.accessToken, required this.onboardingCompleted});

  final String accessToken;
  final bool onboardingCompleted;

  factory RefreshResponse.fromJson(Map<String, dynamic> json) => RefreshResponse(
        accessToken: json['accessToken'] as String,
        onboardingCompleted: json['onboardingCompleted'] as bool,
      );

  @override
  String toString() => 'RefreshResponse(accessToken: $accessToken, onboardingCompleted: $onboardingCompleted)';
}

/// motive-server `POST /auth/exchange` 응답에 대응 — 모바일 전용 흐름이라 accessToken과
/// 함께 refreshToken도 쿠키가 아닌 바디로 내려준다(`AuthController.exchange` 참고).
class MobileTokenResponse {
  const MobileTokenResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.isNew,
    required this.onboardingCompleted,
  });

  final String accessToken;
  final String refreshToken;
  final bool? isNew;
  final bool onboardingCompleted;

  factory MobileTokenResponse.fromJson(Map<String, dynamic> json) => MobileTokenResponse(
        accessToken: json['accessToken'] as String,
        refreshToken: json['refreshToken'] as String,
        isNew: json['isNew'] as bool?,
        onboardingCompleted: json['onboardingCompleted'] as bool,
      );
}

class User {
  const User({
    required this.id,
    required this.email,
    required this.name,
    required this.phone,
    required this.role,
    required this.status,
    this.profileFileId,
    required this.provider,
    this.gender,
    this.birth,
    required this.regDt,
    required this.modDt,
    this.lastLoginDt,
  });

  final int id;
  final String email;
  final String name;
  final String phone;
  final String role;
  final String status;
  final String? profileFileId;
  final String provider;
  final String? gender;
  final String? birth;
  final String regDt;
  final String modDt;
  final String? lastLoginDt;

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as int,
        email: json['email'] as String,
        name: json['name'] as String,
        phone: json['phone'] as String,
        role: json['role'] as String,
        status: json['status'] as String,
        profileFileId: json['profileFileId'] as String?,
        provider: json['provider'] as String,
        gender: json['gender'] as String?,
        birth: json['birth'] as String?,
        regDt: json['regDt'] as String,
        modDt: json['modDt'] as String,
        lastLoginDt: json['lastLoginDt'] as String?,
      );
}
