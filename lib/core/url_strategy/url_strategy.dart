/// 웹 빌드일 때만 `usePathUrlStrategy()`를 실제로 호출하는 조건부 export.
///
/// `flutter_web_plugins`는 내부적으로 `dart:ui_web`(웹 전용 라이브러리)을 쓰기 때문에
/// Android/iOS/데스크톱 빌드에서는 이 파일을 그냥 import만 해도 컴파일이 깨진다
/// (`Dart library 'dart:ui_web' is not available on this platform`). `dart.library.html`
/// 조건으로 웹 컴파일 여부를 컴파일 타임에 분기해 플랫폼별로 다른 파일을 골라 쓴다.
library;

export 'url_strategy_stub.dart' if (dart.library.html) 'url_strategy_web.dart';
