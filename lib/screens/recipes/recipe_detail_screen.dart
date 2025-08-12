import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tasty_track/widgets/animated_loader.dart';
import '../../../utils/colors.dart';
import 'edit_recipe_screen.dart';

class RecipeDetailsScreen extends StatefulWidget {
  final String recipeId;
  const RecipeDetailsScreen({super.key, required this.recipeId});

  @override
  State<RecipeDetailsScreen> createState() => _RecipeDetailsScreenState();
}

class _RecipeDetailsScreenState extends State<RecipeDetailsScreen> {
  Widget _infoChip(String text, IconData icon, Color color) {
    return Chip(
      avatar: Icon(icon, size: 18, color: color),
      label: Text(text, style: const TextStyle(fontSize: 14)),
      backgroundColor: Colors.grey.shade100,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  Future<void> _deleteRecipe() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("User not authenticated")));
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Recipe"),
        content: const Text(
          "Are you sure you want to delete this recipe? This cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('recipes')
          .doc(widget.recipeId)
          .delete();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Recipe deleted successfully")),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to delete recipe: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Recipe Details"),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              if (uid == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("User not authenticated")),
                );
                return;
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditRecipeScreen(recipeId: widget.recipeId),
                ),
              );
            },
          ),
          IconButton(icon: const Icon(Icons.delete), onPressed: _deleteRecipe),
        ],
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('recipes')
            .doc(widget.recipeId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: AnimatedLoader());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Recipe not found."));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  data['name'] ?? '',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  data['description'] ?? '',
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textLight,
                  ),
                ),
                const SizedBox(height: 16),

                // Info chips
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _infoChip(
                      "${data['cookingTime']} min",
                      Icons.timer_outlined,
                      AppColors.primary,
                    ),
                    _infoChip(
                      data['cuisine'] ?? 'N/A',
                      Icons.restaurant_menu,
                      AppColors.textDark,
                    ),
                    _infoChip(
                      data['category'] ?? 'N/A',
                      Icons.fastfood_rounded,
                      AppColors.textDark,
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Ingredients
                Row(
                  children: const [
                    Icon(Icons.list_alt_rounded, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text(
                      "Ingredients",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...(data['ingredients'] as List<dynamic>? ?? []).map(
                  (ing) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      "• ${ing['name']} (${ing['quantity']})",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Steps
                Row(
                  children: const [
                    Icon(Icons.check_circle_outline, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text(
                      "Steps",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...((data['steps'] as List<dynamic>? ?? []).asMap().entries.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      "${entry.key + 1}. ${entry.value}",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                )),
              ],
            ),
          );
        },
      ),
    );
  }
}
