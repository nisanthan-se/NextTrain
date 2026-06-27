import 'package:flutter_test/flutter_test.dart';
import 'package:traindelay_app/services/gemini_service.dart';

void main() {
  group('Gemini reply parsing', () {
    test('extracts reply text from a successful Gemini response', () {
      const responseBody =
          '{"candidates":[{"content":{"parts":[{"text":"Hello from Gemini"}]}}]}';

      expect(extractGeminiReply(responseBody), 'Hello from Gemini');
    });

    test('returns a fallback message when the response has no content', () {
      expect(extractGeminiReply('{"candidates":[]}'), 'No response received.');
    });

    test('formats Gemini quota errors for users', () {
      const responseBody =
          '{"error":{"message":"You exceeded your current quota"}}';

      expect(
        formatGeminiErrorMessage(429, responseBody),
        contains('quota limit'),
      );
    });

    test('formats invalid API key errors for users', () {
      const responseBody =
          '{"error":{"message":"API key not valid. Please pass a valid API key."}}';

      expect(
        formatGeminiErrorMessage(400, responseBody),
        contains('valid Gemini API key'),
      );
    });
  });
}
