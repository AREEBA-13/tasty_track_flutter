import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/recipes/add_recipe_screen.dart';
import '../screens/recipes/recipe_detail_screen.dart';
import '../screens/recipes/edit_recipe_screen.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    '/login': (context) => const LoginScreen(),
    '/register': (context) => const RegisterScreen(),

    '/home': (context) {
      final currentUser = FirebaseAuth.instance.currentUser;
      // If user is not logged in, go to login screen
      if (currentUser == null) {
        return const LoginScreen();
      }
      final args = ModalRoute.of(context)!.settings.arguments;
      return HomeScreen(username: args is String ? args : '');
    },

    '/add-recipe': (context) => const AddRecipeScreen(),

    '/recipe-details': (context) {
      final args = ModalRoute.of(context)!.settings.arguments as String;
      return RecipeDetailsScreen(recipeId: args);
    },

    '/edit-recipe': (context) {
      final args = ModalRoute.of(context)!.settings.arguments as String;
      return EditRecipeScreen(recipeId: args);
    },
  };
}
