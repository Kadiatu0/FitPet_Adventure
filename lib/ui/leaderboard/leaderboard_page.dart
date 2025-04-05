import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/ui/nav_bar.dart';

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const LeaderboardScreen();
  }
}

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  LeaderboardScreenState createState() => LeaderboardScreenState();
}

class LeaderboardScreenState extends State<LeaderboardScreen> {
  String selectedFilter = "Steps"; // Default filter
  bool isGlobal = true; // Toggle between Global and Friends leaderboard
  bool isLoading = false;
  String? currentUserId;

  List<Map<String, dynamic>> globalPlayers = [];
  List<Map<String, dynamic>> friendsPlayers = [];

  @override
  void initState() {
    super.initState();
    _getCurrentUserId(); // Get the current user's ID on init
    _addAllUsersToLeaderboard(); // Add all users to leaderboard if they don't exist
    _fetchLeaderboardData(); // Fetch leaderboard data
  }

  // Simulating fetching the current user ID (for testing purposes)
  Future<void> _getCurrentUserId() async {
    setState(() {
      // IDK WHAT IM DOING OR LOOKING AT.
      // But I think this will work.
      currentUserId = FirebaseAuth.instance.currentUser?.uid;
    });
  }

  // Fetching all users from the users collection and adding them to leaderboards if they don't exist
  Future<void> _addAllUsersToLeaderboard() async {
    try {
      final usersSnapshot =
          await FirebaseFirestore.instance.collection('users').get();

      for (var userDoc in usersSnapshot.docs) {
        final userId = userDoc.id;
        final userData = userDoc.data();

        // Check if user has a name and currentStepcount
        final userName = userData['name']?.toString().trim();
        final currentStepcount = userData['currentStepcount'] ?? 0;

        if (userName == null || userName.isEmpty) {
          print("Skipped user $userId: missing name");
          continue;
        }

        // Check if already exists in leaderboard
        final leaderboardDoc =
            await FirebaseFirestore.instance
                .collection('leaderboards')
                .doc(userId)
                .get();

        if (!leaderboardDoc.exists) {
          // Create new entry with currentStepcount as totalSteps
          await FirebaseFirestore.instance
              .collection('leaderboards')
              .doc(userId)
              .set({
                'userId': userId,
                'userName': userName,
                'totalSteps': currentStepcount,
                'totalMiles': 0,
                'totalCalories': 0,
                'type': 'global',
              });

          print("Added user: $userName ($userId) with $currentStepcount steps");
        } else {
          // Update steps if user already exists
          await FirebaseFirestore.instance
              .collection('leaderboards')
              .doc(userId)
              .update({'totalSteps': currentStepcount});

          print("🔄 Updated steps for $userName ($userId): $currentStepcount");
        }
      }
    } catch (e) {
      print("Error adding users to leaderboard: $e");
    }
  }

  // Maps filter to correct Firestore field
  String getFirestoreField(String filter) {
    switch (filter) {
      case "Steps":
        return "totalSteps";
      case "Miles":
        return "totalMiles";
      case "Calories":
        return "totalCalories";
      default:
        return "totalSteps"; // Default fallback
    }
  }

  Future<void> _fetchLeaderboardData() async {
    setState(() => isLoading = true);

    try {
      final selectedField = getFirestoreField(selectedFilter);

      if (currentUserId == null)
        throw Exception("Current user ID not available");

      // Fetch the current user document from the 'users' collection
      final userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUserId)
              .get();

      final userData = userDoc.data() ?? {};
      final List<dynamic> friendsList = userData['friends'] ?? [];

      // Debugging: Checking the friends list
      print("Fetched friends list: $friendsList");

      QuerySnapshot<Map<String, dynamic>> leaderboardSnapshot;

      if (isGlobal) {
        // Global leaderboard
        leaderboardSnapshot =
            await FirebaseFirestore.instance
                .collection('leaderboards')
                .where('type', isEqualTo: 'global')
                .orderBy(selectedField, descending: true)
                .get();
      } else {
        // Friends leaderboard
        if (friendsList.isEmpty) {
          setState(() {
            friendsPlayers = [];
            isLoading = false;
          });
          print("No friends to display in leaderboard.");
          return;
        }

        // Debugging: Check if friends list has items
        print("Querying leaderboard for friends with IDs: $friendsList");

        // Fetch only friends leaderboards using the friend IDs
        leaderboardSnapshot =
            await FirebaseFirestore.instance
                .collection('leaderboards')
                .where(FieldPath.documentId, whereIn: friendsList)
                .orderBy(selectedField, descending: true)
                .get();
      }

      final leaderboardEntries =
          leaderboardSnapshot.docs.map((doc) {
            final data = doc.data();
            return {
              'userId': data['userId'],
              'userName': data['userName'] ?? 'Unknown',
              'totalSteps': data['totalSteps'] ?? 0,
              'totalMiles': data['totalMiles'] ?? 0,
              'totalCalories': data['totalCalories'] ?? 0,
            };
          }).toList();

      // Debugging: Check the fetched leaderboard data
      print("Leaderboard data fetched: $leaderboardEntries");

      setState(() {
        if (isGlobal) {
          globalPlayers = leaderboardEntries;
        } else {
          friendsPlayers = leaderboardEntries;
        }
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching leaderboard data: $e");
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error fetching leaderboard data.")),
      );
    }
  }

