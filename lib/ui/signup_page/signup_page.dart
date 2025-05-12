import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'signup_viewmodel.dart';

import '../../routing/routes.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  SignupPageState createState() => SignupPageState();
}

class SignupPageState extends State<SignupPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<SignupViewModel>(context);
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 246, 229, 178), // Light Beige Background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        toolbarHeight: 50,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new, 
            color: Color.fromARGB(255, 160, 117, 9),
            size: 28, // size increases boldness of icon 
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          // upper oval
          Positioned(
            top: 0, 
            child: Container(
              width: 250, 
              height: 200,
              decoration: BoxDecoration(
                image:DecorationImage(
                   image: AssetImage("assets/signup.png"), fit: BoxFit.cover),
                color: Color.fromARGB(255, 170, 124, 10), 
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(95, 84, 44, 14),
                    blurRadius: 12,
                    spreadRadius: 3,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              // child: const Center(
              //   child: Text(
              //     'Account\nCreation',
              //     textAlign: TextAlign.center,
              //     style: TextStyle(
              //       fontSize: 24, 
              //       fontWeight: FontWeight.bold,
              //       color: Color.fromARGB(255, 170, 124, 10),
              //       fontFamily: 'PressStart2P', 
              //     ),
              //   ),
              // ),
            ),
          ),
          // Signup Form Box 
          Positioned(
            top: screenHeight * 0.25, 
            left: 20,
            right: 20,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500), 
              child: Container(
                padding: const EdgeInsets.all(40), 
                decoration: BoxDecoration(
                  color: Colors.white,
                    border: Border.all(
                      color: const Color.fromARGB(255, 170, 124, 10), // Solid orange border color
                      width: 2, // Width of the border
                    ),
                  borderRadius: BorderRadius.circular(35),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 15,
                      spreadRadius: 3,
                      offset: const Offset(0, 7),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min, 
                  children: [
                    const Text(
                      'Sign Up',
                      style: TextStyle(
                        fontFamily: 'PressStart2P',
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 170, 124, 10),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Name Field
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        prefixIcon: const Icon(Icons.person, color: Color.fromARGB(255, 170, 124, 10)), 
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    // Email Field
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: const Icon(Icons.email, color: Color.fromARGB(255, 170, 124, 10)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 15),
                    // Password Field
                    TextField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock, color: Color.fromARGB(255, 170, 124, 10)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 20),
                    // Loading Indicator
                    if (viewModel.isLoading) const CircularProgressIndicator(),
                    if (viewModel.errorMessage != null)
                      Text(
                        viewModel.errorMessage!,
                        style: const TextStyle(color: Color.fromARGB(255, 170, 124, 10)),
                      ),
                    const SizedBox(height: 20),
                    // Sign Up Button
                    ElevatedButton(
                      onPressed: viewModel.isLoading
                          ? null
                          : () async {
                              String name = _nameController.text.trim();
                              String email = _emailController.text.trim();
                              String password = _passwordController.text.trim();
                              await viewModel.signUp(name, email, password, context);
                            },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 55),
                        backgroundColor: const Color.fromARGB(255, 170, 124, 10), 
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Already Have an Account?
                    TextButton(
                      onPressed: () {
                        context.push(Routes.login);
                      },
                      child: const Text.rich(
                        TextSpan(
                          text: 'Already have an account? ',
                          style: TextStyle(fontSize: 16, color: Color.fromARGB(255, 170, 124, 10)), 
                          children: [
                            TextSpan(
                              text: 'Log In',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black, 
                              ),
                            ),
                          ],
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
