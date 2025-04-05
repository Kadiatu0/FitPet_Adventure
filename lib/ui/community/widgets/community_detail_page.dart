// View community details when browsing

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../core/ui/nav_bar.dart';

class CommunityDetailPage extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String type;
  final String iconPath;
  final String description;
  final int memberCount;

  const CommunityDetailPage({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.type,
    required this.iconPath,
    required this.description,
    required this.memberCount,
  });

  @override
  State<CommunityDetailPage> createState() => _CommunityDetailPageState();
}

class _CommunityDetailPageState extends State<CommunityDetailPage> {
  List<String> memberNames = [];
  bool isLoading = true;
  bool isMember = false;

  @override
  void initState() {
    super.initState();
    fetchMemberNames();
  }

  // Fetch names of members in the community and check if current user is already a member
  Future<void> fetchMemberNames() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      final communityDoc = await FirebaseFirestore.instance
          .collection('communities')
          .doc(widget.groupId)
          .get();

      final data = communityDoc.data();
      final List<dynamic> memberIds = data?['members'] ?? [];
      final List<String> names = [];

      for (final id in memberIds) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(id)
            .get();

        if (userDoc.exists) {
          final userData = userDoc.data();
          names.add(userData?['name'] ?? 'Unnamed');
        }
      }

      setState(() {
        memberNames = names;
        isMember = currentUser != null && memberIds.contains(currentUser.uid);
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching member names: $e');
    }
  }

  // Join the community and update both user and community documents in Firestore
  Future<void> joinCommunity() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final userId = currentUser.uid;

    // Prevent duplicate joins
    if (isMember) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Already joined community!')),
      );
      return;
    }

    final communityRef =
        FirebaseFirestore.instance.collection('communities').doc(widget.groupId);
    final userRef =
        FirebaseFirestore.instance.collection('users').doc(userId);

    try {
      // Add user to the community's members array
      await communityRef.update({
        'members': FieldValue.arrayUnion([userId]),
      });

      // Update the community's memberCount
      final updatedDoc = await communityRef.get();
      final updatedMembers = updatedDoc.data()?['members'] as List<dynamic>? ?? [];
      await communityRef.update({
        'memberCount': updatedMembers.length,
      });

      // Add this community to the user's joinedGroups
      await userRef.update({
        'joinedGroups': FieldValue.arrayUnion([widget.groupId]),
      });

      // Refresh UI
      fetchMemberNames();
    } catch (e) {
      print('Error joining community: $e');
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Joined community!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0D7A1),
      appBar: AppBar(
        title: const Text('Community Details'),
        backgroundColor: const Color(0xFFD4A055),
        foregroundColor: Colors.black,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Display community icon and basic info
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white,
                        backgroundImage: AssetImage(widget.iconPath),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.groupName,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${widget.memberCount}/10 members',
                              style: const TextStyle(fontSize: 16),
                            ),
                            Text(
                              widget.type,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Community description
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      widget.description,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Show Join button for public communities only
                  if (widget.type.toLowerCase() == 'public')
                    ElevatedButton(
                      onPressed: joinCommunity,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4A055),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: Text(
                        isMember ? 'Already Joined' : 'Join',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    )
                  else
                    const Text(
                      'This Community is Private',
                      style: TextStyle(fontSize: 16, color: Colors.red),
                    ),

                  const SizedBox(height: 20),
                  const Divider(),

                  // Display list of community members
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Members:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: memberNames.length,
                      itemBuilder: (context, index) => ListTile(
                        leading: const Icon(Icons.person),
                        title: Text(memberNames[index]),
                      ),
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: NavBar(),
    );
  }
}
