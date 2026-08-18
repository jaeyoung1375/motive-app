/// motive-ui `features/code/code.type.ts`에 대응.
///
/// ⚠️ motive-ui의 `codeList` 타입은 motive 도메인과 무관한 채용 도메인 필드
/// (`RECRUIT_TYPE_CD` 등)로 고정되어 있었다(motive-ui `12_known_issues` 4번).
/// 이 앱에서는 그 오류를 반복하지 않기 위해 다건 조회 결과를 고정 필드가 아니라
/// `Map<String, List<CodeResponse>>`(그룹ID → 코드 목록)로 일반화한다.
class CodeResponse {
  const CodeResponse({
    required this.comCdId,
    required this.comCdNm,
    required this.dtlCdId,
    required this.dtlCdNm,
    this.dtlCdExpln,
    this.lnkgDtlCdId1,
    this.lnkgDtlCdNm1,
    this.lnkgDtlCdId2,
    this.lnkgDtlCdNm2,
    this.useYn,
    this.sortSeq,
  });

  final String comCdId;
  final String comCdNm;
  final String dtlCdId;
  final String dtlCdNm;
  final String? dtlCdExpln;
  final String? lnkgDtlCdId1;
  final String? lnkgDtlCdNm1;
  final String? lnkgDtlCdId2;
  final String? lnkgDtlCdNm2;
  final String? useYn;
  final int? sortSeq;

  factory CodeResponse.fromJson(Map<String, dynamic> json) => CodeResponse(
        comCdId: json['comCdId'] as String,
        comCdNm: json['comCdNm'] as String,
        dtlCdId: json['dtlCdId'] as String,
        dtlCdNm: json['dtlCdNm'] as String,
        dtlCdExpln: json['dtlCdExpln'] as String?,
        lnkgDtlCdId1: json['lnkgDtlCdId1'] as String?,
        lnkgDtlCdNm1: json['lnkgDtlCdNm1'] as String?,
        lnkgDtlCdId2: json['lnkgDtlCdId2'] as String?,
        lnkgDtlCdNm2: json['lnkgDtlCdNm2'] as String?,
        useYn: json['useYn'] as String?,
        sortSeq: json['sortSeq'] as int?,
      );
}

class ComCodeResponse {
  const ComCodeResponse({required this.comCdId, required this.comCdNm, required this.useYn});

  final String comCdId;
  final String comCdNm;
  final String useYn;

  factory ComCodeResponse.fromJson(Map<String, dynamic> json) => ComCodeResponse(
        comCdId: json['comCdId'] as String,
        comCdNm: json['comCdNm'] as String,
        useYn: json['useYn'] as String,
      );
}
