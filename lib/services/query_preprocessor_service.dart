import 'dart:convert';
import 'package:http/http.dart' as http;

class QueryPreprocessorService {
  static const String apiUrl =
      "https://api.groq.com/openai/v1/chat/completions";
  static const String apiKey =
      "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";
  static const String model = "llama-3.1-8b-instant";

  static Future<Map<String, dynamic>> preprocessQuery(String userQuery) async {
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
              "content": """
You are an assistant that analyzes quiz generation queries.

Return ONLY a JSON object in this **exact** structure:
{
  "number_of_questions": INTEGER,
  "difficulty_level": "easy" | "medium" | "hard",
  "user_query": STRING
}

⚠️ IMPORTANT RULES:
- number_of_questions: Must be between 5 and 15. If user requests <5 or >15, return 10.
- difficulty_level: Must be "easy", "medium", or "hard". Default to "medium" if not mentioned.
- user_query: Extract a clean and clear topic, no filler text.

DO NOT return anything else. No explanation, no markdown, no prefix.

Examples:
User: "give a test on SQL with 20 questions"
Response:
{
  "number_of_questions": 10,
  "difficulty_level": "medium",
  "user_query": "SQL"
}

User: "I want 4 very difficult questions on machine learning"
Response:
{
  "number_of_questions": 10,
  "difficulty_level": "hard",
  "user_query": "Machine Learning"
}



User: "test on AI and ML, medium difficulty, 12 questions"
Response:
{
  "number_of_questions": 12,
  "difficulty_level": "medium",
  "user_query": "Artificial Intelligence and Machine Learning"
}
"""

            },
            {"role": "user", "content": userQuery}
          ],
          "temperature": 0.3,
          "top_p": 0.9,
          "max_tokens": 1000,
        }),
      );

      if (response.statusCode != 200) {
        print("❌ Preprocessing API Error: ${response.body}");
        return _getDefaultResponse(userQuery);
      }

      final rawContent =
          jsonDecode(response.body)["choices"][0]["message"]["content"];
      final cleanedContent =
          rawContent.replaceAll(RegExp(r"```json|```"), "").trim();

      try {
        final parsed = jsonDecode(cleanedContent);
        return parsed;
      } catch (e) {
        print("❌ Preprocessing JSON Decode Error: $e");
        return _getDefaultResponse(userQuery);
      }
    } catch (e) {
      print("❌ Preprocessing Exception: $e");
      return _getDefaultResponse(userQuery);
    }
  }

  static Map<String, dynamic> _getDefaultResponse(String userQuery) {
    return {
      "number_of_questions": 10,
      "difficulty_level": "medium",
      "user_query": userQuery
    };
  }
}
