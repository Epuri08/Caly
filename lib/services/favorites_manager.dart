import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class FavoritesManager {
  static const String _favoritesKey = 'favorites';
  static const String _uploadedKey = 'uploaded_recipes';

  // -------- FAVORITES --------
  static Future<List<Map<String, dynamic>>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_favoritesKey) ?? [];
    return data.map((e) => jsonDecode(e)).cast<Map<String, dynamic>>().toList();
  }

  static Future<void> addFavorite(Map<String, dynamic> recipe) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavorites();
    if (favorites.any((r) => r['id'] == recipe['id'])) return;
    favorites.add(recipe);
    await prefs.setStringList(
        _favoritesKey, favorites.map((e) => jsonEncode(e)).toList());
  }

  static Future<void> removeFavorite(dynamic id) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavorites();
    favorites.removeWhere((r) => r['id'] == id);
    await prefs.setStringList(
        _favoritesKey, favorites.map((e) => jsonEncode(e)).toList());
  }

  static Future<bool> isFavorite(dynamic id) async {
    final favorites = await getFavorites();
    return favorites.any((r) => r['id'] == id);
  }

  // -------- UPLOADED RECIPES --------
  static Future<List<Map<String, dynamic>>> getUploadedRecipes() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_uploadedKey) ?? [];
    return data.map((e) => jsonDecode(e)).cast<Map<String, dynamic>>().toList();
  }

  static Future<void> addUploadedRecipe(Map<String, dynamic> recipe) async {
    final prefs = await SharedPreferences.getInstance();
    final uploaded = await getUploadedRecipes();
    uploaded.add(recipe);
    await prefs.setStringList(
        _uploadedKey, uploaded.map((e) => jsonEncode(e)).toList());
  }

  static Future<void> clearUploadedRecipes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_uploadedKey);
  }
}
