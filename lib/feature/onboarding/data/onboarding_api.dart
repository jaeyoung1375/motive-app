import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../model/onboarding_models.dart';

/// motive-ui `features/onboarding/onboarding.api.ts`의 `insertProfile`에 대응.
/// motive-ui의 `util/FileUtil.ts` `toMultipart`(JSON 파트 + 파일 파트)와 동일한 형태로
/// `FormData`를 구성한다.
///
/// 이미지는 파일 경로가 아니라 바이트(`Uint8List`)로 받는다 — `MultipartFile.fromFile`은
/// `dart:io` 기반이라 Flutter 웹에서 동작하지 않고, `fromBytes`는 모든 플랫폼에서 동작한다.
class OnboardingApi {
  OnboardingApi(this._client);

  final ApiClient _client;

  Future<void> insertProfile(
    InsertProfileRequest body, {
    Uint8List? profileImageBytes,
    String? profileImageName,
  }) async {
    final formData = FormData.fromMap({
      'data': MultipartFile.fromString(
        jsonEncode(body.toJson()),
        contentType: DioMediaType('application', 'json'),
      ),
      if (profileImageBytes != null)
        'profileImage': MultipartFile.fromBytes(profileImageBytes, filename: profileImageName ?? 'profile.jpg'),
    });

    await _client.postForm('/api/v1/fitness-profile', formData, fromJsonT: (_) {});
  }
}
