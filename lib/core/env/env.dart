class Env {
  Env._();

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:9090',
  );

  static const String oauthGoogleUrl =
      '$apiBaseUrl/oauth2/authorization/google?platform=mobile';

  static const String oauthKakaoUrl =
      '$apiBaseUrl/oauth2/authorization/kakao?platform=mobile';

  static const String oauthGithubUrl =
      '$apiBaseUrl/oauth2/authorization/github?platform=mobile';
}
