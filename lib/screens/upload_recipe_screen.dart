import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/favorites_manager.dart';

class UploadRecipeScreen extends StatefulWidget {
  const UploadRecipeScreen({super.key});

  @override
  State<UploadRecipeScreen> createState() => _UploadRecipeScreenState();
}

class _UploadRecipeScreenState extends State<UploadRecipeScreen> {
  final _titleController = TextEditingController();
  final _ingredientsController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _servingsController = TextEditingController();

  File? _selectedImage;
  bool _isUploading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadRecipe() async {
    final title = _titleController.text.trim();
    final ingredients = _ingredientsController.text.trim();
    final instructions = _instructionsController.text.trim();
    final calories = _caloriesController.text.trim();
    final servings = _servingsController.text.trim();

    if (title.isEmpty ||
        ingredients.isEmpty ||
        instructions.isEmpty ||
        calories.isEmpty ||
        servings.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill out all fields")),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      final newRecipe = {
        'id': DateTime.now().millisecondsSinceEpoch,
        'title': title,
        'ingredients': ingredients.split(',').map((e) => e.trim()).toList(),
        'steps': instructions.split('\n').map((e) => e.trim()).toList(),
        'calories': calories,
        'servings': int.tryParse(servings) ?? 1,
        'image': _selectedImage?.path ?? '',
      };

      await FavoritesManager.addUploadedRecipe(newRecipe);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Recipe uploaded successfully!")),
      );

      Navigator.pop(context, newRecipe);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to upload recipe: $e")),
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFFFE7AC1),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Upload Recipe"),
        backgroundColor: const Color(0xFFFE7AC1),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Recipe Photo"),
            GestureDetector(
              onTap: _pickImage,
              child: _selectedImage == null
                  ? Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey),
                ),
                child: const Center(
                  child: Text(
                    "Tap to upload an image",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
                  : ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.file(
                  _selectedImage!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildSectionTitle("Recipe Info"),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: "Recipe Title",
                hintText: "e.g., Chocolate Chip Cookies",
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _caloriesController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Calories",
                hintText: "e.g., 250",
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _servingsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Servings",
                hintText: "e.g., 4",
              ),
            ),
            _buildSectionTitle("Ingredients (comma-separated)"),
            TextField(
              controller: _ingredientsController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: "e.g., 1 cup sugar, 2 eggs, 1 tsp vanilla extract",
              ),
            ),
            _buildSectionTitle("Instructions (one per line)"),
            TextField(
              controller: _instructionsController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: "e.g., Mix sugar and butter until creamy...",
              ),
            ),
            const SizedBox(height: 25),
            Center(
              child: ElevatedButton(
                onPressed: _isUploading ? null : _uploadRecipe,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFE7AC1),
                  foregroundColor: Colors.white,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isUploading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  "Upload Recipe",
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
