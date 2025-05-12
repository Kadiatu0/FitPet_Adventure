import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../view_model/cosmetics_viewmodel.dart';

class EditPetNameButton extends StatefulWidget {
  const EditPetNameButton({super.key, required this.viewModel});

  final CosmeticsViewmodel viewModel;

  @override
  State<EditPetNameButton> createState() => _EditPetNameButtonState();
}

class _EditPetNameButtonState extends State<EditPetNameButton> {
  String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        showCupertinoDialog(
          barrierDismissible: true,
          context: context,
          builder: (_) {
            final TextEditingController controller = TextEditingController();
            return StatefulBuilder(
              builder: (_, setState) {
                return CupertinoAlertDialog(
                  title: Text('Edit Pet Name'),
                  content: Column(
                    children: [
                      SizedBox(height: 10),
                      CupertinoTextField(
                        controller: controller,
                        placeholder: 'Enter new name',
                        maxLength: 21,
                        onChanged: (value) {
                          setState(() {
                            if (value.trim().isEmpty ||
                                !RegExp(r'[a-zA-Z]').hasMatch(value)) {
                              errorMessage =
                                  'Name must contain at least one letter.';
                            } else if (value.split(' ').length > 2 ||
                                value
                                    .split(' ')
                                    .any((word) => word.length > 10)) {
                              errorMessage =
                                  'Two words max, each up to 10 characters.';
                            } else {
                              errorMessage = null;
                            }
                          });
                        },
                      ),
                      if (errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            errorMessage!,
                            style: TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ),
                    ],
                  ),
                  actions: [
                    CupertinoDialogAction(
                      onPressed: () {
                        if (controller.text.trim().isNotEmpty &&
                            errorMessage == null) {
                          widget.viewModel.updatePetName(
                            controller.text.trim(),
                          );
                          context.pop();
                        } else {
                          setState(() {
                            errorMessage = 'Enter a valid name.';
                          });
                        }
                      },
                      child: Text('Save'),
                    ),
                    CupertinoDialogAction(
                      onPressed: () {
                        context.pop();
                      },
                      child: Text('Discard'),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
      icon: Icon(Icons.edit),
    );
  }
}
