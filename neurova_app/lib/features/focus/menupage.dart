import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF13111A),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              'Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            ListTile(
              title: const Text('Dashboard', style: TextStyle(color: Colors.white)),
              onTap: () => context.go('/dashboard'),
            ),
            ListTile(
              title: const Text('Profile', style: TextStyle(color: Colors.white)),
              onTap: () => context.go('/profile'),
            ),
          ],
        ),
      ),
    );
  }
}
