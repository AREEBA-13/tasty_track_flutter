import 'package:flutter/material.dart';
import 'package:tasty_track/services/auth_service.dart';
import 'package:tasty_track/screens/auth/widgets/auth_form_card.dart';
import 'package:velocity_x/velocity_x.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
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

  Future<void> _register() async {
    setState(() => _loading = true);
    try {
      final result = await _authService.register(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _usernameController.text.trim(),
      );
      if (!mounted) return;
      if (result.success) {
        // Sign out so user must log in
        await _authService.signOut();
        if (!mounted) return;
        VxToast.show(
          context,
          msg: "Account Created Successfully! Please log in.",
        );
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        VxToast.show(context, msg: result.error ?? "Registration Failed");
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
        title: "Create Account",
        subtitle: "Register to get started",
        logopath: "lib/assets/images/logo.png",
        fields: [
          TextField(
            controller: _usernameController,
            decoration: _inputDecoration("Username"),
          ),
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
        buttonText: "Register",
        onSubmit: _register,
        loading: _loading,
        footer: TextButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/login');
          },
          child: const Text("Already have an account? Login"),
        ),
      ),
    );
  }
}
