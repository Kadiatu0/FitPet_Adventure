import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import "choose_pet_viewmodel.dart";

class ChoosePetPage extends StatefulWidget {
  const ChoosePetPage({super.key});

  @override
  State<ChoosePetPage> createState() => _ChoosePetPageState();
}

class _ChoosePetPageState extends State<ChoosePetPage> {
  final PageController _pageController = PageController(viewportFraction: 0.8); // Enables smooth scrolling

  void _nextPage() {
    if (_pageController.hasClients) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_pageController.hasClients) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ChoosePetViewModel()..fetchPets(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Choose Your Pet"),
          centerTitle: true,
          backgroundColor: Color.fromARGB(255, 243, 162, 91), // Using the first color
        ),
        body: Consumer<ChoosePetViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (viewModel.errorMessage != null) {
              return Center(child: Text('Error: ${viewModel.errorMessage}'));
            }

            return Padding(
              padding: const EdgeInsets.all(1.0),
              child: Column(
                children: [
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      scrollDirection: Axis.horizontal,
                      itemCount: viewModel.pets.length,
                      itemBuilder: (context, index) {
                        final pet = viewModel.pets[index];
                        return AnimatedBuilder(
                          animation: _pageController,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _pageController.page == index ? 1 : 0.9, // Slightly scales the selected pet
                              child: child,
                            );
                          },
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Pet Info Box (More compact)
                              Container(
                                margin: const EdgeInsets.symmetric(horizontal: 10),
                                padding: const EdgeInsets.symmetric(vertical: 10), // Reduced vertical padding
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color.fromARGB(255, 228, 156, 105),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // Pet name at the top and centered
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        pet.getPetName.toUpperCase(),
                                        style: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Color.fromARGB(255, 2, 1, 0)),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    // Pet image
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(15),
                                      child: Image.asset(
                                        'lib/data/model/assets/${pet.getPetType.toLowerCase()}.JPG',
                                        height: 180, // Reduced height for a more compact box
                                        width: 180, // Reduced width for a more compact box
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    const SizedBox(height: 10), // Reduced space between image and description
                                    // Description in the center (unchanged)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                      child: Text(
                                        pet.getPetDescription,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                                      ),
                                    ),
                                    // Move "Select" button up (no space below the description)
                                    const SizedBox(height: 100), 
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
                                        backgroundColor: Color.fromARGB(255, 243, 162, 91), // Button color
                                      ),
                                      child: Text(
                                        "Select",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Left Scroll Button inside the box (above the pet image)
                              Positioned(
                                left: 5,
                                child: IconButton(
                                  icon: Icon(Icons.arrow_back, size: 40, color: Colors.orange.shade700),
                                  onPressed: _previousPage,
                                ),
                              ),
                              // Right Scroll Button inside the box (above the pet image)
                              Positioned(
                                right: 5,
                                child: IconButton(
                                  icon: Icon(Icons.arrow_forward, size: 40, color: Colors.orange.shade700),
                                  onPressed: _nextPage,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
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
