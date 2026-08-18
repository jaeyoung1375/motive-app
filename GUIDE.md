# motive-app-toy 학습 가이드

motive-app(진짜 서비스)의 핵심 패턴을 작게 재현해보는 연습용 프로젝트입니다.
아래 단계를 **직접 타이핑**하면서 진행하세요. 코드를 통째로 복붙하지 말고,
막히면 "힌트"만 보고 스스로 채워보세요. 정 막히면 "참고" 파일을 열어보세요.

각 단계는 `flutter run -d chrome`(또는 원하는 디바이스)으로 눈으로 확인하며 진행합니다.

---

## Step 1 — StatelessWidget으로 화면 그리기

**목표**: `lib/main.dart`를 지우고, 앱바(AppBar)에 제목 "motive toy"가 있고
본문에 원하는 문구가 뜨는 화면을 처음부터 직접 타이핑.

**힌트**: `void main()` → `runApp` → `MaterialApp` → `Scaffold` → `AppBar` → `Center` → `Text`

**검증 기준**: `flutter run`으로 실행했을 때 앱바 제목과 본문 텍스트가 보인다.

**참고(막힐 때만)**: `motive-app/lib/main.dart:18-40`의 `MotiveApp` — 다만 지금 단계엔
Riverpod/router 없이 순수 `MaterialApp`만 있으면 충분합니다.

---

## Step 2 — StatefulWidget + setState로 상태 추가

**목표**: 버튼을 누르면 화면의 숫자가 1씩 증가하는 카운터를 직접 타이핑.

**힌트**: `StatefulWidget` + `State<T>` + `setState(() { ... })` + `FloatingActionButton(onPressed: ...)`

**검증 기준**: 버튼을 누를 때마다 숫자가 바뀐다(하지만 아직 상태는 이 위젯 안에만 있음).

**참고**: 이건 `flutter create`가 기본으로 만들어주는 카운터 템플릿과 같은 패턴입니다.
직접 타이핑해보고, 안 될 때만 `flutter create`로 임시 폴더를 하나 더 만들어 비교해보세요.

---

## Step 3 — Riverpod으로 상태를 provider로 옮기기

**목표**: Step 2의 카운터를 위젯 내부 `setState`가 아니라 Riverpod `provider`로 옮기기.

**순서**:
1. `pubspec.yaml`에는 이미 `flutter_riverpod`가 추가되어 있습니다 (`flutter pub get` 완료됨).
2. `main()`에서 `runApp(const MyApp())`을 `runApp(const ProviderScope(child: MyApp()))`으로 감싸기.
3. `final counterProvider = StateProvider<int>((ref) => 0);` 를 파일 최상단(클래스 밖)에 선언.
4. 카운터를 보여주는 위젯을 `StatelessWidget` → `ConsumerWidget`으로 바꾸고,
   `build(BuildContext context, WidgetRef ref)` 로 시그니처 변경.
5. 화면에서는 `ref.watch(counterProvider)`로 값을 읽고,
   버튼의 `onPressed`에서는 `ref.read(counterProvider.notifier).state++`로 증가.

**검증 기준**: Step 2와 똑같이 동작하지만, 상태가 위젯이 아니라 provider에 있다.

**참고**: `motive-app/lib/main.dart:12-16`(`ProviderScope`로 감싸는 패턴),
`motive-app/lib/features/auth/provider/auth_provider.dart`(`ref.watch`/`ref.read` 실제 사용례 —
다만 거기는 `AsyncNotifier`라 더 복잡합니다. 지금은 제일 단순한 `StateProvider`로 충분).

---

## Step 4 — dio로 API 호출해서 화면에 표시

**목표**: 공개 테스트 API(`https://jsonplaceholder.typicode.com/todos/1`)를 dio로 GET 요청해서
응답의 `title` 값을 화면에 표시.

**순서**:
1. `pubspec.yaml`에는 이미 `dio`가 추가되어 있습니다.
2. `final apiTodoProvider = FutureProvider<String>((ref) async { ... });` 선언.
   내부에서 `Dio().get('https://jsonplaceholder.typicode.com/todos/1')` 호출 후
   `response.data['title']`을 반환.
3. 화면(`ConsumerWidget`)에서 `final todo = ref.watch(apiTodoProvider);` 로 구독.
4. `todo.when(data: (title) => Text(title), loading: () => CircularProgressIndicator(), error: (e, _) => Text('에러: $e'))`
   로 3가지 상태를 모두 처리.

**검증 기준**: 앱 실행 시 잠깐 로딩 인디케이터가 뜨다가, API에서 받아온 제목 텍스트가 화면에 보인다.

**참고**: `motive-app/lib/core/network/api_client.dart` — 진짜 앱은 인터셉터(토큰 자동 첨부,
401 재발급)까지 있어서 훨씬 복잡합니다. 지금 단계는 `Dio().get(...)` 한 줄이면 충분하고,
`AsyncValue.when(...)` 3분기 처리가 핵심 연습 포인트입니다.

---

## Step 5 (선택) — go_router로 화면 두 개 연결

**목표**: 홈 화면과 상세 화면 두 개를 만들고, 홈에서 버튼을 누르면 상세 화면으로 이동.

**힌트**: `pubspec.yaml`에 `go_router`를 추가(`flutter pub add go_router`) →
`GoRouter(routes: [GoRoute(path: '/', builder: ...), GoRoute(path: '/detail', builder: ...)])` →
`MaterialApp.router(routerConfig: router)` → 이동은 `context.go('/detail')`.

**검증 기준**: 버튼을 누르면 상세 화면으로 전환되고, 브라우저 주소창(웹 실행 시)의 URL도 바뀐다.

**참고**: `motive-app/lib/core/router/app_router.dart:49-183` — 실제 앱은 여기에 로그인
가드(`redirect`)까지 있습니다. 지금은 가드 없이 라우트 두 개만 연결해보면 충분합니다.

---

## 막혔을 때

- 각 단계는 이전 단계가 동작하는 상태에서 시작합니다. 안 되면 `git diff` 없이(이 프로젝트는
  아직 git 초기화 전) 파일을 눈으로 비교하며 어디서 막혔는지 확인하세요.
- Dart 컴파일 에러 메시지는 대체로 정확한 줄 번호와 원인을 알려줍니다. 빨간 줄이 뜬 부분부터
  천천히 읽어보세요.
- 정말 막히면 motive-app의 해당 "참고" 파일을 열어서 구조만 보고, 코드를 그대로 베끼지 말고
  본인 방식으로 다시 타이핑해보세요.
