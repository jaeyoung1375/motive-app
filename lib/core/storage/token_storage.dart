import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// refreshToken을 OS 시큐어 스토리지(Android Keystore / iOS Keychain)에 보관한다.
/// 모바일(non-web) 세션 복원 전용 — 웹은 여전히 httpOnly 쿠키 방식(`/auth/refresh`)을 쓴다.
class TokenStorage {
  const TokenStorage();

  static const _storage = FlutterSecureStorage();
  static const _refreshTokenKey = 'refreshToken';

  Future<void> saveRefreshToken(String token) => _storage.write(key: _refreshTokenKey, value: token);

  Future<String?> readRefreshToken() => _storage.read(key: _refreshTokenKey);

  Future<void> clearRefreshToken() => _storage.delete(key: _refreshTokenKey);
}

final tokenStorageProvider = Provider<TokenStorage>((ref) => const TokenStorage());
