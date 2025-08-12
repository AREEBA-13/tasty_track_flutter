class Recipe {
  final String name;
  final String category;
  final List<String> ingredients;
  final List<String> steps;
  bool isFavorite;

  Recipe({
    required this.name,
    required this.category,
    required this.ingredients,
    required this.steps,
    this.isFavorite = false,
  });
}