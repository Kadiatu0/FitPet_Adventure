import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../routing/routes.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 246, 229, 178),
      body: Stack(
        children: [
          // Curved orange Background
          ClipPath(
            clipper: WelcomeClipper(), // Custom clip for curve
            child: Container(
              height: MediaQuery.of(context).size.height * 0.55,
              width: double.infinity,
              color: const Color.fromARGB(255, 184, 134, 11),
              child: const Center(
                // group pet image
                child: Image(
                  ///Users/helloworld/The_capstone_app/FitPet_Adventure/FitPet_Adventure/assets/group_pic.png
                  image: AssetImage('assets/signup.png'),
                  fit:
                      BoxFit
                          .contain, // Adjust how the image fits within the container
                ),
              ),
            ),
          ),
          // "FitPet Adventure" text
          Positioned(
            top: 60, // top of image
            left: 0,
            right: 0,
            child: Container(
              alignment: Alignment.center,
              child: const Text(
                'FitPet Adventure',
                style: TextStyle(
                  fontFamily: 'PressStart2P',
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      offset: Offset(1.5, 1.5),
                      blurRadius: 3,
                      color: Color.fromARGB(255, 184, 134, 11),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Box buttons
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 80),
              child: Container(
                alignment: Alignment.center,
                height: 310,
                width: 400,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        context.push(Routes.signup);
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: const Color.fromARGB(
                          255,
                          184,
                          134,
                          11,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton(
                      onPressed: () {
                        context.push(Routes.login);
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            color: Color.fromARGB(255, 184, 134, 11),
                          ),
                        ),
                      ),
                      child: const Text(
                        'Log In',
                        style: TextStyle(
                          fontSize: 18,
                          color: Color.fromARGB(255, 184, 134, 11),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextButton(
                      onPressed: () {
                        context.push(Routes.resetPassword);
                      },
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color.fromARGB(255, 184, 134, 11),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Clipper for Curved Background
class WelcomeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 80);
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height - 80,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
