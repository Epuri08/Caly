import 'package:flutter/material.dart';
import '../services/spoonacular_api.dart';
import '../services/favorites_manager.dart';
import 'dart:io';

class RecipeDetailScreen extends StatefulWidget {
  final Map recipe;
  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  Map<String, dynamic>? _details;
  bool _loading = true;
  int _selectedServings = 1;
  int _originalServings = 1;
  bool _isLiked = false;

  @override
  void initState() {
    super.initState();
    _loadRecipeDetails();
    _checkIfLiked();
  }

  Future<void> _loadRecipeDetails() async {
    try {
      // 🧩 If this recipe came from Spoonacular (has numeric ID), fetch full details
      if (widget.recipe['id'] != null && widget.recipe['id'] is int) {
        final details =
        await SpoonacularAPI.fetchRecipeDetails(widget.recipe['id']);
        setState(() {
          _details = details;
          _loading = false;
          _originalServings = details['servings'] ?? 1;
          _selectedServings = _originalServings;
        });
      } else {
        // 🧁 Uploaded recipe — just use the provided data
        setState(() {
          _details = {
            'title': widget.recipe['title'] ?? 'Untitled Recipe',
            'image': widget.recipe['image'],
            'extendedIngredients':
            widget.recipe['ingredients'] ?? [], // expect list of maps
            'analyzedInstructions': widget.recipe['steps'] != null
                ? [
              {'steps': List.generate(widget.recipe['steps'].length, (i) => {'step': widget.recipe['steps'][i]})}
            ]
                : [],
            'nutrition': widget.recipe['nutrition'] ??
                {
                  'nutrients': [
                    {'amount': widget.recipe['calories'] ?? 0}
                  ]
                },
            'servings': widget.recipe['servings'] ?? 1,
          };
          _originalServings = _details!['servings'];
          _selectedServings = _originalServings;
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _checkIfLiked() async {
    final liked = await FavoritesManager.isFavorite(widget.recipe['id']);
    setState(() => _isLiked = liked);
  }

  Future<void> _toggleLike() async {
    setState(() => _isLiked = !_isLiked);
    if (_isLiked) {
      await FavoritesManager.addFavorite(widget.recipe as Map<String, dynamic>);
    } else {
      await FavoritesManager.removeFavorite(widget.recipe['id']);
    }
  }

  List<Map<String, dynamic>> getScaledIngredients() {
    if (_details == null || _details!['extendedIngredients'] == null) return [];
    final factor = _selectedServings / _originalServings;
    return List<Map<String, dynamic>>.from(
      _details!['extendedIngredients'].map((ing) {
        final amount = (ing['amount'] ?? 0) * factor;
        return {
          'name': ing['name'] ?? '',
          'amount': amount.toStringAsFixed(2),
          'unit': ing['unit'] ?? '',
        };
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    const pinkColor = Color(0xFFFE7AC1);
    const blackText = Colors.black;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF5FC),
      appBar: AppBar(
        backgroundColor: pinkColor,
        centerTitle: true,
        title: Text(
          widget.recipe['title'] ?? 'Recipe',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isLiked ? Icons.favorite : Icons.favorite_border,
              color: Colors.white,
            ),
            onPressed: _toggleLike,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _details == null
          ? const Center(child: Text("Failed to load recipe details"))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🖼️ Image — handle both local & network
            if (_details!['image'] != null &&
                _details!['image'].toString().isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: _details!['image'].toString().startsWith('http')
                    ? Image.network(
                  _details!['image'],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 220,
                )
                    : Image.file(
                  // if local upload (File path)
                  File(_details!['image']),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 220,
                ),
              )
            else
              Container(
                height: 220,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.grey.shade200,
                ),
                child: const Icon(Icons.image, size: 80),
              ),

            const SizedBox(height: 20),

            // 🍽️ Serving Size
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Serving Size:",
                  style: TextStyle(
                      color: pinkColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                DropdownButton<int>(
                  value: _selectedServings,
                  items: List.generate(
                    (_originalServings > 10
                        ? _originalServings
                        : 10),
                        (i) => i + 1,
                  )
                      .map(
                        (s) => DropdownMenuItem<int>(
                      value: s,
                      child: Text(
                        s.toString(),
                        style:
                        const TextStyle(color: blackText),
                      ),
                    ),
                  )
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedServings = val);
                    }
                  },
                ),
              ],
            ),

            const SizedBox(height: 8),

            // 🔥 Calories
            if (_details!['nutrition'] != null &&
                _details!['nutrition']['nutrients'] != null)
              Text(
                "Calories per serving: ${_details!['nutrition']['nutrients'][0]['amount'].round()} kcal",
                style: const TextStyle(
                    fontSize: 16,
                    color: blackText,
                    fontWeight: FontWeight.w500),
              ),

            const SizedBox(height: 20),

            // 🧂 Ingredients
            const Text(
              "Ingredients",
              style: TextStyle(
                  color: pinkColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...getScaledIngredients().map(
                  (ing) => Text(
                "• ${ing['amount']} ${ing['unit']} ${ing['name']}",
                style:
                const TextStyle(fontSize: 15, color: blackText),
              ),
            ),

            const SizedBox(height: 24),

            // 👩‍🍳 Steps
            const Text(
              "Steps",
              style: TextStyle(
                  color: pinkColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            if (_details!['analyzedInstructions'] != null &&
                _details!['analyzedInstructions'].isNotEmpty)
              ...List.generate(
                _details!['analyzedInstructions'][0]['steps'].length,
                    (i) {
                  final step = _details!['analyzedInstructions'][0]
                  ['steps'][i];
                  return Padding(
                    padding:
                    const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text(
                      "${i + 1}. ${step['step']}",
                      style: const TextStyle(
                          fontSize: 15, color: blackText),
                    ),
                  );
                },
              )
            else
              const Text(
                "No instructions available.",
                style: TextStyle(color: blackText),
              ),
          ],
        ),
      ),
    );
  }
}
