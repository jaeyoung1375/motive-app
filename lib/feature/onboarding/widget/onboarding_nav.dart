import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// 요약 줄을 눌러 이전 스텝을 수정하러 갈 때, 어디서 왔는지(`returnTo`)를 쿼리 파라미터로
/// 함께 넘긴다. 수정 완료 후 [goNextOrReturn]이 이 값을 보고 원래 있던 화면으로 되돌려준다.
String editStepRoute(BuildContext context, String targetPath) {
  final current = GoRouterState.of(context).uri.toString();
  return '$targetPath?returnTo=${Uri.encodeComponent(current)}';
}

/// `returnTo` 쿼리 파라미터가 있으면(=수정하러 온 경우) 원래 있던 화면으로 돌아가고,
/// 없으면(=평소 온보딩 진행 흐름) 다음 스텝으로 push한다.
void goNextOrReturn(BuildContext context, String nextPath) {
  final returnTo = GoRouterState.of(context).uri.queryParameters['returnTo'];
  if (returnTo != null) {
    context.go(returnTo);
  } else {
    context.push(nextPath);
  }
}
