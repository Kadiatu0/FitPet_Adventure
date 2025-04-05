import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../routing/routes.dart';

class CommunityButton extends StatelessWidget {
  const CommunityButton({super.key});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () {
        context.go(Routes.community);
      },
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.all(10.0),
        side: const BorderSide(color: Colors.black),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        backgroundColor: const Color(0xFFD6B588),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.group_outlined, size: 24, color: Colors.black),
        ],
      ),
    );
  }
}
