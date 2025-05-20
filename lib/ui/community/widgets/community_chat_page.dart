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
      'edited': false,
      'reaction': null,
    });
  }

  // Converts a Firestore timestamp to a readable time
  String formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final dt = timestamp.toDate();
    final now = DateTime.now();

    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final amPm = dt.hour >= 12 ? 'PM' : 'AM';

    if (now.difference(dt).inDays == 0) {
      return "$hour:$minute $amPm";
    } else {
      return "${dt.month}/${dt.day}/${dt.year} $hour:$minute $amPm";
    }
  }

  // Show edit, delete, react options
  void _showMessageOptions(DocumentSnapshot msg, String groupId, String messageId) async {
    final isMe = msg['senderId'] == user?.uid;

    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isMe)
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit'),
              onTap: () => Navigator.pop(context, 'edit'),
            ),
          if (isMe)
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Delete'),
              onTap: () => Navigator.pop(context, 'delete'),
            ),
          ListTile(
            leading: const Icon(Icons.emoji_emotions),
            title: const Text('React'),
            onTap: () => Navigator.pop(context, 'react'),
          ),
        ],
      ),
    );

    switch (selected) {
      case 'edit':
        final controller = TextEditingController(text: msg['text']);
        final edited = await showDialog<String>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Edit Message'),
            content: TextField(controller: controller),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              TextButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Save')),
            ],
          ),
        );
        if (edited != null && edited.trim().isNotEmpty) {
          await FirebaseFirestore.instance
              .collection('communityChats')
              .doc(groupId)
              .collection('messages')
              .doc(messageId)
              .update({'text': edited.trim(), 'edited': true});
        }
        break;

      case 'delete':
        await FirebaseFirestore.instance
            .collection('communityChats')
            .doc(groupId)
            .collection('messages')
            .doc(messageId)
            .delete();
        break;

      case 'react':
        final reaction = await showDialog<String>(
          context: context,
          builder: (context) => SimpleDialog(
            title: const Text('Pick a reaction'),
            children: [
              for (var emoji in ['❤️', '😂', '👍', '😮', '😢'])
                SimpleDialogOption(
                  child: Text(emoji, style: const TextStyle(fontSize: 24)),
                  onPressed: () => Navigator.pop(context, emoji),
                ),
            ],
          ),
        );
        if (reaction != null) {
          await FirebaseFirestore.instance
              .collection('communityChats')
              .doc(groupId)
              .collection('messages')
              .doc(messageId)
              .update({'reaction': reaction});
        }
        break;
    }
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
                    final isMe = msg['senderId'] == user?.uid;

                    final data = msg.data() as Map<String, dynamic>? ?? {};
                    final petName = data['petName'] ?? 'water';
                    final petLevel = data['petLevel'] ?? 1;
                    final timestamp = data['timestamp'] as Timestamp?;
                    final reaction = data['reaction'];
                    final edited = data['edited'] == true;

                    String stage = 'egg';
                    if (petLevel == 2) {
                      stage = 'baby';
                    } else if (petLevel == 3) {
                      stage = 'old';
                    }

                    final petImagePath = 'assets/${petName}_$stage.png';

                    return GestureDetector(
                      onTap: () => _showMessageOptions(msg, widget.groupId, msg.id),
                      child: Padding(
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
                                  backgroundImage: AssetImage(petImagePath),
                                  backgroundColor: Colors.transparent,
                                ),
                              ),
                            Flexible(
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                                ),
                                child: Container(
                                  margin: const EdgeInsets.symmetric(vertical: 4),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isMe ? Colors.green[200] : Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (!isMe)
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 4),
                                          child: Text(
                                            msg['senderName'] ?? 'Unknown',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      Text(
                                        msg['text'] ?? '',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Text(
                                            formatTimestamp(timestamp),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                          if (edited)
                                            const Padding(
                                              padding: EdgeInsets.only(left: 4),
                                              child: Text(
                                                "(edited)",
                                                style: TextStyle(fontSize: 10, color: Colors.grey),
                                              ),
                                            ),
                                        ],
                                      ),
                                      if (reaction != null)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 4.0),
                                          child: Text(
                                            reaction,
                                            style: const TextStyle(fontSize: 18),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
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
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
