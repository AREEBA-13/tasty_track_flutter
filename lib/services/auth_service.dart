import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthResult {
  final bool success;
  final String? uid;
  final String? error;
  final User? user;

  AuthResult({required this.success, this.uid, this.error, this.user});
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _lastLoginKey = 'last_login_time';

  String _mapFirebaseError(String code) {
    final normalized = code.toLowerCase();
    switch (normalized) {
      case 'user-not-found':
      case 'error_user_not_found':
        return 'No account found for that email.';
      case 'wrong-password':
      case 'error_wrong_password':
        return 'Incorrect password.';
      case 'email-already-in-use':
      case 'error_email_already_in_use':
        return 'Email is already registered.';
      case 'weak-password':
      case 'error_weak_password':
        return 'Password should be at least 6 characters.';
      case 'invalid-email':
      case 'error_invalid_email':
        return 'The email address is not valid.';
      case 'invalid-credential':
      case 'error_invalid_credential':
        return 'The credentials are malformed or have expired.';
      case 'operation-not-allowed':
      case 'error_operation_not_allowed':
        return 'This sign-in method is not allowed.';
      default:
        return 'An unknown error occurred. Please try again.';
    }
  }

  Future<void> _saveLoginTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastLoginKey, DateTime.now().millisecondsSinceEpoch);
  }

  Future<bool> isSessionValid() async {
    final prefs = await SharedPreferences.getInstance();
    final lastLoginTime = prefs.getInt(_lastLoginKey);

    if (lastLoginTime == null) return false;

    final now = DateTime.now().millisecondsSinceEpoch;
    // Session valid if last login within 10 minutes (600,000 ms)
    return now - lastLoginTime <= 10 * 60 * 1000;
  }

  // Sign in
  Future<AuthResult> signIn(String email, String password) async {
    try {
      UserCredential cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = cred.user;
      await _saveLoginTime();
      return AuthResult(success: true, uid: user?.uid, user: user);
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, error: _mapFirebaseError(e.code));
    } on PlatformException catch (e) {
      return AuthResult(success: false, error: _mapFirebaseError(e.code));
    } catch (e) {
      return AuthResult(success: false, error: 'Unexpected error: $e');
    }
  }

  // Register and save user to Firestore
  Future<AuthResult> register(
    String email,
    String password,
    String username,
  ) async {
    try {
      UserCredential userCred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCred.user;
      if (user == null) {
        return AuthResult(success: false, error: 'User creation failed.');
      }

      await _firestore.collection('users').doc(user.uid).set({
        'username': username,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await _saveLoginTime();
      return AuthResult(success: true, uid: user.uid, user: user);
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, error: _mapFirebaseError(e.code));
    } on PlatformException catch (e) {
      return AuthResult(success: false, error: _mapFirebaseError(e.code));
    } catch (e) {
      return AuthResult(success: false, error: 'Unexpected error: $e');
    }
  }

  Future<void> signOut() async => _auth.signOut();
}
