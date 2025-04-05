import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'choose_pet_viewmodel.dart';

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

            return SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, size: 30, color: Color.fromARGB(255, 184, 134, 11)),
                        onPressed: () => Navigator.pop(context),
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
                  const SizedBox(height: 0),
                  Image.asset(
                    'assets/${pet.getPetType.toLowerCase()}.png',
                    height: 300,
                    width: 300,
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
                  const SizedBox(height: 50),
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        await viewModel.updateUserPet(pet);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${pet.getPetName} selected!')),
                          );
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
