import 'dart:convert';
import 'package:http/http.dart' as http;

class QuizGeneratorService {
  static const String apiUrl =
      "https://api-inference.huggingface.co/models/mistralai/Mistral-7B-Instruct-v0.2";
  static const String apiKey = ;

  static Future<List<Map<String, dynamic>>> generateQuiz(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Authorization": "Bearer $apiKey",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "inputs": prompt,
          "parameters": {
            "max_new_tokens": 2048,
            "temperature": 0.7,
          }
        }),
      );

      if (response.statusCode != 200) {
        print("❌ API Error: ${response.body}");
        return [];
      }

      final responseData = jsonDecode(response.body);
      final generatedText = responseData[0]["generated_text"];

      final regex = RegExp(r'\[\s*{.*?}\s*\]', dotAll: true);
      final match = regex.firstMatch(generatedText);

      if (match != null) {
        final jsonArrayString = match.group(0);
        final quiz = jsonDecode(jsonArrayString!) as List;
        return quiz.cast<Map<String, dynamic>>();
      } else {
        // Fallback: split into lines and parse one-by-one
        final lines = generatedText.split('\n');
        final List<Map<String, dynamic>> quiz = [];

        for (var line in lines) {
          line = line.trim();
          if (line.startsWith('{') && line.endsWith('}')) {
            try {
              final item = jsonDecode(line);
              if (item is Map<String, dynamic>) {
                quiz.add(item);
              }
            } catch (_) {}
          }
        }
        return quiz;
      }
    } catch (e) {
      print("❌ Exception: $e");
      return [];
    }
  }
}
