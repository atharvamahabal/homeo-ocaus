import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

class VoiceService {
  static final stt.SpeechToText _speech = stt.SpeechToText();

  static Future<bool> init() async {
    bool available = await _speech.initialize(
      onStatus: (status) => print('STT Status: $status'),
      onError: (error) => print('STT Error: $error'),
    );
    return available;
  }

  static Future<void> startListening({
    required Function(String) onResult,
    String languageCode = 'en-US', // Default to English
  }) async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      status = await Permission.microphone.request();
      if (!status.isGranted) return;
    }

    bool available = await _speech.initialize();
    if (available) {
      _speech.listen(
        onResult: (result) {
          if (result.finalResult) {
            onResult(result.recognizedWords);
          }
        },
        localeId: languageCode,
        cancelOnError: true,
        partialResults: true,
        listenMode: stt.ListenMode.dictation,
      );
    }
  }

  static Future<void> stopListening() async {
    await _speech.stop();
  }

  static bool get isListening => _speech.isListening;

  // Bhashini Integration Placeholder
  // To implement Bhashini, we would record audio using the 'record' package
  // and send the audio file to Bhashini's ULCA Inference API.
  static Future<String> translateWithBhashini(String text, String targetLang) async {
    // This would be a REST call to Bhashini API
    // For now, returning the same text
    return text;
  }
}
