// Temporary file with the correct implementation
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:taskflow_ai/core/utils/app_logger.dart';
import 'package:taskflow_ai/features/ai_tools/domain/ai_answer.dart';
import 'package:taskflow_ai/features/ai_tools/domain/ai_tools_repository.dart';
import 'package:taskflow_ai/features/ai_tools/domain/ocr_result.dart';

class GeminiAIToolsRepository implements AIToolsRepository {
  final String _apiKey;
  static const String _model = 'gemini-1.0-pro';
  static const String _baseUrl = 'generativelanguage.googleapis.com';
  static const String _apiVersion = 'v1beta';
  static const String _apiPath = 'models';

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
        'API key not configured. Please check your .env file and ensure GEMINI_API_KEY is set.',
      );
    }

    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$_apiKey',
    );

    try {
      AppLogger.api('$_apiPath/$_model:generateContent', request: body);

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      AppLogger.api(
        endpoint,
        response: response.body,
        statusCode: response.statusCode,
      );

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
  Future<AIAnswer> getAnswerToQuestion(String question) async {
    try {
      final response = await _makeRequest('', {
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
      final response = await _makeRequest('', {
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
      final fullMessage = conversationHistory != null
          ? '${conversationHistory.join("\n")}\n$message'
          : message;

      final response = await _makeRequest('', {
        'contents': [
          {
            'parts': [
              {'text': fullMessage},
            ],
          },
        ],
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
  Future<OCRResult> extractTextFromImage(File imageFile) async {
    AppLogger.log('OCR requested for file: ${imageFile.path}');

    return OCRResult(
      extractedText: 'Text extraction coming soon',
      possibleTasks: ['Task 1', 'Task 2'],
    );
  }

  @override
  Future<String> generateImage(String prompt) async {
    AppLogger.log('Image generation requested: $prompt');

    throw UnimplementedError(
      'Image generation will be implemented soon using Stable Diffusion API.',
    );
  }
}
