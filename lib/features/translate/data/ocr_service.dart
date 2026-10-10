import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

abstract class OcrService {
  /// Returns the recognized text (trimmed, empty if none found).
  Future<String> recognize(String imagePath);
  Future<void> dispose();
}

class MlKitOcrService implements OcrService {
  final _recognizer = TextRecognizer(script: TextRecognitionScript.latin);

  @override
  Future<String> recognize(String imagePath) async {
    final input = InputImage.fromFilePath(imagePath);
    final result = await _recognizer.processImage(input);
    return result.text.trim();
  }

  @override
  Future<void> dispose() => _recognizer.close();
}