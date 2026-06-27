import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';

String extractGeminiReply(String responseBody) {
  try {
    final data = jsonDecode(responseBody) as Map<String, dynamic>;
    final candidates = data['candidates'] as List<dynamic>?;
    final firstCandidate = candidates?.isNotEmpty == true
        ? candidates!.first as Map<String, dynamic>
        : null;
    final content = firstCandidate?['content'] as Map<String, dynamic>?;
    final parts = content?['parts'] as List<dynamic>?;
    final firstPart = parts?.isNotEmpty == true
        ? parts!.first as Map<String, dynamic>
        : null;
    final text = firstPart?['text'];

    if (text is String && text.trim().isNotEmpty) {
      return text.trim();
    }
  } catch (_) {}

  return 'No response received.';
}

String formatGeminiErrorMessage(int statusCode, String responseBody) {
  final lowerBody = responseBody.toLowerCase();

  if (lowerBody.contains('api key not valid') ||
      lowerBody.contains('invalid api key') ||
      (lowerBody.contains('permission denied') && lowerBody.contains('api'))) {
    return 'The Gemini assistant is not configured with a valid Gemini API key. Add your key to the `.env` file as GEMINI_API_KEY.';
  }

  if (statusCode == 429 ||
      lowerBody.contains('quota') ||
      lowerBody.contains('resource_exhausted')) {
    return 'The AI service is temporarily unavailable because its quota limit has been reached. Please try again in a moment.';
  }

  if (statusCode >= 400 && statusCode < 500) {
    return 'The AI request could not be processed. Please try again shortly.';
  }

  return 'The AI service is currently unavailable. Please try again shortly.';
}

String buildFallbackAssistantReply(String userMessage) {
  final message = userMessage.trim().toLowerCase();

  if (message.contains('delay') ||
      message.contains('late') ||
      message.contains('cancel')) {
    return 'I’m currently unable to reach the AI service, but you can still check the latest train status in the app or contact station staff for live delay and cancellation updates.';
  }

  if (message.contains('schedule') ||
      message.contains('time') ||
      message.contains('departure') ||
      message.contains('arrival')) {
    return 'I’m temporarily offline for live AI responses, but the app’s schedule and history sections can help you review train timings and recent updates.';
  }

  return 'I’m currently unable to access the AI service, but I can still help you navigate the app for train updates, schedules, and delay information.';
}

class GeminiService {
  Future<String> sendMessage(String userMessage) async {
    if (geminiApiKey.isEmpty) {
      return 'The Gemini assistant is not configured yet. Add your Gemini API key to the `.env` file as GEMINI_API_KEY to enable live responses.';
    }

    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$geminiModel:generateContent?key=$geminiApiKey',
    );

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'system_instruction': {
          'parts': [
            {'text': geminiSystemPrompt},
          ],
        },
        'contents': [
          {
            'parts': [
              {'text': userMessage},
            ],
          },
        ],
      }),
    );

    String reply;

    if (response.statusCode == 200) {
      reply = extractGeminiReply(response.body);
    } else {
      reply = formatGeminiErrorMessage(response.statusCode, response.body);
    }

    if (reply.contains('No response received.') ||
        reply.contains('temporarily unavailable') ||
        reply.contains('currently unavailable')) {
      reply = buildFallbackAssistantReply(userMessage);
    }

    return reply;
  }
}
