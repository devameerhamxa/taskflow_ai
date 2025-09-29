import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:taskflow_ai/core/utils/app_logger.dart';
import 'package:taskflow_ai/features/ai_tools/domain/ai_answer.dart';
import 'package:taskflow_ai/features/ai_tools/domain/ai_tools_repository.dart';
import 'package:taskflow_ai/features/ai_tools/domain/ocr_result.dart';

class GeminiAIToolsRepository implements AIToolsRepository {
  final String _apiKey;
  static const String _model = 'gemini-pro';
  static const String _baseUrl = 'generativelanguage.googleapis.com';
  static const String _apiVersion = 'v1beta';

  GeminiAIToolsRepository({required String apiKey}) : _apiKey = apiKey {
    // Log if API key is not properly configured
    if (_apiKey.isEmpty) {
      AppLogger.error('Gemini API key is not configured');
    }
  }

  Future<Map<String, dynamic>> _makeRequest(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    if (_apiKey.isEmpty) {
      throw Exception(
        'API key not configured. Please add your Gemini API key to the .env file.',
      );
    }

    final url = Uri.https(
      _baseUrl,
      '$_apiVersion/models/$_model:generateContent',
      {'key': _apiKey},
    );
    final headers = {'Content-Type': 'application/json'};

    try {
      // Log request details
      AppLogger.log(
        'Making API request to: ${url.toString()}',
        tag: 'GeminiAPI',
      );
      AppLogger.api(url.toString(), request: body, headers: headers);

      final stopwatch = Stopwatch()..start();

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );

      stopwatch.stop();
      AppLogger.performance('API call to $endpoint', stopwatch.elapsed);

      // Log response details with sanitized URL (hiding API key)
      final sanitizedUrl = url.toString().replaceAll(_apiKey, '***');
      AppLogger.api(
        sanitizedUrl,
        response: response.body,
        statusCode: response.statusCode,
      );

      if (response.statusCode == 404) {
        AppLogger.error(
          'API endpoint not found. Please check the endpoint URL.',
          tag: 'GeminiAPI',
          error: 'URL: $sanitizedUrl\nResponse: ${response.body}',
        );
        throw Exception('API endpoint not found. URL: $sanitizedUrl');
      }

      if (response.statusCode == 401) {
        AppLogger.error(
          'Authentication failed. Please check your API key.',
          tag: 'GeminiAPI',
          error: 'Response: ${response.body}',
        );
        throw Exception('Authentication failed. Please verify your API key.');
      }
      AppLogger.performance('API call to $endpoint', stopwatch.elapsed);

      // Log response details
      AppLogger.api(
        endpoint,
        response: response.body,
        statusCode: response.statusCode,
      );

      if (response.statusCode == 404) {
        AppLogger.error(
          'API endpoint not found. Please check the endpoint URL.',
          tag: 'GeminiAPI',
          error: 'URL: ${url.toString()}\nResponse: ${response.body}',
        );
        throw Exception('API endpoint not found. URL: ${url.toString()}');
      }

      if (response.statusCode == 401) {
        AppLogger.error(
          'Authentication failed. Please check your API key.',
          tag: 'GeminiAPI',
          error: 'Response: ${response.body}',
        );
        throw Exception('Authentication failed. Please verify your API key.');
      }

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 401) {
        throw Exception(
          'Authentication failed. Please check your API key in the .env file.',
        );
      } else {
        throw Exception(
          'API request failed with status ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e, stack) {
      AppLogger.error(
        'API request failed',
        error: e,
        stackTrace: stack,
        tag: 'GeminiAPI',
      );
      rethrow;
    }
  }

  @override
  Future<OCRResult> extractTextFromImage(File imageFile) async {
    // For now, return placeholder
    return OCRResult(
      extractedText: 'Text extraction coming soon',
      possibleTasks: ['Task 1', 'Task 2'],
    );
  }

  @override
  Future<AIAnswer> getAnswerToQuestion(String question) async {
    try {
      final response = await _makeRequest('models/$_model:generateContent', {
        'contents': [
          {
            'parts': [
              {'text': question},
            ],
          },
        ],
        'generationConfig': {
          'temperature': 0.7,
          'topK': 40,
          'topP': 0.95,
          'maxOutputTokens': 1024,
        },
      });

      final answer =
          response['candidates'][0]['content']['parts'][0]['text'] as String;
      return AIAnswer(
        question: question,
        answer: answer,
        timestamp: DateTime.now(),
      );
    } catch (e, stack) {
      AppLogger.error(
        'Failed to get answer',
        error: e,
        stackTrace: stack,
        tag: 'QA',
      );
      rethrow;
    }
  }

  @override
  Future<String> translateText(String text, String targetLanguage) async {
    try {
      final response = await _makeRequest('models/$_model/generateContent', {
        'contents': [
          {
            'parts': [
              {
                'text':
                    'Translate the following text to $targetLanguage: "$text"',
              },
            ],
          },
        ],
        'generationConfig': {
          'temperature': 0.3,
          'topK': 1,
          'topP': 0.8,
          'maxOutputTokens': 1024,
        },
      });

      return response['candidates'][0]['content']['parts'][0]['text'] as String;
    } catch (e, stack) {
      AppLogger.error(
        'Translation failed',
        error: e,
        stackTrace: stack,
        tag: 'Translate',
      );
      rethrow;
    }
  }

  @override
  Future<String> chat(
    String message, {
    List<String>? conversationHistory,
  }) async {
    try {
      final messages = [
        if (conversationHistory != null)
          for (final msg in conversationHistory)
            {
              'parts': [
                {'text': msg},
              ],
            },
        {
          'parts': [
            {'text': message},
          ],
        },
      ];

      final response = await _makeRequest('models/$_model/generateContent', {
        'contents': messages,
        'generationConfig': {
          'temperature': 0.9,
          'topK': 40,
          'topP': 0.95,
          'maxOutputTokens': 1024,
        },
      });

      return response['candidates'][0]['content']['parts'][0]['text'] as String;
    } catch (e, stack) {
      AppLogger.error('Chat failed', error: e, stackTrace: stack, tag: 'Chat');
      rethrow;
    }
  }

  @override
  Future<String> generateImage(String prompt) async {
    AppLogger.log('Image generation requested: $prompt');

    throw UnimplementedError(
      'Image generation will be implemented soon using Stable Diffusion API.',
    );
  }

  Future<String> chatWithBearer(
    String message, {
    List<String>? conversationHistory,
  }) async {
    final url = Uri.https(
      _baseUrl,
      '$_apiVersion/models/$_model/generateContent',
    );

    final List<Map<String, dynamic>> messages = [];

    // Add conversation history if available
    if (conversationHistory != null) {
      for (final historyMessage in conversationHistory) {
        messages.add({
          'parts': [
            {'text': historyMessage},
          ],
        });
      }
    }

    // Add the current message
    messages.add({
      'parts': [
        {'text': message},
      ],
    });

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'contents': messages,
          'generationConfig': {
            'temperature': 0.7,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 1024,
          },
        }),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return body['candidates'][0]['content']['parts'][0]['text'];
      } else {
        throw Exception('Failed to get chat response: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error in chatWithBearer: $e');
    }
  }
}
