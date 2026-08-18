import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../recommend/provider/recommended_exercise_provider.dart';

/// motive-app `features/home/widget/workout_home_page.dart`의 "오늘의 추천 운동" 카드에 대응.
class RecommendedExerciseCard extends ConsumerWidget {
  const RecommendedExerciseCard({super.key});

  static const _point = Color(0xFF2F80FF);
  static const _textPrimary = Color(0xFF0B1220);
  static const _textSecondary = Color(0xFF64748B);
  static const _border = Color(0xFFE2E8F0);
  static const _placeholder = Color(0xFF94A3B8);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recommendedAsync = ref.watch(recommendedExerciseListProvider);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '오늘의 추천 운동',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: _textPrimary),
              ),
              IconButton(
                onPressed: recommendedAsync.isLoading
                    ? null
                    : () => ref.invalidate(recommendedExerciseListProvider),
                icon: const Icon(Icons.refresh, size: 18, color: _textSecondary),
              ),
            ],
          ),
          recommendedAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, stackTrace) => const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('추천 운동을 불러오지 못했어요.', style: TextStyle(fontSize: 13, color: _placeholder)),
            ),
            data: (exercises) {
              if (exercises.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('아직 준비된 추천 운동이 없어요.', style: TextStyle(fontSize: 13, color: _placeholder)),
                );
              }
              final totalMinutes = exercises.fold<int>(0, (sum, ex) => sum + ex.durationMin);
              final totalSets = exercises.fold<int>(0, (sum, ex) => sum + ex.sets);
              final bodyParts = exercises.map((ex) => ex.bodyPartNm).whereType<String>().toSet().join(', ');
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    '${exercises.length}개의 운동 · $totalSets세트 · $totalMinutes분',
                    style: const TextStyle(fontSize: 13, color: _textSecondary),
                  ),
                  if (bodyParts.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      '운동 부위 $bodyParts',
                      style: const TextStyle(fontSize: 13, color: _textSecondary),
                    ),
                  ],
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => context.push('/recommended-exercises', extra: exercises),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _point,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                      child: const Text(
                        '추천 운동 미리보기',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
