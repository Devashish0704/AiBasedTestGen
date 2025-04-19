import 'dart:convert';
import 'package:http/http.dart' as http;

class QuizGeneratorService {
  static const String apiUrl =
      "https://api.groq.com/openai/v1/chat/completions";
  static const String apiKey =
      "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";
  static const String model = "llama-3.1-8b-instant";

  static Future<String> generateQuiz(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Authorization": "Bearer $apiKey",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "model": model,
          "messages": [
            {
              "role": "system",
              "content":
                  "You are an assistant that generates high-quality multiple-choice questions."
            },
            {"role": "user", "content": prompt}
          ],
          "temperature": 0.5,
          "top_p": 0.9,
          "max_tokens": 1000,
          "penalty": 1.1,
        }),
      );

      if (response.statusCode != 200) {
        print("❌ API Error: ${response.body}");
        return "";
      }

      final rawContent =
          jsonDecode(response.body)["choices"][0]["message"]["content"];
      final cleanedContent =
          rawContent.replaceAll(RegExp(r"```json|```"), "").trim();

      try {
        final parsed = jsonDecode(cleanedContent);
        if (parsed is Map<String, dynamic>) {
          // Validate the quiz format
          if (parsed.containsKey("questions") &&
              parsed["questions"] is List &&
              parsed.containsKey("topic") &&
              parsed.containsKey("description") &&
              parsed.containsKey("level")) {
            return cleanedContent; // Return the cleaned JSON string
          }
        }
        print("⚠️ Invalid quiz format");
        return "";
      } catch (e) {
        print("❌ JSON Decode Error: $e");
        return "";
      }
    } catch (e) {
      print("❌ Exception: $e");
      return "";
    }
  }
}
