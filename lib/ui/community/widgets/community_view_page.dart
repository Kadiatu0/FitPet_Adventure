import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/ui/nav_bar.dart';
import 'community_chat_page.dart';
import 'join_requests_page.dart'; // Import the new page

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
    currentUserId = FirebaseAuth.instance.currentUser?.uid;
    fetchMembers();
  }

  // Fetches community data including members and admin
  Future<void> fetchMembers() async {
    try {
      final communityDoc = await FirebaseFirestore.instance
          .collection('communities')
          .doc(widget.groupId)
          .get();

      final data = communityDoc.data();
      final List<dynamic> memberIds = data?['members'] ?? [];
      final List<Map<String, dynamic>> memberList = [];
      final String? adminId = data?['adminId'];

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

      memberList.sort((a, b) => b['steps'].compareTo(a['steps']));

      setState(() {
        members = memberList;
        isMember = memberIds.contains(currentUserId);
        memberCount = memberList.length;
        isAdmin = adminId == currentUserId;
        adminUserId = adminId;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching community data: $e');
    }
  }

  // Prompt user before leaving the community
  Future<void> leaveCommunity() async {
    if (currentUserId == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Community'),
        content: const Text('Are you sure you want to leave this community?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Leave')),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final communityRef = FirebaseFirestore.instance.collection('communities').doc(widget.groupId);
      final userRef = FirebaseFirestore.instance.collection('users').doc(currentUserId);

      await communityRef.update({
        'members': FieldValue.arrayRemove([currentUserId]),
        'memberCount': FieldValue.increment(-1),
      });

      await userRef.update({
        'joinedGroups': FieldValue.arrayRemove([widget.groupId]),
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You left the community.')),
        );
      }
    } catch (e) {
      print('Error leaving community: $e');
    }
  }

  // Prompt admin before deleting the community
  Future<void> deleteCommunity() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Community'),
        content: const Text('Are you sure you want to delete this community? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final communityRef = FirebaseFirestore.instance.collection('communities').doc(widget.groupId);

      for (final member in members) {
        final userId = member['userId'];
        await FirebaseFirestore.instance.collection('users').doc(userId).update({
          'joinedGroups': FieldValue.arrayRemove([widget.groupId]),
        });
      }

      await communityRef.delete();

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Community deleted.')),
        );
      }
    } catch (e) {
      print('Error deleting community: $e');
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
                  // Community banner
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
                            Text(widget.groupName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                            Text('$memberCount/10 members', style: const TextStyle(fontSize: 16)),
                            Text(widget.type, style: const TextStyle(fontSize: 16)),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Description
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(widget.description, style: const TextStyle(fontSize: 16)),
                  ),

                  const SizedBox(height: 20),

                  // Button options
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

                    // Show "View Join Requests" first for admin of private group
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

                    // Show "Delete" for admin, "Leave" for regular members
                    ElevatedButton(
                      onPressed: isAdmin ? deleteCommunity : leaveCommunity,
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

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Members:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                        if (petLevel == 2) stage = 'baby';
                        if (petLevel == 3) stage = 'old';

                        final petImagePath = 'assets/${petName}_$stage.png';

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: AssetImage(petImagePath),
                            backgroundColor: Colors.white,
                            radius: 24,
                          ),
                          title: Row(
                            children: [
                              Text(member['name']),
                              if (member['userId'] == adminUserId) ...[
                                const SizedBox(width: 6),
                                const Icon(Icons.shield, size: 18, color: Colors.deepPurple),
                              ],
                            ],
                          ),
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
