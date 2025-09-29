import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:taskflow_ai/features/ai_tools/application/ai_tools_providers.dart';

class ImageGenerationScreen extends ConsumerStatefulWidget {
  const ImageGenerationScreen({super.key});

  @override
  ConsumerState<ImageGenerationScreen> createState() =>
      _ImageGenerationScreenState();
}

class _ImageGenerationScreenState extends ConsumerState<ImageGenerationScreen> {
  final _promptController = TextEditingController();
  String? _generatedImageUrl;

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _generateImage() async {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) return;

    try {
      final imageUrl = await ref
          .read(aiToolsControllerProvider.notifier)
          .generateImage(prompt);

      if (!mounted) return;

      setState(() {
        _generatedImageUrl = imageUrl;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(aiToolsControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Generate Image',
          style: GoogleFonts.lato(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Prompt input
            TextField(
              controller: _promptController,
              decoration: const InputDecoration(
                labelText: 'Describe the image you want to create',
                border: OutlineInputBorder(),
                helperText:
                    'Be specific with details like style, colors, and composition',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Generate button
            ElevatedButton(
              onPressed: isLoading ? null : _generateImage,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Generate Image'),
            ),
            const SizedBox(height: 32),

            // Generated image display
            if (_generatedImageUrl != null)
              Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.network(
                      _generatedImageUrl!,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return AspectRatio(
                          aspectRatio: 1,
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return const AspectRatio(
                          aspectRatio: 1,
                          child: Center(
                            child: Icon(
                              Icons.error_outline,
                              size: 48,
                              color: Colors.red,
                            ),
                          ),
                        );
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Image download coming soon!'),
                                ),
                              );
                            },
                            icon: const Icon(Icons.download),
                            label: const Text('Download'),
                          ),
                          const SizedBox(width: 8),
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _generatedImageUrl = null;
                              });
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Generate New'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            else
              Center(
                child: Column(
                  children: [
                    const Icon(
                      Icons.image_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Your generated image will appear here',
                      style: GoogleFonts.lato(fontSize: 16, color: Colors.grey),
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
