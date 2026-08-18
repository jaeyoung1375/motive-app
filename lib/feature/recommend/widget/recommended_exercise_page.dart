import 'package:flutter/material.dart';

import '../../exercise/model/exercise_models.dart';
import '../../exercise/widget/exercise_list_page.dart';
import '../model/recommended_exercise_models.dart';

const _background = Color(0xFFF4F8FF);
const _point = Color(0xFF2F80FF);
const _iconBg = Color(0xFFE4EEFF);
const _textPrimary = Color(0xFF0B1220);
const _textSecondary = Color(0xFF64748B);
const _placeholder = Color(0xFF94A3B8);
const _border = Color(0xFFE2E8F0);
const _danger = Color(0xFFE5484D);

const _durationOptions = [15, 30, 45, 60];

/// motive-app `features/recommend/widget/recommended_exercise_page.dart`(REQ-F-003)에
/// 대응 — 메인 홈 화면 "오늘의 추천 운동" 미리보기. 카드에서 이미 뽑아둔 목록을 그대로
/// 넘겨받아 보여준다(새로 API를 호출하지 않음 — 다시 부르면 서버가 다른 무작위 조합을
/// 줄 수 있어서 카드에 보이던 것과 화면이 달라지는 걸 막기 위함).
///
/// "순서 변경"은 이 화면 안에서만 유효한 로컬 재배열이다 — 서버 SORT_NO(운영자가 지정한
/// 기본 노출 순서)는 건드리지 않는다.
///
/// ⚠️ 화면만 먼저 개발 — "운동 시간" 선택은 UI 상태로만 반영되고(목록엔 영향 없음),
/// "시작하기"(운동 기록 화면 없음)는 아직 스텁이다. "+ 운동 추가하기"로 고른 운동은
/// 세트/중량/횟수/운동시간 정보가 없어(전체 운동 목록 API엔 그 정보가 없음) 임시값을 채운다.
class RecommendedExercisePage extends StatefulWidget {
  const RecommendedExercisePage({super.key, required this.exercises, required this.onBack, required this.onStart});

  final List<RecommendedExerciseResponse> exercises;
  final VoidCallback onBack;
  final void Function(List<RecommendedExerciseResponse> exercises) onStart;

  @override
  State<RecommendedExercisePage> createState() => _RecommendedExercisePageState();
}

class _RecommendedExercisePageState extends State<RecommendedExercisePage> {
  final List<RecommendedExerciseResponse> _items = [];
  bool _reordering = false;
  int? _selectedMinutes;

  @override
  void initState() {
    super.initState();
    _items.addAll(widget.exercises);
  }

