import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tasty_track/widgets/animated_loader.dart';

class AddRecipeScreen extends StatefulWidget {
  const AddRecipeScreen({super.key});

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final _formKey = GlobalKey<FormState>();

  String recipeName = '';
  String description = '';
  String cookingTime = '';
  String cuisine = '';
  String category = '';

  List<Map<String, String>> ingredients = [];
  final ingredientNameController = TextEditingController();
  final ingredientQtyController = TextEditingController();

  List<String> steps = [];
  final stepController = TextEditingController();

  bool isSaving = false;

  Future<void> saveRecipe() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => isSaving = true);

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception("User not logged in");

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('recipes')
          .add({
            'uid': uid,
            'name': recipeName,
            'description': description,
            'ingredients': ingredients,
            'steps': steps,
            'cookingTime': cookingTime,
            'cuisine': cuisine,
            'category': category,
            'createdAt': FieldValue.serverTimestamp(),
          });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Recipe saved successfully!")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  @override
  void dispose() {
    ingredientNameController.dispose();
    ingredientQtyController.dispose();
    stepController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Recipe")),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Removed image picker, kept spacing
              const SizedBox(height: 20),

              TextFormField(
                decoration: const InputDecoration(labelText: "Recipe Name"),
                validator: (val) =>
                    val == null || val.isEmpty ? "Enter recipe name" : null,
                onSaved: (val) => recipeName = val ?? '',
              ),
              const SizedBox(height: 10),

              TextFormField(
                decoration: const InputDecoration(labelText: "Description"),
                maxLines: 3,
                onSaved: (val) => description = val ?? '',
              ),
              const SizedBox(height: 20),

              const Text(
                "Ingredients",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: ingredientNameController,
                      decoration: const InputDecoration(
                        hintText: "Ingredient name",
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: ingredientQtyController,
                      decoration: const InputDecoration(hintText: "Quantity"),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      if (ingredientNameController.text.isNotEmpty &&
                          ingredientQtyController.text.isNotEmpty) {
                        setState(() {
                          ingredients.add({
                            'name': ingredientNameController.text,
                            'quantity': ingredientQtyController.text,
                          });
                          ingredientNameController.clear();
                          ingredientQtyController.clear();
                        });
                      }
                    },
                  ),
                ],
              ),
              ...ingredients.map(
                (ing) => ListTile(
                  title: Text(ing['name'] ?? ''),
                  subtitle: Text("Qty: ${ing['quantity']}"),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        ingredients.remove(ing);
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                "Cooking Steps",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...steps.asMap().entries.map((entry) {
                final idx = entry.key;
                final step = entry.value;
                return ListTile(
                  title: Text(step),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        steps.removeAt(idx);
                      });
                    },
                  ),
                );
              }),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: stepController,
                      decoration: const InputDecoration(
                        hintText: "Step description",
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      if (stepController.text.isNotEmpty) {
                        setState(() {
                          steps.add(stepController.text);
                          stepController.clear();
                        });
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),

              TextFormField(
                decoration: const InputDecoration(
                  labelText: "Cooking Time (e.g. 30 mins)",
                ),
                onSaved: (val) => cookingTime = val ?? '',
              ),
              const SizedBox(height: 20),

              DropdownButtonFormField<String>(
                value: cuisine.isEmpty ? null : cuisine,
                decoration: const InputDecoration(labelText: "Cuisine"),
                items: ['Italian', 'Pakistani', 'Chinese', 'Indian', 'Other']
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (val) => setState(() => cuisine = val ?? ''),
              ),
              const SizedBox(height: 20),

              DropdownButtonFormField<String>(
                value: category.isEmpty ? null : category,
                decoration: const InputDecoration(labelText: "Category"),
                items: ['Breakfast', 'Lunch', 'Dinner', 'Dessert', 'Snack']
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (val) => setState(() => category = val ?? ''),
              ),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isSaving ? null : saveRecipe,
                  child: isSaving
                      ? const AnimatedLoader()
                      : const Text("Save Recipe"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
