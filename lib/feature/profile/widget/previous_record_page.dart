import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/util/date_util.dart';
import '../../exercise/model/exercise_models.dart';
import '../../workout_record/model/workout_record_models.dart';
import '../../workout_record/provider/record_draft_provider.dart';
import '../../workout_record/provider/workout_record_provider.dart';

const _background = Color(0xFFF4F8FF);
const _point = Color(0xFF2F80FF);
const _textPrimary = Color(0xFF0B1220);
const _textSecondary = Color(0xFF64748B);
const _placeholder = Color(0xFF94A3B8);
const _border = Color(0xFFE2E8F0);

/// motive-app `features/profile/widget/previous_record_page.dart`에 대응.
/// 운동기록 작성화면(RecordPage)의 "이전 기록 불러오기"에서 진입한다.
/// 최근 운동기록 10개 중 하나를 골라 "불러오기"를 누르면, 그 기록의 운동/세트를
/// recordDraftProvider(현재 작성 중인 draft)에 이어붙이고 화면을 닫는다.
class PreviousRecordPage extends ConsumerStatefulWidget {
  const PreviousRecordPage({super.key, required this.onClose});

  final VoidCallback onClose;

  @override
  ConsumerState<PreviousRecordPage> createState() => _PreviousRecordPageState();
}

class _PreviousRecordPageState extends ConsumerState<PreviousRecordPage> {
  int? _selectedId;
  bool _loading = false;

  Future<void> _handleLoad() async {
    final selectedId = _selectedId;
    if (selectedId == null || _loading) return;

    setState(() => _loading = true);
    try {
      final detail = await ref.read(workoutRecordApiProvider).fetchDetail(selectedId);
      final loaded = [
        for (final ex in detail.exercises)
          RecordExercise(
            exercise: ExerciseResponse(exerciseId: ex.exerciseId, name: ex.exerciseName, bodyPartCd: '', equipmentCd: ''),
            sets: [for (final s in ex.sets) RecordSet(weight: s.weight, reps: s.reps)],
          ),
      ];
      ref.read(recordDraftProvider.notifier).addAll(loaded);
      widget.onClose();
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('운동 기록을 불러오지 못했어요.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final recordsAsync = ref.watch(recentWorkoutRecordListProvider);

    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 402),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 8, 20, 0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: widget.onClose,
                        icon: const Icon(Icons.close, size: 20, color: _textPrimary),
                      ),
                      const Expanded(
                        child: Text(
                          '이전 운동 기록',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: _textPrimary),
                        ),
                      ),
                      const SizedBox(width: 36),
                    ],
                  ),
                ),
                Expanded(
                  child: recordsAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (error, stackTrace) => const Center(
                      child: Text('기록을 불러오지 못했어요.', style: TextStyle(fontSize: 14, color: _placeholder)),
                    ),
                    data: (records) {
                      if (records.isEmpty) {
                        return const Center(
                          child: Text('이전 운동 기록이 없어요.', style: TextStyle(fontSize: 14, color: _placeholder)),
                        );
                      }
                      return ListView(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                        children: [
                          const Text(
                            '최근 기록 10개를 보여드려요.',
                            style: TextStyle(fontSize: 13, color: _textSecondary),
                          ),
                          const SizedBox(height: 16),
                          for (final record in records)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _RecordOption(
                                record: record,
                                selected: record.workoutRecordId == _selectedId,
                                onTap: () => setState(() => _selectedId = record.workoutRecordId),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _selectedId == null || _loading ? null : _handleLoad,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _point,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: _border,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                        elevation: 0,
                      ),
                      child: Text(
                        _loading ? '불러오는 중...' : '불러오기',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RecordOption extends StatelessWidget {
  const _RecordOption({required this.record, required this.selected, required this.onTap});

  final WorkoutRecordResponse record;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final date = DateUtil.parseRecordDt(record.recordDt);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? _point : _border, width: selected ? 2 : 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}. '
              '(${DateUtil.koreanWeekday(date)})',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              record.bodyPartNms?.isNotEmpty == true ? record.bodyPartNms! : record.categoryCd,
              style: const TextStyle(fontSize: 13, color: _textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
