// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';

// class FriendsChatPage extends StatefulWidget {
//   final String currentUserId;
//   final String friendUserId;
//   final String friendName;

//   const FriendsChatPage({
//     super.key,
//     required this.currentUserId,
//     required this.friendUserId,
//     required this.friendName,
//   });

//   @override
//   State<FriendsChatPage> createState() => _FriendsChatPageState();
// }

// class _FriendsChatPageState extends State<FriendsChatPage> {
//   final TextEditingController _messageController = TextEditingController();

//   // Function to get unique chatId between two users
//   String _getChatId(String userId1, String userId2) {
//     return userId1.hashCode <= userId2.hashCode
//         ? '${userId1}_$userId2'
//         : '${userId2}_$userId1';
//   }

//   // Function to send a message
//   Future<void> _sendMessage() async {
//     if (_messageController.text.trim().isEmpty) return;

//     final message = _messageController.text.trim();
//     _messageController.clear();

//     final timestamp = Timestamp.now();
//     final chatId = _getChatId(widget.currentUserId, widget.friendUserId);

//     // Add the new message to Firestore
//     await FirebaseFirestore.instance
//         .collection('chats')
//         .doc(chatId)
//         .collection('messages')
//         .add({
//           'senderId': widget.currentUserId,
//           'receiverId': widget.friendUserId,
//           'message': message,
//           'timestamp': timestamp,
//           'read':
//               false, // Messages are initially marked as unread when first sent
//         });
//   }

//   // Function to delete a message
//   Future<void> _deleteMessage(String chatId, String messageId) async {
//     final confirm = await showDialog<bool>(
//       context: context,
//       builder:
//           (context) => AlertDialog(
//             title: const Text('Delete Message'),
//             content: const Text(
//               'Are you sure you want to delete this message?',
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context, false),
//                 child: const Text('Cancel'),
//               ),
//               TextButton(
//                 onPressed: () => Navigator.pop(context, true),
//                 child: const Text('Delete'),
//               ),
//             ],
//           ),
//     );

//     if (confirm == true) {
//       await FirebaseFirestore.instance
//           .collection('chats')
//           .doc(chatId)
//           .collection('messages')
//           .doc(messageId)
//           .delete();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final chatId = _getChatId(widget.currentUserId, widget.friendUserId);

//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF8F794C),
//         title: Text(widget.friendName),
//         leading: IconButton(
//           icon: const Icon(Icons.close),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//       ),
//       backgroundColor: const Color(0xFFF5D7A1),
//       body: Column(
//         children: [
//           Expanded(
//             child: StreamBuilder<QuerySnapshot>(
//               stream:
//                   FirebaseFirestore.instance
//                       .collection('chats')
//                       .doc(chatId)
//                       .collection('messages')
//                       .orderBy('timestamp', descending: true)
//                       .snapshots(),
//               builder: (context, snapshot) {
//                 if (!snapshot.hasData) {
//                   return const Center(child: CircularProgressIndicator());
//                 }

//                 final messages = snapshot.data!.docs;

//                 return ListView.builder(
//                   reverse: true,
//                   itemCount: messages.length,
//                   itemBuilder: (context, index) {
//                     final msg = messages[index];
//                     final isMe = msg['senderId'] == widget.currentUserId;
//                     final messageId = msg.id;

//                     return GestureDetector(
//                       onLongPress:
//                           isMe ? () => _deleteMessage(chatId, messageId) : null,
//                       child: Align(
//                         alignment:
//                             isMe ? Alignment.centerRight : Alignment.centerLeft,
//                         child: Container(
//                           margin: const EdgeInsets.symmetric(
//                             vertical: 4,
//                             horizontal: 12,
//                           ),
//                           padding: const EdgeInsets.all(12),
//                           decoration: BoxDecoration(
//                             color: isMe ? Colors.green[200] : Colors.white,
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: ConstrainedBox(
//                             constraints: BoxConstraints(
//                               maxWidth: MediaQuery.of(context).size.width * 0.7,
//                             ),
//                             child: Text(
//                               msg['message'],
//                               style: const TextStyle(fontSize: 16),
//                             ),
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(12),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _messageController,
//                     decoration: InputDecoration(
//                       hintText: 'Type a message...',
//                       filled: true,
//                       fillColor: Colors.white,
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(30),
//                         borderSide: BorderSide.none,
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 IconButton(
//                   icon: const Icon(Icons.send, color: Colors.black),
//                   onPressed: _sendMessage,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FriendsChatPage extends StatefulWidget {
  final String currentUserId;
  final String friendUserId;
  final String friendName;

  const FriendsChatPage({
    super.key,
    required this.currentUserId,
    required this.friendUserId,
    required this.friendName,
  });

  @override
  State<FriendsChatPage> createState() => _FriendsChatPageState();
}

class _FriendsChatPageState extends State<FriendsChatPage> {
  final TextEditingController _messageController = TextEditingController();

  String _getChatId(String userId1, String userId2) {
    return userId1.hashCode <= userId2.hashCode
        ? '${userId1}_$userId2'
        : '${userId2}_$userId1';
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final message = _messageController.text.trim();
    _messageController.clear();

    final timestamp = Timestamp.now();
    final chatId = _getChatId(widget.currentUserId, widget.friendUserId);

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add({
          'senderId': widget.currentUserId,
          'receiverId': widget.friendUserId,
          'message': message,
          'timestamp': timestamp,
          'read': false,
        });
  }

  Future<void> _deleteMessage(String chatId, String messageId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Message'),
            content: const Text(
              'Are you sure you want to delete this message?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .delete();
    }
  }

  String _formatTimestamp(Timestamp timestamp) {
    final dateTime = timestamp.toDate();
    final now = DateTime.now();

    final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final amPm = dateTime.hour >= 12 ? 'PM' : 'AM';

    if (now.difference(dateTime).inDays == 0) {
      return "$hour:$minute $amPm";
    } else {
      return "${dateTime.month}/${dateTime.day}/${dateTime.year} $hour:$minute $amPm";
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatId = _getChatId(widget.currentUserId, widget.friendUserId);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF8F794C),
        title: Text(widget.friendName),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      backgroundColor: const Color(0xFFF5D7A1),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('chats')
                      .doc(chatId)
                      .collection('messages')
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg['senderId'] == widget.currentUserId;
                    final messageId = msg.id;

                    return GestureDetector(
                      onLongPress:
                          isMe ? () => _deleteMessage(chatId, messageId) : null,
                      child: Align(
                        alignment:
                            isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 12,
                          ),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.green[200] : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.7,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  msg['message'],
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatTimestamp(msg['timestamp']),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
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
