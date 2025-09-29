import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskflow_ai/core/services/config_service.dart';
import 'package:taskflow_ai/features/ai_tools/domain/ai_answer.dart';
import 'package:taskflow_ai/features/ai_tools/domain/ai_tools_repository.dart';
import 'package:taskflow_ai/features/ai_tools/domain/ocr_result.dart';
import 'package:taskflow_ai/features/ai_tools/infrastructure/gemini_ai_tools_repository.dart';

// Repository provider
final aiToolsRepositoryProvider = Provider<AIToolsRepository>((ref) {
  final apiKey = ConfigService.instance.geminiApiKey;
  return GeminiAIToolsRepository(apiKey: apiKey);
});

// AI Tools Controller
final aiToolsControllerProvider =
    StateNotifierProvider<AIToolsController, AsyncValue<void>>((ref) {
      final repository = ref.watch(aiToolsRepositoryProvider);
      return AIToolsController(repository);
    });

// Recent answers cache provider
final recentAnswersProvider =
    StateNotifierProvider<RecentAnswersNotifier, List<AIAnswer>>((ref) {
      return RecentAnswersNotifier();
    });

class AIToolsController extends StateNotifier<AsyncValue<void>> {
  final AIToolsRepository _repository;

  AIToolsController(this._repository) : super(const AsyncValue.data(null));

  Future<OCRResult> processImage(File imageFile) async {
    state = const AsyncValue.loading();
    try {
      final result = await _repository.extractTextFromImage(imageFile);
      state = const AsyncValue.data(null);
      return result;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<AIAnswer> askQuestion(String question) async {
    state = const AsyncValue.loading();
    try {
      final answer = await _repository.getAnswerToQuestion(question);
      state = const AsyncValue.data(null);
      return answer;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<String> translateText(String text, String targetLanguage) async {
    state = const AsyncValue.loading();
    try {
      final translation = await _repository.translateText(text, targetLanguage);
      state = const AsyncValue.data(null);
      return translation;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<String> generateImage(String prompt) async {
    state = const AsyncValue.loading();
    try {
      final imageUrl = await _repository.generateImage(prompt);
      state = const AsyncValue.data(null);
      return imageUrl;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<String> chat(
    String message, {
    List<String>? conversationHistory,
  }) async {
    state = const AsyncValue.loading();
    try {
      final response = await _repository.chat(
        message,
        conversationHistory: conversationHistory,
      );
      state = const AsyncValue.data(null);
      return response;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

class RecentAnswersNotifier extends StateNotifier<List<AIAnswer>> {
  RecentAnswersNotifier() : super([]);

  void addAnswer(AIAnswer answer) {
    state = [...state, answer];
    // Keep only last 10 answers
    if (state.length > 10) {
      state = state.sublist(state.length - 10);
    }
  }

  void clearAnswers() {
    state = [];
  }
}
