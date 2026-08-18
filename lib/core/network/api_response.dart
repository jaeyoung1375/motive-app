/// 백엔드 공통 응답 포맷: `{ code, data, message }`, `code == "0000"`이 성공.
/// motive-ui의 util/AxiosUtil.ts 내부 `ApiResponse<T>`에 대응.
class ApiResponse<T> {
  const ApiResponse({required this.code, required this.data, required this.message});

  final String code;
  final T data;
  final String message;

  bool get isSuccess => code == '0000';

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic json) fromJsonT,
  ) {
    return ApiResponse<T>(
      code: json['code'] as String,
      data: fromJsonT(json['data']),
      message: json['message'] as String? ?? '',
    );
  }
}

/// 서버가 `code != "0000"`을 반환했을 때 던지는 예외.
/// motive-ui의 axios 응답 인터셉터가 reject하는 `{code, data, message}`에 대응.
class ApiException implements Exception {
  const ApiException({required this.code, required this.message, this.data});

  final String code;
  final String message;
  final dynamic data;

  @override
  String toString() => 'ApiException($code): $message';
}
