// Page to view all joined communities

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'community_view_page.dart';
import '../../core/ui/nav_bar.dart';

class JoinedPage extends StatefulWidget {
  const JoinedPage({super.key});

  @override
  State<JoinedPage> createState() => _JoinedPageState();
}

class _JoinedPageState extends State<JoinedPage> {
  // List of icons/images for community representation
  final List<String> communityImages = [
    'assets/water_baby.png',
  ];

  // Future to hold the user's joined communities
  late Future<List<DocumentSnapshot>> _joinedCommunitiesFuture;

  @override
  void initState() {
    super.initState();
    _joinedCommunitiesFuture = fetchJoinedCommunities();
  }

  // Fetches the communities that the current user has joined
  Future<List<DocumentSnapshot>> fetchJoinedCommunities() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final joinedGroupIds = List<String>.from(userDoc.data()?['joinedGroups'] ?? []);
    if (joinedGroupIds.isEmpty) return [];

    final communitiesQuery = await FirebaseFirestore.instance
        .collection('communities')
        .where(FieldPath.documentId, whereIn: joinedGroupIds)
        .get();

    return communitiesQuery.docs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0D7A1),
      appBar: AppBar(
        title: const Text('Joined Communities'),
        backgroundColor: const Color(0xFFD4A055),
        foregroundColor: Colors.black,
      ),
      body: FutureBuilder<List<DocumentSnapshot>>(
        future: _joinedCommunitiesFuture,
        builder: (context, snapshot) {
          // Show loading indicator while fetching data
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final communities = snapshot.data ?? [];

          // If no communities have been joined
          if (communities.isEmpty) {
            return const Center(child: Text('You have not joined any communities.'));
          }

          // Display list of joined communities
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: communities.length,
            itemBuilder: (context, index) {
              final doc = communities[index];
              final data = doc.data() as Map<String, dynamic>;
              final int iconIndex = data['iconIndex'] ?? 0;
              final String iconPath = communityImages[iconIndex.clamp(0, communityImages.length - 1)];
              final List<dynamic> members = data['members'] ?? [];
              final int memberCount = members.length;

              return GestureDetector(
                onTap: () {
                  // Navigate to detailed view of the selected community
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CommunityViewPage(
                        groupId: doc.id,
                        groupName: data['groupName'],
                        type: data['type'],
                        iconPath: iconPath,
                        description: data['groupDescription'],
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
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white,
                        backgroundImage: AssetImage(iconPath),
                      ),
                      const SizedBox(width: 20),
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
      bottomNavigationBar: NavBar(),
    );
  }
}
