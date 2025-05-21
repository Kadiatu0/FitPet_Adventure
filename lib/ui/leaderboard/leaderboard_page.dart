import 'package:firebase_auth/firebase_auth.dart';
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
  String selectedFilter = "Steps";
  bool isGlobal = true;
  String? currentUserId;
  List<String> friendsList = [];

  @override
  void initState() {
    super.initState();
    _getCurrentUserId();
    _addAllUsersToLeaderboard();
  }
  
//fetch logged in user's friend list
  Future<void> _getCurrentUserId() async {
    final user = FirebaseAuth.instance.currentUser;
    setState(() {
      currentUserId = user?.uid;
    });
    if (currentUserId != null) {
      final userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUserId)
              .get();
      final userData = userDoc.data() ?? {};
      setState(() {
        friendsList = List<String>.from(userData['friends'] ?? []);
      });
    }
  }

  //add and update users to the leaderboard
  Future<void> _addAllUsersToLeaderboard() async {
    try {
      final usersSnapshot =
          await FirebaseFirestore.instance.collection('users').get();

      for (var userDoc in usersSnapshot.docs) {
        final userId = userDoc.id;
        final userData = userDoc.data();
        final userName = userData['name']?.toString().trim();
        final currentStepcount = userData['currentStepcount'] ?? 0;

        if (userName == null || userName.isEmpty) continue;

        //conversion for miles and calories
        final totalMiles = (currentStepcount / 2000).toStringAsFixed(1);
        final totalCalories = (currentStepcount * 0.04).toStringAsFixed(1);

        final leaderboardDoc =
            await FirebaseFirestore.instance
                .collection('leaderboards')
                .doc(userId)
                .get();

        if (!leaderboardDoc.exists) {
          await FirebaseFirestore.instance
              .collection('leaderboards')
              .doc(userId)
              .set({
                'userId': userId,
                'userName': userName,
                'totalSteps': currentStepcount,
                'totalMiles': totalMiles,
                'totalCalories': totalCalories,
                'type': 'global',
              });
        } else {
          await FirebaseFirestore.instance
              .collection('leaderboards')
              .doc(userId)
              .update({
                'totalSteps': currentStepcount,
                'totalMiles': totalMiles,
                'totalCalories': totalCalories,
              });
        }
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  //mapping to firestore field names
  String getFirestoreField(String filter) {
    switch (filter) {
      case "Steps":
        return "totalSteps";
      case "Miles":
        return "totalMiles";
      case "Calories":
        return "totalCalories";
      default:
        return "totalSteps";
    }
  }

  @override
  Widget build(BuildContext context) {
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
          _buildLeaderboardToggle(),
          const SizedBox(height: 20),
          Expanded(child: _buildLeaderboardStream()),
        ],
      ),
      bottomNavigationBar: NavBar(),
    );
  }

  Widget _buildLeaderboardStream() {
    final selectedField = getFirestoreField(selectedFilter);

    Query<Map<String, dynamic>> query;

    if (isGlobal) {
      query = FirebaseFirestore.instance
          .collection('leaderboards')
          .where('type', isEqualTo: 'global')
          .orderBy(selectedField, descending: true);
    } else {
      // Add current user to the friend list if not already there
      if (currentUserId != null && !friendsList.contains(currentUserId)) {
        friendsList.add(currentUserId!);
      }

      query = FirebaseFirestore.instance
          .collection('leaderboards')
          .where(FieldPath.documentId, whereIn: friendsList)
          .orderBy(selectedField, descending: true);
    }

    //stream data and display list
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());

        //format data
        final docs = snapshot.data!.docs;
        final players =
            docs.map((doc) {
              final data = doc.data();
              return {
                'userId': data['userId'],
                'userName': data['userName'] ?? 'Unknown',
                'totalSteps': data['totalSteps'] ?? 0,
                'totalMiles': data['totalMiles'] ?? 0,
                'totalCalories': data['totalCalories'] ?? 0,
              };
            }).toList();

        return Column(
          children: [
            if (players.length >= 3) _buildTopThreePlayers(players),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: players.length,
                itemBuilder: (context, index) {
                  return _buildLeaderboardItem(
                    index + 1,
                    players[index]["userName"],
                    players[index][getFirestoreField(selectedFilter)],
                    selectedFilter,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  //button for global and friends
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

  //filter buttons for steps, miles, and calories
  Widget _buildFilterButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children:
          [
            "Steps",
            "Miles",
            "Calories",
          ].map((filter) => _buildFilterButton(filter)).toList(),
    );
  }

  Widget _buildFilterButton(String filter) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            selectedFilter = filter;
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

  //card for the top 3 players
  Widget _buildTopThreePlayers(List<Map<String, dynamic>> players) {
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

  //card for top 1 player
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

  //item for leaderboard ranking
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
