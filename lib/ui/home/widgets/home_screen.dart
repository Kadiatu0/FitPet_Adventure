import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show KeyDownEvent, LogicalKeyboardKey;
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../view_model/home_viewmodel.dart';
import '../../../routing/routes.dart';
import '../../core/ui/nav_bar.dart';
import 'pet_view.dart';
import 'steps_graph.dart';

class HomeScreen extends StatelessWidget {
  final HomeViewModel viewModel;

  const HomeScreen({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5D7A1),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, size: 40, color:  Color.fromARGB(255, 46, 40, 30)),
            onPressed: () => Scaffold.of(context).openDrawer(),
            tooltip: 'Settings',
          ),
        ),
      ),

      drawer: Drawer(
        backgroundColor: const Color(0xFFF5D7A1),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 194, 135, 46),
              ),
              child: Text(
                'Settings',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.email, color: Color.fromARGB(255, 228, 159, 55)),
              title: const Text('Change Email'),
              onTap: () {
                Navigator.pop(context);
                context.push(Routes.changeEmail);
              },
            ),
            ListTile(
              leading: const Icon(Icons.lock, color: Color.fromARGB(255, 228, 159, 55)),
              title: const Text('Change Password'),
              onTap: () {
                Navigator.pop(context);
                context.push(Routes.resetPassword);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Color.fromARGB(255, 228, 159, 55)),
              title: const Text('Logout'),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) context.push(Routes.login);
              },
            ),
          ],
        ),
      ),

      body: FutureBuilder(
        future: Future.wait([
          viewModel.loadEvolutionNum(),
          viewModel.loadSteps(),
        ]),
        builder: (_, __) {
          return KeyboardListener(
            focusNode: FocusNode()..requestFocus(),
            autofocus: true,
            onKeyEvent: (event) {
              if (kDebugMode &&
                  event is KeyDownEvent &&
                  event.logicalKey == LogicalKeyboardKey.space) {
                viewModel.incrementSteps();
              }
            },
            child: LayoutBuilder(
              builder: (context, constraints) {
                final petViewHeight = constraints.maxHeight / 3.0;
                final petSize = Size(petViewHeight, petViewHeight);

                return Column(
                  children: [
                    SafeArea(
                      child: PetView(viewModel: viewModel, petSize: petSize),
                    ),
                    const Divider(
                      color: Color.fromARGB(255, 142, 138, 113),
                      thickness: 2.0,
                      height: 0.0,
                    ),
                    StepsGraph(viewModel: viewModel),
                    const Divider(
                      color: Color(0xFF8E8971),
                      thickness: 2.0,
                      height: 0.0,
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),

      bottomNavigationBar: const NavBar(),
    );
  }
}
