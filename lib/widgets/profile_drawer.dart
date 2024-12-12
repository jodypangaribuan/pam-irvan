import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfileDrawer extends StatelessWidget {
  const ProfileDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Colors.black),
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
            leading: const Icon(Iconsax.profile_circle),
            title: const Text('Edit Profile'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Iconsax.shopping_bag),
            title: const Text('My Orders'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Iconsax.location),
            title: const Text('Shipping Address'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Iconsax.setting_2),
            title: const Text('Settings'),
            onTap: () {},
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
