import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sepatu/services/product_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'firebase_options.dart';
import 'routes/app_routes.dart';
import 'theme/app_theme.dart';
import 'providers/theme_provider.dart';
import 'package:sepatu/screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/admin_dashboard_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/auth_service.dart';

void main() async {
  // Ensure platform bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize path provider and database
  await getApplicationDocumentsDirectory();
  await getDatabasesPath();

  // Initialize SharedPreferences
  await SharedPreferences.getInstance();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        Provider(create: (_) => AuthService()),
        ChangeNotifierProvider(
            create: (_) =>
                ProductService()), // Change from Provider to ChangeNotifierProvider
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Sepatu',
          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: Colors.grey[50],
            primarySwatch: Colors.grey,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: Colors.grey[900],
            primarySwatch: Colors.grey,
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.grey[900],
              elevation: 0,
            ),
          ),
          themeMode:
              themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: StreamBuilder<User?>(
            stream: context.read<AuthService>().authStateChanges,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasData) {
                return FutureBuilder<bool>(
                  future: context.read<AuthService>().isAdmin(),
                  builder: (context, adminSnapshot) {
                    if (adminSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    return adminSnapshot.data == true
                        ? const AdminDashboardScreen()
                        : const HomeScreen();
                  },
                );
              }

              return const LoginScreen();
            },
          ),
          routes: {
            '/login': (context) => const LoginScreen(),
            '/register': (context) => const RegisterScreen(),
            '/home': (context) => const HomeScreen(),
            '/admin-dashboard': (context) => const AdminDashboardScreen(),
            '/forgot-password': (context) => const ForgotPasswordScreen(),
            '/cart': (context) =>
                const HomeScreen(initialTab: 2), // Add this line
          },
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
