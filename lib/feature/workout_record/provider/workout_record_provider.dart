import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../data/workout_record_api.dart';
import '../model/workout_record_models.dart';

final workoutRecordApiProvider = Provider<WorkoutRecordApi>(
  (ref) => WorkoutRecordApi(ref.watch(apiClientProvider)),
);

/// motive-app `features/workout_record/provider/workout_record_provider.dart`의
/// `useWorkoutRecordListQuery(yearMonth)`에 대응. queryKey `["workout-records","list",yearMonth]`.
final workoutRecordListProvider = FutureProvider.family<List<WorkoutRecordResponse>, String>(
  (ref, yearMonth) => ref.watch(workoutRecordApiProvider).fetchList(yearMonth: yearMonth),
);

/// `useWorkoutRecordQuery(workoutRecordId)`에 대응. queryKey `["workout-records","detail",id]`.
final workoutRecordDetailProvider = FutureProvider.family<WorkoutRecordResponse, int>(
  (ref, workoutRecordId) => ref.watch(workoutRecordApiProvider).fetchDetail(workoutRecordId),
);

/// "이전 기록 불러오기"용 — 전체 목록(최신순) 중 최근 10개만 취한다.
final recentWorkoutRecordListProvider = FutureProvider<List<WorkoutRecordResponse>>((ref) async {
  final list = await ref.watch(workoutRecordApiProvider).fetchList();
  return list.take(10).toList();
});

/// motive-app `features/workout_record/provider/workout_record_provider.dart`의
/// `WorkoutRecordController`에 대응. 성공 시 영향받은 `yearMonth`(family 캐시 키)만 무효화한다.
class WorkoutRecordController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> create(WorkoutRecordCreateRequest body, {required String affectedYearMonth}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(workoutRecordApiProvider).create(body);
      ref.invalidate(workoutRecordListProvider(affectedYearMonth));
    });
  }

  /// [affectedYearMonths]에 수정 전/후 `yearMonth`를 모두 담아 넘긴다 — 날짜를
  /// 다른 달로 바꾸는 수정이면 두 달의 목록 캐시를 다 무효화해야 하기 때문이다.
  Future<void> update(
    int workoutRecordId,
    WorkoutRecordCreateRequest body, {
    required Set<String> affectedYearMonths,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(workoutRecordApiProvider).update(workoutRecordId, body);
      for (final yearMonth in affectedYearMonths) {
        ref.invalidate(workoutRecordListProvider(yearMonth));
      }
      ref.invalidate(workoutRecordDetailProvider(workoutRecordId));
    });
  }

  Future<void> delete(int workoutRecordId, {required String affectedYearMonth}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(workoutRecordApiProvider).delete(workoutRecordId);
      ref.invalidate(workoutRecordListProvider(affectedYearMonth));
    });
  }
}

final workoutRecordControllerProvider = NotifierProvider<WorkoutRecordController, AsyncValue<void>>(
  WorkoutRecordController.new,
);
