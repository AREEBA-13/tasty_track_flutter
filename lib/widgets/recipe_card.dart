import 'package:flutter/material.dart';
import '../models/recipe_model.dart';

class RecipeCard extends StatelessWidget {
  final Recipe recipe;

  const RecipeCard({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(recipe.name),
        subtitle: Text(recipe.category),
        trailing: Icon(
          recipe.isFavorite ? Icons.favorite : Icons.favorite_border,
        ),
      ),
    );
  }
}
