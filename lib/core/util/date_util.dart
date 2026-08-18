/// motive-app `core/util/date_util.dart`에 대응 — 날짜 관련 소소한 헬퍼. `regDt`/`modDt`
/// (Spring/Jackson 기본 직렬화)는 ISO-8601이라 `DateTime.parse`/`toIso8601String`을 그대로
/// 쓰면 되지만, `recordDt`는 서버 DTO에 `@JsonFormat(pattern = "yyyyMMddHHmm")`가 붙어 있어
/// `"202608121333"` 형태로 내려온다 — 이건 [parseRecordDt]로 파싱해야 한다.
class DateUtil {
  DateUtil._();

  static const _koreanWeekdays = ['월', '화', '수', '목', '금', '토', '일']; // DateTime.weekday: 1=월..7=일

  static String formatYearMonth(DateTime date) => '${date.year}${date.month.toString().padLeft(2, '0')}';

  static String koreanWeekday(DateTime date) => _koreanWeekdays[date.weekday - 1];

  static bool isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  /// `recordDt`(`"yyyyMMddHHmm"`, 예: `"202608121333"`)를 [DateTime]으로 변환한다.
  static DateTime parseRecordDt(String recordDt) => DateTime(
        int.parse(recordDt.substring(0, 4)),
        int.parse(recordDt.substring(4, 6)),
        int.parse(recordDt.substring(6, 8)),
        int.parse(recordDt.substring(8, 10)),
        int.parse(recordDt.substring(10, 12)),
      );
}
