import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:motive_app_toy/core/network/api_client.dart';
import '../data/onboarding_api.dart';
import 'package:motive_app_toy/feature/onboarding/model/onboarding_models.dart';
import 'package:motive_app_toy/feature/onboarding/provider/onboarding_state.dart';

final onboardingApiProvider = Provider<OnboardingApi>(
  (ref) => OnboardingApi(ref.watch(apiClientProvider)),
);

class OnboardingSubmitController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> submit() async {
    final draft = ref.read(onboardingProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(onboardingApiProvider)
          .insertProfile(
            InsertProfileRequest(
              nickname: draft.nickname,
              gender: draft.gender,
              birth: draft.birth,
              goal: draft.goal,
              weeklyCount: draft.weeklyCount,
              levelCd: draft.levelCd,
              equipmentCd: draft.equipmentCd,
              gymId: draft.gymId,
              height: draft.height,
              weight: draft.weight,
              goalWeight: draft.goalWeight,
              experienceCd: draft.experienceCd,
              squat: draft.squat,
              benchPress: draft.benchPress,
            ),
            profileImageBytes: draft.profileImageBytes,
            profileImageName: draft.profileImageName,
          ),
    );
  }
}

final onboardingSubmitControllerProvider =
    NotifierProvider<OnboardingSubmitController, AsyncValue<void>>(
      OnboardingSubmitController.new,
    );

class OnboardingNotifier extends Notifier<OnboardingState> {
  @override
  OnboardingState build() => const OnboardingState();

  void update(OnboardingState Function(OnboardingState state) updater) {
    state = updater(state);
  }

  void clearProfileImage() => state = state.clearProfileImage();

  void reset() => state = const OnboardingState();
}

final onboardingProvider =
    NotifierProvider<OnboardingNotifier, OnboardingState>(
      OnboardingNotifier.new,
    );
