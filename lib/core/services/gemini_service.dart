import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiService {

  String get _apiKey {
    final key = dotenv.env['GEMINI_API_KEY'];
    if (key == null || key.isEmpty || key == 'your_gemini_api_key_here') {
      throw Exception('GEMINI_API_KEY not configured. Please add your API key to the .env file and rebuild the app');
    }
    return key;
  }

  String _getApiUrl(String modelId) {
    return 'https://generativelanguage.googleapis.com/v1beta/models/$modelId:generateContent?key=$_apiKey';
  }

  Future<String> transcribeAudio({
    required String audioFilePath,
    required String modelId,
    String? language,
  }) async {
    final file = File(audioFilePath);
    if (!await file.exists()) {
      throw Exception('Audio file does not exist: $audioFilePath');
    }

    final audioBytes = await file.readAsBytes();
    final base64Audio = base64Encode(audioBytes);

    // Determine MIME type from file extension
    String mimeType = 'audio/aac';
    if (audioFilePath.endsWith('.m4a')) {
      mimeType = 'audio/mp4';
    } else if (audioFilePath.endsWith('.mp3')) {
      mimeType = 'audio/mp3';
    } else if (audioFilePath.endsWith('.wav')) {
      mimeType = 'audio/wav';
    }

    print('Transcribing audio: ${audioBytes.length} bytes, MIME: $mimeType, Model: $modelId');

    final prompt = language != null
        ? 'Transcribe this audio in $language. Provide only the transcription text without any additional commentary.'
        : 'Transcribe this audio. Provide only the transcription text without any additional commentary.';

    final requestBody = {
      'contents': [
        {
          'parts': [
            {'text': prompt},
            {
              'inline_data': {
                'mime_type': mimeType,
                'data': base64Audio,
              }
            }
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0.1,
        'maxOutputTokens': 8192,
      }
    };

    final response = await http.post(
      Uri.parse(_getApiUrl(modelId)),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    if (response.statusCode != 200) {
      throw Exception(
          'Gemini API error: ${response.statusCode} - ${response.body}');
    }

    final data = jsonDecode(response.body);
    return _extractTranscription(data);
  }

  String _extractTranscription(Map<String, dynamic> response) {
    try {
      // Log full response for debugging
      print('Gemini API Response: ${jsonEncode(response)}');

      // Check for errors in response
      if (response.containsKey('error')) {
        final error = response['error'];
        throw Exception('Gemini API error: ${error['message'] ?? error.toString()}');
      }

      final candidates = response['candidates'] as List?;
      if (candidates == null || candidates.isEmpty) {
        throw Exception('No candidates in response. Full response: ${jsonEncode(response)}');
      }

      final candidate = candidates[0] as Map<String, dynamic>;

      // Check if content was blocked
      if (candidate.containsKey('finishReason') &&
          candidate['finishReason'] != 'STOP') {
        throw Exception('Content blocked or filtered: ${candidate['finishReason']}');
      }

      final content = candidate['content'] as Map<String, dynamic>?;
      if (content == null) {
        throw Exception('No content in candidate. Candidate: ${jsonEncode(candidate)}');
      }

      final parts = content['parts'] as List?;
      if (parts == null || parts.isEmpty) {
        throw Exception('No parts in content. Content: ${jsonEncode(content)}');
      }

      final text = parts[0]['text'] as String?;
      if (text == null || text.isEmpty) {
        throw Exception('No text in part. Part: ${jsonEncode(parts[0])}');
      }

      return text.trim();
    } catch (e) {
      print('Error extracting transcription: $e');
      rethrow;
    }
  }

  Future<String> generateSummary({
    required String transcription,
    required String modelId,
  }) async {
    final requestBody = {
      'contents': [
        {
          'parts': [
            {
              'text':
                  'Summarize the following transcription in 2-3 sentences. Focus on the main points and key takeaways:\n\n$transcription'
            }
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0.3,
      }
    };

    final response = await http.post(
      Uri.parse(_getApiUrl(modelId)),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    if (response.statusCode != 200) {
      throw Exception(
          'Gemini API error: ${response.statusCode} - ${response.body}');
    }

    final data = jsonDecode(response.body);
    return _extractTranscription(data);
  }
}