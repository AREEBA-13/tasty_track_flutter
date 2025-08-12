import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tasty_track/utils/routes.dart';
import 'package:tasty_track/utils/themes.dart';
import 'package:tasty_track/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final authService = AuthService();
  final sessionValid = await authService.isSessionValid();

  runApp(TastyTrackApp(initialRoute: sessionValid ? '/home' : '/login'));
}

class TastyTrackApp extends StatelessWidget {
  final String initialRoute;

  const TastyTrackApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tasty Track',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: initialRoute,
      routes: AppRoutes.routes,
    );
  }
}
