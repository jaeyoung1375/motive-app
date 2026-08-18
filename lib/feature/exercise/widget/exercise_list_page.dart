import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../code/provider/code_provider.dart';
import '../model/exercise_models.dart';
import '../provider/exercise_provider.dart';

enum _MyFilter { favorite, recent }

const _background = Color(0xFFF4F8FF);
const _point = Color(0xFF2F80FF);
const _iconBg = Color(0xFFE4EEFF);
const _textPrimary = Color(0xFF0B1220);
const _textSecondary = Color(0xFF64748B);
const _placeholder = Color(0xFF94A3B8);
const _border = Color(0xFFE2E8F0);

/// motive-app `features/exercise/widget/exercise_list_page.dart`에 대응.
/// 프레젠테이션 전용 위젯: [onSelect]가 주어지면 "운동 선택" 모드로 동작하고,
/// 없으면 단순 조회용 "운동 목록" 모드로 동작한다.
class ExerciseListPage extends ConsumerStatefulWidget {
  const ExerciseListPage({super.key, required this.onBack, this.onSelect});

  final VoidCallback onBack;
  final void Function(ExerciseResponse exercise)? onSelect;

  @override
  ConsumerState<ExerciseListPage> createState() => _ExerciseListPageState();
}

class _ExerciseListPageState extends ConsumerState<ExerciseListPage> {
  String _keyword = '';
  _MyFilter? _myFilter;
  final Set<String> _bodyParts = {};
  final Set<String> _equipments = {};
  final Set<int> _favorites = {};

  void _toggleFavorite(int exerciseId) {
    setState(() {
      if (!_favorites.remove(exerciseId)) _favorites.add(exerciseId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bodyPartCodes = ref.watch(codeProvider('BODY_PART_CD')).valueOrNull ?? [];
    final equipmentCodes = ref.watch(codeProvider('EQUIPMENTS_CD')).valueOrNull ?? [];
    final exercises = ref.watch(exerciseListProvider).valueOrNull ?? [];

    final filtered = exercises.where((ex) {
      if (_keyword.isNotEmpty && !ex.name.contains(_keyword)) return false;
      if (_myFilter == _MyFilter.favorite && !_favorites.contains(ex.exerciseId)) return false;
      // TODO: 최근 운동 기록 API 연동 전까지 항상 비어있음 (motive-app과 동일)
      if (_myFilter == _MyFilter.recent) return false;
      if (_bodyParts.isNotEmpty && !_bodyParts.contains(ex.bodyPartCd)) return false;
      if (_equipments.isNotEmpty && !_equipments.contains(ex.equipmentCd)) return false;
      return true;
    }).toList();

    final grouped = <String, List<ExerciseResponse>>{};
    for (final ex in filtered) {
      (grouped[ex.bodyPartNm ?? ex.bodyPartCd] ??= []).add(ex);
    }

    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 402),
            child: Column(
              children: [
                SizedBox(
                  height: 56,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        left: 8,
                        child: IconButton(
                          onPressed: widget.onBack,
                          icon: const Icon(Icons.chevron_left, color: _textPrimary, size: 22),
                        ),
                      ),
                      Text(
                        widget.onSelect != null ? '운동 선택' : '운동 목록',
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: _textPrimary),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _border),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search, size: 16, color: _placeholder),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            onChanged: (value) => setState(() => _keyword = value),
                            decoration: const InputDecoration(
                              hintText: '운동 이름으로 검색해보세요',
                              hintStyle: TextStyle(fontSize: 14, color: _placeholder),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                            style: const TextStyle(fontSize: 14, color: _textPrimary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Row(
                    children: [
                      const Text(
                        'MY',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _placeholder),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: '즐겨찾기',
                        selected: _myFilter == _MyFilter.favorite,
                        onTap: () => setState(
                          () => _myFilter = _myFilter == _MyFilter.favorite ? null : _MyFilter.favorite,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: '최근 한 운동',
                        selected: _myFilter == _MyFilter.recent,
                        onTap: () =>
                            setState(() => _myFilter = _myFilter == _MyFilter.recent ? null : _MyFilter.recent),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 0, 4),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        const Text(
                          '부위',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _placeholder),
                        ),
                        const SizedBox(width: 8),
                        for (final code in bodyPartCodes) ...[
                          _FilterChip(
                            label: code.dtlCdNm,
                            selected: _bodyParts.contains(code.dtlCdId),
                            onTap: () => setState(() {
                              if (!_bodyParts.remove(code.dtlCdId)) _bodyParts.add(code.dtlCdId);
                            }),
                          ),
                          const SizedBox(width: 8),
                        ],
                        const SizedBox(width: 12),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 0, 16),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        const Text(
                          '기구',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _placeholder),
                        ),
                        const SizedBox(width: 8),
                        for (final code in equipmentCodes) ...[
                          _FilterChip(
                            label: code.dtlCdNm,
                            selected: _equipments.contains(code.dtlCdId),
                            onTap: () => setState(() {
                              if (!_equipments.remove(code.dtlCdId)) _equipments.add(code.dtlCdId);
                            }),
                          ),
                          const SizedBox(width: 8),
                        ],
                        const SizedBox(width: 12),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Divider(height: 1, color: _border),
                        const SizedBox(height: 16),
                        Text('전체 ${filtered.length}개', style: const TextStyle(fontSize: 13, color: _placeholder)),
                        if (grouped.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 40),
                            child: Text(
                              _myFilter == _MyFilter.recent ? '최근 운동 기록이 없어요' : '조건에 맞는 운동이 없어요',
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 14, color: _placeholder),
                            ),
                          ),
                        for (final entry in grouped.entries)
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Text(
                                    entry.key,
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _textPrimary),
                                  ),
                                ),
                                for (var i = 0; i < entry.value.length; i++)
                                  _ExerciseRow(
                                    exercise: entry.value[i],
                                    showTopBorder: i > 0,
                                    isFavorite: _favorites.contains(entry.value[i].exerciseId),
                                    onTap: widget.onSelect == null ? null : () => widget.onSelect!(entry.value[i]),
                                    onToggleFavorite: () => _toggleFavorite(entry.value[i].exerciseId),
                                  ),
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
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? _point : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: selected ? null : Border.all(color: _border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : _textSecondary,
          ),
        ),
      ),
    );
  }
}

class _ExerciseRow extends StatelessWidget {
  const _ExerciseRow({
    required this.exercise,
    required this.showTopBorder,
    required this.isFavorite,
    required this.onTap,
    required this.onToggleFavorite,
  });

  final ExerciseResponse exercise;
  final bool showTopBorder;
  final bool isFavorite;
  final VoidCallback? onTap;
  final VoidCallback onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: showTopBorder ? const Border(top: BorderSide(color: _border)) : null,
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: _iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.fitness_center, size: 22, color: _point),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                exercise.name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _textPrimary,
                ),
              ),
            ),
            IconButton(
              onPressed: onToggleFavorite,
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                size: 18,
                color: isFavorite ? _point : _placeholder,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
