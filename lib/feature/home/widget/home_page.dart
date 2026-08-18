import 'package:flutter/material.dart';

import 'main_bottom_nav.dart';
import 'recommended_exercise_card.dart';

/// 온보딩을 마친 사용자의 메인 화면.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FF),
      bottomNavigationBar: const MainBottomNav(),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 402),
            child: const SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: RecommendedExerciseCard(),
            ),
          ),
        ),
      ),
    );
  }
}
