
# Roselyn Coffee Shop Executive (Flutter Game)

<img width="1435" height="564" alt="Screenshot 2025-10-18 at 17 26 52" src="https://github.com/user-attachments/assets/c1608d9b-ec1a-42e0-bfc7-fd0fdf352901" />

<img width="768" height="307" alt="Screenshot 2025-10-18 at 17 27 20" src="https://github.com/user-attachments/assets/d9eed314-1f35-49b0-887b-fcaf0c8c7ae7" />

**Sample Gameplay Diagram:**
<img width="1186" height="1564" alt="image" src="https://github.com/user-attachments/assets/17bb08c6-814b-4847-a2b2-c8fab3c50ea7" />


A **mobile gamebook** built with **Flutter** and **Dart**. You run a small coffee shop for 6 in‑game days, making decisions that affect your coins, beans inventory, customers, and ultimately whether you **win** (thriving business) or **lose** (closed shop).

> 📱 **This is a mobile app.** For correct layout, animations, and sizing, run it on an **iOS Simulator** or **Android Emulator**, or on a real phone via USB. Running on the web (Chrome) is not recommended for the intended UI.

---

## 🎮 Gameplay at a glance

- **Resources**: Coins, Beans, Customers, and Day counter (1 → 6).  
- **Daily cost**: Each “Run the day” deducts **5 coins**.
- **Win**: Reach **≥ 30 customers** by the end.  
- **Lose**: **0 coins** **and** **< 10 beans** at any time.  
- **Events** (one per day) present choices with trade‑offs, e.g.  
  - Morning rush (serve everyone vs turn away some)  
  - Supplier bulk deal (buy beans vs skip)  
  - Competitor opens (promotion vs do nothing)  
  - Machine breakdown (pay repair vs DIY)  
  - Social media buzz (free coffee vs ignore)  
  - Quiet day (serve existing vs do nothing)
- **State management**: `provider` with a `ChangeNotifier` (`GameState`)  
- **Persistence**: `shared_preferences` to save/load progress  
- **Polish**: Google Fonts (`manrope`) + simple **win/lose animations**

---

## 🧰 Tech stack

- **Flutter** (includes **Dart SDK**)  
- Packages: **provider**, **shared_preferences**, **google_fonts**  
- Material UI, animated transitions, local image assets

---

## 🖥️ Prerequisites

You’ll need **Flutter** and **Dart** installed. Flutter already bundles the Dart SDK.

1) **Install Flutter**  
   - macOS (example):  
     ```bash
     brew install --cask flutter
     flutter doctor
     ```
   - Windows/Linux: download from Flutter’s official site and add `flutter` to PATH, then run `flutter doctor`.

2) **Mobile toolchains**  
   - **iOS** (macOS only):
     - Install **Xcode** from the App Store and open it once.
     - Accept licenses: `sudo xcodebuild -license`
     - Install CocoaPods (for iOS plugins): `sudo gem install cocoapods`
     - Verify: `flutter doctor -v`
   - **Android**:
     - Install **Android Studio**, SDK, and one virtual device (AVD).
     - Accept licenses: `flutter doctor --android-licenses`

> If `flutter doctor` shows issues, follow its suggestions until all critical checks are green.

---

## 📁 Project structure (suggested)

```
.
├── lib/
│   └── main.dart                   # (your game code here)
├── assets/
│   └── images/
│       ├── coffee_outside.png
│       ├── coffee_inside.png
│       ├── coffee_win.png
│       ├── coffee_lose.png
│       ├── morning_rush.png
│       ├── supplier_deal.png
│       ├── competitor_opens.png
│       ├── equipment_breakdown.png
│       ├── social_media_buzz.png
│       └── quiet_day.png
├── pubspec.yaml
└── README.md
```

> Make sure your image file names match what the code references (see `Image.asset('images/...')`).

---

## 📦 pubspec.yaml (dependencies & assets)

Add these dependencies and assets (versions are examples; use latest stable if you prefer):

```yaml
name: roselyn_coffee_shop_executive
description: A Flutter mobile gamebook about running a coffee shop.
publish_to: "none"

environment:
  sdk: ">=3.0.0 <4.0.0"

dependencies:
  flutter:
    sdk: flutter
  provider: ^6.0.5
  shared_preferences: ^2.2.2
  google_fonts: ^6.1.0

dev_dependencies:
  flutter_test:
    sdk: flutter

flutter:
  uses-material-design: true
  assets:
    - assets/images/coffee_outside.png
    - assets/images/coffee_inside.png
    - assets/images/coffee_win.png
    - assets/images/coffee_lose.png
    - assets/images/morning_rush.png
    - assets/images/supplier_deal.png
    - assets/images/competitor_opens.png
    - assets/images/equipment_breakdown.png
    - assets/images/social_media_buzz.png
    - assets/images/quiet_day.png
```

Then install packages:

```bash
flutter pub get
```

---

## 🚀 Run on a device/emulator

### iOS (Simulator)
```bash
# Start the iOS Simulator (or open via Xcode > Open Developer Tool > Simulator)
open -a Simulator

# List devices and run
flutter devices
flutter run -d ios
```

### Android (Emulator)
```bash
# Start an AVD from Android Studio (Device Manager) or:
# emulator -avd <Your_AVD_Name>

flutter devices
flutter run -d android
```

> Tip: You can also run from **VS Code** or **Android Studio** using the built‑in Flutter run/debug buttons after selecting a target device.

---

## 🧩 Code overview

- `GameState` (`ChangeNotifier`): stores `coins`, `beans`, `customers`, `day`, plus actions (buy beans, promotions, repairs, etc.) and win/lose checks.
- **Pages**:
  - `GamePageHome` → splash/menu
  - `GamePageStart` → central hub to run each day, shop, or read rules
  - `GameEvent001…006` → daily story events
  - `Beans` → shop to buy beans
  - `Rules` → how to play
  - `GameEndScreen` → win/lose animations + final stats
- **Widgets**: `ResourcesDisplay`, `ResourcesInfoRow`, `Choice`, `StateChoice`, `WinAnimation`, `LoseAnimation`

---

## 🧪 Common pitfalls & fixes

- **"Unable to load asset"** → Check `pubspec.yaml` `assets:` paths and run `flutter pub get`. Ensure images are under `assets/images/...` and listed.
- **iOS CocoaPods errors** → `sudo gem install cocoapods && cd ios && pod install && cd ..`
- **No devices found** → Start an emulator or plug in a device and enable Developer Mode/USB debugging.
- **Layout looks odd on desktop/web** → Use **iOS/Android** targets (this UI is designed for mobile).

---

## 📦 Build releases

```bash
# Android APK (debug)
flutter build apk --debug

# Android APK (release)
flutter build apk --release

# iOS (archive for release)
flutter build ios --release
# Then finish signing/archiving in Xcode (Product > Archive)
```

---

## 📝 License & attribution

- Code: MIT (or choose your preferred license).
- Art/images: ensure you have rights to use/redistribute your assets.

---

## 🙋 Author

Built by Dawid Szczur. PRs and suggestions welcome!
