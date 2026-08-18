import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/util/date_util.dart';
import '../../workout_record/model/workout_record_models.dart';
import '../../workout_record/provider/workout_record_provider.dart';

const _background = Color(0xFFF4F8FF);
const _point = Color(0xFF2F80FF);
const _textPrimary = Color(0xFF0B1220);
const _textSecondary = Color(0xFF64748B);
const _placeholder = Color(0xFF94A3B8);
const _border = Color(0xFFE2E8F0);

/// motive-app `features/profile/widget/record_detail_page.dart`에 대응 — 운동기록 상세.
class RecordDetailPage extends ConsumerWidget {
  const RecordDetailPage({
    super.key,
    required this.workoutRecordId,
    required this.onBack,
    required this.onEdit,
    required this.onDeleted,
  });

  final int workoutRecordId;
  final VoidCallback onBack;
  final void Function(WorkoutRecordResponse record) onEdit;
  final VoidCallback onDeleted;

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, WorkoutRecordResponse record) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('운동 기록 삭제'),
        content: const Text('이 운동 기록을 삭제할까요? 삭제하면 되돌릴 수 없어요.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('취소')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('삭제')),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final affectedYearMonth = DateUtil.formatYearMonth(DateUtil.parseRecordDt(record.recordDt));
    await ref
        .read(workoutRecordControllerProvider.notifier)
        .delete(record.workoutRecordId, affectedYearMonth: affectedYearMonth);
    if (!context.mounted) return;

    if (ref.read(workoutRecordControllerProvider).hasError) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('운동 기록 삭제에 실패했습니다.')));
      return;
    }
    onDeleted();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordAsync = ref.watch(workoutRecordDetailProvider(workoutRecordId));

    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 402),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: onBack,
                        icon: const Icon(Icons.chevron_left, size: 22, color: _textPrimary),
                      ),
                      const Text(
                        '운동 기록',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: _textPrimary),
                      ),
                      recordAsync.valueOrNull == null
                          ? const SizedBox(width: 36, height: 36)
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () => onEdit(recordAsync.value!),
                                  icon: const Icon(Icons.edit_outlined, size: 20, color: _textSecondary),
                                ),
                                IconButton(
                                  onPressed: () => _confirmDelete(context, ref, recordAsync.value!),
                                  icon: const Icon(Icons.delete_outline, size: 20, color: _placeholder),
                                ),
                              ],
                            ),
                    ],
                  ),
                  recordAsync.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.only(top: 80),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (error, stackTrace) => const Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: Center(
                        child: Text('기록을 찾을 수 없어요.', style: TextStyle(fontSize: 14, color: _placeholder)),
                      ),
                    ),
                    data: (record) {
                      final recordDate = DateUtil.parseRecordDt(record.recordDt);
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 20),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: _border),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  record.categoryCd,
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _point),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    '${recordDate.year}년 ${recordDate.month}월 ${recordDate.day}일 '
                                    '(${DateUtil.koreanWeekday(recordDate)}) '
                                    '${recordDate.hour.toString().padLeft(2, '0')}:${recordDate.minute.toString().padLeft(2, '0')}',
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: _textPrimary),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    '운동 시간 ${record.durationMin.toString().padLeft(2, '0')}:00',
                                    style: const TextStyle(fontSize: 13, color: _textSecondary),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (record.exercises.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: Column(
                                children: [
                                  for (final ex in record.exercises)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 12),
                                      child: DecoratedBox(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: _border),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.stretch,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                              decoration: const BoxDecoration(
                                                border: Border(bottom: BorderSide(color: _border)),
                                              ),
                                              child: Text(
                                                ex.exerciseName,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: _textPrimary,
                                                ),
                                              ),
                                            ),
                                            for (var i = 0; i < ex.sets.length; i++)
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                                decoration: i > 0
                                                    ? const BoxDecoration(
                                                        border: Border(top: BorderSide(color: _border)),
                                                      )
                                                    : null,
                                                child: Row(
                                                  children: [
                                                    SizedBox(
                                                      width: 40,
                                                      child: Text(
                                                        '${ex.sets[i].setNo}세트',
                                                        style: const TextStyle(
                                                          fontSize: 13,
                                                          fontWeight: FontWeight.w600,
                                                          color: _textSecondary,
                                                        ),
                                                      ),
                                                    ),
                                                    Text('${_formatWeight(ex.sets[i].weight)}kg', style: const TextStyle(fontSize: 14, color: _textPrimary)),
                                                    const Padding(
                                                      padding: EdgeInsets.symmetric(horizontal: 6),
                                                      child: Text('×', style: TextStyle(fontSize: 14, color: _placeholder)),
                                                    ),
                                                    Text('${ex.sets[i].reps}회', style: const TextStyle(fontSize: 14, color: _textPrimary)),
                                                  ],
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String _formatWeight(double v) => v == v.truncateToDouble() ? v.toInt().toString() : v.toString();
