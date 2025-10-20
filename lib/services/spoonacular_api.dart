import 'dart:convert';
import 'package:http/http.dart' as http;
import 'secrets.dart';

class SpoonacularAPI {
  static Future<List<dynamic>> fetchRecipes(String query, String diet) async {
    final url = Uri.parse(
      'https://api.spoonacular.com/recipes/complexSearch'
          '?apiKey=$spoonacularApiKey'
          '&query=$query'
          '&diet=$diet'
          '&number=10',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['results'];
    } else {
      throw Exception('Failed to load recipes');
    }
  }

  // 🍽️ Fetch full recipe details (ingredients, instructions, nutrition)
  static Future<Map<String, dynamic>> fetchRecipeDetails(int id) async {
    final url = Uri.parse(
      'https://api.spoonacular.com/recipes/$id/information'
          '?apiKey=$spoonacularApiKey&includeNutrition=true',
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load recipe details');
    }
  }
}
