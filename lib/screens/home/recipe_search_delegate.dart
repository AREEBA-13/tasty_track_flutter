import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../recipes/recipe_detail_screen.dart';
import '../../widgets/animated_loader.dart';

class RecipeSearchDelegate extends SearchDelegate {
  String selectedCuisine = 'All';
  String selectedCategory = 'All';

  final List<String> cuisines = [
    'All',
    'Italian',
    'Chinese',
    'Pakistani',
    'Indian',
    'Others',
  ];

  final List<String> categories = [
    'All',
    'Breakfast',
    'Lunch',
    'Dinner',
    'Snack',
    'Dessert',
  ];

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(color: AppColors.textLight),
        border: InputBorder.none,
      ),
      textTheme: theme.textTheme.copyWith(
        titleLarge: const TextStyle(color: AppColors.textDark, fontSize: 18),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.bgColor,
        iconTheme: IconThemeData(color: AppColors.textDark),
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear, color: AppColors.textDark),
          onPressed: () => query = '',
        ),
      IconButton(
        icon: const Icon(Icons.refresh, color: AppColors.primary),
        tooltip: "Reset filters",
        onPressed: () {
          selectedCuisine = 'All';
          selectedCategory = 'All';
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
      onPressed: () => close(context, null),
    );
  }

  bool _recipeMatchesQueryAndFilters(
    QueryDocumentSnapshot doc,
    String queryLower,
    String selectedCuisineLower,
    String selectedCategoryLower,
  ) {
    final name = (doc['name'] ?? '').toString().toLowerCase();
    final cuisine = (doc['cuisine'] ?? '').toString().toLowerCase();
    final category = (doc['category'] ?? '').toString().toLowerCase();

    final matchesQuery = queryLower.isEmpty
        ? true
        : (name.contains(queryLower) ||
              cuisine.contains(queryLower) ||
              category.contains(queryLower));

    final matchesCuisineFilter = (selectedCuisineLower == 'all')
        ? true
        : cuisine == selectedCuisineLower;

    final matchesCategoryFilter = (selectedCategoryLower == 'all')
        ? true
        : category == selectedCategoryLower;

    return matchesQuery && matchesCuisineFilter && matchesCategoryFilter;
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Center(
        child: Text(
          "User not authenticated",
          style: TextStyle(color: AppColors.textDark),
        ),
      );
    }

    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('recipes')
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: AnimatedLoader());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              "No recipes found",
              style: TextStyle(color: AppColors.textLight),
            ),
          );
        }

        final recipes = snapshot.data!.docs;

        final qLower = query.trim().toLowerCase();
        final cuisineLower = selectedCuisine.toLowerCase();
        final categoryLower = selectedCategory.toLowerCase();

        final filtered = recipes
            .where(
              (doc) => _recipeMatchesQueryAndFilters(
                doc,
                qLower,
                cuisineLower,
                categoryLower,
              ),
            )
            .toList();

        return Column(
          children: [
            _buildFiltersBar(context),
            if (filtered.isEmpty)
              const Expanded(
                child: Center(
                  child: Text(
                    "No matching recipes",
                    style: TextStyle(color: AppColors.textLight),
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final recipe = filtered[index];
                    final cuisineText = (recipe['cuisine'] ?? '').toString();
                    final categoryText = (recipe['category'] ?? '').toString();
                    return ListTile(
                      title: Text(
                        recipe['name'] ?? '',
                        style: const TextStyle(
                          color: AppColors.textDark,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        "$cuisineText • $categoryText",
                        style: const TextStyle(
                          color: AppColors.textLight,
                          fontSize: 14,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: AppColors.textLight,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                RecipeDetailsScreen(recipeId: recipe.id),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildFiltersBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: selectedCuisine,
              decoration: const InputDecoration(
                labelText: "Cuisine",
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
              items: cuisines
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (val) {
                selectedCuisine = val ?? 'All';
                query = query;
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: selectedCategory,
              decoration: const InputDecoration(
                labelText: "Category",
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
              items: categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (val) {
                selectedCategory = val ?? 'All';
                query = query;
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget buildResults(BuildContext context) => buildSuggestions(context);
}
