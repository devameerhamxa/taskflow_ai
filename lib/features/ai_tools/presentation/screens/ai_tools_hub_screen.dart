// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:taskflow_ai/features/ai_tools/presentation/screens/ask_ai_screen.dart';
import 'package:taskflow_ai/features/ai_tools/presentation/screens/chat_screen.dart';
import 'package:taskflow_ai/features/ai_tools/presentation/screens/image_generation_screen.dart';
import 'package:taskflow_ai/features/ai_tools/presentation/screens/ocr_task_screen.dart';
import 'package:taskflow_ai/features/ai_tools/presentation/screens/translate_screen.dart';

class AIToolsHubScreen extends ConsumerWidget {
  const AIToolsHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'AI Tools',
          style: GoogleFonts.lato(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: [
          _buildToolCard(
            context,
            icon: Icons.image_search,
            title: 'Scan Image\nto Task',
            color: Colors.blue,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const OCRTaskScreen()),
            ),
          ),
          _buildToolCard(
            context,
            icon: Icons.question_answer,
            title: 'Ask AI a\nQuestion',
            color: Colors.purple,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AskAIScreen()),
            ),
          ),
          _buildToolCard(
            context,
            icon: Icons.translate,
            title: 'Translate\nText',
            color: Colors.green,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TranslateScreen()),
            ),
          ),
          _buildToolCard(
            context,
            icon: Icons.brush,
            title: 'Generate\nImage',
            color: Colors.orange,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ImageGenerationScreen()),
            ),
          ),
          _buildToolCard(
            context,
            icon: Icons.chat_bubble_outline,
            title: 'Chat with\nAI',
            color: Colors.teal,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChatScreen()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withOpacity(0.8), color],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: Colors.white),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
