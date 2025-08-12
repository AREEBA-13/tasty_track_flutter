import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RecipeService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _userRecipesRef() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception("No authenticated user");
    return _firestore.collection('users').doc(uid).collection('recipes');
  }

  Future<List<String>> getFavorites() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return [];
    final favSnapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .get();
    return favSnapshot.docs.map((doc) => doc.id).toList();
  }

  Future<List<String>> toggleFavorite(
    String recipeId,
    Set<String> currentFavorites,
  ) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return currentFavorites.toList();

    final favRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .doc(recipeId);

    if (currentFavorites.contains(recipeId)) {
      await favRef.delete();
      currentFavorites.remove(recipeId);
    } else {
      await favRef.set({'addedAt': FieldValue.serverTimestamp()});
      currentFavorites.add(recipeId);
    }
    return currentFavorites.toList();
  }

  Future<void> deleteRecipe(String recipeId) async {
    await _userRecipesRef().doc(recipeId).delete();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getUserRecipes() {
    return _userRecipesRef().orderBy('createdAt', descending: true).snapshots();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getRecipeById(
    String recipeId,
  ) async {
    return await _userRecipesRef().doc(recipeId).get();
  }
}
