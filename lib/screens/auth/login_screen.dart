import 'package:flutter/material.dart';
import 'package:tasty_track/services/auth_service.dart';
import 'package:tasty_track/screens/auth/widgets/auth_form_card.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _loading = false;

  InputDecoration _inputDecoration(String label, {Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      suffixIcon: suffixIcon,
    );
  }

  Future<void> _login() async {
    setState(() => _loading = true);
    try {
      final result = await _authService.signIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (!mounted) return;

      if (result.success && result.user != null) {
        // Fetch username from Firestore
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(result.user!.uid)
            .get();

        final username =
            userDoc.data()?['username'] ?? result.user!.email ?? '';

        if (!mounted) return;

        Navigator.pushReplacementNamed(context, '/home', arguments: username);
      } else {
        VxToast.show(context, msg: result.error ?? 'Login failed');
      }
    } catch (e) {
      VxToast.show(context, msg: 'Unexpected error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: AuthFormCard(
        title: "Welcome Back",
        subtitle: "Login to your account",
        logopath: "lib/assets/images/logo.png",
        fields: [
          TextField(
            controller: _emailController,
            decoration: _inputDecoration("Email"),
          ),
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: _inputDecoration("Password"),
          ),
        ],
        buttonText: "Login",
        onSubmit: _login,
        loading: _loading,
        footer: TextButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/register');
          },
          child: const Text("Don't have an account? Register"),
        ),
      ),
    );
  }
}
