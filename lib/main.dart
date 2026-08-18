import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:motive_app_toy/core/router/app_router.dart';
import 'package:motive_app_toy/feature/auth/provider/auth_provider.dart';
import 'core/url_strategy/url_strategy.dart';

void main() {
  configurePathUrlStrategy();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  final _appLink = AppLinks();
  StreamSubscription<Uri>? _oauthCallbackSubscription;

  @override
  void initState() {
    super.initState();

    _oauthCallbackSubscription = _appLink.uriLinkStream.listen(
      _handleOAuthCallback,
    );
  }

  Future<void> _handleOAuthCallback(Uri? uri) async {
    if (uri == null ||
        uri.scheme != 'motive-toy' ||
        uri.host != 'oauth-callback') {
      return;
    }
    final code = uri.queryParameters['code'];
    if (code == null) {
      return;
    }

    // authProvider의 최초 build()(세션 복원 시도, 콜드 스타트 시 이 콜백과 동시에 진행 중일 수
    // 있음)가 끝나기 전에 loginWithCode가 state를 쓰면, build() 완료 시점에 그 결과로
    // 덮어써질 수 있다. build() 완료를 먼저 기다린 뒤 로그인 결과를 적용한다.
    await ref.read(authProvider.future);
    await ref.read(authProvider.notifier).loginWithCode(code);
  }

  @override
  void dispose() {
    _oauthCallbackSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'motive',
      debugShowCheckedModeBanner: false,
      routerConfig: ref.watch(routerProvider),
      locale: const Locale('ko'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ko')],
    );
  }
}
