/// motive-ui `features/onboarding/onboarding.type.ts`의 `InsertProfileRequest`에 대응.
class InsertProfileRequest {
  const InsertProfileRequest({
    required this.nickname,
    required this.gender,
    required this.birth,
    required this.goal,
    required this.weeklyCount,
    required this.levelCd,
    required this.equipmentCd,
    required this.gymId,
    required this.height,
    required this.weight,
    required this.goalWeight,
    required this.experienceCd,
    required this.squat,
    required this.benchPress,
  });

  final String nickname;
  final String gender;
  final String birth;
  final String goal;
  final int? weeklyCount;
  final String levelCd;
  final String equipmentCd;
  final String? gymId;
  final double height;
  final double weight;
  final double goalWeight;
  final String experienceCd;
  final bool? squat;
  final bool? benchPress;

  Map<String, dynamic> toJson() => {
        'nickname': nickname,
        'gender': gender,
        'birth': birth,
        'goal': goal,
        'weeklyCount': weeklyCount,
        'levelCd': levelCd,
        'equipmentCd': equipmentCd,
        'gymId': gymId,
        'height': height,
        'weight': weight,
        'goalWeight': goalWeight,
        'experienceCd': experienceCd,
        'squat': squat,
        'benchPress': benchPress,
      };
}
