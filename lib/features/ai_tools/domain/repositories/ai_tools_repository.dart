import 'dart:io';

abstract class AIToolsRepository {
  /// Extracts text from an image file
  Future<String> extractTextFromImage(File imageFile);

  /// Gets an AI-generated answer to a question
  Future<String> getAnswerToQuestion(String question);

  /// Translates text from one language to another
  Future<String> translateText({
    required String text,
    required String sourceLanguage,
    required String targetLanguage,
  });

  /// Chat with the AI
  Future<String> chat(List<Map<String, String>> messages);

  /// Generate an image from a text description
  Future<String> generateImage(String prompt);
}