  Future<void> _openDurationSheet() async {
    final selected = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(26, 8, 26, 24),
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
                const Text(
                  '운동 시간을 선택해주세요',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: _textPrimary),
                ),
                const SizedBox(height: 12),
                for (final minutes in _durationOptions)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('$minutes분', style: const TextStyle(fontSize: 15, color: _textPrimary)),
                    trailing: _selectedMinutes == minutes ? const Icon(Icons.check, color: _point) : null,
                    onTap: () => Navigator.of(context).pop(minutes),
                  ),
              ],
            ),
          ),
        );
      },
    );

    if (selected != null) setState(() => _selectedMinutes = selected);
  }

  Future<void> _openExercisePickerSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) {
        return FractionallySizedBox(
          heightFactor: 0.92,
          child: ExerciseListPage(
            onBack: () => Navigator.of(sheetContext).pop(),
            onSelect: (exercise) {
              setState(() => _items.add(_toRecommendedExercise(exercise)));
              Navigator.of(sheetContext).pop();
            },
          ),
        );
      },
    );
  }

  Future<void> _openRowMenuSheet(RecommendedExerciseResponse exercise) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(26, 8, 26, 24),
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
                Text(
                  exercise.exerciseName,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _textPrimary),
                ),
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.favorite_border, color: _textPrimary),
                  title: const Text('즐겨찾기 추가', style: TextStyle(fontSize: 15, color: _textPrimary)),
                  // TODO: 즐겨찾기 API 연동
                  onTap: () => Navigator.of(sheetContext).pop(),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.delete_outline, color: _danger),
                  title: const Text('운동 삭제', style: TextStyle(fontSize: 15, color: _danger)),
                  // 이 목록(_items)에서만 제거한다 — DB(추천 운동 원본)엔 손대지 않는다.
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    setState(
                      () => _items.removeWhere(
                        (e) => e.recommendedExerciseId == exercise.recommendedExerciseId,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 전체 운동 목록 API(ExerciseResponse)엔 세트/중량/횟수/운동시간이 없다 — 직접
  // 추가한 운동은 일단 기본값(3세트 X 10회, 운동시간 5분)으로 채운다.
  RecommendedExerciseResponse _toRecommendedExercise(ExerciseResponse exercise) {
    return RecommendedExerciseResponse(
      recommendedExerciseId: -DateTime.now().microsecondsSinceEpoch,
      exerciseId: exercise.exerciseId,
      exerciseName: exercise.name,
      bodyPartNm: exercise.bodyPartNm,
      sets: 3,
      weight: 0,
      reps: 10,
      durationMin: 5,
      sortNo: _items.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalMinutes = _items.fold<int>(0, (sum, ex) => sum + ex.durationMin);
    final displayMinutes = _selectedMinutes ?? totalMinutes;

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
                      const Expanded(
                        child: Text(
                          '오늘의 추천 운동',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: _textPrimary),
                        ),
                      ),
                      const SizedBox(width: 36),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                    children: [
                      InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: _openDurationSheet,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _border),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.schedule, size: 18, color: _placeholder),
                              const SizedBox(width: 8),
                              const Text('운동 시간', style: TextStyle(fontSize: 13, color: _textSecondary)),
                              const Spacer(),
                              Text(
                                '$displayMinutes분',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _textPrimary),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.keyboard_arrow_down, size: 18, color: _placeholder),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '총 ${_items.length}개',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _textPrimary),
                            ),
                            OutlinedButton.icon(
                              onPressed: () => setState(() => _reordering = !_reordering),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: _reordering ? _point : _textSecondary,
                                side: BorderSide(color: _reordering ? _point : _border),
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                              ),
                              icon: const Icon(Icons.swap_vert, size: 16),
                              label: Text(_reordering ? '완료' : '순서 변경'),
                            ),
                          ],
                        ),
                      ),
                      if (_reordering)
                        ReorderableListView(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          onReorderItem: (oldIndex, newIndex) => setState(() {
                            final item = _items.removeAt(oldIndex);
                            _items.insert(newIndex, item);
                          }),
                          children: [
                            for (final ex in _items)
                              Padding(
                                key: ValueKey(ex.recommendedExerciseId),
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _RecommendedExerciseRow(exercise: ex, showDragHandle: true),
                              ),
                          ],
                        )
                      else
                        for (final ex in _items)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _RecommendedExerciseRow(
                              exercise: ex,
                              showDragHandle: false,
                              onMore: () => _openRowMenuSheet(ex),
                            ),
                          ),
                      const SizedBox(height: 4),
                      OutlinedButton.icon(
                        onPressed: _openExercisePickerSheet,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _point,
                          side: const BorderSide(color: _border),
                          backgroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('운동 추가하기', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _items.isEmpty ? null : () => widget.onStart(_items),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _point,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: _border,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                        elevation: 0,
                      ),
                      child: const Text('시작하기', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
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

class _RecommendedExerciseRow extends StatelessWidget {
  const _RecommendedExerciseRow({required this.exercise, required this.showDragHandle, this.onMore});

  final RecommendedExerciseResponse exercise;
  final bool showDragHandle;
  final VoidCallback? onMore;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(color: _iconBg, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.fitness_center, size: 22, color: _point),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.exerciseName,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  '${exercise.sets}세트 X ${exercise.weight == exercise.weight.truncateToDouble() ? exercise.weight.toInt() : exercise.weight}kg X ${exercise.reps}회',
                  style: const TextStyle(fontSize: 12, color: _textSecondary),
                ),
              ],
            ),
          ),
          if (showDragHandle)
            const Icon(Icons.drag_handle, size: 20, color: _placeholder)
          else if (onMore != null)
            IconButton(
              onPressed: onMore,
              icon: const Icon(Icons.more_horiz, size: 20, color: _placeholder),
            ),
        ],
      ),
    );
  }
}
