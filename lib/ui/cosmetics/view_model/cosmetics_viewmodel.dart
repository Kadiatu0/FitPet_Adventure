import 'package:flutter/material.dart';

import '../../../data/repositories/firebase/firestore_repository.dart';
import '../../../domain/models/cosmetic.dart';

class CosmeticsViewmodel extends ChangeNotifier {
  CosmeticsViewmodel({required FirestoreRepository firestoreRepository})
    : _firestoreRepository = firestoreRepository;

  Size get cosmeticSize => _cosmeticSize;
  Cosmetic get selectedCosmetic => _selectedCosmetic;
  List<Cosmetic> get placedCosmetics => _placedCosmetics;
  List<String> get availableCosmetics => _availableCosmetics;

  void addCosmetic(
    String imagePath,
    double width,
    double height,
    Offset position,
    double petWidth,
    double petHeight,
  ) {
    _selectedCosmetic = Cosmetic(
      imagePath: imagePath,
      width: width,
      height: height,
      position: position,
      petWidth: petWidth,
      petHeight: petHeight,
    );

    if (!_isWithinBounds(position)) return;
    placedCosmetics.add(_selectedCosmetic);
    notifyListeners();
  }

  void selectCosmetic(Cosmetic cosmetic) {
    _selectedCosmetic = cosmetic;
    notifyListeners();
  }

  void removeCosmetic() {
    placedCosmetics.remove(_selectedCosmetic);
    _selectedCosmetic = Cosmetic(imagePath: '');
    notifyListeners();
  }

  void updateCosmetic({double? scale, double? rotation, Offset? position}) {
    if (scale != null) selectedCosmetic.scale = scale;
    if (rotation != null) selectedCosmetic.rotation = rotation;

    if (position != null && _isWithinBounds(position)) {
      selectedCosmetic.position = position;
    }

    notifyListeners();
  }

  void flipCosmetic() {
    selectedCosmetic.isFlipped = !selectedCosmetic.isFlipped;
    notifyListeners();
  }

  Future<void> saveCosmetics() async {
    final data = placedCosmetics.map((c) => c.toMap()).toList();
    await _firestoreRepository.saveCosmetics(data);
    notifyListeners();
  }

  Future<void> loadCosmetics() async {
    final data = await _firestoreRepository.loadCosmetics();
    placedCosmetics.clear();

    for (final cosmeticMap in data) {
      placedCosmetics.add(Cosmetic.fromMap(cosmeticMap));
    }

    notifyListeners();
  }

  final FirestoreRepository _firestoreRepository;
  final _cosmeticSize = Size(80.0, 80.0);
  Cosmetic _selectedCosmetic = Cosmetic(imagePath: '');
  final List<Cosmetic> _placedCosmetics = [];
  final List<String> _availableCosmetics = [
    'assets/hat.png',
    'assets/sword.png',
  ];

  bool _isWithinBounds(Offset position) {
    // Halves for the center of the image and not the corner.
    final halfWidth = (selectedCosmetic.width / 2);
    final halfHeight = (selectedCosmetic.height / 2);

    // Bounds for the top and left sides.
    if (position.dx < -halfWidth || position.dy < -halfHeight) return false;

    final rightBound = (selectedCosmetic.petWidth - halfWidth);
    final bottomBound = (selectedCosmetic.petHeight - halfHeight);

    if (position.dx > rightBound) return false;
    if (position.dy > bottomBound) return false;

    return true;
  }
}
