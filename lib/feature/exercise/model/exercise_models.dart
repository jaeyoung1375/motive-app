/// motive-ui `features/exercise/exercise.type.ts`(API 응답)에 대응.
class ExerciseResponse {
  const ExerciseResponse({
    required this.exerciseId,
    required this.name,
    required this.bodyPartCd,
    this.bodyPartNm,
    required this.equipmentCd,
    this.equipmentNm,
  });

  final int exerciseId;
  final String name;
  final String bodyPartCd;
  final String? bodyPartNm;
  final String equipmentCd;
  final String? equipmentNm;

  factory ExerciseResponse.fromJson(Map<String, dynamic> json) => ExerciseResponse(
        exerciseId: json['exerciseId'] as int,
        name: json['name'] as String,
        bodyPartCd: json['bodyPartCd'] as String,
        bodyPartNm: json['bodyPartNm'] as String?,
        equipmentCd: json['equipmentCd'] as String,
        equipmentNm: json['equipmentNm'] as String?,
      );
}
