import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'login_viemodel.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<LoginViewModel>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        toolbarHeight: 35,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new, // Use this for a bolder look
            color: Color.fromARGB(255, 243, 162, 91),
            size: 28, // Increase size slightly for more boldness
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // "Log In" Text at the Top
                const Padding(
                  padding: EdgeInsets.only(bottom: 40), // Adjust top padding as needed
                  child: Text(
                    'Log In',
                    style: TextStyle(
                      fontFamily: 'PressStart2P',
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFEA9021),
                    ),
                  ),
                ),
                const SizedBox(height: 0),
                // Image Container 
                Container(
                  width: double.infinity,
                  height: 245, // Height of the image container
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('lib/data/model/assets/egg_pic.png'), 
                      fit: BoxFit.cover, // the image fills the container
                    ),
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                const SizedBox(height: 40),
                // Login Box (Existing)
                Container(
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(35),
                    border: Border.all(
                      color: const Color.fromARGB(255, 230, 145, 55), // Solid orange border color
                      width: 2, // Width of the border
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromARGB(31, 235, 151, 61),
                        blurRadius: 15,
                        spreadRadius: 3,
                        offset: Offset(0, 7),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 0),
                      // Email Field
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: const Icon(Icons.email, color: Color(0xFFFB8C00)),
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
                          prefixIcon: const Icon(Icons.lock, color: Color(0xFFFB8C00)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 0),
                      // Remember Me & Forgot Password
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/reset_password');
                            },
                            child: const Text(
                              'Forgot Password?',
                              style: TextStyle(color: Color(0xFFFB8C00)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 0),
                      if (viewModel.isLoading) const CircularProgressIndicator(),
                      if (viewModel.errorMessage != null)
                        Text(
                          viewModel.errorMessage!,
                          style: const TextStyle(color: Color(0xFFE65100)),
                        ),
                      const SizedBox(height: 0),
                      // Log In Button
                      ElevatedButton(
                        onPressed: viewModel.isLoading
                            ? null
                            : () async {
                                String email = _emailController.text.trim();
                                String password = _passwordController.text.trim();
                                await viewModel.logIn(email, password, context);
                              },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 55),
                          backgroundColor: const Color(0xFFFB8C00),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Log In',
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 0),
                      // Don't Have an Account?
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/signup');
                        },
                        child: const Text.rich(
                          TextSpan(
                            text: 'Don’t have an account? ',
                            style: TextStyle(fontSize: 16, color: Color(0xFFFB8C00)),
                            children: [
                              TextSpan(
                                text: 'Sign Up',
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
