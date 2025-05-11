import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../view_model/cosmetics_viewmodel.dart';

class ClearCosmeticsButton extends StatelessWidget {
  const ClearCosmeticsButton({super.key, required this.viewModel});

  final CosmeticsViewmodel viewModel;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.delete, color: Colors.red, size: 50.0),
      onPressed: () {
        showCupertinoDialog(
          barrierDismissible: true,
          context: context,
          builder: (_) {
            return CupertinoAlertDialog(
              content: Text(
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0),
                'Clear All Cosmetics',
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      viewModel.removeAllCosmetics();
                      context.pop();
                    },
                    child: Text('Yes'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () => context.pop(),
                    child: Text('No'),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
