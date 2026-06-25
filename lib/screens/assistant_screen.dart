import 'dart:convert';
import 'package:flutter/material.dart';
import '../utils/color_utils.dart';
import 'package:http/http.dart' as http;

const String geminiApiKey = String.fromEnvironment(
  'GEMINI_API_KEY',
  defaultValue: '',
);
const String geminiModel = 'gemini-2.0-flash';

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
    return 'The Gemini assistant is not configured with a valid Gemini API key. Please add a working Gemini API key to the app build configuration.';
  }

  if (statusCode == 429 || lowerBody.contains('quota') || lowerBody.contains('resource_exhausted')) {
    return 'The AI service is temporarily unavailable because its quota limit has been reached. Please try again in a moment.';
  }

  if (statusCode >= 400 && statusCode < 500) {
    return 'The AI request could not be processed. Please try again shortly.';
  }

  return 'The AI service is currently unavailable. Please try again shortly.';
}

String buildFallbackAssistantReply(String userMessage) {
  final message = userMessage.trim().toLowerCase();

  if (message.contains('delay') || message.contains('late') || message.contains('cancel')) {
    return 'I’m currently unable to reach the AI service, but you can still check the latest train status in the app or contact station staff for live delay and cancellation updates.';
  }

  if (message.contains('schedule') || message.contains('time') || message.contains('departure') || message.contains('arrival')) {
    return 'I’m temporarily offline for live AI responses, but the app’s schedule and history sections can help you review train timings and recent updates.';
  }

  return 'I’m currently unable to access the AI service, but I can still help you navigate the app for train updates, schedules, and delay information.';
}

class AssistantScreen extends StatefulWidget {
  const AssistantScreen({super.key});

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  static const Color bgColor = Color(0xFF050B12);
  static const Color cyan = Color(0xFF00F5FF);

  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool isLoading = false;

  final List<Map<String, dynamic>> messages = [
    {
      "role": "assistant",
      "content":
          "👋 Welcome to NextTrain AI.\n\nAsk me about train delays, schedules, routes, or railway information."
    }
  ];

  Future<void> sendMessage() async {
    final text = _controller.text.trim();

    if (text.isEmpty) return;

    setState(() {
      messages.add({
        "role": "user",
        "content": text,
      });
      isLoading = true;
    });

    _controller.clear();

    _scrollToBottom();

    try {
      if (geminiApiKey.isEmpty) {
        setState(() {
          messages.add({
            'role': 'assistant',
            'content':
                'The Gemini assistant is not configured yet. Add a valid Gemini API key to the app build configuration to enable live responses.',
          });
        });
        setState(() {
          isLoading = false;
        });
        _scrollToBottom();
        return;
      }

      final uri = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/$geminiModel:generateContent?key=$geminiApiKey',
      );

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': text},
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

      if (reply.contains('No response received.') || reply.contains('temporarily unavailable') || reply.contains('currently unavailable')) {
        reply = buildFallbackAssistantReply(text);
      }

      setState(() {
        messages.add({
          "role": "assistant",
          "content": reply,
        });
      });
    } catch (e) {
      setState(() {
        messages.add({
          "role": "assistant",
          "content":
              "Connection failed.\n\n$e",
        });
      });
    }

    setState(() {
      isLoading = false;
    });

    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(
      const Duration(milliseconds: 300),
      () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration:
                const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color:
                        cyan.withValues(alpha: 0.15),
                  ),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor:
                        cyan.withValues(alpha: 0.15),
                    child: const Icon(
                      Icons.smart_toy,
                      color: cyan,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          "NextTrain AI",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Online",
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding:
                    const EdgeInsets.all(16),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[index];
                  final isUser =
                      msg["role"] == "user";

                  return Align(
                    alignment: isUser
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      constraints:
                          const BoxConstraints(
                        maxWidth: 300,
                      ),
                      margin:
                          const EdgeInsets.only(
                        bottom: 12,
                      ),
                      padding:
                          const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isUser
                            ? cyan.withValues(
                                alpha: 0.15)
                            : Colors.white
                                .withValues(
                                    alpha: 0.06),
                        borderRadius:
                            BorderRadius.circular(
                                18),
                        border: Border.all(
                          color: isUser
                              ? cyan.withValues(
                                  alpha: 0.4)
                              : Colors.white
                                  .withValues(
                                      alpha:
                                          0.08),
                        ),
                      ),
                      child: Text(
                        msg["content"],
                        style:
                            const TextStyle(
                          color: Colors.white,
                          height: 1.4,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            if (isLoading)
              const Padding(
                padding: EdgeInsets.only(
                  bottom: 12,
                ),
                child:
                    CircularProgressIndicator(),
              ),

            Container(
              padding:
                  const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color:
                        cyan.withValues(alpha: 0.15),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                      decoration:
                          InputDecoration(
                        hintText:
                            "Ask NextTrain AI...",
                        hintStyle:
                            TextStyle(
                          color: Colors.white
                              .withValues(
                                  alpha: 0.5),
                        ),
                        filled: true,
                        fillColor: Colors.white
                            .withValues(
                                alpha: 0.04),
                        border:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                                      18),
                          borderSide:
                              BorderSide.none,
                        ),
                      ),
                      onSubmitted:
                          (_) => sendMessage(),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Container(
                    decoration:
                        BoxDecoration(
                      color: cyan
                          .withValues(
                              alpha: 0.15),
                      shape:
                          BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.send,
                        color: cyan,
                      ),
                      onPressed:
                          sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}