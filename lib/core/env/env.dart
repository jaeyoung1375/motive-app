class Env {
  Env._();

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:9090',
  );

  static const String oauthGoogleUrl = String.fromEnvironment(
    'OAUTH_GOOGLE_URL',
    defaultValue:
        'http://localhost:9090/oauth2/authorization/google?platform=mobile',
  );

  static const String oauthKakaoUrl = String.fromEnvironment(
    'OAUTH_KAKAO_URL',
    defaultValue:
        'http://localhost:9090/oauth2/authorization/kakao?platform=mobile',
  );

  static const String oauthGithubUrl = String.fromEnvironment(
    'OAUTH_GITHUB_URL',
    defaultValue:
        'http://localhost:9090/oauth2/authorization/github?platform=mobile',
  );
}
