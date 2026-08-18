import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class OnboardingState {
  const OnboardingState({
    this.nickname = '',
    this.profileImageBytes,
    this.profileImageName,
    this.gender = '',
    this.birth = '',
    this.goal = '',
    this.weeklyCount,
    this.levelCd = '',
    this.equipmentCd = '',
    this.gymId,
    this.height = 165,
    this.weight = 65,
    this.goalWeight = 63,
    this.experienceCd = '',
    this.squat,
    this.benchPress,
  });

  final String nickname;
  final Uint8List? profileImageBytes;
  final String? profileImageName;
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

  OnboardingState copyWith({
    String? nickname,
    Uint8List? profileImageBytes,
    String? profileImageName,
    String? gender,
    String? birth,
    String? goal,
    int? weeklyCount,
    String? levelCd,
    String? equipmentCd,
    String? gymId,
    double? height,
    double? weight,
    double? goalWeight,
    String? experienceCd,
    bool? squat,
    bool? benchPress,
  }) => OnboardingState(
    nickname: nickname ?? this.nickname,
    profileImageBytes: profileImageBytes ?? this.profileImageBytes,
    profileImageName: profileImageName ?? this.profileImageName,
    gender: gender ?? this.gender,
    birth: birth ?? this.birth,
    goal: goal ?? this.goal,
    weeklyCount: weeklyCount ?? this.weeklyCount,
    levelCd: levelCd ?? this.levelCd,
    equipmentCd: equipmentCd ?? this.equipmentCd,
    gymId: gymId ?? this.gymId,
    height: height ?? this.height,
    weight: weight ?? this.weight,
    goalWeight: goalWeight ?? this.goalWeight,
    experienceCd: experienceCd ?? this.experienceCd,
    squat: squat ?? this.squat,
    benchPress: benchPress ?? this.benchPress,
  );

  /// `copyWith`는 null 인자를 "값 없음"으로 취급해 넘어가므로 이미지 "삭제"를
  /// 표현할 수 없다 — 이미지를 다시 null로 되돌릴 때만 이 메서드를 쓴다.
  OnboardingState clearProfileImage() => OnboardingState(
    nickname: nickname,
    gender: gender,
    birth: birth,
    goal: goal,
    weeklyCount: weeklyCount,
    levelCd: levelCd,
    equipmentCd: equipmentCd,
    gymId: gymId,
    height: height,
    weight: weight,
    goalWeight: goalWeight,
    experienceCd: experienceCd,
    squat: squat,
    benchPress: benchPress,
  );
}
