// Community chat

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CommunityChatPage extends StatefulWidget {
  final String groupId;
  final String groupName;

  const CommunityChatPage({
    super.key,
    required this.groupId,
    required this.groupName,
  });

  @override
  State<CommunityChatPage> createState() => _CommunityChatPageState();
}

class _CommunityChatPageState extends State<CommunityChatPage> {
  final TextEditingController _messageController = TextEditingController(); // Controller for the message input field
  final user = FirebaseAuth.instance.currentUser; // Current Firebase authenticated user
  String? userName; // Holds the current user's display name

  @override
  void initState() {
    super.initState();
    fetchUserName(); // Fetch user's name when the widget initializes
  }

  // Fetches the user's name from Firestore and updates the state
  Future<void> fetchUserName() async {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .get();

    if (userDoc.exists) {
      setState(() {
        userName = userDoc['name'];
      });
    }
  }

  // Sends a message to the community chat Firestore collection
  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final message = _messageController.text.trim();
    _messageController.clear();

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .get();

    final pet = userDoc.data()?['pet'] as Map<String, dynamic>? ?? {};
    final petName = pet['name'] ?? 'water';
    final petLevel = pet['level'] ?? 1;

    await FirebaseFirestore.instance
        .collection('communityChats')
        .doc(widget.groupId)
        .collection('messages')
        .add({
      'senderId': user?.uid,
      'senderName': userName ?? 'Unknown',
      'petName': petName,
      'petLevel': petLevel,
      'text': message,
      'timestamp': FieldValue.serverTimestamp(), // Firestore will populate this with the current server time
    });
  }

  // Converts a Firestore timestamp to a readable time
  String formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final dt = timestamp.toDate();
    return DateFormat.jm().format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFD4A055),
        title: Text(widget.groupName),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(), // Close the chat view
        ),
      ),
      backgroundColor: const Color(0xFFF5D7A1),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('communityChats')
                  .doc(widget.groupId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(), // Realtime stream of messages ordered by timestamp
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator()); // Loading state
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true, // Show newest messages at the bottom
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg['senderId'] == user?.uid; // Check if the message is from the current user

                    final data = msg.data() as Map<String, dynamic>? ?? {};
                    final petName = data.containsKey('petName') ? data['petName'] : 'water';
                    final petLevel = data.containsKey('petLevel') ? data['petLevel'] : 1;
                    final timestamp = data['timestamp'] as Timestamp?; // Get message timestamp

                    // Determine pet image stage based on level
                    String stage = 'egg';
                    if (petLevel == 2) {
                      stage = 'baby';
                    } else if (petLevel == 3) {
                      stage = 'old';
                    }

                    final petImagePath = 'assets/${petName}_$stage.png'; // Construct image asset path

                    return Padding(
                      padding: EdgeInsets.only(
                        left: isMe ? 60 : 12,
                        right: isMe ? 12 : 60,
                      ),
                      child: Row(
                        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!isMe)
                            Padding(
                              padding: const EdgeInsets.only(left: 0, right: 6),
                              child: CircleAvatar(
                                radius: 20,
                                backgroundImage: AssetImage(petImagePath), // Pet avatar
                                backgroundColor: Colors.transparent,
                              ),
                            ),
                          Flexible(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: MediaQuery.of(context).size.width * 0.7, // Limit bubble width
                              ),
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isMe ? Colors.green[200] : Colors.white, // Color based on sender
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (!isMe)
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 4),
                                        child: Text(
                                          msg['senderName'] ?? 'Unknown', // Sender name
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    Text(
                                      msg['text'] ?? '', // Message text
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      formatTimestamp(timestamp), // time
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.black),
                  onPressed: _sendMessage, // Send message on press
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
