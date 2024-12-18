import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sepatu/screens/home_screen.dart';
import '../widgets/form_widgets.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      // Create user with email and password
      UserCredential userCred =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (userCred.user != null) {
        // Update user display name
        await userCred.user!.updateDisplayName(_nameController.text.trim());

        // Create user document in Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCred.user!.uid)
            .set({
          'uid': userCred.user!.uid,
          'email': userCred.user!.email,
          'name': _nameController.text.trim(),
          'isAdmin': false,
          'createdAt': FieldValue.serverTimestamp(),
        });

        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
            (route) => false,
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'weak-password':
          message = 'The password provided is too weak.';
          break;
        case 'email-already-in-use':
          message = 'An account already exists for that email.';
          break;
        case 'invalid-email':
          message = 'The email address is not valid.';
          break;
        default:
          message = e.message ?? 'An error occurred during registration.';
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

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF2C3333);
    final secondaryTextColor = isDark ? Colors.white70 : Colors.grey[600];

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                IconButton(
                  icon: Icon(Iconsax.arrow_left,
                      color: isDark ? Colors.white : Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(height: 20),
                Text(
                  'Create Account',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    color: textColor,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign up to get started',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: secondaryTextColor,
                  ),
                ),
                const SizedBox(height: 40),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      FormWidgets.buildTextField(
                        controller: _nameController,
                        icon: Iconsax.user,
                        label: 'Full Name',
                        validator: (value) =>
                            value?.isEmpty ?? true ? 'Name is required' : null,
                      ),
                      const SizedBox(height: 20),
                      FormWidgets.buildTextField(
                        controller: _emailController,
                        icon: Iconsax.sms,
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
                        validator: (value) {
                          if (value?.isEmpty ?? true)
                            return 'Password is required';
                          if (value!.length < 6)
                            return 'Password must be at least 6 characters';
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),
                      FormWidgets.buildGradientButton(
                        onPressed: _handleRegister,
                        text: 'Create Account',
                        isLoading: _isLoading,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account?',
                            style: GoogleFonts.poppins(
                              color: Colors.grey[600],
                              fontSize: 15,
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'Sign In',
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
}
