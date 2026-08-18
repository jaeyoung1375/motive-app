import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/util/date_util.dart';
import '../../exercise/model/exercise_models.dart';
import '../../workout_record/model/workout_record_models.dart';
import '../../workout_record/provider/record_draft_provider.dart';
import '../../workout_record/provider/workout_record_provider.dart';

const _background = Color(0xFFF4F8FF);
const _point = Color(0xFF2F80FF);
const _iconBg = Color(0xFFE4EEFF);
const _textPrimary = Color(0xFF0B1220);
const _textSecondary = Color(0xFF64748B);
const _placeholder = Color(0xFF94A3B8);
const _border = Color(0xFFE2E8F0);

const _categories = ['헬스', '홈트', '러닝', '등산', '야외'];

String _formatWeight(double v) => v == v.truncateToDouble() ? v.toInt().toString() : v.toString();

/// motive-app `features/profile/widget/record_page.dart`에 대응 — 운동기록 작성.
/// `recordDraftProvider`를 직접 구독해 운동/세트 추가·삭제를 처리하고, 제출은
/// `workoutRecordControllerProvider`로 위임한다.
class RecordPage extends ConsumerStatefulWidget {
  const RecordPage({
    super.key,
    this.initialDate,
    this.editingRecord,
    required this.onBack,
    required this.onAddExercise,
    required this.onSubmitted,
    required this.onLoadPrevious,
  });

  final DateTime? initialDate;

  /// null이 아니면 수정 모드로 동작한다 — 폼을 이 기록 값으로 채우고,
  /// 제출 시 등록(POST) 대신 수정(PUT)을 호출한다.
  final WorkoutRecordResponse? editingRecord;
  final VoidCallback onBack;
  final VoidCallback onAddExercise;
  final VoidCallback onSubmitted;
  final VoidCallback onLoadPrevious;

  @override
  ConsumerState<RecordPage> createState() => _RecordPageState();
}

class _RecordPageState extends ConsumerState<RecordPage> {
  late String _category = _categories.first;
  late DateTime _dateTime = widget.initialDate ?? DateTime.now();
  int _hours = 0;
  int _minutes = 0;