  Future<void> syncLeaderboardData() async {
    try {
      // Get the current user document from the users collection
      final userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUserId)
              .get();

      final userData = userDoc.data() ?? {};
      final friendsList = List<String>.from(userData['friends'] ?? []);

      if (friendsList.isEmpty) {
        print('No friends to update.');
        return;
      }

      // Update leaderboard data for each friends
      for (final friendId in friendsList) {
        final friendDoc =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(friendId)
                .get();

        final friendData = friendDoc.data();
        if (friendData != null) {
          final friendName = friendData['name'] ?? 'Unknown';

          // Retrieve the existing leaderboard data for the friend
          final leaderboardDoc =
              await FirebaseFirestore.instance
                  .collection('leaderboards')
                  .doc(friendId)
                  .get();

          if (leaderboardDoc.exists) {
            // If the leaderboard data exists, update it
            await FirebaseFirestore.instance
                .collection('leaderboards')
                .doc(friendId)
                .update({
                  'userName': friendName,
                  'friends': FieldValue.arrayUnion([currentUserId]),
                });
          } else {
            // If no leaderboard data exists, create a new document
            await FirebaseFirestore.instance
                .collection('leaderboards')
                .doc(friendId)
                .set({
                  'userId': friendId,
                  'userName': friendName,
                  'totalSteps': 0,
                  'totalMiles': 0,
                  'totalCalories': 0,
                  'friends': [currentUserId],
                  'type': 'global',
                });
          }
          print('Updated leaderboard for friend $friendName ($friendId)');
        } else {
          print('No data for friend: $friendId');
        }
      }
    } catch (e) {
      print('Error syncing leaderboard data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> players =
        isGlobal ? globalPlayers : friendsPlayers;

    return Scaffold(
      backgroundColor: const Color(0xFFF5D7A1),
      appBar: AppBar(
        title: const Text("Leaderboard"),
        backgroundColor: const Color(0xFF8F794C),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          _buildFilterButtons(),
          const SizedBox(height: 20),
          const Text(
            "Top 3 Players",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _buildTopThreePlayers(players),
          const SizedBox(height: 20),
          _buildLeaderboardToggle(),
          const SizedBox(height: 20),
          Expanded(
            child:
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : players.isEmpty
                    ? const Center(
                      child: Text("You have no friends in the leaderboard."),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: players.length,
                      itemBuilder: (context, index) {
                        return _buildLeaderboardItem(
                          index + 1,
                          players[index]["userName"], // Display userName
                          players[index][getFirestoreField(selectedFilter)],
                          selectedFilter,
                        );
                      },
                    ),
          ),
        ],
      ),
      bottomNavigationBar: NavBar(),
    );
  }

  Widget _buildLeaderboardToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildToggleButton("Global", isGlobal),
        const SizedBox(width: 20),
        _buildToggleButton("Friends", !isGlobal),
      ],
    );
  }

  Widget _buildToggleButton(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isGlobal = (label == "Global");
          _fetchLeaderboardData();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF8F794C) : const Color(0xFFBCAAA4),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children:
          ["Steps", "Miles", "Calories"].map((filter) {
            return _buildFilterButton(filter);
          }).toList(),
    );
  }

  Widget _buildFilterButton(String filter) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            selectedFilter = filter;
            _fetchLeaderboardData();
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor:
              selectedFilter == filter
                  ? const Color(0xFF8F794C)
                  : const Color(0xFFBCAAA4),
        ),
        child: Text(filter, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildTopThreePlayers(List<Map<String, dynamic>> players) {
    if (players.length < 3) return const SizedBox();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildPlayerCard(
          players[1]["userName"],
          players[1][getFirestoreField(selectedFilter)],
          2,
        ),
        _buildPlayerCard(
          players[0]["userName"],
          players[0][getFirestoreField(selectedFilter)],
          1,
          isCrowned: true,
        ),
        _buildPlayerCard(
          players[2]["userName"],
          players[2][getFirestoreField(selectedFilter)],
          3,
        ),
      ],
    );
  }

  Widget _buildPlayerCard(
    String name,
    dynamic value,
    int rank, {
    bool isCrowned = false,
  }) {
    return Column(
      children: [
        if (isCrowned)
          const Icon(Icons.emoji_events, color: Colors.amber, size: 30),
        CircleAvatar(
          radius: rank == 1 ? 40 : 30,
          backgroundColor: const Color(0xFF8F794C),
          child: Text(
            name[0],
            style: const TextStyle(fontSize: 24, color: Colors.white),
          ),
        ),
        const SizedBox(height: 5),
        Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text("$value ${selectedFilter.toLowerCase()}"),
      ],
    );
  }

  Widget _buildLeaderboardItem(
    int rank,
    String name,
    dynamic value,
    String unit,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      color: const Color(0xFFFFF1D6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF8F794C),
          child: Text(
            "$rank",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: Text("$value ${unit.toLowerCase()}"),
      ),
    );
  }
}
