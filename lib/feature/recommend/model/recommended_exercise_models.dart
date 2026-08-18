/// motive-server `RecommendedExerciseResponseDto`에 대응.
class RecommendedExerciseResponse {
  const RecommendedExerciseResponse({
    required this.recommendedExerciseId,
    required this.exerciseId,
    required this.exerciseName,
    this.bodyPartNm,
    this.imageFileId,
    required this.sets,
    required this.weight,
    required this.reps,
    required this.durationMin,
    required this.sortNo,
  });

  final int recommendedExerciseId;
  final int exerciseId;
  final String exerciseName;
  final String? bodyPartNm;
  final int? imageFileId;
  final int sets;
  final double weight;
  final int reps;
  final int durationMin;
  final int sortNo;

  factory RecommendedExerciseResponse.fromJson(Map<String, dynamic> json) => RecommendedExerciseResponse(
        recommendedExerciseId: json['recommendedExerciseId'] as int,
        exerciseId: json['exerciseId'] as int,
        exerciseName: json['exerciseName'] as String,
        bodyPartNm: json['bodyPartNm'] as String?,
        imageFileId: json['imageFileId'] as int?,
        sets: json['sets'] as int,
        weight: (json['weight'] as num).toDouble(),
        reps: json['reps'] as int,
        durationMin: json['durationMin'] as int,
        sortNo: json['sortNo'] as int,
      );
}
