import 'package:flutter/foundation.dart';

@immutable
class OCRResult {
  final String extractedText;
  final List<String> possibleTasks;

  const OCRResult({required this.extractedText, required this.possibleTasks});

  factory OCRResult.fromJson(Map<String, dynamic> json) {
    return OCRResult(
      extractedText: json['extractedText'] as String,
      possibleTasks: (json['possibleTasks'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'extractedText': extractedText, 'possibleTasks': possibleTasks};
  }
}
