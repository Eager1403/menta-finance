class AppConfig {
  AppConfig._();

  /// Backend ya Menta Finance (Spring Boot) - default ni localhost:8080
  /// kwa maendeleo (development). Kwenye production, weka mazingira kwa:
  ///   flutter build web --dart-define=API_BASE_URL=https://api.mentastudio.co.tz
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080',
  );

  static const bool useMockApi = false;

  static const String appName = 'Menta Finance';
  static const String appTagline = 'Mfumo wa Fedha - Menta Studio';

  static const Duration requestTimeout = Duration(seconds: 30);
}
