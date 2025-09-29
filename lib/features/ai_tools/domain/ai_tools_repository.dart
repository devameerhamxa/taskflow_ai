import 'dart:io';
import 'package:taskflow_ai/features/ai_tools/domain/ai_answer.dart';
import 'package:taskflow_ai/features/ai_tools/domain/ocr_result.dart';

abstract class AIToolsRepository {
  /// Extract text from an image and suggest possible tasks
  Future<OCRResult> extractTextFromImage(File imageFile);

  /// Get an AI-generated answer to a question
  Future<AIAnswer> getAnswerToQuestion(String question);

  /// Translate text to another language
  Future<String> translateText(String text, String targetLanguage);

  /// Generate an image from a text prompt
  Future<String> generateImage(String prompt);

  /// Get a conversational response
  Future<String> chat(String message, {List<String>? conversationHistory});
}
