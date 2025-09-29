// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:taskflow_ai/features/ai_tools/application/ai_tools_providers.dart';
import 'package:taskflow_ai/features/tasks/presentation/screens/add_edit_task_screen.dart';

class OCRTaskScreen extends ConsumerStatefulWidget {
  const OCRTaskScreen({super.key});

  @override
  ConsumerState<OCRTaskScreen> createState() => _OCRTaskScreenState();
}

class _OCRTaskScreenState extends ConsumerState<OCRTaskScreen> {
  File? _selectedImage;
  final _imagePicker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _imagePicker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
        _processImage();
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
    }
  }

  Future<void> _processImage() async {
    if (_selectedImage == null) return;

    try {
      final result = await ref
          .read(aiToolsControllerProvider.notifier)
          .processImage(_selectedImage!);

      if (!mounted) return;

      // Show task suggestions dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'Detected Tasks',
            style: GoogleFonts.lato(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Extracted Text:',
                style: GoogleFonts.lato(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(result.extractedText),
              const SizedBox(height: 16),
              Text(
                'Suggested Tasks:',
                style: GoogleFonts.lato(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              ...result.possibleTasks.map(
                (task) => ListTile(
                  title: Text(task),
                  onTap: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddEditTaskScreen(parsedTaskData: null),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error processing image: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(aiToolsControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Scan Image to Task',
          style: GoogleFonts.lato(fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_selectedImage != null) ...[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Image.file(_selectedImage!),
                ),
              ),
            ] else
              const Icon(Icons.image_search, size: 120, color: Colors.grey),
            const SizedBox(height: 32),
            if (isLoading)
              const CircularProgressIndicator()
            else
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Take Photo'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Choose Image'),
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
