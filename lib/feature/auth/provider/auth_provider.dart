import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/storage/token_storage.dart';
import '../data/auth_api.dart';
import '../model/auth_models.dart';

final authApiProvider = Provider<AuthApi>((ref) => AuthApi(ref.watch(apiClientProvider)));

/// motive-ui `features/auth/auth.query.ts`의 `useGetTokenQuery` + `AuthBootstrap.tsx`에 대응.
///
/// 앱 시작 시(main.dart에서 최초 1회 watch) 세션을 복원해 accessToken을 ApiClient에 채워두고
/// 온보딩 완료 여부(`onboardingCompleted`)를 노출한다. 웹은 `/auth/refresh`(httpOnly 쿠키),
/// 모바일은 `TokenStorage`에 보관된 refreshToken으로 `/auth/refresh/mobile`을 호출한다 —
/// 두 경로 모두 실패하면(= refreshToken 없음/만료) 비로그인 상태로 간주한다 — 재시도하지 않음
/// (motive-ui의 `retry: false`에 대응, Riverpod은 기본적으로 자동 재시도가 없으므로
/// 별도 설정이 필요 없다).
class AuthNotifier extends AsyncNotifier<RefreshResponse?> {
  @override
  Future<RefreshResponse?> build() async {
    ref.read(apiClientProvider).onTokenExpired = _reissueAccessToken;
    try {
      if (kIsWeb) {
        final result = await ref.read(authApiProvider).refresh();
        ref.read(apiClientProvider).setAccessToken(result.accessToken);
        return result;
      }

      final storedRefreshToken = await ref.read(tokenStorageProvider).readRefreshToken();
      if (storedRefreshToken == null) {
        return null;
      }
      return _applyMobileToken(await ref.read(authApiProvider).refreshMobile(storedRefreshToken));
    } catch (_) {
      ref.read(apiClientProvider).setAccessToken(null);
      return null;
    }
  }

  /// `ApiClient`가 401을 받았을 때 호출한다(`onTokenExpired`). 새 accessToken을 반환하면
  /// 실패했던 요청을 재시도하고, null을 반환하면(재발급 불가) 기존 401 처리(로그아웃)로 넘어간다.
  /// `build()`와 달리 세션 상태(`state`)는 건드리지 않는다 — 이미 로그인된 세션 도중 발생하는
  /// 일시적인 재발급이므로 화면에 로딩을 노출할 필요가 없다.
  Future<String?> _reissueAccessToken() async {
    try {
      if (kIsWeb) {
        return (await ref.read(authApiProvider).refresh()).accessToken;
      }

      final storedRefreshToken = await ref.read(tokenStorageProvider).readRefreshToken();
      if (storedRefreshToken == null) return null;

      final result = await ref.read(authApiProvider).refreshMobile(storedRefreshToken);
      await ref.read(tokenStorageProvider).saveRefreshToken(result.refreshToken);
      return result.accessToken;
    } catch (_) {
      return null;
    }
  }

  bool get isLoggedIn => state.value != null;

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => build());
  }

  Future<void> clear() async {
    // accessToken을 지우기 전에 먼저 호출해야 한다 — 서버가 인증된 요청으로 유저를 식별해서
    // Redis의 refreshToken을 지운다. 실패해도(네트워크 오류 등) 로컬 로그아웃은 진행한다.
    try {
      await ref.read(authApiProvider).logout();
    } catch (_) {}

    ref.read(apiClientProvider).setAccessToken(null);
    if (!kIsWeb) {
      ref.read(tokenStorageProvider).clearRefreshToken();
    }
    state = const AsyncData(null);
  }

  /// 소셜 로그인 딥링크 콜백에서 받은 1회용 코드로 로그인을 완료한다.
  Future<void> loginWithCode(String code) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () async => _applyMobileToken(await ref.read(authApiProvider).exchange(code)),
    );
  }

  /// accessToken을 ApiClient에 채우고(모바일이면) refreshToken을 시큐어 스토리지에 저장한 뒤,
  /// 세션 상태로 변환한다. `exchange`/`refreshMobile` 양쪽 응답에 공통으로 쓰인다.
  Future<RefreshResponse> _applyMobileToken(MobileTokenResponse result) async {
    ref.read(apiClientProvider).setAccessToken(result.accessToken);
    if (!kIsWeb) {
      await ref.read(tokenStorageProvider).saveRefreshToken(result.refreshToken);
    }
    return RefreshResponse(accessToken: result.accessToken, onboardingCompleted: result.onboardingCompleted);
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, RefreshResponse?>(AuthNotifier.new);

/// motive-ui `features/auth/auth.query.ts`의 `useMeQuery`에 대응.
/// 로그인 상태(accessToken 확보)일 때만 호출한다.
final meProvider = FutureProvider<User?>((ref) async {
  final auth = await ref.watch(authProvider.future);
  if (auth == null) return null;
  return ref.read(authApiProvider).me();
});
