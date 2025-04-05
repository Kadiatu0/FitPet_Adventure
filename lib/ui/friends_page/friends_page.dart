import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  FriendsPageState createState() => FriendsPageState();
}

class FriendsPageState extends State<FriendsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String searchQuery = "";
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _getCurrentUserId();
  }

  // Get the currently logged-in user's ID
  Future<void> _getCurrentUserId() async {
    setState(() {
      currentUserId = '3iksXYPMgmg3tNmudaudTQ4rmef1';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5D7A1),
      appBar: AppBar(
        title: const Text("Friends"),
        backgroundColor: const Color(0xFF8F794C),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          indicatorColor: Colors.black,
          tabs: const [
            Tab(text: "My Friends"),
            Tab(text: "Requests"),
            Tab(text: "Browse Users"),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildFriendsList(),
                _buildFriendRequestsList(),
                _buildBrowseUsersList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Search bar to filter friends list and users
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        onChanged: (value) {
          setState(() {
            searchQuery = value.toLowerCase();
          });
        },
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          hintText: "Search friends or users...",
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // Fetch friends list from Firestore
  Widget _buildFriendsList() {
    if (currentUserId == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return StreamBuilder<DocumentSnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection("users")
              .doc(currentUserId)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(child: Text("User data not found."));
        }

        List<dynamic> friendIds = snapshot.data!["friends"] ?? [];

        if (friendIds.isEmpty) {
          return const Center(child: Text("You have no friends yet."));
        }

        return _buildFriendsFromIds(friendIds);
      },
    );
  }

  // Fetch friend requests from Firestore and apply search filter
  Widget _buildFriendRequestsList() {
    if (currentUserId == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return StreamBuilder<DocumentSnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection("users")
              .doc(currentUserId)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(child: Text("User data not found."));
        }

        List<dynamic> friendRequests = snapshot.data!["friendRequests"] ?? [];

        if (friendRequests.isEmpty) {
          return const Center(child: Text("You have no friend requests."));
        }

        return _buildFriendRequestsFromIds(friendRequests);
      },
    );
  }

  // Fetch friend request senders' details from Firestore based on IDs
  Widget _buildFriendRequestsFromIds(List<dynamic> friendRequests) {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection("users")
              .where("uid", whereIn: friendRequests)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text("Error loading requests: ${snapshot.error}"),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No friend requests found."));
        }

        List<Map<String, dynamic>> requests =
            snapshot.data!.docs
                .map((doc) => doc.data() as Map<String, dynamic>)
                .where((request) {
                  String userName = request["name"]?.toLowerCase() ?? '';
                  return userName.contains(searchQuery.toLowerCase());
                })
                .toList();

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            return _buildFriendRequestItem(
              requests[index]["name"],
              requests[index]["level"],
              requests[index]["uid"],
            );
          },
        );
      },
    );
  }

  // UI for a single friend request entry
  Widget _buildFriendRequestItem(String name, int? level, String id) {
    return Card(
      color: const Color(0xFFFFF1D6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: const Color(0xFF8F794C),
          child: const Text("😀", style: TextStyle(fontSize: 24)),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.check, color: Colors.green),
              onPressed: () => acceptFriendRequest(currentUserId!, id),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: () => rejectFriendRequest(currentUserId!, id),
            ),
          ],
        ),
      ),
    );
  }

  // Fetch friends' details from Firestore based on IDs
  Widget _buildFriendsFromIds(List<dynamic> friendIds) {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection("users")
              .where("uid", whereIn: friendIds)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text("Error loading friends: ${snapshot.error}"),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No friends found."));
        }

        List<Map<String, dynamic>> friends =
            snapshot.data!.docs
                .map((doc) => doc.data() as Map<String, dynamic>)
                .where(
                  (friend) =>
                      friend["name"].toLowerCase().contains(searchQuery),
                )
                .toList();

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: friends.length,
          itemBuilder: (context, index) {
            return _buildFriendItem(
              friends[index]["name"],
              friends[index]["level"],
              friends[index]["uid"],
              friends[index]["uid"],
            );
          },
        );
      },
    );
  }

  // UI for a single friend entry with Remove Friend option
  Widget _buildFriendItem(String name, int? level, String id, String userId) {
    return Card(
      color: const Color(0xFFFFF1D6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: const Color(0xFF8F794C),
          child: const Text("😀", style: TextStyle(fontSize: 24)),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: IconButton(
          icon: const Icon(Icons.remove_circle, color: Colors.red),
          onPressed: () => removeFriend(currentUserId!, id),
        ),
      ),
    );
  }

  Widget _buildBrowseUsersList() {
    return StreamBuilder<DocumentSnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection("users")
              .doc(currentUserId)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(child: Text("User data not found."));
        }

        List<dynamic> sentRequests = snapshot.data!["sentRequests"] ?? [];
        List<dynamic> friends = snapshot.data!["friends"] ?? [];

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection("users").snapshots(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (userSnapshot.hasError) {
              return Center(child: Text("Error: ${userSnapshot.error}"));
            }

            if (!userSnapshot.hasData || userSnapshot.data!.docs.isEmpty) {
              return const Center(child: Text("No users found."));
            }

            List<Map<String, dynamic>> users =
                userSnapshot.data!.docs
                    .map((doc) => doc.data() as Map<String, dynamic>)
                    .where((user) {
                      String userName = user["name"]?.toLowerCase() ?? '';
                      return userName.contains(searchQuery.toLowerCase()) &&
                          user["uid"] != currentUserId &&
                          !sentRequests.contains(user["uid"]) &&
                          !friends.contains(user["uid"]);
                    })
                    .toList();

            return Padding(
              padding: const EdgeInsets.all(16),
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  return Card(
                    color: const Color(0xFFFFF1D6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 25,
                        backgroundColor: const Color(0xFF8F794C),
                        child: const Text("😀", style: TextStyle(fontSize: 24)),
                      ),
                      title: Text(
                        users[index]["name"] ?? 'Unknown',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.person_add, color: Colors.blue),
                        onPressed: () async {
                          await sendFriendRequest(
                            currentUserId!,
                            users[index]["uid"],
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  // Send a friend request and update Firestore to track sent requests
  Future<void> sendFriendRequest(
    String currentUserId,
    String receiverUserId,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .update({
            'sentRequests': FieldValue.arrayUnion([receiverUserId]),
          });

      await FirebaseFirestore.instance
          .collection('users')
          .doc(receiverUserId)
          .update({
            'friendRequests': FieldValue.arrayUnion([currentUserId]),
          });

      print('Friend request sent!');
    } catch (e) {
      print('Error sending friend request: $e');
    }
  }

  // Accept a friend request
  Future<void> acceptFriendRequest(
    String currentUserId,
    String senderUserId,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .update({
            'friends': FieldValue.arrayUnion([senderUserId]),
            'friendRequests': FieldValue.arrayRemove([senderUserId]),
          });

      await FirebaseFirestore.instance
          .collection('users')
          .doc(senderUserId)
          .update({
            'friends': FieldValue.arrayUnion([currentUserId]),
          });

      print('Friend request accepted!');
    } catch (e) {
      print('Error accepting friend request: $e');
    }
  }

  // Reject a friend request
  Future<void> rejectFriendRequest(
    String currentUserId,
    String senderUserId,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .update({
            'friendRequests': FieldValue.arrayRemove([senderUserId]),
          });

      print('Friend request rejected!');
    } catch (e) {
      print('Error rejecting friend request: $e');
    }
  }

  // Remove a friend
  Future<void> removeFriend(String currentUserId, String friendUserId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .update({
            'friends': FieldValue.arrayRemove([friendUserId]),
          });

      await FirebaseFirestore.instance
          .collection('users')
          .doc(friendUserId)
          .update({
            'friends': FieldValue.arrayRemove([currentUserId]),
          });

      print('Friend removed!');
    } catch (e) {
      print('Error removing friend: $e');
    }
  }
}
