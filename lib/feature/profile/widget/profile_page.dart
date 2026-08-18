import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/util/date_util.dart';
import '../../home/widget/main_bottom_nav.dart';
import '../../workout_record/model/workout_record_models.dart';
import '../../workout_record/provider/workout_record_provider.dart';

enum _Tab { record, activity }

const _background = Color(0xFFF4F8FF);
const _point = Color(0xFF2F80FF);
const _iconBg = Color(0xFFE4EEFF);
const _textPrimary = Color(0xFF0B1220);
const _textSecondary = Color(0xFF64748B);
const _placeholder = Color(0xFF94A3B8);
const _border = Color(0xFFE2E8F0);

// TODO: 칼로리 계산 로직 연동 전까지 사용하는 하드코딩 값 (motive-app과 동일)
const _mockKcal = 69;

const _dayLabels = ['일', '월', '화', '수', '목', '금', '토'];

/// motive-app `features/profile/widget/profile_page.dart`에 대응.
/// 프레젠테이션+데이터 조회 위젯: 달력에서 날짜를 고르면 그날의 운동기록을 보여주고,
/// 없으면 [onAddRecord]로, 있으면 [onOpenRecordDetail]로 이동을 위임한다.
class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({
    super.key,
    required this.onAddRecord,
    required this.onOpenRecordDetail,
    required this.onOpenSettings,
  });

  final void Function(DateTime recordDt) onAddRecord;
  final void Function(int workoutRecordId) onOpenRecordDetail;
  final VoidCallback onOpenSettings;

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  _Tab _tab = _Tab.record;
  DateTime _viewDate = DateTime.now();
  DateTime? _selectedDate = DateTime.now();

  void _prevMonth() => setState(() => _viewDate = DateTime(_viewDate.year, _viewDate.month - 1, 1));
  void _nextMonth() => setState(() => _viewDate = DateTime(_viewDate.year, _viewDate.month + 1, 1));
  void _today() => setState(() {
        final now = DateTime.now();
        _viewDate = now;
        _selectedDate = now;
      });

  @override
  Widget build(BuildContext context) {
    final yearMonth = DateUtil.formatYearMonth(_viewDate);
    final records = ref.watch(workoutRecordListProvider(yearMonth)).valueOrNull ?? [];
    final selectedDate = _selectedDate;
    final selectedDateRecords = selectedDate == null
        ? <WorkoutRecordResponse>[]
        : records.where((r) => DateUtil.isSameDay(DateUtil.parseRecordDt(r.recordDt), selectedDate)).toList();

    final firstDayOfMonth = DateTime(_viewDate.year, _viewDate.month, 1);
    final daysInMonth = DateTime(_viewDate.year, _viewDate.month + 1, 0).day;
    final leadingEmpty = firstDayOfMonth.weekday % 7;
    final cells = <DateTime?>[
      ...List.filled(leadingEmpty, null),
      for (var d = 1; d <= daysInMonth; d++) DateTime(_viewDate.year, _viewDate.month, d),
    ];

    return Scaffold(
      backgroundColor: _background,
      bottomNavigationBar: const MainBottomNav(),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 402),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '프로필',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: _textPrimary),
                      ),
                      InkWell(
                        onTap: widget.onOpenSettings,
                        customBorder: const CircleBorder(),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                          child: const Icon(Icons.settings, size: 18, color: _textSecondary),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: _TabButton(
                            label: '기록',
                            active: _tab == _Tab.record,
                            onTap: () => setState(() => _tab = _Tab.record),
                          ),
                        ),
                        Expanded(
                          child: _TabButton(
                            label: '활동',
                            active: _tab == _Tab.activity,
                            onTap: () => setState(() => _tab = _Tab.activity),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_tab == _Tab.record) ...[
                    Container(
                      margin: const EdgeInsets.only(top: 16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _border),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                onPressed: _prevMonth,
                                icon: const Icon(Icons.chevron_left, size: 18, color: _placeholder),
                              ),
                              Text(
                                '${_viewDate.year}년 ${_viewDate.month.toString().padLeft(2, '0')}월',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _textPrimary),
                              ),
                              IconButton(
                                onPressed: _nextMonth,
                                icon: const Icon(Icons.chevron_right, size: 18, color: _placeholder),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              for (final label in _dayLabels)
                                Expanded(
                                  child: Center(
                                    child: Text(
                                      label,
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _placeholder),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          GridView.count(
                            crossAxisCount: 7,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              for (final day in cells)
                                day == null
                                    ? const SizedBox.shrink()
                                    : _DayCell(
                                        day: day,
                                        isSelected: selectedDate != null && DateUtil.isSameDay(day, selectedDate),
                                        isToday: DateUtil.isSameDay(day, DateTime.now()),
                                        hasRecord: records.any(
                                          (r) => DateUtil.isSameDay(DateUtil.parseRecordDt(r.recordDt), day),
                                        ),
                                        onTap: () => setState(() => _selectedDate = day),
                                      ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: _today,
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: _border),
                                  foregroundColor: _textSecondary,
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: const Text('오늘', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (selectedDateRecords.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Column(
                          children: [
                            for (final record in selectedDateRecords)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _RecordCard(
                                  record: record,
                                  onTap: () => widget.onOpenRecordDetail(record.workoutRecordId),
                                ),
                              ),
                          ],
                        ),
                      )
                    else
                      Container(
                        margin: const EdgeInsets.only(top: 16),
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: _border),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: const BoxDecoration(color: _iconBg, shape: BoxShape.circle),
                              child: const Icon(Icons.inbox, size: 22, color: _point),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              '운동 기록 추가',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _textPrimary),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              '이전에 했던 운동을 기록하고,\n앞으로의 운동은 모티브와 함께 해요!',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 13, color: _textSecondary),
                            ),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: ElevatedButton(
                                  onPressed: () => widget.onAddRecord(selectedDate ?? DateTime.now()),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _point,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    elevation: 0,
                                  ),
                                  child: const Text('추가하기', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ] else
                    Container(
                      margin: const EdgeInsets.only(top: 16),
                      width: double.infinity,
                      padding: const EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _border),
                      ),
                      child: const Center(
                        child: Text('아직 활동 내역이 없어요', style: TextStyle(fontSize: 14, color: _textSecondary)),
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

class _TabButton extends StatelessWidget {
  const _TabButton({required this.label, required this.active, required this.onTap});

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: active ? _point : Colors.transparent, width: 2)),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            fontWeight: active ? FontWeight.w600 : FontWeight.normal,
            color: active ? _textPrimary : _placeholder,
          ),
        ),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.isSelected,
    required this.isToday,
    required this.hasRecord,
    required this.onTap,
  });

  final DateTime day;
  final bool isSelected;
  final bool isToday;
  final bool hasRecord;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dotColor = isSelected ? Colors.white : _point;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2),
        decoration: BoxDecoration(color: isSelected ? _point : null, shape: BoxShape.circle),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              '${day.day}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.white : _textPrimary,
              ),
            ),
            if (isToday && !isSelected || hasRecord)
              Positioned(
                bottom: 3,
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(color: hasRecord ? dotColor : _point, shape: BoxShape.circle),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _RecordCard extends ConsumerWidget {
  const _RecordCard({required this.record, required this.onTap});

  final WorkoutRecordResponse record;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exerciseCount =
        ref.watch(workoutRecordDetailProvider(record.workoutRecordId)).valueOrNull?.exercises.length;
    final recordDate = DateUtil.parseRecordDt(record.recordDt);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
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
                Text.rich(
                  TextSpan(
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _textPrimary),
                    children: [
                      TextSpan(
                        text: '${recordDate.month.toString().padLeft(2, '0')}.${recordDate.day.toString().padLeft(2, '0')}. ',
                      ),
                      const TextSpan(text: '운동', style: TextStyle(color: _point)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, size: 18, color: _placeholder),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Row(
                children: [
                  _StatChip(
                    icon: Icons.fitness_center,
                    value: exerciseCount != null ? '$exerciseCount' : '-',
                    unit: '개',
                  ),
                  const SizedBox(width: 20),
                  const _StatChip(icon: Icons.local_fire_department, value: '$_mockKcal', unit: 'kcal'),
                  const SizedBox(width: 20),
                  _StatChip(
                    icon: Icons.schedule,
                    value: '${record.durationMin.toString().padLeft(2, '0')}:00',
                    unit: '',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.icon, required this.value, required this.unit});

  final IconData icon;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(color: _background, shape: BoxShape.circle),
          child: Icon(icon, size: 16, color: _textSecondary),
        ),
        const SizedBox(width: 8),
        Text.rich(
          TextSpan(
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: _textPrimary),
            children: [
              TextSpan(text: value),
              TextSpan(text: unit, style: const TextStyle(fontWeight: FontWeight.normal, color: _textSecondary)),
            ],
          ),
        ),
      ],
    );
  }
}
