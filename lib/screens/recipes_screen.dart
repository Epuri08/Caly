import 'package:flutter/material.dart';
import '../services/spoonacular_api.dart';
import 'recipe_detail_screen.dart';
import '../screens/favorites_screen.dart';
import 'my_recipes_screen.dart';
import 'upload_recipe_screen.dart';
import 'uploaded_recipes_screen.dart'; // ✅ new page

class RecipesScreen extends StatefulWidget {
  const RecipesScreen({super.key});

  @override
  State<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen> {
  final TextEditingController _controller = TextEditingController();
  String _selectedDiet = '';
  List _recipes = [];
  bool _isLoading = false;
  int _selectedIndex = 0; // ✅ Track nav tab

  @override
  void initState() {
    super.initState();
    _loadDefaultRecipes();
  }

  /// 🌸 Load popular recipes
  Future<void> _loadDefaultRecipes() async {
    setState(() => _isLoading = true);
    try {
      final defaultRecipes = await SpoonacularAPI.fetchRecipes("popular", "");
      setState(() {
        _recipes = defaultRecipes;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading default recipes: $e");
      setState(() => _isLoading = false);
    }
  }

  /// 🔍 Search recipes by keyword & diet
  Future<void> _searchRecipes() async {
    final query = _controller.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _recipes = [];
    });

    try {
      final results = await SpoonacularAPI.fetchRecipes(query, _selectedDiet);
      setState(() {
        _recipes = results;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error searching recipes: $e");
      setState(() => _isLoading = false);
    }
  }

  /// 🩷 Bottom Navigation Logic
  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const FavoritesScreen()),
      ).then((_) => setState(() => _selectedIndex = 0));
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const UploadRecipeScreen()),
      ).then((_) => setState(() => _selectedIndex = 0));
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const UploadedRecipesScreen()),
      ).then((_) => setState(() => _selectedIndex = 0));
    }
  }

  @override
  Widget build(BuildContext context) {
    const pinkColor = Color(0xFFFE7AC1);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF5FC),

      appBar: AppBar(
        backgroundColor: pinkColor,
        title: const Text(
          "Find Recipes",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // 🔍 Search Bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.pink.shade100.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _controller,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _searchRecipes(),
                  decoration: InputDecoration(
                    hintText: "Search recipes...",
                    prefixIcon:
                    const Icon(Icons.search, color: Color(0xFFFE7AC1)),
                    border: InputBorder.none,
                    contentPadding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.arrow_forward_ios_rounded,
                          color: Color(0xFFFE7AC1)),
                      onPressed: _searchRecipes,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // 🥗 Dietary Restriction Dropdown
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: pinkColor),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedDiet.isEmpty ? null : _selectedDiet,
                    hint: const Text("Select restriction"),
                    items: [
                      "gluten free",
                      "ketogenic",
                      "vegetarian",
                      "vegan",
                      "pescatarian",
                      "paleo",
                    ].map((diet) {
                      return DropdownMenuItem(
                        value: diet,
                        child: Text(diet),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedDiet = value ?? '');
                    },
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // 💕 Recipe Grid
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _recipes.isEmpty
                    ? const Center(
                  child: Text(
                    "No recipes found. Try a new search!",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                )
                    : GridView.builder(
                  padding: const EdgeInsets.only(bottom: 10),
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.9,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: _recipes.length,
                  itemBuilder: (context, index) {
                    final recipe = _recipes[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                RecipeDetailScreen(recipe: recipe),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.pink.shade100
                                  .withOpacity(0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.stretch,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                              ),
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: Image.network(
                                  recipe['image'] ?? '',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 6),
                              child: Text(
                                recipe['title'] ?? '',
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
              ),
            ],
          ),
        ),
      ),

      // 🌸 3-tab Pink Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFFFE7AC1),
        unselectedItemColor: const Color(0xFFFE7AC1),
        onTap: (index) {
          setState(() => _selectedIndex = index);
          if (index == 0) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoritesScreen()))
                .then((_) => setState(() => _selectedIndex = 0));
          } else if (index == 1) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const UploadRecipeScreen()))
                .then((_) => setState(() => _selectedIndex = 0));
          } else if (index == 2) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const MyRecipesScreen()))
                .then((_) => setState(() => _selectedIndex = 0));
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "Favorites"),
          BottomNavigationBarItem(icon: Icon(Icons.upload), label: "Upload"),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: "My Recipes"), // 👈 new
        ],
      ),
    );
  }
}
