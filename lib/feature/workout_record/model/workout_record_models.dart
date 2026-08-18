/// motive-app `features/workout_record/model/workout_record_models.dart`에 대응.
class WorkoutRecordSetRequest {
  const WorkoutRecordSetRequest({required this.setNo, required this.weight, required this.reps});

  final int setNo;
  final double weight;
  final int reps;

  Map<String, dynamic> toJson() => {'setNo': setNo, 'weight': weight, 'reps': reps};
}

class WorkoutRecordExerciseRequest {
  const WorkoutRecordExerciseRequest({required this.exerciseId, required this.sets});

  final int exerciseId;
  final List<WorkoutRecordSetRequest> sets;

  Map<String, dynamic> toJson() => {
        'exerciseId': exerciseId,
        'sets': sets.map((s) => s.toJson()).toList(),
      };
}

class WorkoutRecordCreateRequest {
  const WorkoutRecordCreateRequest({
    required this.categoryCd,
    required this.recordDt,
    required this.durationMin,
    required this.exercises,
  });

  final String categoryCd;
  final String recordDt;
  final int durationMin;
  final List<WorkoutRecordExerciseRequest> exercises;

  Map<String, dynamic> toJson() => {
        'categoryCd': categoryCd,
        'recordDt': recordDt,
        'durationMin': durationMin,
        'exercises': exercises.map((e) => e.toJson()).toList(),
      };
}

class WorkoutRecordSetResponse {
  const WorkoutRecordSetResponse({required this.setNo, required this.weight, required this.reps});

  final int setNo;
  final double weight;
  final int reps;

  factory WorkoutRecordSetResponse.fromJson(Map<String, dynamic> json) => WorkoutRecordSetResponse(
        setNo: json['setNo'] as int,
        weight: (json['weight'] as num).toDouble(),
        reps: json['reps'] as int,
      );
}

class WorkoutRecordExerciseResponse {
  const WorkoutRecordExerciseResponse({
    required this.exerciseId,
    required this.exerciseName,
    required this.sets,
  });

  final int exerciseId;
  final String exerciseName;
  final List<WorkoutRecordSetResponse> sets;

  factory WorkoutRecordExerciseResponse.fromJson(Map<String, dynamic> json) => WorkoutRecordExerciseResponse(
        exerciseId: json['exerciseId'] as int,
        exerciseName: json['exerciseName'] as String,
        sets: (json['sets'] as List)
            .map((s) => WorkoutRecordSetResponse.fromJson(s as Map<String, dynamic>))
            .toList(),
      );
}

class WorkoutRecordResponse {
  const WorkoutRecordResponse({
    required this.workoutRecordId,
    required this.categoryCd,
    required this.recordDt,
    required this.durationMin,
    required this.exercises,
    this.bodyPartNms,
  });

  final int workoutRecordId;
  final String categoryCd;
  final String recordDt;
  final int durationMin;
  final List<WorkoutRecordExerciseResponse> exercises;

  /// 부위명 목록(쉼표 구분, 중복 제거) — 목록 조회(`fetchList`)에서만 채워진다.
  final String? bodyPartNms;

  factory WorkoutRecordResponse.fromJson(Map<String, dynamic> json) => WorkoutRecordResponse(
        workoutRecordId: json['workoutRecordId'] as int,
        categoryCd: json['categoryCd'] as String,
        recordDt: json['recordDt'] as String,
        durationMin: json['durationMin'] as int,
        exercises: (json['exercises'] as List?)
                ?.map((e) => WorkoutRecordExerciseResponse.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        bodyPartNms: json['bodyPartNms'] as String?,
      );
}