  @override
  void initState() {
    super.initState();
    final editing = widget.editingRecord;
    if (editing == null) {
      // 빌드 도중에는 provider를 수정할 수 없어(Riverpod 제약) 빌드가 끝난 뒤로 미룬다.
      Future.microtask(() {
        if (mounted) ref.read(recordDraftProvider.notifier).reset();
      });
      return;
    }
    _category = editing.categoryCd;
    _dateTime = DateUtil.parseRecordDt(editing.recordDt);
    _hours = editing.durationMin ~/ 60;
    _minutes = editing.durationMin % 60;
    final draftExercises = [
      for (final ex in editing.exercises)
        RecordExercise(
          exercise: ExerciseResponse(exerciseId: ex.exerciseId, name: ex.exerciseName, bodyPartCd: '', equipmentCd: ''),
          sets: [for (final s in ex.sets) RecordSet(weight: s.weight, reps: s.reps)],
        ),
    ];
    Future.microtask(() {
      if (mounted) ref.read(recordDraftProvider.notifier).setAll(draftExercises);
    });
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_dateTime));
    if (time == null || !mounted) return;
    setState(() => _dateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute));
  }

  Future<void> _handleSubmit() async {
    final editing = widget.editingRecord;
    final draft = ref.read(recordDraftProvider);
    final body = WorkoutRecordCreateRequest(
      categoryCd: _category,
      recordDt: _dateTime.toIso8601String(),
      durationMin: _hours * 60 + _minutes,
      exercises: [
        for (final r in draft)
          WorkoutRecordExerciseRequest(
            exerciseId: r.exercise.exerciseId,
            sets: [
              for (var i = 0; i < r.sets.length; i++)
                WorkoutRecordSetRequest(setNo: i + 1, weight: r.sets[i].weight, reps: r.sets[i].reps),
            ],
          ),
      ],
    );

    final controller = ref.read(workoutRecordControllerProvider.notifier);
    if (editing != null) {
      await controller.update(
        editing.workoutRecordId,
        body,
        affectedYearMonths: {DateUtil.formatYearMonth(_dateTime), DateUtil.formatYearMonth(DateUtil.parseRecordDt(editing.recordDt))},
      );
    } else {
      await controller.create(body, affectedYearMonth: DateUtil.formatYearMonth(_dateTime));
    }
    if (!mounted) return;

    if (ref.read(workoutRecordControllerProvider).hasError) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(editing != null ? '운동 기록 수정에 실패했습니다.' : '운동 기록 등록에 실패했습니다.')));
      return;
    }
    ref.read(recordDraftProvider.notifier).reset();
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(editing != null ? '운동 기록이 수정되었습니다.' : '운동 기록이 등록되었습니다.')));
    widget.onSubmitted();
  }

  @override
  Widget build(BuildContext context) {
    final records = ref.watch(recordDraftProvider);
    final isPending = ref.watch(workoutRecordControllerProvider).isLoading;
    final isEditing = widget.editingRecord != null;

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
                        onPressed: widget.onBack,
                        icon: const Icon(Icons.chevron_left, size: 22, color: _textPrimary),
                      ),
                      Text(
                        isEditing ? '운동 기록 수정' : '운동 기록',
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: _textPrimary),
                      ),
                      TextButton(
                        onPressed: isPending ? null : _handleSubmit,
                        child: Text(
                          isPending ? '${isEditing ? '수정' : '등록'}중...' : (isEditing ? '수정' : '추가'),
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: _point),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (final c in _categories) ...[
                            _CategoryChip(label: c, selected: _category == c, onTap: () => setState(() => _category = c)),
                            const SizedBox(width: 8),
                          ],
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 28),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('날짜 및 시간', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: _textPrimary)),
                        OutlinedButton(
                          onPressed: _pickDateTime,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: _border),
                            backgroundColor: Colors.white,
                            foregroundColor: _textPrimary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: Text(
                            '${_dateTime.year}-${_dateTime.month.toString().padLeft(2, '0')}-${_dateTime.day.toString().padLeft(2, '0')} '
                            '${_dateTime.hour.toString().padLeft(2, '0')}:${_dateTime.minute.toString().padLeft(2, '0')}',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('운동한 시간', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: _textPrimary)),
                        Row(
                          children: [
                            _NumberField(
                              initialValue: _hours,
                              onChanged: (v) => _hours = v,
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 6),
                              child: Text('시간', style: TextStyle(fontSize: 13, color: _placeholder)),
                            ),
                            _NumberField(
                              initialValue: _minutes,
                              onChanged: (v) => _minutes = v,
                            ),
                            const Padding(
                              padding: EdgeInsets.only(left: 6),
                              child: Text('분', style: TextStyle(fontSize: 13, color: _placeholder)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Padding(padding: EdgeInsets.only(top: 24), child: Divider(height: 1, color: _border)),
                  Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text.rich(
                          TextSpan(
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: _textPrimary),
                            children: [
                              TextSpan(text: '상세 기록 '),
                              TextSpan(text: '(선택)', style: TextStyle(color: _placeholder, fontWeight: FontWeight.normal)),
                            ],
                          ),
                        ),
                        Material(
                          color: _iconBg,
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: widget.onAddExercise,
                            child: const SizedBox(
                              width: 32,
                              height: 32,
                              child: Icon(Icons.add, size: 18, color: _point),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (records.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Column(
                        children: [
                          for (final r in records)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _ExerciseCard(record: r),
                            ),
                        ],
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(top: 32),
                    child: Center(
                      child: InkWell(
                        onTap: widget.onLoadPrevious,
                        borderRadius: BorderRadius.circular(999),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: _border),
                          ),
                          child: const Text(
                            '이전 기록 불러오기',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _textPrimary),
                          ),
                        ),
                      ),
                    ),
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

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? _point : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: selected ? null : Border.all(color: _border),
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: selected ? Colors.white : _textSecondary),
        ),
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({required this.initialValue, required this.onChanged});

  final int initialValue;
  final void Function(int value) onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      height: 44,
      child: TextFormField(
        initialValue: '$initialValue',
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 15, color: _textPrimary),
        decoration: InputDecoration(
          isDense: true,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _border)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _border)),
        ),
        onChanged: (v) => onChanged(int.tryParse(v) ?? 0),
      ),
    );
  }
}

