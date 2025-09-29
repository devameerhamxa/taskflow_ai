import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:taskflow_ai/features/ai_tools/domain/repositories/ai_tools_repository.dart';

class GeminiAIToolsRepository implements AIToolsRepository {
  final String _apiKey;
  final String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta';

  GeminiAIToolsRepository({required String apiKey}) : _apiKey = apiKey;

  @override
  Future<String> extractTextFromImage(File imageFile) async {
    throw UnimplementedError('OCR not yet implemented');
  }

  @override
  Future<String> getAnswerToQuestion(String question) async {
    final url = '$_baseUrl/models/gemini-pro:generateContent?key=$_apiKey';

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
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
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['candidates'][0]['content']['parts'][0]['text'];
    } else {
      throw Exception('Failed to get answer: ${response.body}');
    }
  }

  @override
  Future<String> translateText({
    required String text,
    required String sourceLanguage,
    required String targetLanguage,
  }) async {
    final prompt =
        'Translate the following text from $sourceLanguage to $targetLanguage:\n\n$text';

    return getAnswerToQuestion(prompt);
  }

  @override
  Future<String> chat(List<Map<String, String>> messages) async {
    final url = '$_baseUrl/models/gemini-pro:generateContent?key=$_apiKey';

    final formattedMessages = messages.map((msg) {
      return {
        'parts': [
          {'text': msg['content']},
        ],
        'role': msg['role'],
      };
    }).toList();

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': formattedMessages,
        'generationConfig': {
          'temperature': 0.9,
          'topK': 40,
          'topP': 0.95,
          'maxOutputTokens': 1024,
        },
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['candidates'][0]['content']['parts'][0]['text'];
    } else {
      throw Exception('Failed to get chat response: ${response.body}');
    }
  }

  @override
  Future<String> generateImage(String prompt) async {
    // Note: Since Gemini doesn't support image generation yet,
    // we'll use a different API (e.g., DALL-E or Stable Diffusion)
    // For now, this is a placeholder that will need to be implemented
    // with your chosen image generation API
    throw UnimplementedError(
      'Image generation not yet implemented. '
      'Please implement using your preferred image generation API.',
    );
  }
}
