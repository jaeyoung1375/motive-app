import '../../../core/network/api_client.dart';
import '../model/code_models.dart';

/// motive-ui `features/code/code.api.ts`에 대응.
class CodeApi {
  CodeApi(this._client);

  final ApiClient _client;

  /// `GET /api/v1/public/codes` — 그룹ID 목록으로 다건 조회.
  Future<Map<String, List<CodeResponse>>> fetchCodeList(
    List<String> comCdIds,
  ) => _client.get(
    '/api/v1/public/codes',
    queryParameters: {'comCdIds': comCdIds},
    fromJsonT: (json) => (json as Map<String, dynamic>).map(
      (key, value) => MapEntry(
        key,
        (value as List)
            .map((e) => CodeResponse.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
    ),
  );

  /// `GET /api/v1/public/code` — 단건(그룹) 조회.
  Future<List<CodeResponse>> fetchCode(String comCdId) => _client.get(
    '/api/v1/public/code',
    queryParameters: {'comCdId': comCdId},
    fromJsonT: (json) => (json as List)
        .map((e) => CodeResponse.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}
