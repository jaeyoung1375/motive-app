import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:motive_app_toy/feature/auth/provider/auth_provider.dart';
import 'package:motive_app_toy/feature/home/widget/home_page.dart';
import 'package:motive_app_toy/feature/home/widget/landing_route.dart';

class HomeRootRoute extends ConsumerWidget {
  const HomeRootRoute({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return authState.when(
      data: (session) {
        if (session == null) {
          return const _BlankBackground();
        }

        return session.onboardingCompleted
            ? const HomePage()
            : const LandingRoute();
      },
      loading: () => const _BlankBackground(),
      error: (error, stackTrace) => const _BlankBackground(),
    );
  }
}

class _BlankBackground extends StatelessWidget {
  const _BlankBackground();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(backgroundColor: Color(0xFFF4F8FF));
  }
}
