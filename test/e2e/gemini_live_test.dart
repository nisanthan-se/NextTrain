import 'package:flutter_test/flutter_test.dart';
import 'package:traindelay_app/config/app_config.dart';
import 'package:traindelay_app/services/gemini_service.dart';

import 'test_helpers.dart';

/// Live API test — requires a valid GEMINI_API_KEY in `.env`.
void main() {
  setUpAll(() async {
    await loadTestEnv();
  });

  test('Gemini API returns a railway-related reply', () async {
    if (geminiApiKey.isEmpty) {
      // ignore: avoid_print
      print('Skipping live Gemini test: no GEMINI_API_KEY in .env');
      return;
    }

    final service = GeminiService();
    final reply = await service.sendMessage(
      'In one sentence, what is NextTrain useful for?',
    );

    expect(reply, isNotEmpty);
    expect(reply.toLowerCase(), isNot(contains('not configured')));
    expect(reply.toLowerCase(), isNot(contains('valid gemini api key')));
  });
}
