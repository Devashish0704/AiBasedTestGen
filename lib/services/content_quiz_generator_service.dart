import 'dart:convert';
import 'package:http/http.dart' as http;

class ContentQuizGeneratorService {
  static const String apiUrl =
      "https://api.groq.com/openai/v1/chat/completions";
  static const String apiKey =
      "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";
  static const String model = "llama-3.1-8b-instant";

  /// Generates a quiz from the provided content
  static Future<String> generateQuizFromContent(String content) async {
    try {
      final prompt = '''
You are an expert assistant that generates high-quality multiple-choice quizzes ONLY from the provided content.

Content to generate quiz from:
$content

Rules:
1. Generate exactly 10 multiple-choice questions based ONLY on the provided content.
2. Each question must be answerable from the content.
3. Do not include any information that's not in the content.
4. Use clear, concise language.
5. Make questions test understanding, not just memorization.

Each question object must follow this exact format:
{
  "question": "Question text?",
  "options": ["Option 1", "Option 2", "Option 3", "Option 4"],
  "correctIndex": 0  // Index from 0 to 3
}

Final Output Format:
Return the entire quiz as a single JSON object:
{
  "topic": "Topic derived from content",
  "level": "Medium",
  "questions": [ ...10 formatted questions... ],
  "quiz_icon": "One of: code, storage, web, design_services, school, science, sports_esports, book, computer, lightbulb"
}

⚠️ Strict Guidelines:
- The "quiz_icon" field must contain only one of the allowed icon names — no quotes, no explanation.
- Do not return anything outside of the JSON object.
- Do not use markdown formatting or any extra text.
- Every question must be directly answerable from the provided content.
''';

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
              "content": prompt,
            },
            {"role": "user", "content": "Generate quiz now."}
          ],
          "temperature": 0.5,
          "top_p": 0.9,
          "max_tokens": 1000,
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
        print("Parsed JSON: $parsed");
        if (parsed is Map<String, dynamic>) {
          // Validate the quiz format
          if (_validateQuizStructure(parsed)) {
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

  /// Validates that the quiz JSON has the required structure
  static bool _validateQuizStructure(Map<String, dynamic> quiz) {
    if (!quiz.containsKey('questions') ||
        !quiz.containsKey('topic') ||
        !quiz.containsKey('level') ||
        !quiz.containsKey('quiz_icon')) {
      return false;
    }

    final questions = quiz['questions'] as List;
    if (questions.isEmpty || questions.length != 10) return false;

    for (var question in questions) {
      if (!question.containsKey('question') ||
          !question.containsKey('options') ||
          !question.containsKey('correctIndex')) {
        return false;
      }

      final options = question['options'] as List;
      if (options.length != 4) return false;

      final correctIndex = question['correctIndex'] as int;
      if (correctIndex < 0 || correctIndex > 3) return false;
    }

    return true;
  }
}
