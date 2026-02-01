import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

class ReadingUtils {
  static final stt.SpeechToText _speech = stt.SpeechToText();
  static final ImagePicker _picker = ImagePicker();

  /// ===== Speech-to-Text =====
  static Future<bool> listen({
    required TextEditingController controller,
    required bool isListening,
    required Function(bool) onStateChange,
  }) async {
    if (!isListening) {
      var status = await Permission.microphone.request();
      if (!status.isGranted) {
        print("Mic permission denied");
        return false;
      }

      bool available = await _speech.initialize(
        onStatus: (status) => print("Speech status: $status"),
        onError: (error) => print("Speech error: $error"),
      );

      if (available) {
        onStateChange(true);

        _speech.listen(
          localeId: 'ar',
          listenMode: stt.ListenMode.dictation,
          onResult: (result) {
            final numbers = result.recognizedWords.replaceAll(
              RegExp(r'[^0-9]'),
              '',
            );
            controller.text = numbers;
          },
        );
      } else {
        print("Speech not available");
      }

      return true;
    } else {
      onStateChange(false);
      await _speech.stop();
      return false;
    }
  }

  /// ===== OCR + Camera / Gallery =====
  static Future<void> extractNumbersFromImage({
    required BuildContext context,
    required TextEditingController controller,
    required Function(bool) onProcessingChange,
  }) async {
    try {
      onProcessingChange(true);

      // اختيار المصدر
      final ImageSource? source = await showModalBottomSheet<ImageSource>(
        context: context,
        builder: (context) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.blue),
                title: const Text('Camera'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.blue),
                title: const Text('Gallery'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        ),
      );

      if (source == null) {
        onProcessingChange(false);
        return;
      }

      final XFile? pickedFile = await _picker.pickImage(source: source);

      if (pickedFile == null) {
        onProcessingChange(false);
        return;
      }

      final File imageFile = File(pickedFile.path);
      final InputImage inputImage = InputImage.fromFile(imageFile);
      final textRecognizer = TextRecognizer();
      final RecognizedText recognizedText = await textRecognizer.processImage(
        inputImage,
      );

      final allText = recognizedText.text;

      // ==== تحسين استخراج الأرقام ====
      // 1. الأرقام بالإنجليزي
      final numbersEN = RegExp(
        r'\d+',
      ).allMatches(allText).map((m) => m.group(0)).join('');
      // 2. الأرقام بالعربي (٠١٢٣٤٥٦٧٨٩)
      final arabicNumbersMap = {
        '٠': '0',
        '١': '1',
        '٢': '2',
        '٣': '3',
        '٤': '4',
        '٥': '5',
        '٦': '6',
        '٧': '7',
        '٨': '8',
        '٩': '9',
      };
      String numbersAR = '';
      for (var char in allText.split('')) {
        if (arabicNumbersMap.containsKey(char)) {
          numbersAR += arabicNumbersMap[char]!;
        }
      }

      final numbers = numbersEN + numbersAR;

      if (numbers.isNotEmpty) {
        controller.text = numbers;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reading detected: $numbers'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No numbers found in image'),
            backgroundColor: Colors.orange,
          ),
        );
      }

      await textRecognizer.close();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      onProcessingChange(false);
    }
  }
}