class _ExerciseCard extends ConsumerStatefulWidget {
  const _ExerciseCard({required this.record});

  final RecordExercise record;

  @override
  ConsumerState<_ExerciseCard> createState() => _ExerciseCardState();
}

/// 세트 목록은 위치(index)만으로 식별되고 고유 id가 없다 — `removeSet`으로 중간 세트를
/// 지우면 뒤 세트들이 한 칸씩 당겨진다. `TextFormField(initialValue:)`(비제어)로는 이
/// 재배치를 반영하지 못해 삭제 후 엉뚱한 값이 남아 보이는 문제가 생겨, 세트 개수가 변할
/// 때만(값만 바뀔 때는 타이핑 중이므로 건드리지 않는다) 컨트롤러 텍스트를 강제로 동기화한다.
class _ExerciseCardState extends ConsumerState<_ExerciseCard> {
  final List<TextEditingController> _weightControllers = [];
  final List<TextEditingController> _repsControllers = [];

  @override
  void initState() {
    super.initState();
    _syncControllers();
  }

  @override
  void didUpdateWidget(covariant _ExerciseCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.record.sets.length != widget.record.sets.length) {
      _syncControllers();
    }
  }

  void _syncControllers() {
    final sets = widget.record.sets;
    while (_weightControllers.length < sets.length) {
      _weightControllers.add(TextEditingController());
      _repsControllers.add(TextEditingController());
    }
    while (_weightControllers.length > sets.length) {
      _weightControllers.removeLast().dispose();
      _repsControllers.removeLast().dispose();
    }
    for (var i = 0; i < sets.length; i++) {
      _weightControllers[i].text = _formatWeight(sets[i].weight);
      _repsControllers[i].text = '${sets[i].reps}';
    }
  }

  @override
  void dispose() {
    for (final c in _weightControllers) {
      c.dispose();
    }
    for (final c in _repsControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final record = widget.record;
    final exerciseId = record.exercise.exerciseId;
    return DecoratedBox(
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
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: _border))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  record.exercise.name,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _textPrimary),
                ),
                IconButton(
                  onPressed: () => ref.read(recordDraftProvider.notifier).removeExercise(exerciseId),
                  icon: const Icon(Icons.close, size: 16, color: _placeholder),
                ),
              ],
            ),
          ),
          for (var i = 0; i < record.sets.length; i++)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: i > 0 ? const BoxDecoration(border: Border(top: BorderSide(color: _border))) : null,
              child: Row(
                children: [
                  SizedBox(
                    width: 40,
                    child: Text('${i + 1}세트', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _textSecondary)),
                  ),
                  SizedBox(
                    width: 64,
                    height: 36,
                    child: TextFormField(
                      controller: _weightControllers[i],
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14, color: _textPrimary),
                      decoration: InputDecoration(
                        isDense: true,
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(vertical: 6),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: _border)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: _border)),
                      ),
                      onChanged: (v) => ref
                          .read(recordDraftProvider.notifier)
                          .updateSet(exerciseId, i, weight: double.tryParse(v) ?? 0),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6),
                    child: Text('kg', style: TextStyle(fontSize: 12, color: _placeholder)),
                  ),
                  SizedBox(
                    width: 64,
                    height: 36,
                    child: TextFormField(
                      controller: _repsControllers[i],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14, color: _textPrimary),
                      decoration: InputDecoration(
                        isDense: true,
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(vertical: 6),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: _border)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: _border)),
                      ),
                      onChanged: (v) => ref
                          .read(recordDraftProvider.notifier)
                          .updateSet(exerciseId, i, reps: int.tryParse(v) ?? 0),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 6),
                    child: Text('회', style: TextStyle(fontSize: 12, color: _placeholder)),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => ref.read(recordDraftProvider.notifier).removeSet(exerciseId, i),
                    icon: const Icon(Icons.delete_outline, size: 16, color: _placeholder),
                  ),
                ],
              ),
            ),
          InkWell(
            onTap: () => ref.read(recordDraftProvider.notifier).addSet(exerciseId),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Text('세트 추가', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _point)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
