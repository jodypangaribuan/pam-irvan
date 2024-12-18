import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sepatu/screens/admin_dashboard_screen.dart';
import 'package:sepatu/screens/home_screen.dart';
import '../widgets/form_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final secondaryTextColor = isDark ? Colors.white70 : Colors.black54;
    final backgroundColor = isDark ? Colors.grey[900] : Colors.grey[50];

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 60),
                Center(
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: 120,
                    width: 120,
                    color: isDark ? Colors.white : null,
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  'Welcome back',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    color: textColor,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'Sign in to continue',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: secondaryTextColor,
                  ),
                ),
                const SizedBox(height: 20),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      FormWidgets.buildTextField(
                        controller: _emailController,
                        icon: Iconsax.user,
                        label: 'Email',
                        validator: (value) {
                          if (value?.isEmpty ?? true)
                            return 'Email is required';
                          if (!value!.contains('@'))
                            return 'Enter a valid email';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      FormWidgets.buildTextField(
                        controller: _passwordController,
                        icon: Iconsax.lock,
                        label: 'Password',
                        isPassword: true,
                        isPasswordVisible: _isPasswordVisible,
                        onTogglePassword: () {
                          setState(
                              () => _isPasswordVisible = !_isPasswordVisible);
                        },
                        validator: (value) {
                          if (value?.isEmpty ?? true)
                            return 'Password is required';
                          if (value!.length < 6)
                            return 'Password must be at least 6 characters';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/forgot-password'),
                          child: Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      FormWidgets.buildGradientButton(
                        onPressed: _handleLogin,
                        text: 'Sign In',
                        isLoading: _isLoading,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account?",
                            style: GoogleFonts.poppins(
                              color: Colors.grey[600],
                              fontSize: 15,
                            ),
                          ),
                          TextButton(
                            onPressed: () =>
                                Navigator.pushNamed(context, '/register'),
                            child: Text(
                              'Sign Up',
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF34495E),
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      // First try to sign in
      UserCredential userCred =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Only proceed to check admin status if sign in was successful
      if (userCred.user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userCred.user!.uid)
            .get();

        if (!userDoc.exists) {
          throw FirebaseAuthException(
            code: 'user-not-found',
            message: 'User data not found.',
          );
        }

        bool isAdmin =
            (userDoc.data() as Map<String, dynamic>)['isAdmin'] ?? false;

        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) =>
                  isAdmin ? const AdminDashboardScreen() : const HomeScreen(),
            ),
            (route) => false,
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'No user found with this email.';
          break;
        case 'wrong-password':
          message = 'Wrong password provided.';
          break;
        case 'invalid-credential':
          message = 'The credentials provided are invalid.';
          break;
        case 'invalid-email':
          message = 'The email address is not valid.';
          break;
        default:
          message = e.message ?? 'An error occurred during login.';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
