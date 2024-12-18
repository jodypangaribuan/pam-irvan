import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Add this import
import '../providers/theme_provider.dart';

class ProfileDrawer extends StatelessWidget {
  const ProfileDrawer({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final result = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 340,
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[850] : Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 32),
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Iconsax.logout,
                      color: Colors.red[700],
                      size: 28,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Logout',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'Are you sure you want to logout?',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: isDark ? Colors.white70 : Colors.black54,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Container(
                width: double.infinity,
                height: 1,
                color: isDark ? Colors.white12 : Colors.black12,
              ),
              IntrinsicHeight(
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        style: TextButton.styleFrom(
                          foregroundColor:
                              isDark ? Colors.white60 : Colors.black54,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(28),
                            ),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: 1,
                      color: isDark ? Colors.white12 : Colors.black12,
                    ),
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              bottomRight: Radius.circular(28),
                            ),
                          ),
                        ),
                        child: Text(
                          'Logout',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (result == true) {
      await FirebaseAuth.instance.signOut();
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    }
  }

  // Add this method
  Future<DocumentSnapshot?> _getUserData(String uid) async {
    try {
      return await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
    } catch (e) {
      debugPrint('Error fetching user data: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final user = FirebaseAuth.instance.currentUser;

    return Drawer(
      child: Column(
        children: [
          FutureBuilder<DocumentSnapshot?>(
            future: user != null ? _getUserData(user.uid) : null,
            builder: (context, snapshot) {
              String name = 'User';
              String email = 'No email';

              if (snapshot.hasData && snapshot.data != null) {
                final userData = snapshot.data!.data() as Map<String, dynamic>?;
                if (userData != null) {
                  name = userData['name'] ?? 'User';
                  email = userData['email'] ?? 'No email';
                }
              }

              return UserAccountsDrawerHeader(
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[900] : Colors.black,
                ),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: user?.photoURL != null
                      ? CachedNetworkImage(
                          imageUrl: user!.photoURL!,
                          imageBuilder: (context, imageProvider) => Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          placeholder: (context, url) =>
                              const CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              const Icon(Iconsax.profile_circle),
                        )
                      : const Icon(Iconsax.profile_circle, size: 40),
                ),
                accountName: Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                accountEmail: Text(email),
              );
            },
          ),
          ListTile(
            leading: Icon(Iconsax.profile_circle,
                color: isDark ? Colors.white70 : Colors.black87),
            title: Text('Edit Profile',
                style:
                    TextStyle(color: isDark ? Colors.white : Colors.black87)),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Iconsax.shopping_bag,
                color: isDark ? Colors.white70 : Colors.black87),
            title: Text('My Orders',
                style:
                    TextStyle(color: isDark ? Colors.white : Colors.black87)),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Iconsax.location,
                color: isDark ? Colors.white70 : Colors.black87),
            title: Text('Shipping Address',
                style:
                    TextStyle(color: isDark ? Colors.white : Colors.black87)),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Iconsax.setting_2,
                color: isDark ? Colors.white70 : Colors.black87),
            title: Text('Settings',
                style:
                    TextStyle(color: isDark ? Colors.white : Colors.black87)),
            onTap: () {},
          ),
          ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [Colors.indigo.shade900, Colors.purple.shade900]
                      : [Colors.orange.shade300, Colors.yellow.shade400],
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.purple.withOpacity(0.3)
                        : Colors.orange.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: InkWell(
                onTap: () async {
                  await themeProvider.toggleTheme();
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedOpacity(
                      opacity: isDark ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: const Icon(Icons.nightlight_round,
                          color: Colors.white, size: 20),
                    ),
                    AnimatedOpacity(
                      opacity: isDark ? 0.0 : 1.0,
                      duration: const Duration(milliseconds: 300),
                      child: const Icon(Icons.wb_sunny,
                          color: Colors.white, size: 20),
                    ),
                  ],
                ),
              ),
            ),
            title: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: TextStyle(
                color: isDark ? Colors.purple.shade100 : Colors.orange.shade700,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              child: Text(isDark ? 'Night Mode Active' : 'Day Mode Active'),
            ),
            subtitle: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: TextStyle(
                color: isDark ? Colors.purple.shade200 : Colors.orange.shade800,
                fontSize: 12,
              ),
              child: Text(isDark ? 'Tap to brighten up' : 'Tap to wind down'),
            ),
            onTap: () async {
              await themeProvider.toggleTheme();
            },
          ),
          const Spacer(),
          ListTile(
            leading: const Icon(Iconsax.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () => _handleLogout(context),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
