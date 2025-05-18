// Page to browse communities

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'community_detail_page.dart';
import '../../core/ui/nav_bar.dart';

// BrowsePage allows the user to view and search all communities from Firestore
class BrowsePage extends StatefulWidget {
  const BrowsePage({super.key});

  @override
  State<BrowsePage> createState() => _BrowsePageState();
}

class _BrowsePageState extends State<BrowsePage> {
  String searchQuery = '';

  // List of placeholder community images (can be expanded)
final List<String> communityImages = [
  'assets/earth_old.png',
  'assets/sky_old.png',
  'assets/space_old.png',
];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0D7A1),
      appBar: AppBar(
        title: const Text('Browse Communities'),
        backgroundColor: const Color(0xFFD4A055),
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          // Search bar input
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (value) => setState(() => searchQuery = value.toLowerCase()),
              decoration: InputDecoration(
                hintText: '1-12 letters, no spaces',
                prefixIcon: const Icon(Icons.search),
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Firestore stream to get community data in real-time
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('communities').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return const Center(child: Text('Something went wrong'));
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Filter communities based on search query
                final allCommunities = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name = data['groupName']?.toLowerCase() ?? '';
                  return name.contains(searchQuery);
                }).toList();

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: allCommunities.length,
                  itemBuilder: (context, index) {
                    final doc = allCommunities[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final int iconIndex = data['iconIndex'] ?? 0;
                    final String iconPath = communityImages[iconIndex.clamp(0, communityImages.length - 1)];
                    final List<dynamic> members = data['members'] ?? [];
                    final int memberCount = members.length;

                    // Community card
                    return GestureDetector(
                      onTap: () {
                        // Navigate to detailed view of the community
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CommunityDetailPage(
                              groupName: data['groupName'],
                              type: data['type'],
                              groupId: doc.id,
                              memberCount: memberCount,
                              iconPath: iconPath,
                              description: data['groupDescription'] ?? '',
                            ),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFD4A055), Color(0xFFB37830)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.brown.withOpacity(0.3),
                              offset: const Offset(4, 4),
                              blurRadius: 5,
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Community icon
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.transparent,
                              backgroundImage: AssetImage(iconPath),
                            ),
                            const SizedBox(width: 20),
                            // Community info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data['groupName'] ?? 'Community Name',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    doc.id,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    data['type'] ?? 'Type',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '$memberCount/10 members',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      // Bottom navigation bar
      bottomNavigationBar: NavBar(),
    );
  }
}