// Page for users to create a community

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/ui/nav_bar.dart';

class CreatePage extends StatefulWidget {
  const CreatePage({super.key});

  @override
  _CreatePageState createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  // Determines whether the community is public or private
  bool isPublic = true;

  // Stores the index of the selected icon
  int selectedIconIndex = -1;

  // Tracks validation error message for name input
  String? nameError;

  // Controllers for community name and description input
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  // Available community icon paths
  final List<String> communityImages = [
    'assets/earth_old.png',
    'assets/sky_old.png',
    'assets/space_old.png',
  ];

  // Handles validation and submission of community creation
  Future<void> _createCommunity() async {
    final name = nameController.text.trim();
    final description = descriptionController.text.trim();
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    // Validate the name input
    if (name.isEmpty) {
      setState(() => nameError = 'Enter a name!');
      return;
    } else if (name.contains(' ')) {
      setState(() => nameError = 'No spaces allowed!');
      return;
    } else if (name.length > 12) {
      setState(() => nameError = 'Name is too long!');
      return;
    }

    setState(() => nameError = null);

    // Add the new community to Firestore
    final newCommunityRef = await FirebaseFirestore.instance
        .collection('communities')
        .add({
      'groupName': name,
      'groupDescription': description,
      'type': isPublic ? 'Public' : 'Private',
      'members': [currentUserId],
      'adminId': currentUserId,
      'iconIndex': selectedIconIndex,
      'memberCount': 1,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Add community ID to user's joinedGroups
    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .update({
      'joinedGroups': FieldValue.arrayUnion([newCommunityRef.id]),
    });

    // Show confirmation and navigate back
    final messenger = ScaffoldMessenger.of(context);
    Navigator.pop(context);

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: const Text(
              "Community created!",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFFD4A055),
            duration: const Duration(seconds: 2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0D7A1),
      appBar: AppBar(
        title: const Text('Create Community'),
        backgroundColor: const Color(0xFFD4A055),
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Display logged-in user's name and profile image
              FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser?.uid)
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }

                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return const Text('User not found');
                  }

                  final userData = snapshot.data!.data() as Map<String, dynamic>;
                  final userName = userData['name'] ?? 'Unknown';
                  final petMap = userData['pet'] as Map<String, dynamic>? ?? {};
                  final petType = petMap['type']?.toString().replaceAll(' ', '_') ?? 'water';
                  final evolutionBarPoints = petMap['evolutionBarPoints'] ?? 0;

                  String stage;
                  if (evolutionBarPoints >= 2) {
                    stage = 'old';
                  } else if (evolutionBarPoints == 1) {
                    stage = 'baby';
                  } else {
                    stage = 'egg';
                  }

                  final petImagePath = 'assets/${petType}_$stage.png';

                  return Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: AssetImage(petImagePath),
                        backgroundColor: Colors.transparent,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        userName,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 20),

              // Community creation form container
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.brown, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Select an icon for the community
                    const Text(
                      'Community Icon',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(communityImages.length, (index) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedIconIndex = index;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: selectedIconIndex == index
                                  ? const Color(0xFFD4A055)
                                  : Colors.grey[300],
                              border: Border.all(
                                color: selectedIconIndex == index
                                    ? Colors.black
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 20,
                              backgroundImage: AssetImage(communityImages[index]),
                              backgroundColor: Colors.transparent,
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 15),

                    // Community name input
                    const Text(
                      'Community Name',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        hintText: '1-12 letters, no spaces',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.brown),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        errorText: nameError,
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Public or private community toggle
                    const Text(
                      'Join Settings',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Public button
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isPublic ? const Color(0xFFD4A055) : Colors.white,
                              foregroundColor: isPublic ? Colors.white : Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: const BorderSide(color: Colors.brown),
                              ),
                            ),
                            onPressed: () => setState(() => isPublic = true),
                            child: const Text('Public'),
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Private button
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isPublic ? Colors.white : const Color(0xFFD4A055),
                              foregroundColor: isPublic ? Colors.black : Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: const BorderSide(color: Colors.brown),
                              ),
                            ),
                            onPressed: () => setState(() => isPublic = false),
                            child: const Text('Private'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    // Community description input
                    const Text(
                      'Community Description',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    TextField(
                      controller: descriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: '150 words maximum',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.brown),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Submit button
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD4A055),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 50),
                        ),
                        onPressed: _createCommunity,
                        child: const Text(
                          'Create',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavBar(),
    );
  }
}
