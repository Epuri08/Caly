import 'dart:io';
import 'package:flutter/material.dart';
import '../services/favorites_manager.dart';
import 'recipe_detail_screen.dart';

class UploadedRecipesScreen extends StatefulWidget {
  const UploadedRecipesScreen({super.key});

  @override
  State<UploadedRecipesScreen> createState() => _UploadedRecipesScreenState();
}

class _UploadedRecipesScreenState extends State<UploadedRecipesScreen> {
  List<Map<String, dynamic>> _uploaded = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUploadedRecipes();
  }

  Future<void> _loadUploadedRecipes() async {
    final uploaded = await FavoritesManager.getUploadedRecipes();
    setState(() {
      _uploaded = uploaded;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    const pinkColor = Color(0xFFFE7AC1);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF5FC),
      appBar: AppBar(
        title: const Text(
          'My Uploaded Recipes 🍽️',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: pinkColor,
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _uploaded.isEmpty
          ? const Center(
        child: Text(
          'No recipes uploaded yet!',
          style: TextStyle(fontSize: 18, color: Colors.black54),
        ),
      )
          : RefreshIndicator(
        onRefresh: _loadUploadedRecipes,
        child: ListView.builder(
          itemCount: _uploaded.length,
          itemBuilder: (context, index) {
            final recipe = _uploaded[index];
            final title = recipe['title'] ?? 'Untitled';
            final calories = recipe['calories']?.toString() ?? 'N/A';
            final servings =
                recipe['servings']?.toString() ?? 'Unknown';
            final imagePath = recipe['image'] ?? '';

            return Card(
              margin: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 3,
              child: ListTile(
                leading: imagePath.isNotEmpty &&
                    File(imagePath).existsSync()
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(
                    File(imagePath),
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                )
                    : const Icon(Icons.image_not_supported,
                    size: 50, color: Colors.grey),
                title: Text(
                  title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                subtitle: Text(
                  'Calories: $calories kcal | Servings: $servings',
                  style: const TextStyle(fontSize: 13),
                ),
                trailing:
                const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          RecipeDetailScreen(recipe: recipe),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
