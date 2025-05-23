import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'choose_pet_viewmodel.dart';
import '../../routing/routes.dart';

class ChoosePetPage extends StatefulWidget {
  const ChoosePetPage({super.key});

  @override
  State<ChoosePetPage> createState() => _ChoosePetPageState();
}

class _ChoosePetPageState extends State<ChoosePetPage> {
  int currentIndex = 0;

  void _goToNextPet(ChoosePetViewModel viewModel) {
    if (currentIndex < viewModel.pets.length - 1) {
      setState(() {
        currentIndex++;
      });
    }
  }

  void _goToPreviousPet(ChoosePetViewModel viewModel) {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChoosePetViewModel()..fetchPets(),
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 246, 229, 178),
        body: Consumer<ChoosePetViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (viewModel.errorMessage != null) {
              return Center(child: Text('Error: ${viewModel.errorMessage}'));
            }

            if (viewModel.pets.isEmpty) {
              return const Center(child: Text("No pets found."));
            }

            final pet = viewModel.pets[currentIndex];
            String pet_name = pet.getPetName.toLowerCase().replaceAll(' ', '');
            return SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, size: 30, color: Color.fromARGB(255, 184, 134, 11)),
                        onPressed: () => context.pop(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 0),
                  const Text(
                    "CHOOSE YOUR PET",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 170, 124, 10),
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Wiggly Border Box around the image
                  ClipPath(
                    clipper: WigglyBorderClipper(), // Custom Clipper
                    child: Container(
                      height: 250,
                      width: 250,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/${pet_name}egg.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 0),
                  Column(
                    children: [
                      Text(
                        pet.getPetName.toUpperCase(),
                        style: TextStyle(
                          fontSize: 22,
                          color: Color.fromARGB(255, 170, 124, 10),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // Underline
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        height: 2,
                        width: 80, // Adjust this width to match the text or fit the design
                        color: const Color.fromARGB(255, 170, 124, 10),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color.fromARGB(255, 121, 85, 72),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              pet.getPetDescription,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.arrow_back_ios, size: 50),
                                  onPressed: () => _goToPreviousPet(viewModel),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.arrow_forward_ios, size: 50),
                                  onPressed: () => _goToNextPet(viewModel),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        await viewModel.updateUserPet(pet);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${pet.getPetName} selected!')),
                          );
                          context.go(Routes.home);
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: ${e.toString()}')),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 184, 134, 11),
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Select",
                      style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// Custom Clipper for Wiggly Border
class WigglyBorderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, 0);

    // Create wavy effect on the top edge
    for (double i = 0; i < size.width; i++) {
      path.lineTo(i, 10 * (i % 2 == 0 ? 1 : -1));
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
