import 'package:flutter/material.dart';

import '../../recommend/model/recommended_exercise_models.dart';
import '../../workout_record/model/workout_record_models.dart';

const _background = Color(0xFFF4F8FF);
const _point = Color(0xFF2F80FF);
const _iconBg = Color(0xFFE4EEFF);
const _textPrimary = Color(0xFF0B1220);
const _textSecondary = Color(0xFF64748B);
const _placeholder = Color(0xFF94A3B8);
const _border = Color(0xFFE2E8F0);

const _defaultCategoryCd = '헬스';

String _formatWeight(num v) => v == v.roundToDouble() ? v.toInt().toString() : v.toString();

class _SetState {
  _SetState({required this.weight, required this.reps});

  double weight;
  int reps;
  bool done = false;
}

/// 추천 운동 미리보기 화면의 "시작하기"에서 진입하는 운동 진행 화면.
/// [exercises] 순서대로 한 번에 하나씩, 세트를 하나씩 완료 처리한다. 각 세트의
/// 중량/개수는 카드를 탭해서 바꿀 수 있다(추천값이 기본으로 채워져 있을 뿐).
///
/// 모든 운동을 마치면 지금까지 기록한 세트로 [WorkoutRecordCreateRequest]를 만들어
/// [onFinish]에 넘긴다 — 실제 등록(POST) 여부와 이후 이동은 라우트가 결정한다.
class WorkoutSessionPage extends StatefulWidget {
  const WorkoutSessionPage({super.key, required this.exercises, required this.onBack, required this.onFinish});

  final List<RecommendedExerciseResponse> exercises;
  final VoidCallback onBack;
  final Future<void> Function(WorkoutRecordCreateRequest request) onFinish;

  @override
  State<WorkoutSessionPage> createState() => _WorkoutSessionPageState();
}

class _WorkoutSessionPageState extends State<WorkoutSessionPage> {
  late final DateTime _startedAt = DateTime.now();
  late final List<List<_SetState>> _sets = [
    for (final ex in widget.exercises)
      List.generate(ex.sets, (_) => _SetState(weight: ex.weight, reps: ex.reps)),
  ];
  int _exerciseIndex = 0;

  void _completeCurrentSet() {
    final sets = _sets[_exerciseIndex];
    final currentSetIndex = sets.indexWhere((s) => !s.done);
    if (currentSetIndex == -1) return;

    setState(() => sets[currentSetIndex].done = true);

    if (sets.every((s) => s.done)) {
      if (_exerciseIndex == widget.exercises.length - 1) {
        _finish();
      } else {
        setState(() => _exerciseIndex++);
      }
    }
  }

  Future<void> _editSet(_SetState set) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) {
        final keyboardInset = MediaQuery.of(sheetContext).viewInsets.bottom;
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(26, 8, 26, 24 + keyboardInset),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(top: 8, bottom: 20),
                    decoration: BoxDecoration(color: _border, borderRadius: BorderRadius.circular(999)),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: _formatWeight(set.weight),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 15, color: _textPrimary),
                        decoration: InputDecoration(
                          labelText: '중량(kg)',
                          isDense: true,
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _border)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _border)),
                        ),
                        onChanged: (v) => setState(() => set.weight = double.tryParse(v) ?? set.weight),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        initialValue: '${set.reps}',
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 15, color: _textPrimary),
                        decoration: InputDecoration(
                          labelText: '개수(회)',
                          isDense: true,
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _border)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _border)),
                        ),
                        onChanged: (v) => setState(() => set.reps = int.tryParse(v) ?? set.reps),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _addSet() {
    final sets = _sets[_exerciseIndex];
    final last = sets.last;
    setState(() => sets.add(_SetState(weight: last.weight, reps: last.reps)));
  }

  Future<void> _finish() async {
    final request = WorkoutRecordCreateRequest(
      categoryCd: _defaultCategoryCd,
      recordDt: DateTime.now().toIso8601String(),
      durationMin: DateTime.now().difference(_startedAt).inMinutes,
      exercises: [
        for (var i = 0; i < widget.exercises.length; i++)
          WorkoutRecordExerciseRequest(
            exerciseId: widget.exercises[i].exerciseId,
            sets: [
              for (var s = 0; s < _sets[i].length; s++)
                WorkoutRecordSetRequest(setNo: s + 1, weight: _sets[i][s].weight, reps: _sets[i][s].reps),
            ],
          ),
      ],
    );
    await widget.onFinish(request);
  }

  @override
  Widget build(BuildContext context) {
    final exercise = widget.exercises[_exerciseIndex];
    final sets = _sets[_exerciseIndex];
    final currentSetIndex = sets.indexWhere((s) => !s.done);

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
                        onPressed: widget.onBack,
                        icon: const Icon(Icons.chevron_left, size: 22, color: _textPrimary),
                      ),
                      Expanded(
                        child: Text(
                          '${_exerciseIndex + 1} / ${widget.exercises.length}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: _textSecondary),
                        ),
                      ),
                      const SizedBox(width: 36),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(color: _iconBg, borderRadius: BorderRadius.circular(12)),
                            child: const Icon(Icons.fitness_center, size: 24, color: _point),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  exercise.exerciseName,
                                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _textPrimary),
                                ),
                                if (exercise.bodyPartNm != null) ...[
                                  const SizedBox(height: 2),
                                  Text(exercise.bodyPartNm!, style: const TextStyle(fontSize: 13, color: _textSecondary)),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      for (var i = 0; i < sets.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _SetCard(
                            setNo: i + 1,
                            set: sets[i],
                            isCurrent: i == currentSetIndex,
                            onTap: () => _editSet(sets[i]),
                          ),
                        ),
                      OutlinedButton.icon(
                        onPressed: _addSet,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _point,
                          side: const BorderSide(color: _border),
                          backgroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('세트 추가', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _completeCurrentSet,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _point,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Text('세트 완료', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
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

class _SetCard extends StatelessWidget {
  const _SetCard({required this.setNo, required this.set, required this.isCurrent, required this.onTap});

  final int setNo;
  final _SetState set;
  final bool isCurrent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final labelColor = set.done ? _placeholder : _textPrimary;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isCurrent ? _point : _border, width: isCurrent ? 1.5 : 1),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 48,
              child: Text(
                '$setNo세트',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: labelColor),
              ),
            ),
            Expanded(
              child: Text(
                '${_formatWeight(set.weight)}kg / ${set.reps}회',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: labelColor),
              ),
            ),
            const Icon(Icons.edit_outlined, size: 16, color: _placeholder),
            const SizedBox(width: 10),
            Icon(
              set.done ? Icons.check_circle : Icons.radio_button_unchecked,
              size: 22,
              color: set.done ? _point : _border,
            ),
          ],
        ),
      ),
    );
  }
}
