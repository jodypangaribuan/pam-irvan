import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class ProfileDrawer extends StatelessWidget {
  const ProfileDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[900] : Colors.black,
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: CachedNetworkImage(
                imageUrl: 'https://via.placeholder.com/150',
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
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),
            accountName: const Text('John Doe'),
            accountEmail: const Text('john.doe@example.com'),
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
            onTap: () {},
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
