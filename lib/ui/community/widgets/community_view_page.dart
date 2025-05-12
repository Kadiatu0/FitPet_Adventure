import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/ui/nav_bar.dart';
import 'community_chat_page.dart';

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
  List<Map<String, dynamic>> members = [];
  bool isLoading = true;
  int memberCount = 0;
  bool isMember = false;
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    currentUserId = FirebaseAuth.instance.currentUser?.uid;
    fetchMembers();
  }

  Future<void> fetchMembers() async {
    try {
      final communityDoc = await FirebaseFirestore.instance
          .collection('communities')
          .doc(widget.groupId)
          .get();

      final data = communityDoc.data();
      final List<dynamic> memberIds = data?['members'] ?? [];
      final List<Map<String, dynamic>> memberList = [];

      for (final id in memberIds) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(id)
            .get();

        if (userDoc.exists) {
          final userData = userDoc.data();
          final name = userData?['name'] ?? 'Unnamed';
          final steps = userData?['currentStepcount'] ?? 0;

          final petMap = userData?['pet'] as Map<String, dynamic>? ?? {};
          final petName = petMap['name'] ?? 'water';
          final petLevel = petMap['level'] ?? 1;

          memberList.add({
            'name': name,
            'steps': steps,
            'petName': petName,
            'petLevel': petLevel,
          });
        }
      }

      memberList.sort((a, b) => b['steps'].compareTo(a['steps']));

      setState(() {
        members = memberList;
        isMember = memberIds.contains(currentUserId);
        memberCount = memberList.length;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching community data: $e');
    }
  }

  Future<void> leaveCommunity() async {
    if (currentUserId == null) return;

    final communityRef = FirebaseFirestore.instance.collection('communities').doc(widget.groupId);
    final userRef = FirebaseFirestore.instance.collection('users').doc(currentUserId);

    try {
      await communityRef.update({
        'members': FieldValue.arrayRemove([currentUserId]),
        'memberCount': FieldValue.increment(-1),
      });

      await userRef.update({
        'joinedGroups': FieldValue.arrayRemove([widget.groupId]),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You left the community.')),
        );
      }

      await fetchMembers();
    } catch (e) {
      print('Error leaving community: $e');
    }
  }

  void openChat() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CommunityChatPage(
          groupId: widget.groupId,
          groupName: widget.groupName,
        ),
      ),
    );
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

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      widget.description,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),

                  const SizedBox(height: 20),

                  if (isMember) ...[
                    ElevatedButton(
                      onPressed: openChat,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Open Group Chat',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: leaveCommunity,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Leave Community',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),
                  const Divider(),

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
                      itemCount: members.length,
                      itemBuilder: (context, index) {
                        final member = members[index];
                        final petName = member['petName'];
                        final petLevel = member['petLevel'];

                        String stage = 'egg';
                        if (petLevel == 2) {
                          stage = 'baby';
                        } else if (petLevel == 3) {
                          stage = 'old';
                        }

                        final petImagePath = 'assets/${petName}_$stage.png';

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: AssetImage(petImagePath),
                            backgroundColor: Colors.white,
                            radius: 24,
                          ),
                          title: Text(member['name']),
                          subtitle: Text('${member['steps']} steps'),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: NavBar(),
    );
  }
}