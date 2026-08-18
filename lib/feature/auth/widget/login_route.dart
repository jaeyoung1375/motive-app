import 'package:flutter/widgets.dart';
import 'package:motive_app_toy/core/env/Env.dart';
import 'package:motive_app_toy/feature/auth/widget/login_page.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginRoute extends StatelessWidget {
  const LoginRoute({super.key});

  Future<void> _launchOAuth(String url) =>
      launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);

  @override
  Widget build(BuildContext context) {
    return LoginPage(
      onGoogleLogin: () => _launchOAuth(Env.oauthGoogleUrl),
      onKakaoLogin: () => _launchOAuth(Env.oauthKakaoUrl),
      onGithubLogin: () => _launchOAuth(Env.oauthGithubUrl),
    );
  }
}
