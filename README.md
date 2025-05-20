# Fitpet Adventure

Welcome to **FitPet Adventure**, a mobile app that turns your real-life steps into progress for raising your own virtual pet. Stay fit while having fun!

---

## 📌 Description

**FitPet Adventure** is a Flutter-based fitness app where your physical activity (steps) helps grow and evolve a virtual pet. The more you walk, the stronger your digital companion becomes. Track your steps, check pet progress, compete with friends, and stay motivated in your fitness journey!

---

## 🛠️ Technologies & Packages Used

### 🔧 Core Technologies

* **Flutter** (Mobile App Framework)
* **Firebase** (Authentication & Cloud Firestore)
* **Provider** (State Management)
* **Xcode 14.0+** for iOS build (iOS 18.3+ supported)

### 📦 Key Packages (with versions)

```yaml
flutter:
  sdk: flutter
firebase_core: ^3.12.1
firebase_auth: ^5.5.1
cloud_firestore: ^5.6.5
provider: ^6.1.2
fl_chart: ^0.70.2
go_router: ^14.8.1
pedometer: ^4.0.2
permission_handler: ^11.4.0
percent_indicator: ^4.2.4
intl: ^0.20.2
uuid: ^4.5.1
flutter_lints: ^5.0.0
```

For a full list of all packages used, see the `pubspec.lock` file.

---

## 🧩 System Dependencies

* Flutter SDK version `3.7.0` or higher
* Dart 3.x
* Xcode `14.0`+ with iOS `18.3` or above (for iOS builds)
* Android Studio (optional for Android development)
* Firebase Project with Authentication and Firestore enabled

---

## 🚀 Installation & Run Instructions

### 🔹 Firebase Setup

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Create a new Firebase project
3. Add your flutter app to the project (follow all steps given)
4. Enable **Firebase Authentication** (Email/Password)
5. Enable **Cloud Firestore**, use database design in final project documentation

### 🔹 Clone the Repo

```bash
git clone git@github.com:Kadiatu0/FitPet_Adventure.git
cd fitpet_adventure
```

### 🔹 Install Dependencies

```bash
flutter pub get
```

### 🔹 iOS Configuration

1. Open `ios/Runner.xcworkspace` in **Xcode**
2. Ensure `GoogleService-Info.plist` is added
3. Set deployment target to iOS 18.3 or higher

### 🔹 Run the App

```bash
flutter run
```

---

## Credits

### Cosmetics
* https://xxashuraxx.itch.io/sword
* https://snoopethduckduck.itch.io/shields
* https://snoopethduckduck.itch.io/swords
* https://free-game-assets.itch.io/free-bow-and-crossbow-pixel-art-icons
* https://tankepxs.itch.io/free-weapon-pack
* https://henrysoftware.itch.io/pixel-food
