import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OCRService {
  final TextRecognizer _textRecognizer =
      TextRecognizer(script: TextRecognitionScript.latin);

  Future<String> extractText(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);

      final RecognizedText recognizedText =
          await _textRecognizer.processImage(inputImage);

      return recognizedText.text;
    } catch (e) {
      return '';
    }
  }

  Future<Map<String, String>> scanMedicine(String imagePath) async {
    final text = await extractText(imagePath);

    final result = <String, String>{
      'name': '',
      'strength': '',
      'expiry': '',
      'batchNumber': '',
      'rawText': text,
    };

    final lines = text.split('\n');

    for (final line in lines) {
      final cleanedLine = line.trim();

      if (cleanedLine.isEmpty) {
        continue;
      }

      // Detect expiry date
      if (RegExp(
        r'(EXP|EXPIRY|EXP DATE|EXPIRATION)',
        caseSensitive: false,
      ).hasMatch(cleanedLine)) {
        result['expiry'] = cleanedLine;
      }

      // Detect batch number
      if (RegExp(
        r'(BATCH|BATCH NO|B\.NO|LOT)',
        caseSensitive: false,
      ).hasMatch(cleanedLine)) {
        result['batchNumber'] = cleanedLine;
      }

      // Detect strength
      if (RegExp(
        r'\b\d+\s*(mg|ml|mcg|g|kg)\b',
        caseSensitive: false,
      ).hasMatch(cleanedLine)) {
        result['strength'] = cleanedLine;
      }
    }

    // If no expiry was detected
    if (result['expiry']!.isEmpty) {
      result['expiry'] = 'Expiry Unknown';
    }

    // Use first meaningful line as medicine name
    if (result['name']!.isEmpty && lines.isNotEmpty) {
      for (final line in lines) {
        final cleanedLine = line.trim();

        if (cleanedLine.isNotEmpty &&
            !RegExp(
              r'(EXP|EXPIRY|BATCH|LOT|mg|ml|mcg)',
              caseSensitive: false,
            ).hasMatch(cleanedLine)) {
          result['name'] = cleanedLine;
          break;
        }
      }
    }

    return result;
  }

  void dispose() {
    _textRecognizer.close();
  }
}
