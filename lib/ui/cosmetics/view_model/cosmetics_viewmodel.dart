import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../data/repositories/firebase/firestore_repository.dart';
import '../../../domain/models/cosmetic.dart';
import '../../../utils/get_evolution_name.dart';

class CosmeticsViewmodel extends ChangeNotifier {
  CosmeticsViewmodel({required FirestoreRepository firestoreRepository})
    : _firestoreRepository = firestoreRepository;

  Size get cosmeticSize => _cosmeticSize;
  Cosmetic get selectedCosmetic => _selectedCosmetic;
  List<String> get availableCosmetics => _availableCosmetics;
  Map<String, Cosmetic> get placedCosmetics => _placedCosmetics;
  Future<String> get petName async => await _firestoreRepository.petName;
  Future<String> get petType async => await _firestoreRepository.petType;
  Future<String> get petEvolutionName async =>
      getEvolutionName(await _firestoreRepository.petEvolutionNum);

  Future<void> updatePetName(String name) async {
    await _firestoreRepository.updatePetName(name);
    notifyListeners();
  }

  void addCosmetic(
    String imagePath,
    double width,
    double height,
    Offset position,
    double petWidth,
    double petHeight,
  ) {
    if (placedCosmetics.length == 100) return;

    final uuid = Uuid().v4();

    _selectedCosmetic = Cosmetic(
      imagePath: imagePath,
      uuid: uuid,
      width: width,
      height: height,
      position: position,
      petWidth: petWidth,
      petHeight: petHeight,
    );

    if (!(_isWithinBounds(position))) {
      _selectedCosmetic = Cosmetic(imagePath: '');
      return;
    }

    _placedCosmetics[uuid] = _selectedCosmetic;
    _firestoreRepository.saveCosmetic(_selectedCosmetic);
    notifyListeners();
  }

  void selectCosmetic(Cosmetic cosmetic) {
    _selectedCosmetic = cosmetic;
    notifyListeners();
  }

  void removeCosmetic() {
    _placedCosmetics.remove(selectedCosmetic.uuid);
    _firestoreRepository.deleteCosmetic(selectedCosmetic);
    _selectedCosmetic = Cosmetic(imagePath: '');
    notifyListeners();
  }

  void removeAllCosmetics() {
    _placedCosmetics.clear();
    _firestoreRepository.deleteAllCosmetics();
    _selectedCosmetic = Cosmetic(imagePath: '');
    notifyListeners();
  }

  void updateCosmetic({double? scale, double? rotation, Offset? position}) {
    if (scale != null) _selectedCosmetic.scale = scale;
    if (rotation != null) _selectedCosmetic.rotation = rotation;

    if (position != null && _isWithinBounds(position)) {
      _selectedCosmetic.position = position;
    }

    notifyListeners();
  }

  void flipCosmetic() {
    _selectedCosmetic.isFlipped = !_selectedCosmetic.isFlipped;
    notifyListeners();
  }

  void saveCosmetic() {
    if (selectedCosmetic.imagePath == '') return;

    _placedCosmetics[selectedCosmetic.uuid] = selectedCosmetic;
    _firestoreRepository.saveCosmetic(selectedCosmetic);
    notifyListeners();
  }

  Future<void> loadCosmetics() async {
    _placedCosmetics = await _firestoreRepository.loadCosmetics();
  }

  final FirestoreRepository _firestoreRepository;
  final _cosmeticSize = Size(100.0, 100.0);
  Cosmetic _selectedCosmetic = Cosmetic(imagePath: '');
  Map<String, Cosmetic> _placedCosmetics = {};
  // Order of the cosmetics in the list is how its displayed in the UI.
  final List<String> _availableCosmetics = [
    'assets/sword.png',
    'assets/shield.png',
    'assets/staff.png',
    'assets/bow.png',
    'assets/crossbow.png',
    'assets/m1911.png',
    'assets/mac10.png',
    'assets/beer.png',
    'assets/moonshine.png',
    'assets/whiskey.png',
    'assets/wine.png',
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
