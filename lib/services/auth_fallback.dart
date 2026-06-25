bool shouldUseDemoAuthFallback(String errorMessage) {
  final normalized = errorMessage.toLowerCase();
  return normalized.contains('invalid-app-credential') ||
      normalized.contains('api key') ||
      normalized.contains('project id') ||
      normalized.contains('your_') ||
      normalized.contains('your-') ||
      normalized.contains('firebaseoptions') ||
      normalized.contains('no firebase app');
}
