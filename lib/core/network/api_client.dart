import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../env/env.dart';
import 'api_response.dart';

/// motive-ui의 util/AxiosUtil.ts에 대응하는 HTTP 클라이언트.
///
/// ⚠️ **모바일 전환 시 반드시 재검토할 지점**: motive-server의 인증은
/// accessToken을 응답 바디로, refreshToken은 `httpOnly` 쿠키로 내려주는
/// 웹 전제 설계다(motive-server `06_domain_playbooks/auth.md`). 브라우저는
/// 쿠키를 자동 저장/전송하지만 네이티브 앱은 그렇지 않다 — 이 클라이언트는
/// 현재 쿠키 저장소를 연결하지 않았으므로 `/auth/refresh`가 refreshToken
/// 쿠키를 못 받아 동작하지 않는다. 실제 로그인 연동 전에 다음 중 하나를
/// 백엔드팀과 확정해야 한다:
///   1) `dio_cookie_manager` + `cookie_jar`로 쿠키 저장소를 붙인다 (백엔드
///      쿠키 방식을 그대로 유지)
///   2) 백엔드가 모바일 클라이언트에는 refreshToken을 응답 바디로 내려주도록
///      바꾸고, 앱은 `flutter_secure_storage`에 저장한다
/// 아래 인터셉터는 accessToken(Authorization 헤더) 처리만 구현되어 있다.
class ApiClient {
  ApiClient() : dio = Dio(BaseOptions(baseUrl: Env.apiBaseUrl, connectTimeout: const Duration(seconds: 5))) {
    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor(requestHeader: false, responseBody: true));
    }
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_accessToken != null) {
            options.headers['Authorization'] = 'Bearer $_accessToken';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          final status = error.response?.statusCode;
          final path = error.requestOptions.path;
          final isAuthRoute = path.contains('/auth/login') || path.contains('/auth/refresh');
          final alreadyRetried = error.requestOptions.extra['retriedAfterRefresh'] == true;

          if (status == 401 && !isAuthRoute && !alreadyRetried && onTokenExpired != null) {
            final newToken = await _refreshToken();
            if (newToken != null) {
              try {
                final retryOptions = error.requestOptions
                  ..headers['Authorization'] = 'Bearer $newToken'
                  ..extra['retriedAfterRefresh'] = true;
                handler.resolve(await dio.fetch(retryOptions));
                return;
              } on DioException {
                // 재시도도 실패하면 아래의 기본 401 처리로 넘어간다.
              }
            }
          }

          if (status == 401 && !isAuthRoute) {
            _accessToken = null;
            onUnauthorized?.call();
          }
          handler.next(error);
        },
      ),
    );
  }

  final Dio dio;

  /// accessToken은 메모리에만 보관한다(motive-ui와 동일하게 앱 재시작 시 소실 →
  /// `/auth/refresh` 재호출로 복구하는 흐름을 그대로 따른다).
  String? _accessToken;

  void setAccessToken(String? token) => _accessToken = token;
  String? get accessToken => _accessToken;

  /// 401 발생 시 라우터를 홈/로그인으로 이동시키는 콜백.
  /// motive-ui의 `window.location.href = "/"`에 대응 — main.dart에서 주입한다.
  void Function()? onUnauthorized;

  /// 401 발생 시 토큰 재발급을 시도하는 콜백. 새 accessToken을 반환하면 실패했던 요청을
  /// 그 토큰으로 재시도하고, null을 반환하면(재발급 불가) 기존 401 처리로 넘어간다.
  /// `AuthNotifier`(auth_provider.dart)가 주입한다.
  Future<String?> Function()? onTokenExpired;

  /// 동시에 여러 요청이 401을 받아도 재발급 호출은 한 번만 나가도록 진행 중인 Future를 공유한다.
  Future<String?>? _refreshFuture;

  Future<String?> _refreshToken() {
    return _refreshFuture ??= onTokenExpired!().then((token) {
      if (token != null) _accessToken = token;
      return token;
    }).whenComplete(() => _refreshFuture = null);
  }

  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic json) fromJsonT,
  }) async {
    final res = await dio.get(path, queryParameters: queryParameters);
    return _unwrap(res, fromJsonT);
  }

  Future<T> post<T>(
    String path, {
    Object? body,
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic json) fromJsonT,
  }) async {
    final res = await dio.post(path, data: body, queryParameters: queryParameters);
    return _unwrap(res, fromJsonT);
  }

  Future<T> put<T>(
    String path, {
    Object? body,
    required T Function(dynamic json) fromJsonT,
  }) async {
    final res = await dio.put(path, data: body);
    return _unwrap(res, fromJsonT);
  }

  Future<T> patch<T>(
    String path, {
    Object? body,
    required T Function(dynamic json) fromJsonT,
  }) async {
    final res = await dio.patch(path, data: body);
    return _unwrap(res, fromJsonT);
  }

  Future<T> delete<T>(
    String path, {
    required T Function(dynamic json) fromJsonT,
  }) async {
    final res = await dio.delete(path);
    return _unwrap(res, fromJsonT);
  }

  Future<T> postForm<T>(
    String path,
    FormData formData, {
    required T Function(dynamic json) fromJsonT,
  }) async {
    final res = await dio.post(path, data: formData);
    return _unwrap(res, fromJsonT);
  }

  T _unwrap<T>(Response res, T Function(dynamic json) fromJsonT) {
    final body = ApiResponse<T>.fromJson(res.data as Map<String, dynamic>, fromJsonT);
    if (!body.isSuccess) {
      throw ApiException(code: body.code, message: body.message, data: body.data);
    }
    return body.data;
  }
}

/// 앱 전체에서 공유하는 단일 ApiClient 인스턴스.
/// motive-ui의 `util/AxiosUtil.ts` 모듈 스코프 axios 인스턴스에 대응.
final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());
