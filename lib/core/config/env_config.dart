/// Environment configuration for the app.
/// In production, load these from secure storage or CI/CD secrets.
class EnvConfig {
  EnvConfig._();

  /// Base URL for the AI service (mock endpoint for MVP).
  static const String aiServiceBaseUrl = String.fromEnvironment(
    'AI_SERVICE_BASE_URL',
    defaultValue: 'https://api.example.com',
  );

  /// API key for AI service (placeholder for MVP).
  static const String aiServiceApiKey = String.fromEnvironment(
    'AI_SERVICE_API_KEY',
    defaultValue: 'mock-api-key',
  );

  /// Whether we're using the mock AI service.
  static const bool useMockAiService = bool.fromEnvironment(
    'USE_MOCK_AI_SERVICE',
    defaultValue: true,
  );
}
