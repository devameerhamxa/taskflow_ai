import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:taskflow_ai/features/ai_tools/application/ai_tools_providers.dart';
import 'package:taskflow_ai/features/ai_tools/domain/ai_answer.dart';

class AskAIScreen extends ConsumerStatefulWidget {
  const AskAIScreen({super.key});

  @override
  ConsumerState<AskAIScreen> createState() => _AskAIScreenState();
}

class _AskAIScreenState extends ConsumerState<AskAIScreen> {
  final _questionController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _questionController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _askQuestion() async {
    final question = _questionController.text.trim();
    if (question.isEmpty) return;

    try {
      final answer = await ref
          .read(aiToolsControllerProvider.notifier)
          .askQuestion(question);

      if (!mounted) return;

      // Add to recent answers
      ref.read(recentAnswersProvider.notifier).addAnswer(answer);
      _questionController.clear();

      // Scroll to bottom after answer is added
      await Future.delayed(const Duration(milliseconds: 100));
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final answers = ref.watch(recentAnswersProvider);
    final isLoading = ref.watch(aiToolsControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ask AI',
          style: GoogleFonts.lato(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (answers.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: () {
                ref.read(recentAnswersProvider.notifier).clearAnswers();
              },
              tooltip: 'Clear History',
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: answers.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.question_answer_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Ask me anything!',
                          style: GoogleFonts.lato(
                            fontSize: 20,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: answers.length,
                    itemBuilder: (context, index) {
                      final answer = answers[index];
                      return _buildQACard(answer);
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _questionController,
                    decoration: InputDecoration(
                      hintText: 'Ask a question...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      filled: true,
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _askQuestion(),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: isLoading ? null : _askQuestion,
                  child: isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQACard(AIAnswer answer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'You',
                        style: GoogleFonts.lato(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(answer.question),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.purple,
                  child: Icon(Icons.smart_toy, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI Assistant',
                        style: GoogleFonts.lato(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(answer.answer),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
