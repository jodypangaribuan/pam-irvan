import 'package:flutter/material.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/forgot_password_screen.dart';
// import other screens as needed

class AppRoutes {
  static final routes = {
    '/': (context) => const LoginScreen(),
    '/register': (context) => const RegisterScreen(),
    '/forgot-password': (context) => const ForgotPasswordScreen(),
    // Add other routes here
  };
}
