import 'package:flutter/material.dart';

import 'home_button.dart';
import 'leaderboard_button.dart';
import 'friends_button.dart';
import 'community_button.dart';
import 'cosmetics_button.dart';

class NavBar extends StatelessWidget {
  const NavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 10.0,
          children: [
            Expanded(child: HomeButton()),
            Expanded(child: LeaderboardButton()),
            Expanded(child: FriendsButton()),
            Expanded(child: CommunityButton()),
            Expanded(child: CosmeticsButton()),
          ],
        ),
      ),
    );
  }
}
