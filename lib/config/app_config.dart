import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Resolves the Gemini API key from build-time defines or the `.env` file.
String get geminiApiKey {
  const fromDefine = String.fromEnvironment('GEMINI_API_KEY');
  if (fromDefine.isNotEmpty) {
    return fromDefine;
  }

  return dotenv.env['GEMINI_API_KEY']?.trim() ?? '';
}

const String geminiModel = 'gemini-2.5-flash';

const String geminiSystemPrompt = '''
You are NextTrain AI, a helpful assistant for Sri Lanka Railways passengers.
Answer questions about train delays, schedules, routes, stations, and travel tips.
Keep responses concise, practical, and friendly. If you do not know live data, say so and suggest checking the NextTrain app prediction feature or station staff.
''';
