// Main page when community tab is clicked

import 'package:flutter/material.dart';
import 'create_page.dart';
import 'joined_page.dart';
import 'browse_page.dart';
import '../../core/ui/nav_bar.dart';

// Entry point for the Community section
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Arial'),
      home: const CommunityMain(), // Launches the CommunityMain page
    );
  }
}

// Main page for the Community module
class CommunityMain extends StatelessWidget {
  const CommunityMain({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDD098),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Header banner
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
              decoration: BoxDecoration(
                color: const Color(0xFFD4A055),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Community',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Button to create a new community
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CreatePage()),
                );
              },
              child: _buildMenuButton('Create', Icons.add),
            ),

            // Button to view communities the user has joined
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const JoinedPage()),
                );
              },
              child: _buildMenuButton('Joined', Icons.check),
            ),

            // Button to browse all available communities
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BrowsePage()),
                );
              },
              child: _buildMenuButton('Browse', Icons.group),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavBar(), // Custom navigation bar
    );
  }

  // Utility method to build stylized menu buttons
  Widget _buildMenuButton(String title, IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      width: 220,
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFD4A055), Color(0xFFB37830)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withOpacity(0.5),
            offset: const Offset(4, 4),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 10),
          Icon(icon, color: Colors.white),
        ],
      ),
    );
  }
}
