// Viewing a joined community

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/ui/nav_bar.dart';
import 'community_chat_page.dart';
import 'join_requests_page.dart';

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
  bool isAdmin = false;
  String? currentUserId;
  String? adminUserId;

  @override
  void initState() {
    super.initState();
    currentUserId = FirebaseAuth.instance.currentUser?.uid; // Set current user ID
    fetchMembers(); // Load members on init
  }

  // Fetch community info and determine admin/member status
  Future<void> fetchMembers() async {
    try {
      final communityDoc = await FirebaseFirestore.instance
          .collection('communities')
          .doc(widget.groupId)
          .get();

      final data = communityDoc.data();
      final List<dynamic> memberIds = data?['members'] ?? [];
      adminUserId = data?['adminId'];
      isAdmin = adminUserId == currentUserId;

      final List<Map<String, dynamic>> memberList = [];

      // Loop through each member ID to get user data
      for (final id in memberIds) {
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(id).get();
        if (userDoc.exists) {
          final userData = userDoc.data();
          final name = userData?['name'] ?? 'Unnamed';
          final steps = userData?['currentStepcount'] ?? 0;

          final petMap = userData?['pet'] as Map<String, dynamic>? ?? {};
          final petName = petMap['type'] ?? 'water';
          final petLevel = petMap['level'] ?? 1;

          memberList.add({
            'name': name,
            'steps': steps,
            'petName': petName,
            'petLevel': petLevel,
            'userId': id,
          });
        }
      }

      // Sort members by step count (descending)
      memberList.sort((a, b) => b['steps'].compareTo(a['steps']));

      setState(() {
        members = memberList;
        isMember = memberIds.contains(currentUserId);
        memberCount = memberList.length;
      });
    } catch (e) {
      print('Error fetching members: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  // Navigate to group chat screen
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

  // Navigate to join requests screen (admin only)
  void viewJoinRequests() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JoinRequestsPage(
          groupId: widget.groupId,
          groupName: widget.groupName,
        ),
      ),
    );
  }

  // Confirm before leaving community
  Future<void> confirmLeaveCommunity() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Leave Community'),
        content: const Text('Are you sure you want to leave this community?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Leave')),
        ],
      ),
    );

    if (confirm == true) {
      final userRef = FirebaseFirestore.instance.collection('users').doc(currentUserId);
      final groupRef = FirebaseFirestore.instance.collection('communities').doc(widget.groupId);

      // Remove user from community and update Firestore
      await groupRef.update({
        'members': FieldValue.arrayRemove([currentUserId]),
        'memberCount': FieldValue.increment(-1),
      });

      await userRef.update({
        'joinedGroups': FieldValue.arrayRemove([widget.groupId]),
      });

      if (mounted) Navigator.pop(context);
    }
  }

  // Confirm before deleting community (admin only)
  Future<void> confirmDeleteCommunity() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Community'),
        content: const Text('Are you sure you want to delete this community for everyone?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );

    if (confirm == true) {
      final groupRef = FirebaseFirestore.instance.collection('communities').doc(widget.groupId);
      await groupRef.delete(); // Delete the community

      if (mounted) Navigator.pop(context);
    }
  }

  // Confirm before kicking a member (admin only)
  Future<void> confirmKickMember(String userIdToKick) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Kick Member'),
        content: const Text('Remove this member from the community?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Kick')),
        ],
      ),
    );

    if (confirm == true) {
      final userRef = FirebaseFirestore.instance.collection('users').doc(userIdToKick);
      final groupRef = FirebaseFirestore.instance.collection('communities').doc(widget.groupId);

      // Remove user from group in Firestore
      await groupRef.update({
        'members': FieldValue.arrayRemove([userIdToKick]),
        'memberCount': FieldValue.increment(-1),
      });

      await userRef.update({
        'joinedGroups': FieldValue.arrayRemove([widget.groupId]),
      });

      await fetchMembers(); // Refresh the member list
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
          ? const Center(child: CircularProgressIndicator()) // Show loading spinner
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.transparent,
                        backgroundImage: AssetImage(widget.iconPath),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.groupName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                            Text('$memberCount/10 members', style: const TextStyle(fontSize: 16)),
                            Text(widget.type, style: const TextStyle(fontSize: 16)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Align(alignment: Alignment.centerLeft, child: Text(widget.description, style: const TextStyle(fontSize: 16))),
                  const SizedBox(height: 20),

                  // Show join requests button if admin of a private group
                  if (isAdmin && widget.type.toLowerCase() == 'private') ...[
                    ElevatedButton(
                      onPressed: viewJoinRequests,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4A055),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('View Join Requests', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 10),
                  ],

                  // Show chat and leave/delete buttons for members
                  if (isMember) ...[
                    ElevatedButton(
                      onPressed: openChat,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5A9F9F),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Open Group Chat', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: isAdmin ? confirmDeleteCommunity : confirmLeaveCommunity,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB54848),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        isAdmin ? 'Delete Community' : 'Leave Community',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),
                  const Divider(),

                  // Member list heading
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Members:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 10),

                  // List of all members
                  Expanded(
                    child: ListView.builder(
                      itemCount: members.length,
                      itemBuilder: (context, index) {
                        final member = members[index];
                        final petName = member['petName'];
                        final petLevel = member['petLevel'];
                        final memberId = member['userId'];

                        String stage = 'egg';
                        if (petLevel == 2) stage = 'baby';
                        else if (petLevel == 3) stage = 'old';

                        final petImagePath = 'assets/${petName}_$stage.png';

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: AssetImage(petImagePath),
                            backgroundColor: Colors.transparent,
                            radius: 24,
                          ),
                          title: Row(
                            children: [
                              Text(member['name']),
                              if (memberId == adminUserId)
                                const Padding(
                                  padding: EdgeInsets.only(left: 6),
                                  child: Icon(Icons.shield, size: 18, color: Colors.deepPurple),
                                ),
                            ],
                          ),
                          subtitle: Text('${member['steps']} steps'),
                          trailing: isAdmin && memberId != currentUserId
                              ? IconButton(
                                  icon: const Icon(Icons.person_remove, color: Colors.red),
                                  onPressed: () => confirmKickMember(memberId),
                                )
                              : null,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: NavBar(), // App's bottom navigation bar
    );
  }
}
