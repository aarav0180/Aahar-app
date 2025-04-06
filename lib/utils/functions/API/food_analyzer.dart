import 'dart:convert';
import 'package:http/http.dart' as http;

class FoodAnalyzerService {
  static const String _apiUrl = "https://aahar-455814.et.r.appspot.com/analyze-food";

  /// Sends a list of image URLs to the AI food analyzer API.
  /// Returns the parsed JSON response as a Map, or null if there’s an error.
  static Future<Map<String, dynamic>?> analyzeFood(List<String> imageUrls) async {
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "imageUrls": imageUrls,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("✅ AI Response: $data");
        return data;
      } else {
        print("❌ Error ${response.statusCode}: ${response.body}");
        return null;
      }
    } catch (e) {
      print("⚠️ Exception occurred: $e");
      return null;
    }
  }
}
