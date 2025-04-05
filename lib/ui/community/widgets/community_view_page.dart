// View a joined community after clicking on it

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/ui/nav_bar.dart';

// Stateful widget to display detailed information about a joined community
class CommunityViewPage extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String type;
  final String iconPath;
  final String description;

  const CommunityViewPage({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.type,
    required this.iconPath,
    required this.description,
  });

  @override
  State<CommunityViewPage> createState() => _CommunityViewPageState();
}

class _CommunityViewPageState extends State<CommunityViewPage> {
  List<String> memberNames = [];
  bool isLoading = true;
  int memberCount = 0;

  @override
  void initState() {
    super.initState();
    fetchMemberNames();
  }

  // Fetches member names from Firestore for the selected community
  Future<void> fetchMemberNames() async {
    try {
      final communityDoc = await FirebaseFirestore.instance
          .collection('communities')
          .doc(widget.groupId)
          .get();

      final data = communityDoc.data();
      final List<dynamic> memberIds = data?['members'] ?? [];
      memberCount = memberIds.length;

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
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching community data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0D7A1),
      appBar: AppBar(
        title: const Text('Community Info'),
        backgroundColor: const Color(0xFFD4A055),
        foregroundColor: Colors.black,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Community header with icon and details
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
                              '$memberCount/10 members',
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
                  const Divider(),

                  // List of community members
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
