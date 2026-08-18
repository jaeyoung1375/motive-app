import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../data/code_api.dart';
import '../model/code_models.dart';

final codeApiProvider = Provider<CodeApi>((ref) => CodeApi(ref.watch(apiClientProvider)));

/// motive-ui `features/code/code.query.ts`의 `useCodeQuery({ comCdId })`에 대응.
final codeProvider = FutureProvider.family<List<CodeResponse>, String>(
  (ref, comCdId) => ref.watch(codeApiProvider).fetchCode(comCdId),
);
