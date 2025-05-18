// Join Requests

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class JoinRequestsPage extends StatefulWidget {
  final String groupId;
  final String groupName;

  const JoinRequestsPage({
    super.key,
    required this.groupId,
    required this.groupName,
  });

  @override
  State<JoinRequestsPage> createState() => _JoinRequestsPageState();
}

class _JoinRequestsPageState extends State<JoinRequestsPage> {
  List<Map<String, dynamic>> requests = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchJoinRequests();
  }

  /// Fetches user data for all IDs in joinRequests
  Future<void> fetchJoinRequests() async {
    try {
      final communityDoc = await FirebaseFirestore.instance
          .collection('communities')
          .doc(widget.groupId)
          .get();

      final requestIds = List<String>.from(communityDoc.data()?['joinRequests'] ?? []);
      final List<Map<String, dynamic>> users = [];

      for (final id in requestIds) {
        final userDoc =
            await FirebaseFirestore.instance.collection('users').doc(id).get();
        if (userDoc.exists) {
          final data = userDoc.data();
          users.add({
            'uid': id,
            'name': data?['name'] ?? 'Unnamed',
          });
        }
      }

      setState(() {
        requests = users;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching join requests: $e');
    }
  }

  /// Approves a user: adds to members, removes from requests
  Future<void> approveUser(String uid) async {
    final communityRef = FirebaseFirestore.instance.collection('communities').doc(widget.groupId);
    final userRef = FirebaseFirestore.instance.collection('users').doc(uid);

    try {
      await communityRef.update({
        'joinRequests': FieldValue.arrayRemove([uid]),
        'members': FieldValue.arrayUnion([uid]),
        'memberCount': FieldValue.increment(1),
      });

      await userRef.update({
        'joinedGroups': FieldValue.arrayUnion([widget.groupId]),
      });

      fetchJoinRequests();
    } catch (e) {
      print('Error approving user: $e');
    }
  }

  /// Rejects a user - removes from requests
  Future<void> rejectUser(String uid) async {
    try {
      final communityRef = FirebaseFirestore.instance.collection('communities').doc(widget.groupId);
      await communityRef.update({
        'joinRequests': FieldValue.arrayRemove([uid]),
      });

      fetchJoinRequests();
    } catch (e) {
      print('Error rejecting user: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Join Requests - ${widget.groupName}'),
        backgroundColor: const Color(0xFFD4A055),
        foregroundColor: Colors.black,
      ),
      backgroundColor: const Color(0xFFF0D7A1),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : requests.isEmpty
              ? const Center(child: Text('No pending join requests.'))
              : ListView.builder(
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    final user = requests[index];
                    return ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(user['name']),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.check, color: Colors.green),
                            onPressed: () => approveUser(user['uid']),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () => rejectUser(user['uid']),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
