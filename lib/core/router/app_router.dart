import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:motive_app_toy/feature/auth/provider/auth_provider.dart';
import 'package:motive_app_toy/feature/auth/widget/login_route.dart';
import 'package:motive_app_toy/feature/home/widget/home_root_route.dart';
import 'package:motive_app_toy/feature/onboarding/widget/step1_route.dart';
import 'package:motive_app_toy/feature/onboarding/widget/step2_route.dart';
import 'package:motive_app_toy/feature/onboarding/widget/step3_route.dart';
import 'package:motive_app_toy/feature/onboarding/widget/step4_route.dart';
import 'package:motive_app_toy/feature/onboarding/widget/step5_route.dart';
import 'package:motive_app_toy/feature/onboarding/widget/step6_route.dart';
import 'package:motive_app_toy/feature/onboarding/widget/step7_route.dart';
import 'package:motive_app_toy/feature/onboarding/widget/step8_route.dart';
import 'package:motive_app_toy/feature/onboarding/widget/step9_route.dart';
import 'package:motive_app_toy/feature/onboarding/widget/step10_route.dart';
import 'package:motive_app_toy/feature/exercise/widget/exercise_list_route.dart';
import 'package:motive_app_toy/feature/profile/widget/previous_record_route.dart';
import 'package:motive_app_toy/feature/profile/widget/profile_route.dart';
import 'package:motive_app_toy/feature/profile/widget/record_detail_route.dart';
import 'package:motive_app_toy/feature/profile/widget/record_route.dart' show RecordRoute, RecordRouteArgs;
import 'package:motive_app_toy/feature/recommend/model/recommended_exercise_models.dart';
import 'package:motive_app_toy/feature/recommend/widget/recommended_exercise_route.dart';
import 'package:motive_app_toy/feature/settings/widget/settings_route.dart';
import 'package:motive_app_toy/feature/workout/widget/workout_session_route.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _AuthRefreshNotifier();
  ref.listen(authProvider, (previous, next) {
    if (previous != next) refreshNotifier.notify();
  });
  ref.onDispose(refreshNotifier.dispose);
  return GoRouter(
    initialLocation: '/',
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final isLoginRoute = state.matchedLocation == '/login';

      return authState.when(
        data: (session) {
          if (session == null) {
            return isLoginRoute ? null : '/login';
          }

          return isLoginRoute ? '/' : null;
        },
        loading: () => null,
        error: (error, stackTrace) => isLoginRoute ? null : '/login',
      );
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const HomeRootRoute()),
      GoRoute(path: '/login', builder: (context, state) => const LoginRoute()),
      GoRoute(
        path: '/onboarding/step-1',
        builder: (context, state) => const Step1Route(),
      ),
      GoRoute(
        path: '/onboarding/step-2',
        builder: (context, state) => const Step2Route(),
      ),
      GoRoute(
        path: '/onboarding/step-3',
        builder: (context, state) => const Step3Route(),
      ),
      GoRoute(
        path: '/onboarding/step-4',
        builder: (context, state) => const Step4Route(),
      ),
      GoRoute(
        path: '/onboarding/step-5',
        builder: (context, state) => const Step5Route(),
      ),
      GoRoute(
        path: '/onboarding/step-6',
        builder: (context, state) => const Step6Route(),
      ),
      GoRoute(
        path: '/onboarding/step-7',
        builder: (context, state) => const Step7Route(),
      ),
      GoRoute(
        path: '/onboarding/step-8',
        builder: (context, state) => const Step8Route(),
      ),
      GoRoute(
        path: '/onboarding/step-9',
        builder: (context, state) => const Step9Route(),
      ),
      GoRoute(
        path: '/onboarding/step-10',
        builder: (context, state) => const Step10Route(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsRoute(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileRoute(),
      ),
      GoRoute(
        path: '/profile/record',
        builder: (context, state) => RecordRoute(args: state.extra as RecordRouteArgs?),
      ),
      GoRoute(
        path: '/profile/record/previous',
        builder: (context, state) => const PreviousRecordRoute(),
      ),
      GoRoute(
        path: '/profile/record/:id',
        builder: (context, state) => RecordDetailRoute(
          workoutRecordId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/exercises',
        builder: (context, state) => ExerciseListRoute(
          isSelectMode: state.uri.queryParameters['select'] == '1',
        ),
      ),
      GoRoute(
        path: '/recommended-exercises',
        builder: (context, state) =>
            RecommendedExerciseRoute(exercises: state.extra as List<RecommendedExerciseResponse>),
      ),
      GoRoute(
        path: '/workout-session',
        builder: (context, state) =>
            WorkoutSessionRoute(exercises: state.extra as List<RecommendedExerciseResponse>),
      ),
    ],
  );
});

class _AuthRefreshNotifier extends ChangeNotifier {
  void notify() => notifyListeners();
}
