import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../exercise/model/exercise_models.dart';

/// motive-app `features/workout_record/provider/record_draft_provider.dart`에 대응 —
/// 운동기록 작성 중 서버 미저장 상태(draft). 제출 시 `WorkoutRecordCreateRequest`로 변환한다.
class RecordSet {
  const RecordSet({this.weight = 0, this.reps = 0});

  final double weight;
  final int reps;

  RecordSet copyWith({double? weight, int? reps}) =>
      RecordSet(weight: weight ?? this.weight, reps: reps ?? this.reps);
}

class RecordExercise {
  const RecordExercise({required this.exercise, required this.sets});

  final ExerciseResponse exercise;
  final List<RecordSet> sets;

  RecordExercise copyWith({List<RecordSet>? sets}) =>
      RecordExercise(exercise: exercise, sets: sets ?? this.sets);
}

const _defaultSetCount = 4;

class RecordDraftNotifier extends Notifier<List<RecordExercise>> {
  @override
  List<RecordExercise> build() => [];

  void addExercise(ExerciseResponse exercise) {
    if (state.any((r) => r.exercise.exerciseId == exercise.exerciseId)) return;
    state = [
      ...state,
      RecordExercise(
        exercise: exercise,
        sets: List.generate(_defaultSetCount, (_) => const RecordSet()),
      ),
    ];
  }

  void removeExercise(int exerciseId) {
    state = state.where((r) => r.exercise.exerciseId != exerciseId).toList();
  }

  void addSet(int exerciseId) {
    state = state.map((r) {
      if (r.exercise.exerciseId != exerciseId) return r;
      final last = r.sets.isNotEmpty ? r.sets.last : const RecordSet();
      return r.copyWith(sets: [...r.sets, last]);
    }).toList();
  }

  void removeSet(int exerciseId, int setIndex) {
    state = state.map((r) {
      if (r.exercise.exerciseId != exerciseId) return r;
      final sets = [...r.sets]..removeAt(setIndex);
      return r.copyWith(sets: sets);
    }).toList();
  }

  void updateSet(int exerciseId, int setIndex, {double? weight, int? reps}) {
    state = state.map((r) {
      if (r.exercise.exerciseId != exerciseId) return r;
      final sets = [...r.sets];
      sets[setIndex] = sets[setIndex].copyWith(weight: weight, reps: reps);
      return r.copyWith(sets: sets);
    }).toList();
  }

  void reset() => state = [];

  /// 기존 운동기록을 수정할 때 draft를 그 내용으로 통째로 채운다.
  void setAll(List<RecordExercise> records) => state = records;

  /// "이전 기록 불러오기" — 불러온 운동들을 현재 draft에 이어붙인다. 이미 담겨있는 운동
  /// (exerciseId 중복)은 [addExercise]와 동일하게 건너뛴다.
  void addAll(List<RecordExercise> records) {
    final existingIds = state.map((r) => r.exercise.exerciseId).toSet();
    state = [
      ...state,
      ...records.where((r) => !existingIds.contains(r.exercise.exerciseId)),
    ];
  }
}

final recordDraftProvider = NotifierProvider<RecordDraftNotifier, List<RecordExercise>>(
  RecordDraftNotifier.new,
);
