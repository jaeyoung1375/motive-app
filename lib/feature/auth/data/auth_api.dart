import '../../../core/network/api_client.dart';
import '../model/auth_models.dart';

/// motive-ui `features/auth/auth.query.ts`의 axios 호출부에 대응.
class AuthApi {
  AuthApi(this._client);

  final ApiClient _client;

  Future<RefreshResponse> refresh() => _client.post(
        '/api/v1/auth/refresh',
        fromJsonT: (json) => RefreshResponse.fromJson(json as Map<String, dynamic>),
      );

  Future<User> me() => _client.get(
        '/api/v1/auth/me',
        fromJsonT: (json) => User.fromJson(json as Map<String, dynamic>),
      );

  /// 서버(Redis)에 보관된 refreshToken을 제거한다. accessToken이 있어야 호출 가능하므로
  /// 로컬 토큰을 지우기 전에 먼저 호출해야 한다.
  Future<void> logout() => _client.post(
        '/api/v1/auth/logout',
        fromJsonT: (_) {},
      );

  /// 소셜 로그인 딥링크 콜백(`motive://oauth-callback?code=`)의 1회용 코드를 실제 토큰으로 교환.
  Future<MobileTokenResponse> exchange(String code) => _client.post(
        '/api/v1/auth/exchange',
        body: {'code': code},
        fromJsonT: (json) => MobileTokenResponse.fromJson(json as Map<String, dynamic>),
      );

  /// 모바일 전용 refresh — 쿠키 대신 시큐어 스토리지에 보관해둔 refreshToken을 바디로 보낸다.
  Future<MobileTokenResponse> refreshMobile(String refreshToken) => _client.post(
        '/api/v1/auth/refresh/mobile',
        body: {'refreshToken': refreshToken},
        fromJsonT: (json) => MobileTokenResponse.fromJson(json as Map<String, dynamic>),
      );
}
