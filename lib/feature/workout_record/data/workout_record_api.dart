import '../../../core/network/api_client.dart';
import '../model/workout_record_models.dart';

/// motive-app `features/workout_record/data/workout_record_api.dart`에 대응.
class WorkoutRecordApi {
  WorkoutRecordApi(this._client);

  final ApiClient _client;

  Future<void> create(WorkoutRecordCreateRequest body) => _client.post(
        '/api/v1/workout-records',
        body: body.toJson(),
        fromJsonT: (_) {},
      );

  /// 백엔드 `WorkoutRecordUpdateDto`가 `WorkoutRecordInsertDto`와 필드가 동일해
  /// 요청 바디 타입은 [WorkoutRecordCreateRequest]를 재사용한다.
  Future<void> update(int workoutRecordId, WorkoutRecordCreateRequest body) => _client.put(
        '/api/v1/workout-records/$workoutRecordId',
        body: body.toJson(),
        fromJsonT: (_) {},
      );

  Future<void> delete(int workoutRecordId) => _client.delete(
        '/api/v1/workout-records/$workoutRecordId',
        fromJsonT: (_) {},
      );

  /// 백엔드는 항상 로그인 회원의 전체 목록을 최신순(recordDt DESC)으로 내려준다
  /// (`yearMonth`는 서버에서 쓰이지 않는다 — 넘기면 그냥 무시됨). [yearMonth]는 캐시 무효화
  /// 단위(`workoutRecordListProvider.family`)를 나누기 위한 클라이언트 쪽 키일 뿐이라 생략 가능하다.
  Future<List<WorkoutRecordResponse>> fetchList({String? yearMonth}) => _client.get(
        '/api/v1/workout-records',
        queryParameters: yearMonth == null ? null : {'yearMonth': yearMonth},
        fromJsonT: (json) =>
            (json as List).map((e) => WorkoutRecordResponse.fromJson(e as Map<String, dynamic>)).toList(),
      );

  Future<WorkoutRecordResponse> fetchDetail(int workoutRecordId) => _client.get(
        '/api/v1/workout-records/$workoutRecordId',
        fromJsonT: (json) => WorkoutRecordResponse.fromJson(json as Map<String, dynamic>),
      );
}
