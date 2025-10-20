import 'package:flutter/material.dart';
import '../services/favorites_manager.dart';
import 'recipe_detail_screen.dart';

class MyRecipesScreen extends StatefulWidget {
  const MyRecipesScreen({super.key});

  @override
  State<MyRecipesScreen> createState() => _MyRecipesScreenState();
}

class _MyRecipesScreenState extends State<MyRecipesScreen> {
  List<Map<String, dynamic>> _uploadedRecipes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUploadedRecipes();
  }

  Future<void> _loadUploadedRecipes() async {
    final uploaded = await FavoritesManager.getUploadedRecipes();
    setState(() {
      _uploadedRecipes = uploaded;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    const pink = Color(0xFFFE7AC1);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF5FC),
      appBar: AppBar(
        backgroundColor: pink,
        title: const Text('My Recipes', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _uploadedRecipes.isEmpty
          ? const Center(
        child: Text("You haven’t uploaded any recipes yet."),
      )
          : GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.9,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: _uploadedRecipes.length,
        itemBuilder: (context, index) {
          final recipe = _uploadedRecipes[index];
          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    RecipeDetailScreen(recipe: recipe),
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.pink.shade100.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    child: recipe['image'] != null &&
                        recipe['image'].toString().isNotEmpty
                        ? Image.network(
                      recipe['image'],
                      fit: BoxFit.cover,
                      height: 120,
                    )
                        : Container(
                      height: 120,
                      color: Colors.pink[50],
                      child: const Icon(Icons.image_not_supported,
                          color: Colors.grey),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      recipe['title'] ?? 'Untitled Recipe',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
