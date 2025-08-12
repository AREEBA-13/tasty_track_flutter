import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tasty_track/screens/home/recipe_search_delegate.dart';
import 'package:tasty_track/services/recipe_service.dart';
import 'package:tasty_track/utils/colors.dart';
import 'package:tasty_track/widgets/animated_loader.dart';

class HomeScreen extends StatefulWidget {
  final String username;
  const HomeScreen({super.key, required this.username});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _auth = FirebaseAuth.instance;
  final RecipeService _recipeService = RecipeService();
  Set<String> favoritesSet = {};

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final favs = await _recipeService.getFavorites();
    if (!mounted) return;
    setState(() {
      favoritesSet = favs.toSet();
    });
  }

  Future<void> _toggleFavorite(String recipeId) async {
    final updatedFavs = await _recipeService.toggleFavorite(
      recipeId,
      favoritesSet,
    );
    if (!mounted) return;
    setState(() {
      favoritesSet = updatedFavs.toSet();
    });
  }

  void _handleLogout() {
    _auth.signOut().then((_) {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _auth.currentUser;

    if (currentUser == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/login');
        }
      });
      return const Scaffold(body: Center(child: AnimatedLoader()));
    }

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primary,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hello, ${widget.username} 👋",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            const Text(
              "Here’s what’s cooking today",
              style: TextStyle(fontSize: 14, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: RecipeSearchDelegate());
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadFavorites(),
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _recipeService.getUserRecipes(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: AnimatedLoader());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text(
                  "No recipes yet. Tap + to add one!",
                  style: TextStyle(fontSize: 16, color: AppColors.textLight),
                ),
              );
            }
            final recipes = snapshot.data!.docs;
            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: recipes.length,
              itemBuilder: (context, index) {
                final recipe = recipes[index].data();
                final recipeId = recipes[index].id;
                final isFavorite = favoritesSet.contains(recipeId);

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  elevation: 3,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    title: Text(
                      recipe['name'] ?? 'Untitled',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: AppColors.textDark,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          recipe['description'] ?? '',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textLight,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          children: [
                            Chip(
                              label: Text(
                                recipe['cuisine'] ?? 'N/A',
                                style: const TextStyle(fontSize: 12),
                              ),
                              backgroundColor: Colors.orange.shade50,
                              padding: const EdgeInsets.all(0),
                            ),
                            Chip(
                              label: Text(
                                recipe['category'] ?? 'N/A',
                                style: const TextStyle(fontSize: 12),
                              ),
                              backgroundColor: Colors.orange.shade50,
                              padding: const EdgeInsets.all(0),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: Colors.red,
                          ),
                          onPressed: () => _toggleFavorite(recipeId),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            await _recipeService.deleteRecipe(recipeId);
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/recipe-details',
                        arguments: recipeId,
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: () {
          Navigator.pushNamed(context, '/add-recipe');
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "Add Recipe",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
